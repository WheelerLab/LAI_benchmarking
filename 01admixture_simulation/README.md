# Ad-Sim
Pipeline for consistent and standardized simulation of admixed genotypes. Creates simulated genotypes as well as pruned and thinned genotypes for benchmarking at different snp levels.
Based off of the code run by [Angela Andaleon](https://github.com/RyanSchu/Local_Ancestry-3-way-admixture/blob/master/class_project_scripts/02a1_simulate_admixture.sh) which in turn uses the [admixture simulation tool](https://github.com/slowkoni/admixture-simulation) created by the makers of RFMix.

This pipeline has been made mostly to maintain consistency for ease of benchmarking different admixture analysis softwares. Adsim pipeline first creates simulated genotypes using the admixture simulation tool. From there these can be consistently pruned and or thinned as the user desires and as different software demands. This makes it easy to benchmark at different numbers of snps. Note, adsim is designed to prune and thin each input population independently. This results in different snps across each files. That said, it is fairly trivial to analyze them jointly by concatonating vcf files and pruning/thinning from there.

### Data

Pipeline is tested on publicly available data from [1000 genomes](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/)

### Software
* [Admixture simulation tool](https://github.com/slowkoni/admixture-simulation)
* [plink](https://www.cog-genomics.org/plink/1.9/)
* [vcftools](http://vcftools.sourceforge.net/man_latest.html)
* [bcftools](https://samtools.github.io/bcftools/bcftools.html)  
* awk
* sed
* tabix


At testing all software is run on a linux machine running ubuntu
