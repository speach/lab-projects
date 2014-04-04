#! /usr/bin/env bash

#BSUB -J align[1-10]
#BSUB -o log/align.%J.out
#BSUB -e log/align.%J.err
#BSUB -n 8

set -o nounset -o pipefail -o errexit -x

source config.sh

NUM_THREADS=8

sample=${SAMPLES[$(($LSB_JOBINDEX - 1))]}
fastq="$FASTQDIR/$sample.fastq.gz"

alnresults=$RESULT/$sample/alignments
bgresults=$RESULT/$sample/bedgraphs

if [[ ! -d $alnresults ]]; then
    mkdir -p $alnresults
fi
if [[ ! -d $bgresults ]]; then
    mkdir -p $bgresults
fi

bam=$alnresults/$sample.bam

stats=$alnresults/$sample.stats.txt

# no trimming needed, 5' ``T`` is accounted for by sequencing primer
if [[ ! -f $bam ]]; then
    bowtie2 -U $fastq -x $BOWTIEINDEX \
        --threads $NUM_THREADS \
        2> $stats \
        | samtools view -ShuF4 - \
        | samtools sort -o - $sample.temp -m 8G \
        > $bam
    samtools index $bam
fi

strands=("both" "pos" "neg")
strandargs=("" "-strand +" "-strand -")

for sidx in ${!strands[@]}; do
    strand=${strands[$sidx]}
    strandarg=${strandargs[$sidx]}

    bedgraph=$bgresults/$sample.strand.$strand.counts.bg

    bedtools genomecov -5 -bg \
        -g $CHROM_SIZES -ibam $bam \
        $strandarg \
        > $bedgraph
done

