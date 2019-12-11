#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_LampLD_amd

#rm /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/LAMPLD/*
#/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/03_LAMP_LD.sh \
#--query /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.vcf \
#--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.bcf \
#--pos /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned_pos_list.txt \
#--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/AFA_11g.ref.map \
#--out /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/LAMPLD/AFA

rm /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/LAMPLD/*
/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/03_LAMP_LD.sh \
--query /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.vcf \
--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.bcf \
--pos /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned_pos_list.txt \
--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/his_two_way.ref.map \
--out /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/LAMPLD/HIS_two_way

rm /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/LAMPLD/*
/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/03_LAMP_LD.sh \
--query /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.vcf \
--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.bcf \
--pos /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned_pos_list.txt \
--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/his_three_way.ref.map \
--out /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/LAMPLD/HIS_threeway
