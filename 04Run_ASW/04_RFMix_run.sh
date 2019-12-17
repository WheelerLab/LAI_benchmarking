#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_RFMix_ASW

rm -r /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/RFMix/*
python /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/04_RFMix_mesa.py \
 --ref_bcf /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/chr22_thinned_two_way_ref.recode.vcf \
 --query_vcf /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/ASW_thinned.recode.vcf \
 --map /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/ASW_genetic_map_intersection.txt \
 --pop /home/rschubert1/data/Local_ancestry_project/1000G_references/2_way_afa_pop_code.txt \
 --tag ASW_results \
 --out /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/RFMix

