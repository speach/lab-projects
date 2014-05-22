# 10 yeast samples
SAMPLES=(6_4.rep1 Afu_BG234_predig CPD.rep1
         UDG_predig ung1_predig
         6_4.rep2  Afu_Y7092_predig  CPD.rep2
         UDG_postdig  ung1_5fu_predig)

PROJECT=$HOME/devel/lab-projects/excision-seq-ms
FASTQDIR=$PROJECT/ncbi-geo/fastq

ASSEMBLY=sacCer1
BOWTIEINDEX=$HOME/ref/genomes/$ASSEMBLY/$ASSEMBLY
CHROM_SIZES=$HOME/ref/genomes/$ASSEMBLY/$ASSEMBLY.chrom.sizes
FASTA=$HOME/ref/genomes/$ASSEMBLY/$ASSEMBLY.fa
RESULT=$PROJECT/results/$ASSEMBLY
LOG=$PROJECT/log
GDARCHIVE="$RESULT/genomedata/exseq.ms.genomedata"

# from modmap pipeline
BIN=$HOME/devel/modmap/modmap
RSCRIPTS=$HOME/devel/modmap/R

