#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_MOSAIC_adm

#~/scratch/software/Local_Ancestry/06_MOSAIC.sh \
#--ancestries 2 \
#--query /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.vcf \
#--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.bcf \
#--geneticmap /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned_genetic_map_intersection.txt \
#--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/AFA_11g.ref.map \
#--generations 7 \
#--chrom 22 \
#--outdir /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/MOSAIC/ \
#--prefix AFA_two_way \
#--ncores 1

~/scratch/software/Local_Ancestry/06_MOSAIC.sh \
--ancestries 2 \
--query /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.vcf \
--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.bcf \
--geneticmap /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned_genetic_map_intersection.txt \
--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/his_two_way.ref.map \
--generations 11 \
--chrom 22 \
--outdir /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/MOSAIC/ \
--prefix HIS_two_way \
--ncores 1

#~/scratch/software/Local_Ancestry/06_MOSAIC.sh \
#--ancestries 3 \
#--query /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.vcf \
#--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.bcf \
#--geneticmap /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned_genetic_map_intersection.txt \
#--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/his_three_way.ref.map \
#--generations 11 \
#--chrom 22 \
#--outdir /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/MOSAIC \
#--prefix HIS_three_way \
#--ncores 1
