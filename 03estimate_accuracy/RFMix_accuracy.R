###calc RFMix accuracy

library(data.table)
library(argparse)
library(dplyr)
"%&%" = function(a,b) paste(a,b,sep="")

parser <- ArgumentParser()
parser$add_argument("--viterbi", help="Rdata object ouput by MOSAIC")
parser$add_argument("--haps.hap.gz", help="haplotype genome file")
parser$add_argument("--ref.map", help="admixed sample list")
parser$add_argument("--classes", help="classes file made for rfmix input")
parser$add_argument("--nanc", help="number of ancestries estimated")
parser$add_argument("--result", help="results file output by adsim")
parser$add_argument("--out", help="file you would like to output as")
args <- parser$parse_args()

print("processing snp ids")
snps<-fread("zcat " %&% args$haps.hap.gz, select = c(1,3))
colnames(snps)<-c("chm","pos")
rfout<-fread(args$viterbi, header = F)
rfout<-as.data.frame(cbind.data.frame(snps,rfout))
true_ancestry<-fread(args$result, header = T)
true_ancestry_subset<-inner_join(true_ancestry,snps,by=c("chm","pos"))

#separating true ancesty into ancestral groups
snp_count_true<-nrow(true_ancestry_subset)
nanc<-as.numeric(args$nanc)
n_haps<-(ncol(true_ancestry_subset) - 2)
nindv<-n_haps/2
true_ancestry_decomposed_haploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*n_haps)
rf_ancestry_decomposed_haploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*n_haps)

decompose_hap_to_ancestries<-function(haplotype, nanc){
  decomposed_anc<-matrix(,nrow = nrow(haplotype),ncol = nanc)
  anc1<-ifelse(haplotype==1,1,0)
  anc2<-ifelse(haplotype==2,1,0)
  decomposed_anc[,1]<-anc1
  decomposed_anc[,2]<-anc2
  if (nanc == 3){
    anc3<-ifelse(haplotype==3,1,0)
    decomposed_anc[,3]<-anc3
    return(decomposed_anc)
  } else {
    return(decomposed_anc)
  }
}
print("separating haplotypes into composite ancestries")
for (i in c(1:n_haps)){
  j<-i+2
  k<-i*nanc
  if(nanc==3){
    storage_indices<-c(k-2,k-1,k)
  } else {
    storage_indices<-c(k-1,k)
  }
  true_ancestry_decomposed_haploid[,storage_indices]<-decompose_hap_to_ancestries(select(true_ancestry_subset, c(j)),nanc)
  rf_ancestry_decomposed_haploid[,storage_indices]<-decompose_hap_to_ancestries(select(rfout, c(j)),nanc)
}

true_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)
rf_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)

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
  
  rfhap1<-rf_ancestry_decomposed_haploid[,hap1_indices]
  rfhap2<-rf_ancestry_decomposed_haploid[,hap2_indices]
  rfdip<-(rfhap1 + rfhap2)
  rf_ancestry_decomposed_diploid[,storage_indices]<-rfdip
}

#hap_corr<-c(rep(NA,n_haps))
dip_corr<-c(rep(NA,nindv))
str(rf_ancestry_decomposed_diploid)
print("correlating diploid")
for (i in c(1:nindv)){
  j<-i*nanc
  threshold<-(1/nanc)
  if(nanc==3){
    storage_indices<-c(j-2,j-1,j)
    flip<-c(2,1,3)
  } else {
    storage_indices<-c(j-1,j)
    flip<-c(2,1)
  }
  rf_indiv_i<-rf_ancestry_decomposed_diploid[,storage_indices]
  true_indiv_i<-true_ancestry_decomposed_diploid[,storage_indices]
  cat(i,"\n")
  #cat("estimated\n")
  #str(rf_indiv_i)
  #cat("true\n")
  #str(true_indiv_i)
  corr<-cor.test(rf_indiv_i,true_indiv_i)
  if (((nanc == 3)) | ((nanc == 2) & (corr$estimate < 0))){
    rf_indiv_i<-rf_indiv_i[,flip]
    #str(rf_indiv_i)
    corr<-cor.test(rf_indiv_i,true_indiv_i)
  }
  dip_corr[i]<-corr$estimate
}

dip_corr
fwrite(as.list(dip_corr),args$out,sep ="\t")
