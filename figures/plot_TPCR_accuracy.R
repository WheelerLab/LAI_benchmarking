##new new accuracy results chr22
library(dplyr)
library(data.table)
library(multcompView)
library(ggplot2)
library(viridis)
library(tibble)
library(tidyr)
library(egg)

tag_facet2 <- function(p, open = "", close = "", tag_pool = LETTERS, x = -Inf, y = Inf, ## from stackoverflow https://stackoverflow.com/questions/56064042/using-facet-tags-and-strip-labels-together-in-ggplot2 based on egg tag_facet
                       hjust = -0.5, vjust = 1.5, fontface = 2, family = "", ...) {
  
  gb <- ggplot_build(p)
  lay <- gb$layout$layout
  tags <- cbind(lay, label = paste0(open, tag_pool[lay$PANEL], close), x = x, y = y)
  p + geom_text(data = tags, aes_string(x = "x", y = "y", label = "label"), ..., hjust = hjust, 
                vjust = vjust, fontface = fontface, family = family, inherit.aes = FALSE)
}

'%&%' = function(a,b) paste(a,b,sep="")

tmp1<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_chr22/accuracy/abs_diff_RFMix_accuracy.txt") %>% mutate(software="RFMix",pop="3WAY",chr=22)
tmp2<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_chr22/accuracy/abs_diff_RFMix_accuracy.txt")  %>% mutate(software="RFMix",pop="HIS",chr=22)
tmp3<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_chr22/accuracy/abs_diff_RFMix_accuracy.txt") %>% mutate(software="RFMix",pop="AFA",chr=22)
tmp4<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_simulated/accuracy/abs_diff_RFMix_accuracy.txt") %>% mutate(software="RFMix",pop="3WAY",chr=1)
tmp5<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_simulated/accuracy/abs_diff_RFMix_accuracy.txt")  %>% mutate(software="RFMix",pop="HIS",chr=1)
tmp6<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_simulated/accuracy/abs_diff_RFMix_accuracy.txt") %>% mutate(software="RFMix",pop="AFA",chr=1)
RFMix<-bind_rows(tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)

tmp1<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_chr22/accuracy/abs_diff_LAMPLD_accuracy.txt") %>% mutate(software="LAMPLD",pop="3WAY",chr=22)
tmp2<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_chr22/accuracy/abs_diff_LAMPLD_accuracy.txt")  %>% mutate(software="LAMPLD",pop="HIS",chr=22)
tmp3<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_chr22/accuracy/abs_diff_LAMPLD_accuracy.txt") %>% mutate(software="LAMPLD",pop="AFA",chr=22)
tmp4<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_simulated/accuracy/abs_diff_LAMPLD_accuracy.txt") %>% mutate(software="LAMPLD",pop="3WAY",chr=1)
tmp5<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_simulated/accuracy/abs_diff_LAMPLD_accuracy.txt")  %>% mutate(software="LAMPLD",pop="HIS",chr=1)
tmp6<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_simulated/accuracy/abs_diff_LAMPLD_accuracy.txt") %>% mutate(software="LAMPLD",pop="AFA",chr=1)
LAMPLD<-bind_rows(tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)


tmp1<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_chr22/accuracy/abs_diff_ELAI_accuracy.txt") %>% mutate(software="ELAI",pop="3WAY",chr=22)
tmp2<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_chr22/accuracy/abs_diff_ELAI_accuracy.txt")  %>% mutate(software="ELAI",pop="HIS",chr=22)
tmp3<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_chr22/accuracy/abs_diff_ELAI_accuracy.txt") %>% mutate(software="ELAI",pop="AFA",chr=22)
tmp4<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_simulated/accuracy/abs_diff_ELAI_accuracy.txt") %>% mutate(software="ELAI",pop="3WAY",chr=1)
tmp5<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_simulated/accuracy/abs_diff_ELAI_accuracy.txt")  %>% mutate(software="ELAI",pop="HIS",chr=1)
tmp6<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_simulated/accuracy/abs_diff_ELAI_accuracy.txt") %>% mutate(software="ELAI",pop="AFA",chr=1)
ELAI<-bind_rows(tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)


tmp1<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_chr22/accuracy/abs_diff_Loter_accuracy.txt") %>% mutate(software="Loter",pop="3WAY",chr=22)
tmp2<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_chr22/accuracy/abs_diff_Loter_accuracy.txt")  %>% mutate(software="Loter",pop="HIS",chr=22)
tmp3<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_chr22/accuracy/abs_diff_Loter_accuracy.txt") %>% mutate(software="Loter",pop="AFA",chr=22)
tmp4<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_simulated/accuracy/abs_diff_Loter_accuracy.txt") %>% mutate(software="Loter",pop="3WAY",chr=1)
tmp5<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_simulated/accuracy/abs_diff_Loter_accuracy.txt")  %>% mutate(software="Loter",pop="HIS",chr=1)
tmp6<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_simulated/accuracy/abs_diff_Loter_accuracy.txt") %>% mutate(software="Loter",pop="AFA",chr=1)
Loter<-bind_rows(tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)


tmp1<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_chr22/accuracy/abs_diff_MOSAIC_accuracy.txt") %>% mutate(software="MOSAIC",pop="3WAY",chr=22)
tmp2<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_chr22/accuracy/abs_diff_MOSAIC_accuracy.txt")  %>% mutate(software="MOSAIC",pop="HIS",chr=22)
tmp3<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_chr22/accuracy/abs_diff_MOSAIC_accuracy.txt") %>% mutate(software="MOSAIC",pop="AFA",chr=22)
tmp4<-fread("Z:/data/Local_ancestry_project/revisions/simulate/three_way_simulated/accuracy/abs_diff_MOSAIC_accuracy.txt") %>% mutate(software="MOSAIC",pop="3WAY",chr=1)
tmp5<-fread("Z:/data/Local_ancestry_project/revisions/simulate/two_way_simulated/accuracy/abs_diff_MOSAIC_accuracy.txt")  %>% mutate(software="MOSAIC",pop="HIS",chr=1)
tmp6<-fread("Z:/data/Local_ancestry_project/revisions/simulate/afa_simulated/accuracy/abs_diff_MOSAIC_accuracy.txt") %>% mutate(software="MOSAIC",pop="AFA",chr=1)
MOSAIC<-bind_rows(tmp1,tmp2,tmp3,tmp4,tmp5,tmp6)


all_software<-bind_rows(RFMix,ELAI,LAMPLD,Loter,MOSAIC)
all_software_long<-melt(data = all_software, id.vars=c("pop","software","chr")) %>% 
  mutate(value=if_else(pop=="3WAY",value*3/2,value)) %>% 
  mutate(TCR=if_else(chr==22,1-value/(2*50000),1-value/(2*44332)),ID=software %&% "_" %&% chr)

sub<-all_software_long[(all_software_long$pop== "3WAY"),]
medians<-tapply(sub$TCR,sub$software,median)
model<-lm(TCR~software,data=sub)
print(medians)
A<-aov(model)
tukey<-TukeyHSD(A)
heat_data<-tukey$software %>% 
  as.data.frame() %>% 
  rename_all(function(n){paste("3WAY",n,sep="_")}) %>% 
  rownames_to_column()

for (i in c("HIS","AFA","3WAY")){
  sub<-all_software_long[(all_software_long$pop== i),]
  medians<-tapply(sub$TCR,sub$software,median)
  model<-lm(TCR~software,data=sub)
  print(medians)
  A<-aov(model)
  tukey<-TukeyHSD(A)
  print(tukey$software)
  heat_data<-tukey$software %>% 
    as.data.frame() %>% 
    rename_all(function(n){paste(i,n,sep="_")}) %>% 
    rownames_to_column() %>%
    inner_join(heat_data,by="rowname")
  
  #setEPS()
  #postscript("Z:/data/Local_ancestry_project/revisions/" %&% i %&% "_Tukey.eps")
  #png("Z:/data/Local_ancestry_project/revisions/TPCR_" %&% i %&% "_pooled_Tukey.png")
  #par(mar=c(5,8,4,1)+.1)
  #plot(tukey, las=1)
  #title("\n" %&% i)
  #dev.off()
} #; tukey$software
heat_data1<-heat_data %>% 
  select(contains("rowname") | contains("p adj")) %>% 
  melt(id.vars="rowname") %>%
  separate(variable,into=c("pop"),sep="_") %>% 
  rename(p_adj="value")
heat_data2<-heat_data %>% 
  select(contains("rowname") | contains("diff")) %>% 
  melt(id.vars="rowname") %>%
  separate(variable,into=c("pop"),sep="_") %>% 
  rename(diff="value")
heat_data_long<-inner_join(heat_data1,heat_data2,by=c("rowname","pop")) %>% 
  separate(rowname,into=c("software1","software2"),sep="-",remove=FALSE)

heat_data_matrix<-heat_data_long %>% 
  filter(pop == "3WAY") %>% dcast(software1 ~ software2, value.var="p_adj") %>% 
  as.matrix()
heatmap(heat_data_matrix)
gH<-ggplot(data=heat_data_long)
gH + geom_tile(x=)

gV<-ggplot(data = all_software_long, aes(x=ID,y=TCR))


pdf("Z:/data/Local_ancestry_project/revisions/TPCR_accuracy_both_chr_v2.pdf")
f6<-gV + 
  geom_violin(aes(fill=ID),scale = "width") + 
  facet_wrap(~pop,ncol=1) + 
  scale_fill_viridis(discrete = T) + 
  geom_boxplot(width=0.1) + 
  theme_bw() +
  theme(axis.text.x = element_text(size=8),legend.position = "none") +
  ylab("True Positive Call Rate") +
  xlab("Software")
tag_facet2(f6,vjust=14.5)
dev.off()
