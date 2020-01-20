runtimes<-fread("Z:/data/time_bench",header = T)
melted<-melt(runtimes, id = c("pop","cohort","nsnps"))
melted$nancestors<-ifelse((melted$pop == "EVEN" | melted$pop == "BRYC"),3,2)

ggroups<-ggplot(data = melted)
pdf("Z:/data/Local_ancestry_project/Runtime vs Ancestry.pdf")
ggroups + geom_violin(aes(x=as.factor(nancestors), y =value, fill = as.factor(nancestors))) + 
  facet_wrap(~variable) +
  theme_bw(15) +
  scale_fill_viridis(discrete=T, name = "Number of \nAncestral \nPopulations") +
  xlab("Number of Ancestral Populations") +
  ylab("Runtime (s)") +
  geom_boxplot(aes(x=as.factor(nancestors), y =value),width = 0.3) +
  ggtitle("Runtime per software between \ntwo and three way ancestries")
dev.off()

maxmem<-fread("Z:/data/mem_bench",header = T)

melted<-melt(maxmem, id = c("pop","cohort","nsnps"))
melted$nancestors<-ifelse((melted$pop == "EVEN" | melted$pop == "BRYC"),3,2)
melted$value<-(melted$value/1000)
ggroups<-ggplot(data = melted)
pdf("Z:/data/Local_ancestry_project/Memory vs Ancestry.pdf")
ggroups + geom_violin(aes(x=as.factor(nancestors), y =value, fill = as.factor(nancestors))) + 
  facet_wrap(~variable) +
  theme_bw(15) +
  scale_fill_viridis(discrete=T, name = "Number of \nAncestral \nPopulations") +
  xlab("Number of Ancestral Populations") +
  ylab("Maximum Memory Usage (Mb)") +
  geom_boxplot(aes(x=as.factor(nancestors), y =value),width = 0.3) +
  ggtitle("Memory Usage per software between \ntwo and three way ancestries")
dev.off()



threeway<-filter(melted,nancestors==3)
twoway<-filter(melted,nancestors==2)

loter2<-filter(twoway, variable == "Loter")
loter3<-filter(threeway, variable == "Loter")
rf2<-filter(twoway, variable == "RFMIX")
rf3<-filter(threeway, variable == "RFMIX")
mos2<-filter(twoway, variable == "MOSAIC")
mos3<-filter(threeway, variable == "MOSAIC")
lamp2<-filter(twoway, variable == "LAMPLD")
lamp3<-filter(threeway, variable == "LAMPLD")
elai2<-filter(twoway, variable == "ELAI")
elai3<-filter(threeway, variable == "ELAI")

mean(loter2$value)
sd(loter2$value)
mean(loter3$value)
sd(loter3$value)

mean(rf2$value)
sd(rf2$value)
mean(rf3$value)
sd(rf3$value)

mean(mos2$value)
sd(mos2$value)
mean(mos3$value)
sd(mos3$value)

mean(lamp2$value)
sd(lamp2$value)
mean(lamp3$value)
sd(lamp3$value)

mean(elai2$value)
sd(elai2$value)
mean(elai3$value)
sd(elai3$value)

mean(twoway$value)
sd(twoway$value)

mean(threeway$value)
sd(threeway$value)
