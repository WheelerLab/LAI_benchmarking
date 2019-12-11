#!/bin/bash
#pop=$1
#pop_code_dir=$2

while :
do
    case "$1" in
      --ref) #path to Native American .vcf reference file (see RFMix output)
	        ref="$2"  
	        shift 2
	        ;;
      --query) #path to European .vcf reference file (see RFMix output)
         	query="$2"
	        shift 2
	        ;;
      --pop) #pop code file input into admixture analysis
      	 	pop="$2"
	        shift 2
	        ;;
      --out) #output prefix
          out="$2"
	        shift 2
	        ;;
      --pos) #output prefix
          pos="$2"
                shift 2
                ;;
	     *)  # No more options
          shift
	        break
	        ;;
     esac #CEU vcf, NAT vcf if it exists, and YRI vcf if it exists
done


echo "extracting new references from admixture simulation"
awk -v p=${out:=./LAMP} '{print $1 > p $2 "_reference.txt"}' ${pop}
#direction_of_admixture=$(ls ${out}*_reference.txt | wc -l)
for i in ${out}*_reference.txt
do
	bcftools view -S ${i::-4}.txt --force-samples -o ${i::-4}.vcf ${ref} #extract reference pops inds (not founders)
done

echo "creating haplotypes"
bcftools convert --hapsample --vcf-ids ${query} -o ${out}admixed.haps #weird haplotype format; convert to LAMP-LD format externally
for i in ${out}*_reference.txt
do
	bcftools convert --hapsample --vcf-ids ${i::-4}.vcf -o ${i::-4}.haps
done

echo "converting haplotypes to LAMP format"
for i in ${out}*.haps.hap.gz
do
	if [ ! -s ${i} ]
	then
		rm ${i}
		continue
	fi
	echo $i
	if [[ ${i} == "${out}admixed.haps.hap.gz" ]]
	then
		/usr/bin/python2 /home/rschubert1/scratch/software/Local_Ancestry/class_project_scripts/03a2_bcftools_haps_to_LAMP-LD_haps.py --hap.gz ${i} --haps ${i::-7} --adm #admixed haplotypes are special for some reason
		sed -i -e "s/\\*//g" ${i::-7}
	else	
		/usr/bin/python2 /home/rschubert1/scratch/software/Local_Ancestry/class_project_scripts/03a2_bcftools_haps_to_LAMP-LD_haps.py --hap.gz ${i} --haps ${i::-7}
		sed -i -e "s/\\*//g" ${i::-7}
	fi
done

echo "performing lamp estimation"
direction_of_admixture=$(ls ${out}*_reference.haps | wc -l)
if [ ${direction_of_admixture} == 3 ]
then
	echo "running three way estimation"
	~/scratch/time /home/rschubert1/scratch/software/LAMPLD-v1.0/bin/unolanc 300 15 ${pos} ${out}CEU_reference.haps ${out}YRI_reference.haps ${out}NAT_reference.haps ${out}admixed.haps ${out}admixed_est.txt #version of LAMP-LD for 2-way admixture
elif [ ${direction_of_admixture} == 2 ]
then
	echo "running two-way estimation"
	if [ -e ${out}NAT_reference.haps ]
	then
		~/scratch/time /home/rschubert1/scratch/software/LAMPLD-v1.0/bin/unolanc2way 300 15 ${pos} ${out}CEU_reference.haps ${out}NAT_reference.haps ${out}admixed.haps ${out}admixed_est.txt
	else
		~/scratch/time /home/rschubert1/scratch/software/LAMPLD-v1.0/bin/unolanc2way 300 15 ${pos} ${out}CEU_reference.haps ${out}YRI_reference.haps ${out}admixed.haps ${out}admixed_est.txt
	fi
fi
 #use default window size of 300 and default number of states HMM 15
perl /home/rschubert1/scratch/software/LAMPLD-v1.0/convertLAMPLDout.pl ${out}admixed_est.txt ${out}admixed_est.long #convert from compact to long format
