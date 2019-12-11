##make accuracy plot
library(viridis)
library(ggplot2)
library(data.table)
library(dplyr)
library(reshape2)
RFMix1<-fread("Z:/data/Local_ancestry_project/redoancestry/threeway/accuracy/RFMix_accuracy.txt")
RFMix2<-fread("Z:/data/Local_ancestry_project/redoancestry/afatwoway/accuracy/RFMix_accuracy.txt")
RFMix3<-fread("Z:/data/Local_ancestry_project/redoancestry/histwoway/accuracy/RFMix_accuracy.txt")

RFMix1$pop<-"3WAY"
RFMix2$pop<-"AFA"
RFMix3$pop<-"HIS"

RFMix1$software<-"RFMix"
RFMix2$software<-"RFMix"
RFMix3$software<-"RFMix"

RFMix<-rbind.data.frame(RFMix1,RFMix2) %>% rbind.data.frame(RFMix3)

ELAI1<-fread("Z:/data/Local_ancestry_project/redoancestry/threeway/accuracy/ELAI_accuracy.txt")
ELAI2<-fread("Z:/data/Local_ancestry_project/redoancestry/afatwoway/accuracy/ELAI_accuracy.txt")
ELAI3<-fread("Z:/data/Local_ancestry_project/redoancestry/histwoway/accuracy/ELAI_accuracy.txt")

ELAI1$pop<-"3WAY"
ELAI2$pop<-"AFA"
ELAI3$pop<-"HIS"

ELAI1$software<-"ELAI"
ELAI2$software<-"ELAI"
ELAI3$software<-"ELAI"

ELAI<-rbind.data.frame(ELAI1,ELAI2) %>% rbind.data.frame(ELAI3)

Loter1<-fread("Z:/data/Local_ancestry_project/redoancestry/threeway/accuracy/Loter_accuracy.txt")
Loter2<-fread("Z:/data/Local_ancestry_project/redoancestry/afatwoway/accuracy/Loter_accuracy.txt")
Loter3<-fread("Z:/data/Local_ancestry_project/redoancestry/histwoway/accuracy/Loter_accuracy.txt")

Loter1$pop<-"3WAY"
Loter2$pop<-"AFA"
Loter3$pop<-"HIS"

Loter1$software<-"Loter"
Loter2$software<-"Loter"
Loter3$software<-"Loter"

Loter<-rbind.data.frame(Loter1,Loter2) %>% rbind.data.frame(Loter3)

MOSAIC1<-fread("Z:/data/Local_ancestry_project/redoancestry/threeway/accuracy/MOSAIC_accuracy.txt")
MOSAIC2<-fread("Z:/data/Local_ancestry_project/redoancestry/afatwoway/accuracy/MOSAIC_accuracy.txt")
MOSAIC3<-fread("Z:/data/Local_ancestry_project/redoancestry/histwoway/accuracy/MOSAIC_accuracy.txt")

MOSAIC1$pop<-"3WAY"
MOSAIC2$pop<-"AFA"
MOSAIC3$pop<-"HIS"

MOSAIC1$software<-"MOSAIC"
MOSAIC2$software<-"MOSAIC"
MOSAIC3$software<-"MOSAIC"

MOSAIC<-rbind.data.frame(MOSAIC1,MOSAIC2) %>% rbind.data.frame(MOSAIC3)

LAMPLD1<-fread("Z:/data/Local_ancestry_project/redoancestry/threeway/accuracy/LAMPLD_accuracy.txt")
LAMPLD2<-fread("Z:/data/Local_ancestry_project/redoancestry/afatwoway/accuracy/LAMPLD_accuracy.txt")
LAMPLD3<-fread("Z:/data/Local_ancestry_project/redoancestry/histwoway/accuracy/LAMPLD_accuracy.txt")

LAMPLD1$pop<-"3WAY"
LAMPLD2$pop<-"AFA"
LAMPLD3$pop<-"HIS"

LAMPLD1$software<-"LAMPLD"
LAMPLD2$software<-"LAMPLD"
LAMPLD3$software<-"LAMPLD"

LAMPLD<-rbind.data.frame(LAMPLD1,LAMPLD2) %>% rbind.data.frame(LAMPLD3)

all_software_long %>% filter(software=="ELAI") %>% select(value) %>% str()


all_software<-rbind.data.frame(RFMix,ELAI) %>% rbind.data.frame(LAMPLD) %>% rbind.data.frame(MOSAIC) %>% rbind.data.frame(Loter)

all_software_long<-melt(data = all_software, id.vars=c("pop","software"))
gV<-ggplot(data = all_software_long, aes(x=software,y=value))
gV + geom_violin(aes(fill=software)) + 
  facet_wrap(~pop) + 
  scale_fill_viridis(discrete = T) + 
  geom_boxplot(width=0.1) + 
  theme_bw() +
  ylab("Pearson Correlation Coefficient") +
  xlab("Software")
