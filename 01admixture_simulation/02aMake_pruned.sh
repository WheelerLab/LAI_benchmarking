#!/bin/bash

## takes in outputs of simulation for pruning
##takes in the ref.bcf.gz as well as the query.vcf file
## makes internal calls to plink and vcftools
## rather than calling bcftools to prune the file, makes a call to plink to generate the pruned list then vcftools to filter the file. This method was found to be much faster than calling bcftools

outPathDefault="./adsim_pruned"
r2ThresholdDefault=0.5

while :
do
    case "$1" in
      --vcf) #simulated vcf file to be pruned. Required.
                vcfFile="$2"
                shift 2
                ;;
      --out | -o) #same as normal plink - Path to out files and the shared prefix
                outPath="$2"
                shift 2
                ;;
      --bcf) #simulated bcf file to be pruned. Required.
                bcfFile="$2"
                shift 2
                ;;
      --r2) #R squared threshold to filter by. Default is 0.5. 
                r2Threshold="$2"
                shift 2
                ;;
      --map | -m | --genetic-map) #genetic map file - filtered map file is preferred. REQUIRED.
                geneticMap="$2"
                shift 2
                ;;
      --help | -h) 
                echo "--vcf : vcf file to extract samples from. Typically 1000 genome file. REQUIRED."
                echo "--out or -o : Use is as in plink - Path to out files and the shared prefix. Default is WORKING_DIR/adsim_pruned"
                echo "--map or -m or --genetic-map : genetic map file - format is rsid pos centimorgan-pos. REQUIRED."
                echo "--r2 : R squared threshold to filter by. Default is 0.5."
                exit 0
                ;;
      -*) #unknown
                echo "Error: Unknown option: $1" >&2
                echo "./simulate.sh --help or ./simulate.sh -h for option help"
                exit 1
                ;;
      *)  # No more options
                shift
                break
                ;;
     esac
done
if [ -z "${vcfFile}" ] || [ ! -e "${vcfFile}" ]
then
  echo "Query VCF not set or DNE. Please input a valid VCF."
  echo "./simulate.sh --help or ./simulate.sh -h for option help"
  echo "Exiting"
  exit 1
fi
if [ -z "${bcfFile}" ] || [ ! -e "${bcfFile}" ]
then
  echo "Reference BCF not set or DNE. Please input a valid BCF."
  echo "./simulate.sh --help or ./simulate.sh -h for option help"
  echo "Exiting"
  exit 1
fi
if [ -z "${geneticMap}" ] || [ ! -e "${geneticMap}" ]
then
  echo "Genetic map file not set or DNE. Please input a valid map."
  echo "./simulate.sh --help or ./simulate.sh -h for option help"
  echo "Exiting"
  exit 1
fi
echo "making pruned list"
sed -i -e "5 s/VAR/ALT/g" "${vcfFile}" ##vcftools outputs a weird header
plink --vcf "${vcfFile}" --indep-pairwise 50 5 "${r2Threshold:=r2ThresholdDefault}" --out "${outPath:=outPathDefault}"_pruned_list
echo "making new genetic map"
Rscript scripts/01bIntersect_map_snp_list.R --snps "${outPath}"_pruned_list.prune.in --map "${geneticMap}" --out "${outPath}"_pruned
echo "making new query vcf"
vcftools --vcf "${vcfFile}" --snps "${outPath}"_pruned_snp_list_intersection.txt --out "${outPath}"_pruned --recode
echo "making new reference bcf"
vcftools --bcf "${bcfFile}" --snps "${outPath}"_pruned_snp_list_intersection.txt --out "${outPath}"_pruned --recode-bcf
tabix  "${outPath}"_pruned.recode.bcf



