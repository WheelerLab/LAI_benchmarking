### Local ancestry acuracy ELAI
library(data.table)
library(argparse)
library(dplyr)
library(MOSAIC)
"%&%" = function(a,b) paste(a,b,sep="")

parser <- ArgumentParser()
parser$add_argument("--ps.21", help="resultant output of ELAI")
parser$add_argument("--haps.sample", help="admixed samle list as in MOSAIC intermediate files")
parser$add_argument("--nancestries", help="number of ancestries")
parser$add_argument("--result", help="results file output by adsimr")
parser$add_argument("--pos", help="snplist")
parser$add_argument("--out", help="file you would like to output as")
args <- parser$parse_args()

#Read in snp ids
print("processing snp ids")
bim<-fread(args$pos, header = F, drop = "V1")
#dim(bim)
colnames(bim)<-c("pos","chm")
bim<-select(bim,chm,pos)
elai_out<-as.data.frame(fread(args$ps.21,header = F))
ncols<-ncol(elai_out)
#fread(args$ps.21, col.names = F)

#read in true ancestry and keep only snps found in bim file
print("reading in  true ancestry")
true_ancestry_subset<-as.data.frame(fread(args$result,header = T, showProgress = T))
true_ancestry_subset<-inner_join(bim,true_ancestry_subset,by=c("chm","pos"))

snp_count_true<-nrow(true_ancestry_subset)
nanc<-as.numeric(args$nanc)
n_haps<-(ncol(true_ancestry_subset) - 2)
nindv<-n_haps/2
true_ancestry_decomposed_haploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*n_haps)

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
}

true_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)
elai_ancestry_decomposed_diploid<-matrix(NA,nrow=snp_count_true,ncol=nanc*nindv)

anc1_index<-seq(1, ncols, nanc)
anc2_index<-seq(2, ncols, nanc)
if(nanc==3){
  anc3_index<-seq(3, ncols, nanc)
}

print("converting haploid to diploid and reformatting elai output")
for (i in c(1:nindv)){
  cat(i,"\n")
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
  
  anc1_dosage<-elai_out[i,anc1_index]
  anc2_dosage<-elai_out[i,anc2_index]
  colnames(anc2_dosage)<-colnames(anc1_dosage)
  if (nanc ==3 ){
    anc3_dosage<-elai_out[i,anc3_index]
    colnames(anc3_dosage)<-colnames(anc1_dosage)
    indiv<-rbind(anc1_dosage,rbind(anc2_dosage,anc3_dosage)) %>% t()
  } else{
    indiv<-rbind(anc1_dosage,anc2_dosage) %>% t()
  }
  # str(indiv)
  elai_ancestry_decomposed_diploid[,storage_indices]<-indiv 
}

str(elai_ancestry_decomposed_diploid)

hap_corr<-c(rep(NA,n_haps))
dip_corr<-c(rep(NA,nindv))
#debugging matrix
anc_corr<-c(rep(NA,nindv*nanc))


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
  elai_indiv_i<-elai_ancestry_decomposed_diploid[,storage_indices]
  true_indiv_i<-true_ancestry_decomposed_diploid[,storage_indices]
  corr<-cor.test(elai_indiv_i,true_indiv_i)
  if (((nanc == 3)) | ((nanc == 2) & (corr$estimate < 0))){
    elai_indiv_i<-elai_indiv_i[,flip]
    #str(elai_indiv_i)
    corr<-cor.test(elai_indiv_i,true_indiv_i)
  }
  dip_corr[i]<-corr$estimate
  
  j<-i*nanc
  if(nanc==3){
    storage_indices<-c(j-2,j-1,j)
    corr1<-cor.test(elai_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-2], method="pearson")
    corr2<-cor.test(elai_ancestry_decomposed_diploid[,j-2],true_ancestry_decomposed_diploid[,j-1], method="pearson")
    corr3<-cor.test(elai_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j], method="pearson")
    # if (corr1$estimate < 0){
    #   corr1<-cor.test(elai_ancestry_decomposed_diploid[,j-2],true_ancestry_decomposed_diploid[,j-2], method="pearson")
    #   corr2<-cor.test(elai_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j-1], method="pearson")
    # }
    anc_corr[storage_indices]<-c(corr1$estimate,corr2$estimate,corr3$estimate)
  } else {
    storage_indices<-c(j-1,j)
    corr1<-cor.test(elai_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j], method="pearson")
    corr2<-cor.test(elai_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j-1], method="pearson")
    # if (corr1$estimate < 0){
    #   corr1<-cor.test(elai_ancestry_decomposed_diploid[,j-1],true_ancestry_decomposed_diploid[,j], method="pearson")
    #   corr2<-cor.test(elai_ancestry_decomposed_diploid[,j],true_ancestry_decomposed_diploid[,j-1], method="pearson")
    # }
    anc_corr[storage_indices]<-c(corr1$estimate,corr2$estimate)
  }
}
anc_corr
# dip_corr
fwrite(as.list(dip_corr),args$out,sep ="\t")


# #create two empty data frames to fill with diploid ancestries
# diploid_true<-data.frame(matrix(ncol = 20,nrow=50000))
# local_df<-data.frame(matrix(ncol = 20,nrow=50000))
# #convert haploid ancestries to diploid ancestries
# if (args$nancestries == 3){
#   ncols<-ncol(elai_out)
#   random<-c(1,2,3)
#   anc1_index<-seq(1, ncols, 3)
#   anc2_index<-seq(2, ncols, 3)
#   anc3_index<-seq(3, ncols, 3)
#   for ( i in c(1:20)){ 
#     cat( i, "/20\n")
#     hap2<-i*2
#     hap1<-hap2-1
#     
# 
#     anc1_dosage<-round(elai_out[..i,..anc1_index],0)
#     anc2_dosage<-round(elai_out[..i,..anc2_index],0)
#     anc3_dosage<-round(elai_out[..i,..anc3_index],0)
#     anc1_dosage[anc1_dosage==2]<-11
#     anc2_dosage[anc2_dosage==2]<-22
#     anc3_dosage[anc3_dosage==2]<-33
#     anc1_dosage[anc1_dosage==1]<-1
#     anc2_dosage[anc2_dosage==1]<-2
#     anc3_dosage[anc3_dosage==1]<-3
#     inidv<-cbind.data.frame(anc1_dosage,cbind.data.frame(anc2_dosage,anc3_dosage))
#     indiv<-apply(indiv,1,sort,decreasing=F) %>% t()
#     indiv_diploid<-indiv[,1] %&% indiv[,2] %&% indiv[,3]
#     indiv_diploid<-as.numeric(indiv_diploid)
#     indiv_diploid[indiv_diploid==0]<-sample(random,1)
#     indiv_diploid[indiv_diploid == 11] <- 1
#     indiv_diploid[indiv_diploid == 12] <- 2
#     indiv_diploid[indiv_diploid == 13] <- 3
#     indiv_diploid[indiv_diploid == 22] <- 4
#     indiv_diploid[indiv_diploid == 23] <- 5
#     indiv_diploid[indiv_diploid == 33] <- 6
#     local_df[,i]<-indiv_diploid
#     
#     #repeat process for results df
#     dip_t<-paste(res[,hap1+2],res[,hap2+2],sep="")
#     dip_t<-gsub("32","23",gsub("31","13",gsub("21","12",dip_t)))
#     dip_t<-gsub("32","23",gsub("31","13",gsub("21","12",dip_t)))
#     dip_t<-gsub("32","23",gsub("31","13",gsub("21","12",dip_t)))
#     dip_t[dip_t == "11"] <- 1
#     dip_t[dip_t == "12"] <- 2
#     dip_t[dip_t == "13"] <- 3
#     dip_t[dip_t == "22"] <- 4
#     dip_t[dip_t == "23"] <- 5
#     dip_t[dip_t == "33"] <- 6
#     dip_t<-as.numeric(dip_t)
#     diploid_true[,i]<-dip_t
#   }
# } else if (args$nancestries ==2){
#   random<-c(1,2)
#   ncols<-ncol(elai_out)
#   anc1_index<-seq(1, ncols, 2)
#   anc2_index<-seq(2, ncols, 2)
#   anc1_population<-round(elai_out[,..anc1_index],0) %>% t()
#   anc2_population<-round(elai_out[,..anc2_index],0) %>% t()
#   str(anc1_population)
#   str(anc2_population)
#   for ( i in c(1:20)){ 
#     cat( i, "/ 20\n")
#     hap2<-i*2
#     hap1<-hap2-1
#     
#     print("getting ancestral dosages")
#     anc1_dosage<-anc1_population[,i]
#     anc2_dosage<-anc2_population[,i]
#     print("encoding")
#     anc1_dosage[anc1_dosage==2]<-11
#     anc2_dosage[anc2_dosage==2]<-22
#     anc1_dosage[anc1_dosage==1]<-1
#     anc2_dosage[anc2_dosage==1]<-2
#     print("creating diploid encoding")
#     indiv<-cbind.data.frame(anc1_dosage,anc2_dosage)
#     indiv<-apply(indiv,1,sort,decreasing=F) %>% t()
#     indiv_diploid<-indiv[,1] %&% indiv[,2]
#     indiv_diploid<-as.numeric(indiv_diploid) 
#     indiv_diploid[indiv_diploid == 11] <- 1
#     indiv_diploid[indiv_diploid == 12] <- 2
#     indiv_diploid[indiv_diploid == 22] <- 3
#     local_df[,i]<-indiv_diploid
#     print("creating dipoid true ancestry")
#     dip_t<-paste(res[,hap1+2],res[,hap2+2],sep="")
#     dip_t<-gsub("21","12",dip_t)
#     dip_t[dip_t == "11"] <- 1
#     dip_t[dip_t == "12"] <- 2
#     dip_t[dip_t == "22"] <- 3
#     diploid_true[,i]<-as.numeric(dip_t)
#   }
# }
# ## assign snp ids to MOSAIC
# local_df<-as.data.frame(cbind.data.frame(bim,local_df))
# #colnames(local_df)<-c("chm","pos",ids)
# diploid_true<-as.data.frame(cbind.data.frame(bim,diploid_true))
# ##read in known ancestry, make sure it has only the right snp, and cols in the right order
# #fwrite(local_df)
# 
# #sanity check
# print("MOS dim:")
# dim(local_df)
# # str(local_df)
# print("actual dim")
# dim(diploid_true)
# # str(diploid_true)
# # fwrite(diploid_true,"~/software/Local_Ancestry/MOS_test_True.txt", sep = "\t")
# # fwrite(local_df,"~/software/Local_Ancestry/MOS_test_estimated.txt", sep = "\t")
# #begin corr tests per haplotype
# corrs<-c(rep(0,20))
# for (i in c(1:20)){
#   corrs[i]<-cor.test(local_df[,(i+2)],diploid_true[,(i+2)],method="pearson")[[4]]
#   # print(sd(local_df[,(i+2)]))
#   # print(sd(diploid_true[,(i+2)]))
# }
# warnings()
# corrs[is.na(corrs)]<-1.01
# str(corrs)
# #fwrite(local_df,"~/software/Local_Ancestry/Local_DF.txt",col.names = T,sep='\t' )
# #process and write to file
# corr_R2<-corrs*corrs
# 
# print("writing corrs")
# fwrite(as.list(corrs),args$out %&% "_dip_accuracy.txt",sep="\t")
# print("writing corr R2")
# corr_R2<-as.list(corr_R2)
# str(corr_R2)
# fwrite(corr_R2,args$out %&% "_dip_accuracy.txt",sep="\t",append=T)
