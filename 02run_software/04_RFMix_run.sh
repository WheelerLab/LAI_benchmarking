#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_RFMix_adm_3WAY

#rm /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/RFMix/*
#python /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/04_RFMix_mesa.py \
# --ref_bcf /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.bcf \
# --query_vcf /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.vcf \
# --map /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned_genetic_map_intersection.txt \
# --pop /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/AFA_11g.ref.map \
# --tag AFA_two_way \
# --out /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/RFMix/

#rm /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/RFMix/*
#python /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/04_RFMix_mesa.py \
#--ref_bcf /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.bcf \
#--query_vcf /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.vcf \
#--map /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned_genetic_map_intersection.txt \
#--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/his_two_way.ref.map \
#--tag HIS_two_way \
#--out /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/RFMix/

rm /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/RFMix/*
python /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/04_RFMix_mesa.py \
--ref_bcf /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.bcf \
--query_vcf /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.vcf  \
--map /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned_genetic_map_intersection.txt \
--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/his_three_way.ref.map \
--tag HIS_three_way \
--out /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/RFMix/
