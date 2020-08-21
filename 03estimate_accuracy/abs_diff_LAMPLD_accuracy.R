
###calc LAMP accuracy

library(data.table)
library(argparse)
library(dplyr)
"%&%" = function(a,b) paste(a,b,sep="")

parser <- ArgumentParser()
parser$add_argument("--long", help="Rdata object ouput by MOSAIC")
parser$add_argument("--haps.hap.gz", help="admixed sample list")
parser$add_argument("--haps.sample", help="admixed sample list")
parser$add_argument("--result", help="results file output by adsim")
parser$add_argument("--nanc", help="number of ancestries estimated")
parser$add_argument("--out", help="file you would like to output as")
args <- parser$parse_args()

print("processing sample ids")
##read in samples
samps<-fread(args$haps.sample, header = F, skip = 2)
samps$V1<-paste(samps$V1, ".0", sep = "")
samps$V2<-paste(samps$V2, ".1", sep = "")
samps$V3<-NULL
#assign sample ids to MOSAIC
ids<-as.vector(t(samps))

print("processing snp ids")
##read in snps
snps<-fread("zcat " %&% args$haps.hap.gz, select = c(1,3))
colnames(snps)<-c("chm","pos")

print("processing true ancestry")
true_ancestry_subset<-fread(args$result, header = T) %>% inner_join(snps, by = c("chm","pos")) 

print("processing in LAMPLD results")
long<-fread(args$long, header = F)
long<-strsplit(long$V1,"")
long<-matrix(unlist(long), nrow=length(long), byrow=T)  %>% t()
long<-apply(long,2,as.numeric) %>% as.data.frame(stringsAsFactors = F) 

snp_count_true<-nrow(true_ancestry_subset)
nanc<-as.numeric(args$nanc)
n_haps<-(ncol(true_ancestry_subset) - 2)
nindv<-n_haps/2

decompose_hap_to_ancestries<-function(haplotype, nanc, index){
  decomposed_anc<-matrix(,nrow = nrow(haplotype),ncol = nanc)
  anc1<-ifelse(haplotype==index,1,0)
  anc2<-ifelse(haplotype==(index+1),1,0)
  decomposed_anc[,1]<-anc1
  decomposed_anc[,2]<-anc2
  if (nanc == 3){
    anc3<-ifelse(haplotype==(index+2),1,0)
    decomposed_anc[,3]<-anc3
    return(decomposed_anc)
  } else {
    return(decomposed_anc)
  }
}

true_ancestry_decomposed_haploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*n_haps)
LAMPLD_ancestry_decomposed_haploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*n_haps)
# str(long)
# str(true_ancestry_subset)
# str(long)
print("separating haplotypes into composite ancestries")
## calc both true and maximized
for (i in c(1:n_haps)){
  j<-i+2
  k<-i*nanc
  if(nanc==3){
    storage_indices<-c(k-2,k-1,k)
  } else {
    storage_indices<-c(k-1,k)
  }
  true_ancestry_decomposed_haploid[,storage_indices]<-decompose_hap_to_ancestries(select(true_ancestry_subset, c(j)),nanc,1)
  LAMPLD_ancestry_decomposed_haploid[,storage_indices]<-decompose_hap_to_ancestries(select(long, c(i)),nanc,0)
  
  
  # x1<-select(long, (hap1)) %>% unlist %>% as.numeric()
  # y1<-select(res,(hap1)) %>% unlist %>% as.numeric()
  # 
  # x2<-select(long, (hap2)) %>% unlist %>% as.numeric()
  # y2<-select(res,(hap2)) %>% unlist %>% as.numeric()
  # 
  # hap1_unflipped<-cor.test(x1,y1,method="pearson")
  # hap2_unflipped<-cor.test(x2,y2,method="pearson")
  # hap_cor_unmaxed[hap1]<-hap1_unflipped$estimate
  # hap_cor_unmaxed[hap2]<-hap2_unflipped$estimate
  # 
  # hap1_flipped<-cor.test(x1,y2,method="pearson")
  # hap2_flipped<-cor.test(x2,y1,method="pearson")
  # # str(hap1_unflipped$estimate)
  # # str(hap2_unflipped$estimate)
  # # str(hap1_flipped$estimate)
  # # str(hap2_flipped$estimate)
  # mu_unflipped<-mean(c(hap1_unflipped$estimate,hap2_unflipped$estimate),na.rm = T)
  # mu_flipped<-mean(c(hap1_flipped$estimate,hap2_flipped$estimate), na.rm = T)
  # mu_unflipped<-ifelse(!is.na(mu_unflipped),mu_unflipped,0) 
  # mu_flipped<-ifelse(!is.na(mu_flipped),mu_flipped,0) 
  # # print("here")
  # if (mu_unflipped > mu_flipped){
  #   hap_cor_maximized[hap1]<-ifelse(!is.na(hap1_unflipped$estimate),hap1_unflipped$estimate,1.01)
  #   hap_cor_maximized[hap2]<-ifelse(!is.na(hap2_unflipped$estimate),hap2_unflipped$estimate,1.01)
  # } else {
  #   hap_cor_maximized[hap1]<-ifelse(!is.na(hap1_flipped$estimate),hap1_unflipped$estimate,1.01)
  #   hap_cor_maximized[hap2]<-ifelse(!is.na(hap2_flipped$estimate),hap2_unflipped$estimate,1.01)
  # }
    
}
# hap_cor_unmaxed[is.na(hap_cor_unmaxed)]<-1.01
# hap_cor_maximized[is.na(hap_cor_maximized)]<-1.01
# hap_cor_unmaxed<-as.list(hap_cor_unmaxed)
# hap_cor_maximized<-as.list(hap_cor_maximized)
# str(hap_cor_unmaxed)
# str(hap_cor_maximized)
# fwrite(hap_cor_unmaxed,args$out %&% "_haps_unmaxed_accuracy.txt", sep="\t", col.names = F)
# fwrite(hap_cor_maximized,args$out %&% "_haps_maxed_accuracy.txt", sep="\t", col.names = F)

true_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)
LAMPLD_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)

print("converting haploid to diploid")
for (i in c(1:nindv)){
  k<-i*nanc*2
  j<-i*nanc
  
  if(nanc==3){
    hap1_indices<-c(k-5,k-4,k-3)
    hap2_indices<-c(k-2,k-1,k)
    storage_indices<-c(j-2,j-1,j)
  } else {
    hap1_indices<-c(k-3,k-2)
    hap2_indices<-c(k-1,k)
    storage_indices<-c(j-1,j)
  }
  
  hap1<-true_ancestry_decomposed_haploid[,hap1_indices]
  hap2<-true_ancestry_decomposed_haploid[,hap2_indices]
  dip<-(hap1 + hap2)
  true_ancestry_decomposed_diploid[,storage_indices]<-dip
  
  LAMPLDhap1<-LAMPLD_ancestry_decomposed_haploid[,hap1_indices]
  LAMPLDhap2<-LAMPLD_ancestry_decomposed_haploid[,hap2_indices]
  LAMPLDdip<-(LAMPLDhap1 + LAMPLDhap2)
  LAMPLD_ancestry_decomposed_diploid[,storage_indices]<-LAMPLDdip
}

# str(true_ancestry_decomposed_diploid)
# str(LAMPLD_ancestry_decomposed_diploid)


dip_corr<-c(rep(NA,nindv))
print("correlating diploid")
for (i in c(1:nindv)){
  j<-i*nanc
  threshold<-(1/nanc)
  if(nanc==3){
    storage_indices<-c(j-2,j-1,j)
    flip<-c(1,3,2)
  } else {
    storage_indices<-c(j-1,j)
    flip<-c(2,1)
  }
  LAMPLD_indiv_i<-LAMPLD_ancestry_decomposed_diploid[,storage_indices]

  true_indiv_i<-true_ancestry_decomposed_diploid[,storage_indices]
  corr<-sum(abs(LAMPLD_indiv_i - true_indiv_i))/2
  if (nanc == 3){
    LAMPLD_indiv_i<-LAMPLD_indiv_i[,flip]
    #str(LAMPLD_indiv_i)
    corr<-sum(abs(LAMPLD_indiv_i - true_indiv_i))/3
  }
  dip_corr[i]<-corr
  # j<-i*nanc
  # if(nanc==3){
  #   storage_indices<-c(j-2,j-1,j)
  #   corr1<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j-2],true_ancestry_decomposed_diploid[,j-2], method="pearson")
  #   corr2<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j], method="pearson")
  #   corr3<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   # if (corr1$estimate < 0){
  #   #   corr1<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j-2],true_ancestry_decomposed_diploid[,j-2], method="pearson")
  #   #   corr2<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   # }
  #   dip_corr[storage_indices]<-c(corr1$estimate,corr2$estimate,corr3$estimate)
  # } else {
  #   storage_indices<-c(j-1,j)
  #   corr1<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j], method="pearson")
  #   corr2<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   # if (corr1$estimate < 0){
  #   #   corr1<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   #   corr2<-cor.test(LAMPLD_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j], method="pearson")
  #   # }
  #   dip_corr[storage_indices]<-c(corr1$estimate,corr2$estimate)
  # }
}

# dip_corr
fwrite(as.list(dip_corr),args$out,sep ="\t")

# for (i in c(1:20)){
#   cat(i,"/ 20\n")
#   hap2<- i * 2
#   hap1<-hap2-1
#   
#   dip_pred<-paste(long[,hap1],long[,hap2],sep="")
#   dip_pred[dip_pred == "00"] <- 1
#   dip_pred[dip_pred == "01"] <- 2
#   dip_pred[dip_pred == "02"] <- 3
#   dip_pred[dip_pred == "11"] <- 4
#   dip_pred[dip_pred == "12"] <- 5
#   dip_pred[dip_pred == "22"] <- 6
#   dip_pred<-as.numeric(dip_pred)
#   diploid_predicted[,i]<-dip_pred
#   
#   
#   dip_t<-paste(res[,hap1+2],res[,hap2+2],sep="")
#   dip_t<- gsub("32","23",gsub("31","13",gsub("21","12",dip_t)))
#   dip_t[dip_t == "11"] <- 1
#   dip_t[dip_t == "12"] <- 2
#   dip_t[dip_t == "13"] <- 3
#   dip_t[dip_t == "22"] <- 4
#   dip_t[dip_t == "23"] <- 5
#   dip_t[dip_t == "33"] <- 6
#   dip_t<-as.numeric(dip_t)
#   diploid_true[,i]<-dip_t
# }

# long<-cbind.data.frame(snps,diploid_predicted)
# res<-cbind.data.frame(snps,diploid_true)
# #long<-long + 1
# #colnames(long)<-c("chm","pos",ids)
# corrs<-c(rep(0,20))
# str(long)
# str(res)
# for (i in c(1:20)){
#   j<-i+2
#   corrs[i]<-cor.test(as.numeric(unlist(long[,..j])),as.numeric(unlist(res[,..j])),method="pearson")[[4]]
# }
# str(corrs)
# corrs[is.na(corrs)]<-1.001
# corr_R2<-corrs*corrs
# 
# print("writing corrs")
# fwrite(as.list(corrs),args$out %&% "_dip_accuracy.txt",sep="\t")
# print("writing corr R2")
# str(corr_R2)
# corr_R2<-as.list(corr_R2)
# str(corr_R2)
# fwrite(corr_R2,args$out %&% "_dip_accuracy.txt",sep="\t",append=T)
