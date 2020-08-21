library(dplyr)
library(data.table)
library(multcompView)
library(ggplot2)
library(viridis)

bench<-fread("Z:/data/Local_ancestry_project/revisions/time_mem_benchmarks.txt")

#colnames(bench)<-c("pop" ,    "software"  ,     "time"  ,  "mem"  ,   "nanc" , "chr")
bench<-bench %>%   mutate(mem=mem/1000)
##time
ggroups<-ggplot(data = bench)
pdf("Z:/data/Local_ancestry_project/revisions/time_chr22_new_sims.pdf")
ggroups + geom_point(aes(x=as.factor(nanc), y =time, colour =as.factor(nanc))) + 
  facet_wrap(~software) +
  theme_bw(15) +
  labs(colour= "Number of \nAncestral \nPopulations") +
  xlab("Number of Ancestral Populations") +
  ylab("Runtime (s)")
dev.off()

for (i in c("RFMix","ELAI","LAMPLD","MOSAIC","Loter")){
  sub<-bench[bench$software == i,]
  model<-lm(time ~ nanc,data=sub)
  cat(i,"\n")
  print(summary(aov(model)))
}

pdf("Z:/data/Local_ancestry_project/revisions/memory_chr22_new_sims.pdf")
ggroups + geom_point(aes(x=as.factor(nanc), y =mem, colour =as.factor(nanc))) + 
  facet_wrap(~software) +
  theme_bw(15) +
 labs(colour = "Number of \nAncestral \nPopulations" ) +
  xlab("Number of Ancestral Populations") +
  ylab("Maximum Memory Usage (Mb)") 
dev.off()

for (i in c("RFMix","ELAI","LAMPLD","MOSAIC","Loter")){
  sub<-bench[bench$software == i,]
  model<-lm(mem ~ nanc,data=sub)
  cat(i,"\n")
  print(summary(aov(model)))
}
