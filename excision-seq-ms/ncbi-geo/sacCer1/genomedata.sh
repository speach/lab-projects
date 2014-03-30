#! /usr/bin/env bash

#BSUB -J gd.create
#BSUB -e log/gd.create.%J.err
#BSUB -o log/gd.create.%J.out

set -e

GDARCHIVE="exseq.ms.genomedata"
FASTA="$HOME/ref/genomes/sacCer1/sacCer1.fa"

genomedata-load \
    -t cpd.rep1="bedgraphs/CPD.rep1.bg.gz" \
    -t cpd.rep2="bedgraphs/CPD.rep2.bg.gz" \
    -t 64.rep1="bedgraphs/6_4.rep1.bg.gz" \
    -t 64.rep1="bedgraphs/6_4.rep2.bg.gz" \
    -t udg.afu.bg234.predig="bedgraphs/Afu_BG234_predig.bg.gz" \
    -t udg.afu.y7092.predig="bedgraphs/Afu_Y7092_predig.bg.gz" \
    -t udg.postdig="bedgraphs/UDG_postdig.bg.gz" \
    -t udg.predig="bedgraphs/UDG_predig.bg.gz" \
    -t udg.ung1.5fu.postdig="bedgraphs/ung1_5fu_predig.bg.gz" \
    -t udg.ung1.postdig="bedgraphs/ung1_predig.bg.gz" \
    -s $FASTA \
    $GDARCHIVE \
    --verbose
