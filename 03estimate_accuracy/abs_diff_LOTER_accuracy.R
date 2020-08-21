###Loter acc

library(data.table)
library(argparse)
library(dplyr)
"%&%" = function(a,b) paste(a,b,sep="")

parser <- ArgumentParser()
parser$add_argument("--loter", help="Loter results file")
parser$add_argument("--poslist", help="haplotype genome file")
parser$add_argument("--ref.map", help="admixed sample list")
parser$add_argument("--classes", help="classes file made for lotermix input")
parser$add_argument("--nanc", help="number of ancestries estimated")
parser$add_argument("--anc", help="ancestry")
parser$add_argument("--result", help="results file output by adsim")
parser$add_argument("--out", help="file you would like to output as")
args <- parser$parse_args()

print("processing snp ids")
snps<-fread(args$poslist, header = F)
snps$chm<-22
colnames(snps)<-c("pos","chm")
loterout<-fread(args$loter, header = F) %>% t() %>% as.data.frame()
loterout<-as.data.frame(cbind.data.frame(snps,loterout))
true_ancestry<-fread(args$result, header = T)
# str(true_ancestry)

intersection<-select(true_ancestry,chm,pos) %>% inner_join(snps,by=c("chm","pos"))
true_ancestry_subset<-inner_join(true_ancestry,intersection,by=c("chm","pos"))
loterout<-inner_join(loterout,intersection,by=c("chm","pos"))
dim(true_ancestry_subset)
dim(loterout)
#separating true ancesty into ancestral groups
snp_count_true<-nrow(true_ancestry_subset)
nanc<-as.numeric(args$nanc)
n_haps<-(ncol(true_ancestry_subset) - 2)
nindv<-n_haps/2
true_ancestry_decomposed_haploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*n_haps)
loter_ancestry_decomposed_haploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*n_haps)

decompose_hap_to_ancestries_res<-function(haplotype, nanc){
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
decompose_hap_to_ancestries_loter<-function(haplotype, nanc){
  decomposed_anc<-matrix(,nrow = nrow(haplotype),ncol = nanc)
  anc1<-ifelse(haplotype==0,1,0)
  anc2<-ifelse(haplotype==1,1,0)
  decomposed_anc[,1]<-anc1
  decomposed_anc[,2]<-anc2
  if (nanc == 3){
    anc3<-ifelse(haplotype==2,1,0)
    decomposed_anc[,3]<-anc3
    return(decomposed_anc)
  } else {
    return(decomposed_anc)
  }
}
print("separating haplotypes into composite ancestries")
# dim(loterout)
# dim(true_ancestry_subset)
for (i in c(1:n_haps)){
  j<-i+2
  k<-i*nanc
  if(nanc==3){
    storage_indices<-c(k-2,k-1,k)
  } else {
    storage_indices<-c(k-1,k)
  }
  #str(true_ancestry_subset)
  true_ancestry_decomposed_haploid[,storage_indices]<-decompose_hap_to_ancestries_res(select(true_ancestry_subset, c(j)),nanc); #str(true_ancestry_decomposed_haploid)
  loter_ancestry_decomposed_haploid[,storage_indices]<-decompose_hap_to_ancestries_loter(select(loterout, c(j)),nanc); #str(loter_ancestry_decomposed_haploid)
}

true_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)
loter_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)

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
  
  loterhap1<-loter_ancestry_decomposed_haploid[,hap1_indices]
  loterhap2<-loter_ancestry_decomposed_haploid[,hap2_indices]
  loterdip<-(loterhap1 + loterhap2)
  loter_ancestry_decomposed_diploid[,storage_indices]<-loterdip
}

#ls hap_corr<-c(rep(NA,n_haps))
dip_corr<-c(rep(NA,nindv))

print("correlating diploid")
for (i in c(1:nindv)){
  j<-i*nanc
  threshold<-(1/nanc)
  if(nanc==3){
    storage_indices<-c(j-2,j-1,j)
    flip<-c(1,2,3)
    # flip<-c(1,3,2)
    # flip<-c(2,1,3)
    # flip<-c(2,3,1)
    # flip<-c(3,1,2)
     #flip<-c(3,2,1)
  } else {
    storage_indices<-c(j-1,j)
    flip<-c(2,1)
  }
  loter_indiv_i<-loter_ancestry_decomposed_diploid[,storage_indices]
  # if (args$anc == "HIS"){
  #   loter_indiv_i<-loter_indiv_i[,flip]
  # }
  true_indiv_i<-true_ancestry_decomposed_diploid[,storage_indices]
  corr<-sum(abs(loter_indiv_i - true_indiv_i))/2
  # str(corr)
  # str(corr$estimate)
  if (nanc == 3){
    loter_indiv_i<-loter_indiv_i[,flip]
    #str(loter_indiv_i)
    corr<-sum(abs(loter_indiv_i - true_indiv_i))/3
  }
  dip_corr[i]<-corr
  
  # j<-i*nanc
  # if(nanc==3){
  #   storage_indices<-c(j-2,j-1,j)
  #   corr1<-cor.test(loter_ancestry_decomposed_diploid[,j-2],true_ancestry_decomposed_diploid[,j-2], method="pearson")
  #   corr2<-cor.test(loter_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   corr3<-cor.test(loter_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j], method="pearson")
  #   # if (corr1$estimate < 0){
  #   #   corr1<-cor.test(loter_ancestry_decomposed_diploid[,j-2],true_ancestry_decomposed_diploid[,j-2], method="pearson")
  #   #   corr2<-cor.test(loter_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   # }
  #   dip_corr[storage_indices]<-c(corr1$estimate,corr2$estimate,corr3$estimate)
  # } else {
  #   storage_indices<-c(j-1,j)
  #   corr1<-cor.test(loter_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j], method="pearson")
  #   corr2<-cor.test(loter_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   # if (corr1$estimate < 0){
  #   #   corr1<-cor.test(loter_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
  #   #   corr2<-cor.test(loter_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j], method="pearson")
  #   # }
  #   dip_corr[storage_indices]<-c(corr1$estimate,corr2$estimate)
  # }
}

dip_corr
mean(dip_corr)
# quit()
fwrite(as.list(dip_corr),args$out,sep ="\t")
