### LA bar plot

library(data.table)
library(argparse)
library(dplyr)
library(ggplot2)
library(viridis)
"%&%" = function(a,b) paste(a,b,sep="")

parser <- ArgumentParser()
parser$add_argument("--result", help="results file output by adsim", nargs='+')
parser$add_argument("--poslist", help="subset of positions to take samples from")
parser$add_argument("--samples", help="sample file input to adsim")
parser$add_argument("--out", help="png file")
parser$add_argument("--title", help="plot title")
parser$add_argument("--ancestry_threshold", help="percentage of ancestry to filter individuals", type = "integer")
parser$add_argument("--ancestry",help="which ancestry to filter individuals")
parser$add_argument("--ancestry_range",help="threshold plus minus range is used for filtering", type = "integer")
args <- parser$parse_args()

ancestry<-as.data.frame(fread(args$result[1],header = T))
# str(ancestry)
if (length(args$result) > 1) {
  for (i in c(2:length(args$result))){
    tmp<-fread(args$result[i], header = T)
    ancestry<-inner_join(ancestry,tmp,by=c("chm","pos"))
  }
}

if (!is.null(args$poslist)){
  pos<-fread(args$poslist, header = F)
  print(dim(ancestry))
  ancestry<-inner_join(ancestry,pos,by=c("pos"="V1"))

}
print(dim(ancestry))
samples<-fread(args$samples, header = F)
if(grepl("ACB",args$samples)){
  samples<-filter(samples,V2!="NAT")
}
print(samples$V2)
if(grepl("EVEN",args$title) | grepl("BRYC",args$title)){
  sort_index=3
} else{
  sort_index=1
}
print(sort_index)
pops<-unique(samples$V2)
str(pops)
#str(ancestry)
total<-nrow(ancestry)
#print(colnames(ancestry))
proportions<-as.data.frame(table(ancestry[,3]))
proportions$ID<-colnames(ancestry)[3]
proportions$percent<-proportions$Freq/total
proportions$perc1<-ifelse(proportions$Var1==sort_index,proportions$percent,0)
proportions$perc1<-ifelse(sum(proportions$perc1)!=0, sum(proportions$perc1), (1-sum(proportions$percent)))
proportions$nswitches<-(length(rle(ancestry[,3])$lengths) - 1) 

for (i in c(2:(ncol(ancestry)-2))){
  i<-i+2
  indiv<-as.data.frame(table(ancestry[,i]))
  indiv$ID<-colnames(ancestry)[i]
  indiv$percent<-indiv$Freq/total
  indiv$perc1<-ifelse(indiv$Var1==sort_index,indiv$percent,0)
  indiv$perc1<-ifelse(sum(indiv$perc1)!=0, sum(indiv$perc1), (1-sum(indiv$percent)))
  indiv$nswitches<-(length(rle(ancestry[,i])$lengths) - 1) 
  proportions<-rbind.data.frame(proportions,indiv)
}

proportions$Var1<-as.numeric(proportions$Var1)
str(proportions)
for (i in c(1:length(pops))){
proportions$Var1[proportions$Var1==i]<-pops[i]
str(proportions)
}
str(proportions)
str(pops)
gP<-ggplot(proportions, aes(x=ID,y=Freq,fill=Var1))
png(args$out %&% ".png")
gP + geom_bar(position="fill",stat="identity", aes(x=reorder(ID,-perc1))) +
  scale_y_continuous(labels = scales::percent_format()) +
  ggtitle(args$title %&% " haplotype ancestry distribution")
  # scale_color_viridis(discrete=TRUE, option="C") +
  # scale_fill_viridis(discrete=TRUE, option="C")
dev.off()
# setEPS()
pdf(args$out %&% ".pdf")
gP + geom_bar(position="fill",stat="identity", aes(x=reorder(ID,-perc1))) +
  scale_y_continuous(labels = scales::percent_format()) +
  ggtitle(args$title %&% " haplotype ancestry distribution")
# scale_color_viridis(discrete=TRUE, option="C") +
# scale_fill_viridis(discrete=TRUE, option="C")
dev.off()
fwrite(proportions, args$out %&% ".txt")

if(!is.null(args$ancestry)){
  lb<-(args$ancestry_threshold - args$ancestry_range)/100
  ub<-(args$ancestry_threshold + args$ancestry_range)/100
  anc_haploid<-proportions %>% filter(Var1 == args$ancestry) %>% mutate(diploidID=gsub("\\.[0-9]+","",ID))
  anc_diploid<-aggregate(x = anc_haploid$percent, by = list(anc_haploid$diploidID), FUN = mean)
  colnames(anc_diploid)<-c("diploidID","percent")
  filtered<-anc_diploid %>% filter(percent > lb) %>% filter(percent < ub)
  fwrite(filtered, args$out %&% "_filtered_percentages.txt")
  sample_ids<-filtered %>% select(diploidID)
  fwrite(filtered, args$out %&% "_filtered_IDs_percentages.txt")
  
  str(lb); str(ub)
  str(anc_haploid);   str(anc_diploid);  str(filtered)
  
}