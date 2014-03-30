#! /usr/bin/env bash

#BSUB -J segway.master
#BSUB -o log/segway.master.%J.out
#BSUB -e log/segway.master.%J.err

PROJECT="$HOME/devel/lab-projects/exicion-seq-ms"
GDARCHIVE="$PROJECT/genomedata/sacCer1/exseq.ms.genomedata"

NUM_LABELS=8
TRACKSPEC="-t yabuki.timing -t udg -t sheared"
COMMONSPEC="--num-labels=$NUM_LABELS $TRACKSPEC"

INCLUDEFILENAME="includes/include.bed"
EXCLUDEFILENAME="includes/exclude.bed"
REGIONSPEC="--include-coords=$INCLUDEFILENAME
--exclude-coords=$EXCLUDEFILENAME"

SEGTABLEFILENAME="includes/seg_table.tab"
RESOLUTION=500
RULER_SCALE=2000
VARSPEC="--resolution=$RESOLUTION --ruler-scale=$RULER_SCALE
--seg-table=$SEGTABLEFILENAME"

PRIOR_STRENGTH=1000

TRAINDIRNAME="$RESULTS/train"
IDENTIFYDIRNAME="$RESULTS/identify"
RESULTS="$PROJECT/stat-model/segway/labels-$NUM_LABELS-resolution-$RESOLUTION"

segway train $GDARCHIVE $TRAINDIRNAME \
    $COMMONSPEC $REGIONSPEC \
    $VARSPEC \
    --prior-strength=$PRIOR_STRENGTH \
    --split-sequences=250000

segway identify $GDARCHIVE $TRAINDIRNAME $IDENTIFYDIRNAME \
    $COMMONSPEC $REGIONSPEC \
    $VARSPEC \
   -i "$TRAINDIRNAME/params/input.master" \
   -p "$TRAINDIRNAME/params/params.params" \
   -s "$TRAINDIRNAME/segway.str"

segway-layer "$IDENTIFYDIRNAME/segway.bed.gz" "$IDENTIFYDIRNAME/segway.layered.bed.gz"
