#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_MOSAIC_ASW
rm -r /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/Mosaic/*
~/scratch/software/Local_Ancestry/06_MOSAIC.sh \
--ancestries 2 \
--query /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/ASW_thinned.recode.vcf \
--ref /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/chr22_thinned_two_way_ref.recode.vcf \
--geneticmap /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/ASW_genetic_map_intersection.txt \
--pop /home/rschubert1/data/Local_ancestry_project/1000G_references/2_way_afa_pop_code.txt \
--generations 7 \
--chrom 22 \
--outdir /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/Mosaic/ \
--prefix ASW \
--ncores 1

