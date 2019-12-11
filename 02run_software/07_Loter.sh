#!/bin/bash
outDirDefault=.
outDefault=pop
#numAncestriesDefault=2
#numGenDefault=7
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
      --pop) #population code file. First column sample ids. Second column population codes
                pop="$2"
                shift 2
                ;;
      --out) #as in plink prefix of output including optional path specification
                outDir="$2"
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

echo "creating reference vcfs"
awk -v o=${outDir:=$outDirDefault} '{print $1 > o $2 "_samples.txt"}' ${pop}

for i in ${outDir}*_samples.txt
do
	bcftools view -S ${i} ${ref} -o ${i::-12}_ref.vcf
done

(/usr/bin/time -v -o ${outDir}_benchmarking.txt loter_cli -r ${outDir}*_ref.vcf -a ${query} -f vcf -o ${outDir}_results.txt -n 1 -v)
(/usr/bin/time -v -o ${outDir}_pc_benchmarking.txt loter_cli -pc -r ${outDir}*_ref.vcf -a ${query} -f vcf -o ${outDir}_results.txt -n 1 -v)
