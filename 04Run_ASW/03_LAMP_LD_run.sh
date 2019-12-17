#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_LampLD_ASW

rm -r /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/LampLD/*
/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/03_LAMP_LD.sh \
--query /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/ASW_thinned.recode.vcf \
--ref /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/chr22_thinned_two_way_ref.recode.vcf \
--pos /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/ASW_pos_list.intersection.txt \
--pop /home/rschubert1/data/Local_ancestry_project/1000G_references/2_way_afa_pop_code.txt \
--out /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/LampLD/ASW
