#! /usr/bin/env bash

#BSUB -J segtools.master
#BSUB -o log/segtools.master.%J.out
#BSUB -e log/segtools.master.%J.err

set -o nounset -o pipefail -o errexit -x

NUM_LABELS=8
RESOLUTION=500
PROJECT="$HOME/devel/lab-projects/excision-seq-ms"
GDARCHIVE="$PROJECT/genomedata/sacCer1/exseq.ms.genomedata"
RESULTS="$PROJECT/stat-model/segway/labels-$NUM_LABELS-resolution-$RESOLUTION"
IDENTIFYDIRNAME="$RESULTS/identify"
SEGMENTATION="$IDENTIFYDIRNAME/segway.bed.gz"

<<DOC
segtools-aggregation
segtools-flatten
segtools-length-distribution
segtools-transition            
segtools-gmtk-parameters
segtools-nucleotide-frequency
segtools-feature-distance
segtools-html-report
segtools-overlap
DOC

segtools-signal-distribution $SEGMENTATION $GDARCHIVE
