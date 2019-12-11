#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_Elai_ASW

#run ELAI

#/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/05_ELAI.sh \
#--CEU /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/RFMix/CEU_AFA_11g.ref.map_ref.vcf.gz \
#--YRI /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/RFMix/YRI_AFA_11g.ref.map_ref.vcf.gz \
#--adm /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/RFMix/AFA_11g.ref.map.vcf.gz \
#--out /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/ELAI/AFA_two_way

/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/05_ELAI.sh \
--CEU /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/RFMix/CEU_his_two_way.ref.map_ref.vcf.gz \
--NAT /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/RFMix/NAT_his_two_way.ref.map_ref.vcf.gz \
--adm /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/RFMix/his_two_way.ref.map.vcf.gz \
--out /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/ELAI/his_two_way 

#/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/05_ELAI.sh \
#--CEU /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/RFMix/CEU_his_three_way.ref.map_ref.vcf.gz \
#--YRI /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/RFMix/YRI_his_three_way.ref.map_ref.vcf.gz \
#--NAT /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/RFMix/NAT_his_three_way.ref.map_ref.vcf.gz \
#--adm /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/RFMix/his_three_way.ref.map.vcf.gz \
#--out /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/ELAI/his_three_way
