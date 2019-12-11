###subset results

library(data.table)
library(argparse)
library(dplyr)
library(ggplot2)
library(tidyr)
"%&%" = function(a,b) paste(a,b,sep="")

parser <- ArgumentParser()
parser$add_argument("--results", help="true ancestry output by adsim tool")
parser$add_argument("--samples", help="list of samples to subset to")
parser$add_argument("--bim", help="bim file as in plink containing snps to subset to")
parser$add_argument("--plot", help="plot LA distribution", action='store_true')
parser$add_argument("--popcode", help="pop code as put into adsim tool")
parser$add_argument("--out", help="file to output as")
args <- parser$parse_args()


results<-fread(args$results, header = T)

samples<-fread(args$samples,header = F)
samples$V2<-samples
samples$V1<-paste(samples$V1,"0",sep=".")
samples$V2<-paste(samples$V2,"1",sep=".")
samples<-c(t(samples))



header<-c("chm","pos",samples)

results_sample_subsets<-results %>% select(one_of(header))


snps<-fread(args$bim,header = F)
colnames(snps)<-c("chr","rs","cm","bp","ref","alt")
snps<- snps %>% select("chr","bp")


final_subset<-results_sample_subsets %>% inner_join(snps,by=c("chm"="chr","pos"="bp"))

fwrite(final_subset,args$out %&% "subset_results.txt",col.names = T,row.names = F,sep="\t",quote=F)
if(args$plot){
  
popcodes<-fread(args$popcode, header = F)  

sort_index<-1
pops<-unique(popcodes$V2)
str(pops)
total<-nrow(final_subset)
#print(colnames(final_subset))
proportions<-as.data.frame(table(final_subset[,3]))
proportions$ID<-colnames(final_subset)[3]
proportions$percent<-proportions$Freq/total
proportions$perc1<-ifelse(proportions$Var1==sort_index,proportions$percent,0)
proportions$perc1<-ifelse(sum(proportions$perc1)!=0, sum(proportions$perc1), (1-sum(proportions$percent)))
proportions$nswitches<-(length(rle(final_subset[,3])$lengths) - 1) 

for (i in c(2:(ncol(final_subset)-2))){
  i<-i+2
  indiv<-as.data.frame(table(final_subset[,i]))
  indiv$ID<-colnames(final_subset)[i]
  indiv$percent<-indiv$Freq/total
  indiv$perc1<-ifelse(indiv$Var1==sort_index,indiv$percent,0)
  indiv$perc1<-ifelse(sum(indiv$perc1)!=0, sum(indiv$perc1), (1-sum(indiv$percent)))
  indiv$nswitches<-(length(rle(final_subset[,i])$lengths) - 1) 
  proportions<-rbind.data.frame(proportions,indiv)
}

proportions$Var1<-as.numeric(proportions$Var1)
# str(proportions)
for (i in c(1:length(pops))){
  proportions$Var1[proportions$Var1==i]<-pops[i]
  # str(proportions)
}
# ?reorder
anc_haploid<-proportions %>% mutate(diploidID=gsub("\\.[0-9]+","",ID)) %>% mutate(diploid_anc_ID = paste(diploidID,Var1)) %>% select(diploid_anc_ID,percent,perc1)
str(anc_haploid)
anc_diploid<-aggregate(anc_haploid, by = list(anc_haploid$diploid_anc_ID), FUN = mean) %>% separate(Group.1,into=c("ID","anc"),sep=" ")
#colnames(anc_diploid)<-c("ID","anc","percent","perc1")
levels<-anc_diploid[order(anc_diploid$anc,anc_diploid$percent),]
str(anc_diploid)
 gP<-ggplot(anc_diploid, aes(x=reorderID,y=percent,fill=anc))
 png(args$out %&% ".png")
 gP + geom_bar(position="fill",stat="identity",aes(x=reorder(ID,-perc1))) +
   scale_y_continuous(labels = scales::percent_format()) +
   ggtitle(args$title %&% " haplotype final subset distribution")
}