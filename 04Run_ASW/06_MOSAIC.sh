#!/bin/bash
outDirDefault=.
outDefault=pop
numAncestriesDefault=2
numGenDefault=7
nCoresDefault=0
while :
do
    case "$1" in
      --ancestries | -a) #path to Native American .vcf reference file (see RFMix output)
                numAncestries="$2"
                shift 2
                ;;
      --ref) #path to Native American .vcf reference file (see RFMix output)
	        ref="$2"  
	        shift 2
	        ;;
      --query) #path to European .vcf reference file (see RFMix output)
         	vcfFile="$2"
	        shift 2
	        ;;
      --chrom) #which chromosome are you doing 
                chrom="$2"
                shift 2
                ;;
      --pop) #population code file
                pop="$2"
                shift 2
                ;;
      --prefix) #output prefix - should be the code of the study population
                out="$2"
                shift 2
                ;;
      --outdir) #make directory and place outputs there, else places in current directory
                outDir="$2"
                shift 2
                ;;
      --help | -h)
		echo "--vcf : vcf file containing admixed genotypes. REQUIRED."
		echo "--pop : population code - determines prefix of output"
		echo "--outdir : make directory and place outputs there, else places in current directory"
		echo "--geneticmap : genetic map file for chr22 in corresponding build"
                exit 0
                ;;
      --geneticmap) #genetic map file for chr22 in corresponding build
                mapFile="$2"
		shift 2
                ;;
      --generations | -g) #genetic map file for chr22 in corresponding build
                numGen="$2"
                shift 2
                ;;
      --ncores | -n)
                nCores="$2"
                shift 2
                ;;
      -*) #unknown
                echo "Error: Unknown option: $1" >&2
                echo "./vcf_lift.sh --help or ./vcf_lift.sh -h for option help"
                exit 1
                ;;
      *)  # No more options
                shift
                break
                ;;
     esac
done

transpose() {
awk '
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' "$1"
}
echo "${outDir:=$outDirDefault}"

if [ ! -z "${outDir:=$outDirDefault}" ] && [ ! -d "${outDir:=$outDirDefault}" ]
then
        mkdir -p "${outDir}"
fi

if [ ! -z "${outDir}"/intermediate ] && [ ! -d "${outDir}"/intermediate ]
then
        mkdir "${outDir}"/intermediate
fi

echo "constructing admixed files"
echo "contstructing genofile"
~/bin/bcftools convert --hapsample --vcf-ids ${vcfFile} -o ${outDir}/intermediate/${out}_${chrom}.haps
zcat ${outDir}/intermediate/${out}_${chrom}.haps.hap.gz | cut -f 6- -d " " | sed "s/ //g" > ${outDir}/intermediate/${out}genofile.${chrom}


echo "constructing snp file"
sort -k 1 -u ${mapFile} > ${outDir}/intermediate/${out}_tmp_map
/home/rschubert1/scratch/software/plink_bin/plink --vcf ${vcfFile} --update-cm ${outDir}/intermediate/${out}_tmp_map 3 1 --make-just-bim --out ${outDir}/intermediate/${out}_${chrom}_cm
awk '{print "\t" $2 " " $1 " " $3 " " $4 " " $5 " " $6}' ${outDir}/intermediate/${out}_${chrom}_cm.bim | sort -g -k 4 > ${outDir}/intermediate/snpfile.${chrom}

echo "constructing rates file"
nsites=$( cat ${mapFile}  | wc -l )
echo ":sites:${nsites}" > ${outDir}/intermediate/rates.${chrom}
cat ${mapFile} | awk '{print $2 " " $3}' | transpose >> ${outDir}/intermediate/rates.${chrom}

echo "constructing reference files"

awk -v p=${outDir}/intermediate/ '{print $1 > p $2 "_reference.txt"}' ${pop}

for i in ${outDir}/intermediate/*_reference.txt
do
	~/bin/bcftools view -S ${i} --force-samples -o ${i::-4}.vcf ${ref} #extract reference pops inds (not founders)
done

for i in ${outDir}/intermediate/*_reference.vcf
do
	~/bin/bcftools convert --hapsample --vcf-ids ${i::-4}.vcf -o ${i::-4}.haps
	zcat ${i::-4}.haps.hap.gz | cut -f 6- -d " " | sed "s/ //g" > ${i::-14}genofile.${chrom}
done

echo "constructing samples file"
tail -n +3 ${outDir}/intermediate/${out}_${chrom}.haps.sample | awk -v pop=${out} '{print pop " " $1}' > ${outDir}/intermediate/sample.names
awk  '{print $2 " " $1}' ${pop} >> ${outDir}/intermediate/sample.names
cd ${outDir}
echo "running mosaic using:"
echo "target ${out}"
echo "data ${outDir}/intermediate/"
echo "${chrom}"
echo "nanc ${numAncestries:=$numAncestriesDefault}"
echo "ngen ${numGen:=$numGenDefault}"
( /home/rschubert1/scratch/time --verbose Rscript /home/rschubert1/scratch/software/MOSAIC/mosaic.R ${out} ${outDir}/intermediate/ -c ${chrom}:${chrom} -a "${numAncestries:=$numAncestriesDefault}" -m ${nCores:=$nCoresDefault} --gens "${numGen:=$numGenDefault}") 2> ${outDir}/${out}_benchmarking.txt

