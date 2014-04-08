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
    ignore_modes=("all" "only-mito" "no-mito" "only-2micron")
    ignore_args=("" "--only-chrom chrM"
                 "--ignore-chrom chrM"
                 "--only-chrom 2micron")
else
    ignore_modes=("all" "only-mito" "no-mito")
    ignore_args=("" "--only-chrom chrM"
                 "--ignore-chrom chrM")
fi

for ig_idx in ${!ignore_modes[@]}; do

    ignore_mode=${ignore_modes[$ig_idx]}

    # -------------------------------------------------------
    # --- nuc_freq plots ------------------------------------
    plottypes=("hist" "scatter")
    for plot_type in ${plottypes[@]}; do

        subplotdir="$plotdir/nuc_freqs/$plot_type"
        if [[ ! -d $subplotdir ]]; then
            mkdir -p $subplotdir
        fi

        counts="$results/nuc_freqs/$sample.ignore.$ignore_mode.nuc_freqs.tab.gz"
        sampleid="$sample.subset-$ignore_mode"
        Rscript --vanilla $RSCRIPTS/nuc.freqs.R $counts "$sampleid" $plot_type $subplotdir

    done
done

# convert all PDFs to PNGs
for pdffile in $(find $plotdir -name '*.pdf' -print); do
    pngdirname=$(dirname $pdffile)
    pngfilename="$(basename $pdffile .pdf).png"
    pngfilepath="$pngdirname/$pngfilename"
    convert $pdffile $pngfilepath
done

