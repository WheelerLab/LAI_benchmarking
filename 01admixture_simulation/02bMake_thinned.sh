#!/bin/bash

## takes in outputs of simulation for pruning
##takes in the ref.bcf.gz as well as the query.vcf file
## makes internal calls to plink and vcftools
## rather than calling bcftools to prune the file, makes a call to plink to generate the pruned list then vcftools to filter the file. This method was found to be much faster than calling bcftools

outPathDefault="./adsim_pruned"
thinThreshDefault=50000

while :
do
    case "$1" in
      --vcf) #simulated vcf file to be pruned. Required.
                vcfFile=$2
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
      --thin | -t) #thinning threshold. Default is 50000
                thinThresh="$2"
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
                echo "--thin | -t : thinning threshold. Default is 50000"
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
sed -i -e "5 s/VAR/ALT/g" "${vcfFile}"
plink --vcf "${vcfFile}" --thin-count "${thinThresh:=thinThreshDeafult}" --out "${outPath:=outPathDefault}"_thinned_list --make-just-bim
awk '{print $2}' "${outPath}"_thinned_list.bim > "${outPath}"_thinned_list.txt
echo "making new genetic map"
Rscript scripts/01bIntersect_map_snp_list.R --snps "${outPath}"_thinned_list.txt --map "${geneticMap}" --out "${outPath}"_thinned
echo "making new query vcf"
vcftools --vcf "${vcfFile}" --snps "${outPath}"_thinned_snp_list_intersection.txt --recode --out "${outPath}"_thinned
echo "making new reference bcf"
vcftools --bcf "${bcfFile}" --snps "${outPath}"_thinned_snp_list_intersection.txt --out "${outPath}"_thinned --recode-bcf
bcftools index "${outPath}"_thinned.recode.bcf


