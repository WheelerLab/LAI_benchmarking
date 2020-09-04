library(dplyr)
library(data.table)
library(multcompView)
library(ggplot2)
library(viridis)
library(egg)

tag_facet2 <- function(p, open = "", close = "", tag_pool = LETTERS, x = -Inf, y = Inf, ## from stackoverflow https://stackoverflow.com/questions/56064042/using-facet-tags-and-strip-labels-together-in-ggplot2 based on egg tag_facet
                       hjust = -0.5, vjust = 1.5, fontface = 2, family = "", ...) {
  
  gb <- ggplot_build(p)
  lay <- gb$layout$layout
  tags <- cbind(lay, label = paste0(open, tag_pool[lay$PANEL], close), x = x, y = y)
  p + geom_text(data = tags, aes_string(x = "x", y = "y", label = "label"), ..., hjust = hjust, 
                vjust = vjust, fontface = fontface, family = family, inherit.aes = FALSE)
}

bench<-fread("Z:/data/Local_ancestry_project/revisions/time_mem_benchmarks.txt")

#colnames(bench)<-c("pop" ,    "software"  ,     "time"  ,  "mem"  ,   "nanc" , "chr")
bench<-bench %>%   mutate(mem=mem/1000)
##time
ggroups<-ggplot(data = bench)
pdf("Z:/data/Local_ancestry_project/revisions/time_chr22_new_sims.pdf")
f1<-ggroups + geom_point(aes(x=as.factor(nanc), y =time, colour =as.factor(nanc))) + 
  facet_wrap(~software) +
  theme_bw(15) +
  labs(colour= "Number of \nAncestral \nPopulations") +
  xlab("Number of Ancestral Populations") +
  ylab("Runtime (s)") +
  theme(legend.position = "none")
tag_facet2(f1)
dev.off()

for (i in c("RFMix","ELAI","LAMPLD","MOSAIC","Loter")){
  sub<-bench[bench$software == i,]
  model<-lm(time ~ nanc,data=sub)
  cat(i,"\n")
  print(summary(aov(model)))
}

pdf("Z:/data/Local_ancestry_project/revisions/memory_chr22_new_sims.pdf")
f2<-ggroups + geom_point(aes(x=as.factor(nanc), y =mem, colour =as.factor(nanc))) + 
  facet_wrap(~software) +
  theme_bw(15) +
 labs(colour = "Number of \nAncestral \nPopulations" ) +
  xlab("Number of Ancestral Populations") +
  ylab("Maximum Memory Usage (MB)") +
  theme(legend.position = "none")
tag_facet2(f2)
dev.off()

for (i in c("RFMix","ELAI","LAMPLD","MOSAIC","Loter")){
  sub<-bench[bench$software == i,]
  model<-lm(mem ~ nanc,data=sub)
  cat(i,"\n")
  print(summary(aov(model)))
}
