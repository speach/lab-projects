#! /usr/bin/env bash

#BSUB -J nuc.counts[1-10]
#BSUB -o log/nuc.freqs.%J.%I.out
#BSUB -e log/nuc.freqs.%J.%I.err

set -o nounset -o pipefail -o errexit -x

source config.sh

sample=${SAMPLES[$(($LSB_JOBINDEX - 1))]}

if [[ $ASSEMBLY == "sacCer2" ]]; then
    ignore_modes=("all" "only-mito" "no-mito" "only-2micron")
    ignore_args=("" "--only-chrom chrM"
                 "--ignore-chrom chrM"
                 "--only-chrom 2micron")
else
    ignore_modes=("all" "only-mito" "no-mito")
    ignore_args=("" "--only-chrom chrM"
                 "--ignore-chrom chrM")
fi

# mono, di and trinucleotides
sizes="1 2 3"

bedgraphs=$RESULT/$sample/bedgraphs
results=$RESULT/$sample/nuc_freqs

if [[ ! -d $results ]]; then
    mkdir -p $results
fi

posbedgraph=$bedgraphs/$sample.strand.pos.counts.bg
negbedgraph=$bedgraphs/$sample.strand.neg.counts.bg

for ig_idx in ${!ignore_modes[@]}; do

    ignore_mode=${ignore_modes[$ig_idx]}
    ignore_arg=${ignore_args[$ig_idx]}

    output="$results/$sample.ignore.$ignore_mode.nuc_freqs.tab"

    if [[ ! -f "$output.gz" ]]; then
        for size in $sizes; do

            cmd="python $BIN/nuc_frequencies.py \
                --region-size $size \
                -p $posbedgraph \
                -n $negbedgraph \
                -f $FASTA \
                $ignore_arg \
                --verbose >> $output"

            jobid="nf_calc.$LSB_JOBID.$LSB_JOBINDEX"
            bsub -J $jobid \
                 -o "log/nf_calc.$LSB_JOBID.$LSB_JOBINDEX.out" \
                 -e "log/nf_calc.$LSB_JOBID.$LSB_JOBINDEX.err" \
                 $cmd
        done
        bsub -J "gzip.$jobid" -w "done($jobid)" "gzip $output"
    fi
done

