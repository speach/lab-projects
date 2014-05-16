bedtools nuc -fi sacCer1.fa -bed ../bedgraphs/raghu.timing.bedgraph.gz |
cut -f1-5 | grep -v '^#' | gzip -c >
../R-analysis/raghu.timing.gc-content.tab.gz
