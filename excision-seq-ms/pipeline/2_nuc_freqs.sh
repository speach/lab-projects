#! /usr/bin/env bash

#BSUB -J nuc.counts[1-10]
#BSUB -o log/nuc.freqs.%J.%I.out
#BSUB -e log/nuc.freqs.%J.%I.err

set -o nounset -o pipefail -o errexit -x

source config.sh

sample=${SAMPLES[$(($LSB_JOBINDEX - 1))]}

if [[ $ASSEMBLY == "sacCer2" ]]; then
    include_modes=("all" "only-mito" "no-mito" "only-2micron")
    include_args=("" "--only-chrom chrM"
                 "--ignore-chrom chrM"
                 "--only-chrom 2micron")
else
    include_modes=("all" "only-mito" "no-mito")
    include_args=("" "--only-chrom chrM"
                 "--ignore-chrom chrM")
fi

# mono, di and trinucleotides
sizes="1 2 3"

# count thresholds
count_thresh="1 10 30"

bedgraphs=$RESULT/$sample/bedgraphs
results=$RESULT/$sample/nuc_freqs

if [[ ! -d $results ]]; then
    mkdir -p $results
fi

posbedgraph="$bedgraphs/$sample.strand.pos.counts.bg.gz"
negbedgraph="$bedgraphs/$sample.strand.neg.counts.bg.gz"

for inc_idx in ${!include_modes[@]}; do

    include_mode=${include_modes[$inc_idx]}
    include_arg=${include_args[$inc_idx]}

    for mincount in $count_thresh; do

        output="$results/$sample.include.$include_mode.mincount.$mincount.nuc_freqs.tab"

        if [[ ! -f "$output.gz" ]]; then
            for size in $sizes; do

                cmd="python $BIN/nuc_frequencies.py \
                    --region-size $size \
                    --minimum-counts $mincount \
                    -p $posbedgraph \
                    -n $negbedgraph \
                    -f $FASTA \
                    $include_arg \
                    --verbose >> $output"

                jobid="nf_calc.$LSB_JOBID.$LSB_JOBINDEX"
                bsub -J $jobid \
                     -o "log/nf_calc.$LSB_JOBID.$LSB_JOBINDEX.out" \
                     -e "log/nf_calc.$LSB_JOBID.$LSB_JOBINDEX.err" \
                     $cmd
            done
            # gzip file
            bsub -o /dev/null -e /dev/null \
                -J "gzip.$jobid" -w "done($jobid)" "gzip $output"
        fi
    done
done

