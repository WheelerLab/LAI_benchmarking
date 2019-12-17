#make files for and run ELAI (using files from the RFMix run)
#bash 05_ELAI.sh --CEU sim_RFMix/CEU_ACB_ref.vcf.gz --YRI sim_RFMix/YRI_ACB_ref.vcf.gz --adm sim_RFMix/ACB.vcf.gz --out ACB

while :
do
    case "$1" in
      --NAT) #path to Native American .vcf reference file (see RFMix output)
	        NAT="$2"  
	        shift 2
	        ;;
      --CEU) #path to European .vcf reference file (see RFMix output)
         	CEU="$2"
	        shift 2
	        ;;
      --YRI) #path to west African .vcf reference file (see RFMix output)
      	 	YRI="$2"
	        shift 2
	        ;;
      --adm) #path to admixed, LD-pruned .vcf file
          adm="$2"
	        shift 2
	        ;;
      --out) #output prefix
          out="$2"
	        shift 2
	        ;;
	     *)  # No more options
          shift
	        break
	        ;;
     esac #CEU vcf, NAT vcf if it exists, and YRI vcf if it exists
done

#to store files
#mkdir -p sim_ELAI/
#mkdir -p sim_ELAI/results/

#convert adm to bimbam
~/bin/bcftools convert $adm -Ob -o $out.bcf.gz #runs into error when going directly from vcf  #pull LD pruned SNPs
~/scratch/software/plink_bin/plink --bcf $out.bcf.gz --write-snplist --recode bimbam --out $out --allow-extra-chr 0

#convert references to BIMBAM
if [[ -f $NAT ]]; then
  ~/scratch/software/plink_bin/plink --extract ${out}.snplist --vcf $NAT --recode bimbam --out ${out}_NAT --allow-extra-chr 0
fi
if [[ -f $CEU ]]; then
  ~/scratch/software/plink_bin/plink --extract ${out}.snplist --vcf $CEU --recode bimbam --out ${out}_CEU --allow-extra-chr 0
fi
if [[ -f $YRI ]]; then
  ~/scratch/software/plink_bin/plink --extract ${out}.snplist --vcf $YRI --recode bimbam --out ${out}_YRI --allow-extra-chr 0
fi

#run ELAI
dir=$(pwd)
echo ELAI is annoying and you have to have a copy you can run locally to write the output, so get your very own ELAI directory to also be annoyed.

if [[ -f $NAT && $CEU && $YRI ]]; then
    echo "Running 3-way admixture between NAT, CEU, and YRI"
    cd /home/rschubert1/scratch/software/elai
    (/home/rschubert1/scratch/time -v ./elai-lin -g ${out}_NAT.recode.geno.txt -p 10 -g ${out}_CEU.recode.geno.txt -p 11 -g ${out}_YRI.recode.geno.txt -p 12 -g ${out}.recode.geno.txt -p 1 -pos ${out}.recode.pos.txt -C 3 -o 3WAY) 2> ${out}_benchmarking.txt
elif [[ -f $NAT && $CEU ]]; then
    echo "Running 2-way admixture between NAT and CEU"
    cd /home/rschubert1/scratch/software/elai
    (/home/rschubert1/scratch/time -v ./elai-lin -g ${out}_NAT.recode.geno.txt -p 10 -g ${out}_CEU.recode.geno.txt -p 11 -g ${out}.recode.geno.txt -p 1 -pos ${out}.recode.pos.txt -C 2 -o HIS) 2> ${out}_benchmarking.txt
elif [[ -f $YRI && $CEU ]]; then
    echo "Running 2-way admixture between CEU and YRI"
    cd /home/rschubert1/scratch/software/elai
    (/home/rschubert1/scratch/time -v ./elai-lin -g ${out}_CEU.recode.geno.txt -p 10 -g ${out}_YRI.recode.geno.txt -p 11 -g ${out}.recode.geno.txt -p 1 -pos ${out}.recode.pos.txt -C 2 -o ASW) 2> ${out}_benchmarking.txt
elif [[ -f $NAT && $YRI ]]; then
    echo "Running 2-way admixture between NAT and YRI"
    cd /home/rschubert1/scratch/software/elai
    (/home/rschubert1/scratch/time -v ./elai-lin -g ${out}_NAT.recode.geno.txt -p 10 -g $dir/sim_ELAI/${out}_YRI.recode.geno.txt -p 11 -g $dir/sim_ELAI/${out}.recode.geno.txt -p 1 -pos $dir/sim_ELAI/${out}.recode.pos.txt -C 2 -o ${out}) 2> $dir/sim_ELAI/results/${out}_benchmarking.txt
else
    echo "Please input a proper combination of reference files for your cohort."
fi

mv $out.ps21.txt $out.results.txt
echo Output is at ${out}.results.txt. Have a nice day!
