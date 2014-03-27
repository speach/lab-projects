library(dplyr)
library(plyr)
library(ggplot2)

colnames = c('chrom','start','end','timing','exseq')
dfx <- read.table('raghu.timing.uracil.post.exseq.tab.gz', col.names=colnames)
tbl <- tbl_df(dfx)

# remove extreme outliers
tbl <- tbl %.% filter(exseq < 50 & exseq > 0 & timing < 51)

attach(tbl)

# fourth order polynomical is good fit
model <- lm(exseq ~ poly(timing, 4, raw=TRUE))

gp <- ggplot(tbl, aes(x = timing, y = exseq,
                  group = round_any(timing, 3)))

# boxplot per Trep
gp + geom_boxplot(fill='grey') +
  ggtitle('Raghu / post-dig uracil Ex-seq') + 
  xlab('Trep') + 
  ylab('Ex-seq signal') + 
  theme_bw() +
  geom_line(x = timing, 
            y = predict(model, data.frame(x=timing)), 
            col='red')


