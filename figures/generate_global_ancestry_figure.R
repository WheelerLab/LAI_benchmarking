###subset results

library(data.table)
library(argparse)
library(dplyr)
library(ggplot2)
library(tidyr)
"%&%" = function(a,b) paste(a,b,sep="")

parser <- ArgumentParser()
parser$add_argument("--results1", help="true ancestry output by adsim tool")
parser$add_argument("--results2", help="true ancestry output by adsim tool")
parser$add_argument("--samples1", help="list of samples to subset to")
parser$add_argument("--samples2", help="list of samples to subset to")
parser$add_argument("--bim1", help="bim file as in plink containing snps to subset to")
parser$add_argument("--bim2", help="bim file as in plink containing snps to subset to")
parser$add_argument("--plot", help="plot LA distribution", action='store_true')
# parser$add_argument("--xaxis", help="xaxis label")
parser$add_argument("--title", help="title label")
parser$add_argument("--popcode1", help="pop code as put into adsim tool")
parser$add_argument("--popcode2", help="pop code as put into adsim tool")
parser$add_argument("--out", help="file to output as")
args <- parser$parse_args()


##Process chr1

results<-fread(args$results1, header = T)

samples<-fread(args$samples1,header = F)
samples$V2<-samples
samples$V1<-paste(samples$V1,"0",sep=".")
samples$V2<-paste(samples$V2,"1",sep=".")
samples<-c(t(samples))



header<-c("chm","pos",samples)

results_sample_subsets<-results %>% select(one_of(header))


snps<-fread(args$bim1,header = F)
colnames(snps)<-c("chr","rs","cm","bp","ref","alt")
snps<- snps %>% select("chr","bp")


final_subset1<-results_sample_subsets %>% inner_join(snps,by=c("chm"="chr","pos"="bp"))

####process chr22

results<-fread(args$results2, header = T)

samples<-fread(args$samples2,header = F)
samples$V2<-samples
samples$V1<-paste(samples$V1,"0",sep=".")
samples$V2<-paste(samples$V2,"1",sep=".")
samples<-c(t(samples))



header<-c("chm","pos",samples)

results_sample_subsets<-results %>% select(one_of(header))


snps<-fread(args$bim2,header = F)
colnames(snps)<-c("chr","rs","cm","bp","ref","alt")
snps<- snps %>% select("chr","bp")


final_subset2<-results_sample_subsets %>% inner_join(snps,by=c("chm"="chr","pos"="bp"))


#fwrite(final_subset,args$out %&% "subset_results.txt",col.names = T,row.names = F,sep="\t",quote=F)
if(args$plot){
  
popcodes<-fread(args$popcode1, header = F)  

sort_index<-1
pops<-unique(popcodes$V2)
str(pops)
total<-nrow(final_subset1)
#print(colnames(final_subset))
proportions1<-as.data.frame(table(final_subset1[,3]))
proportions1$ID<-colnames(final_subset1)[3]
proportions1$percent<-proportions1$Freq/total
proportions1$perc1<-ifelse(proportions1$Var1==sort_index,proportions1$percent,0)
proportions1$perc1<-ifelse(sum(proportions1$perc1)!=0, sum(proportions1$perc1), (1-sum(proportions1$percent)))
proportions1$nswitches<-(length(rle(final_subset1[,3])$lengths) - 1) 

for (i in c(2:(ncol(final_subset1)-2))){
  i<-i+2
  indiv<-as.data.frame(table(final_subset1[,i]))
  indiv$ID<-colnames(final_subset1)[i]
  indiv$percent<-indiv$Freq/total
  indiv$perc1<-ifelse(indiv$Var1==sort_index,indiv$percent,0)
  indiv$perc1<-ifelse(sum(indiv$perc1)!=0, sum(indiv$perc1), (1-sum(indiv$percent)))
  indiv$nswitches<-(length(rle(final_subset1[,i])$lengths) - 1) 
  proportions1<-rbind.data.frame(proportions1,indiv)
}

proportions1$Var1<-as.numeric(proportions1$Var1)
# str(proportions)
for (i in c(1:length(pops))){
  proportions1$Var1[proportions1$Var1==i]<-pops[i]
  # str(proportions)
}
# ?reorder
anc_haploid1<-proportions1 %>% mutate(diploidID=gsub("\\.[0-9]+","",ID)) %>% mutate(diploid_anc_ID = paste(diploidID,Var1)) %>% select(diploid_anc_ID,percent,perc1)
# str(anc_haploid)
anc_diploid1<-aggregate(anc_haploid1, by = list(anc_haploid1$diploid_anc_ID), FUN = function(x) mean(as.numeric(as.character(x)))) %>% separate(Group.1,into=c("ID","anc"),sep=" ")
# colnames(anc_diploid)<-c("ID","anc","percent","perc1")
 # levels<-anc_diploid[order(anc_diploid$anc,anc_diploid$percent),]

#process chr22

popcodes<-fread(args$popcode2, header = F)  

sort_index<-1
pops<-unique(popcodes$V2)
str(pops)
total<-nrow(final_subset2)
#print(colnames(final_subset))
proportions2<-as.data.frame(table(final_subset2[,3]))
proportions2$ID<-colnames(final_subset2)[3]
proportions2$percent<-proportions2$Freq/total
proportions2$perc1<-ifelse(proportions2$Var1==sort_index,proportions2$percent,0)
proportions2$perc1<-ifelse(sum(proportions2$perc1)!=0, sum(proportions2$perc1), (1-sum(proportions2$percent)))
proportions2$nswitches<-(length(rle(final_subset2[,3])$lengths) - 1) 

for (i in c(2:(ncol(final_subset2)-2))){
  i<-i+2
  indiv<-as.data.frame(table(final_subset2[,i]))
  indiv$ID<-colnames(final_subset2)[i]
  indiv$percent<-indiv$Freq/total
  indiv$perc1<-ifelse(indiv$Var1==sort_index,indiv$percent,0)
  indiv$perc1<-ifelse(sum(indiv$perc1)!=0, sum(indiv$perc1), (1-sum(indiv$percent)))
  indiv$nswitches<-(length(rle(final_subset2[,i])$lengths) - 1) 
  proportions2<-rbind.data.frame(proportions2,indiv)
}

proportions2$Var1<-as.numeric(proportions2$Var1)
# str(proportions)
for (i in c(1:length(pops))){
  proportions2$Var1[proportions2$Var1==i]<-pops[i]
  # str(proportions)
}
# ?reorder
anc_haploid2<-proportions2 %>% mutate(diploidID=gsub("\\.[0-9]+","",ID)) %>% mutate(diploid_anc_ID = paste(diploidID,Var1)) %>% select(diploid_anc_ID,percent,perc1)
# str(anc_haploid)
anc_diploid2<-aggregate(anc_haploid2, by = list(anc_haploid2$diploid_anc_ID), FUN = function(x) mean(as.numeric(as.character(x)))) %>% separate(Group.1,into=c("ID","anc"),sep=" ")

anc_diploid<-rbind.data.frame(anc_diploid1,anc_diploid2)


str(anc_diploid)
gP<-ggplot(anc_diploid, aes(x=ID,y=percent,fill=anc))
gP + geom_bar(position="fill",stat="identity", aes(x=reorder(ID,-perc1))) +
  scale_y_continuous(labels = scales::percent_format()) + 
  ggtitle(args$title %&% " haplotype ancestry distribution") +  theme(axis.text.x = element_blank()) + ggsave(args$out %&% ".pdf")
fwrite(anc_diploid,args$out %&% "_percentages.txt",col.names=T)
}
# warnings()