#! /usr/bin/env bash

#BSUB -J norm_gc[1-10]
#BSUB -o log/norm_gc.%J.%I.out
#BSUB -e log/norm_gc.%J.%I.err

# make normalized tracks to account for possible GC content bias

set -o nounset -o pipefail -o errexit -x
source $HOME/devel/lab-projects/excision-seq-ms/pipeline/config.sh

sample=${SAMPLES[$(($LSB_JOBINDEX - 1))]}
bedgraphdir=$RESULT/$sample/bedgraphs

# strategy:
# 1. make windows across genome
# 2. calculate GC content in each window (report bedgraph)
# 3. calculate mean Ex-seq signal in windows
# 4. normalized mean signal by GC content (signal * content)
# 5. report bedgraph

outdir="$bedgraphdir/gc_norm"
if [[ ! -d $outdir ]]; then
    mkdir -p $outdir
fi

window_sizes=(5 50 500 5000)
strands=("both" "pos" "neg")

for winsize in ${window_sizes[@]}; do
    for strand in ${strands[@]}; do

        bedgraph=$bedgraphdir/$sample.strand.$strand.counts.bg.gz
        normbg="$outdir/$sample.win.$winsize.gcnorm.bg"

        bedtools makewindows -g $CHROM_SIZES -w $winsize \
            | bedtools nuc -fi $FASTA -bed - \
            | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$5}' \
            | bedtools map -a - -b $bedgraph -c 4 -o mean -null 0 \
            | awk '$5 > 0' \
            | awk 'BEGIN {OFS="\t"} {print $1,$2,$3, $5*$4}' \
            > $normbg
    done
done

