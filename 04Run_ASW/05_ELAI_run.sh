#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_Elai_ASW

#run ELAI
#MXL
/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/05_ELAI.sh \
--CEU /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/RFMix/CEU_2_way_afa_pop_code_ref.vcf.gz \
--YRI /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/RFMix/YRI_2_way_afa_pop_code_ref.vcf.gz  \
--adm /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/RFMix/2_way_afa_pop_code.vcf.gz \
--out /home/rschubert1/data/Local_ancestry_project/paper_run_ASW/two_way/Elai/ASW
