#! /usr/bin/env bash

#BSUB -J plots[1-10]
#BSUB -e log/plots.%J.%I.err
#BSUB -o log/plots.%J.%I.out
#BSUB -q normal

<<DOC
DOC

set -o nounset -o pipefail -o errexit -x

source config.sh

sample=${SAMPLES[$(($LSB_JOBINDEX - 1))]}
results=$RESULT/$sample

plotdir=$results/plots
if [[ $ASSEMBLY == "sacCer2" ]]; then
    include_modes=("all" "only-mito" "no-mito" "only-2micron")
    include_args=("" "--only-chrom chrM"
                 "--include-chrom chrM"
                 "--only-chrom 2micron")
else
    include_modes=("all" "only-mito" "no-mito")
    include_args=("" "--only-chrom chrM"
                 "--include-chrom chrM")
fi

# count thresholds
count_thresh="1 10 30"

for inc_idx in ${!include_modes[@]}; do

    include_mode=${include_modes[$inc_idx]}

    # -------------------------------------------------------
    # --- nuc_freq plots ------------------------------------
    for mincount in $count_thresh; do
        output="$results/$sample.include.$include_mode.mincount.$mincount.nuc_freqs.tab"

        plottypes=("hist" "scatter")
        for plot_type in ${plottypes[@]}; do

            subplotdir="$plotdir/nuc_freqs/$plot_type"
            if [[ ! -d $subplotdir ]]; then
                mkdir -p $subplotdir
            fi

            counts="$results/$sample.include.$include_mode.mincount.$mincount.nuc_freqs.tab"
            sampleid="$sample.subset-$ignore_mode"
            Rscript --vanilla $RSCRIPTS/nuc.freqs.R $counts "$sampleid" $plot_type $subplotdir
        done
    done
done

# convert all PDFs to PNGs
for pdffile in $(find $plotdir -name '*.pdf' -print); do
    pngdirname=$(dirname $pdffile)
    pngfilename="$(basename $pdffile .pdf).png"
    pngfilepath="$pngdirname/$pngfilename"
    convert $pdffile $pngfilepath
done

