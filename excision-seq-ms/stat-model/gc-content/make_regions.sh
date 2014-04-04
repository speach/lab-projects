#! /usr/bin/env bash

#BSUB -J make_regions
#BSUB -e log/make_regions.%J.err
#BSUB -o log/make_regions.%J.out

source $HOME/devel/lab-projects/excision-seq-ms/pipeline/config.sh

WIN_SIZE=1000
windowbed="$ASSEMBLY.windows.$WIN_SIZE.bed"
contentbed="$ASSEMBLY.windows.$WIN_SIZE.content.bed"

bedtools makewindows -g $CHROM_SIZES -n $WIN_SIZE > $windowbed
bedtools nuc -fi $FASTA -bed $windowbed > $contentbed
