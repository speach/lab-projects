#! /usr/bin/env bash

# make normalized tracks to account for possible GC content bias

source $HOME/devel/lab-projects/excision-seq-ms/pipline/config.sh

window_sizes=(5 50 500)
signalbg=XXX

# strategy:
# 1. make windows across genome
# 2. calculate GC content in each window (report bedgraph)
# 3. calculate mean Ex-seq signal in windows
# 4. normalized mean signal by GC content (signal * content)
# 5. report bedgraph

for winsize in ${window_sizes[@]}; do

    normbg="$sample.win.$winsize.gcnorm.bg"

    bedtools makewindows -g $CHROM_SIZES -w $winsize \
        | bedtools nuc -fi $FASTA -bed - \
        | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$5}' \
        | bedtools map -a - -b $signalbg -c 4 -o mean -null 0 \
        | awk '$5 > 0' \
        | awk 'BEGIN {OFS="\t"} {print $1,$2,$3, $5*$4}' \
        > $normbg
done
