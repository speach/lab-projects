#! /usr/bin/env bash

#BSUB -J segway.master
#BSUB -o log/segway.master.%J.out
#BSUB -e log/segway.master.%J.err

set -o nounset -o pipefail -o errexit -x

PROJECT="$HOME/devel/lab-projects/excision-seq-ms"
GDARCHIVE="$PROJECT/genomedata/sacCer1/exseq.ms.genomedata"

<<TRACKNAMES
cpd.rep1
cpd.rep2
64.rep1
udg.afu.bg234.predig
udg.afu.y7092.predig
udg.postdig
udg.predig
udg.ung1.5fu.postdig
udg.ung1.postdig
rep.timing.yabuki
rep.timing.raghu
TRACKNAMES

NUM_LABELS=8
TRACKSPEC="-t udg.postdig -t udg.predig -t rep.timing.raghu
-t udg.ung1.5fu.postdig"
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

RESULTS="$PROJECT/stat-model/segway/labels-$NUM_LABELS-resolution-$RESOLUTION"
if [[ ! -d $RESULTS ]]; then
    mkdir -p $RESULTS
fi

TRAINDIRNAME="$RESULTS/train"
IDENTIFYDIRNAME="$RESULTS/identify"

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
