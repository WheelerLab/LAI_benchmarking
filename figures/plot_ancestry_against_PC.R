library(data.table)
library(ggplot2)
library(dplyr)
library(viridis)
get_percent<-function(ancestry){
  sum(ancestry)/(length(ancestry)[1]*2)
}

PC10<-fread("Z:/data/Local_ancestry_project/paper_run_ASW/rethin/ASW_chr22.PC10.eigenvec")


elai<-fread("Z:/data/Local_ancestry_project/paper_run_ASW/rethin/two_way/software_correlation.txt_elai_ancestry_decomposed_diploid")
mos<-fread("Z:/data/Local_ancestry_project/paper_run_ASW/rethin/two_way/software_correlation.txt_mos_ancestry_decomposed_diploid")
LAMPLD<-fread("Z:/data/Local_ancestry_project/paper_run_ASW/rethin/two_way/software_correlation.txt_LAMPLD_ancestry_decomposed_diploid")
rf<-fread("Z:/data/Local_ancestry_project/paper_run_ASW/rethin/two_way/software_correlation.txt_rf_ancestry_decomposed_diploid")
loter<-fread("Z:/data/Local_ancestry_project/paper_run_ASW/rethin/two_way/software_correlation.txt_loter_ancestry_decomposed_diploid")

odds<-c(seq(1,122,2))
evens<-odds + 1

elai_perc<-apply(X=elai,MARGIN=2,FUN=get_percent)
mos_perc<-apply(X=mos,MARGIN=2,FUN=get_percent)
LAMPLD_perc<-apply(X=LAMPLD,MARGIN=2,FUN=get_percent)
rf_perc<-apply(X=rf,MARGIN=2,FUN=get_percent)
loter_perc<-apply(X=loter,MARGIN=2,FUN=get_percent)

names<-c("fid","iid",paste("PC",c(1:10),sep=""),"% AFA")

elai_anc<-cbind.data.frame(PC10,elai_perc[evens])
colnames(elai_anc)<-names
elai_anc$software<-"ELAI"

mos_anc<-cbind.data.frame(PC10,mos_perc[odds])
colnames(mos_anc)<-names
mos_anc$software<-"MOSAIC"

LAMPLD_anc<-cbind.data.frame(PC10,LAMPLD_perc[evens])
colnames(LAMPLD_anc)<-names
LAMPLD_anc$software<-"LAMPLD"

rf_anc<-cbind.data.frame(PC10,rf_perc[evens])
colnames(rf_anc)<-names
rf_anc$software<-"RFMix"

loter_anc<-cbind.data.frame(PC10,loter_perc[evens])
colnames(loter_anc)<-names
loter_anc$software<-"Loter"



Ancestry_long<-rbind.data.frame(elai_anc,mos_anc) %>% rbind.data.frame(LAMPLD_anc) %>% rbind.data.frame(rf_anc) %>% rbind.data.frame(loter_anc)
colnames(Ancestry_long)

model<-lm(`% AFA` ~ PC1 + software, data = Ancestry_long)
summary(model)
summary.aov(model)



for (i in c("Loter","ELAI","LAMPLD","MOSAIC","RFMix")){
  print(i)
  soft<-filter(Ancestry_long, software == i)
  cor<-cor.test(soft$`% AFA`,soft$PC1,methos = "pearson")
  print(cor$estimate^2)
}
g<-ggplot(data=Ancestry_long,aes(x=PC1, y=`% AFA`,colour=software)) +
  geom_point() + ylab("Proportion Estimated African Ancestry")
setEPS()
postscript("Z:/data/Local_ancestry_project/paper_run_ASW/rethin/two_way/Ancestry_vs_PC1.eps")
g + scale_colour_viridis(discrete = T) + 
  theme_bw(15) 
dev.off()
             