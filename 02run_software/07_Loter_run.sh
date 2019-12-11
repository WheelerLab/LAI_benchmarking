#!/bin/bash
#$ -S /bin/bash
#$ -pe mpi 1
#$ -N run_Loter_adm

/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/07_Loter.sh \
--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.bcf \
--query /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/thin_thinned.recode.vcf \
--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/AFA_11g.ref.map \
--out /home/rschubert1/data/Local_ancestry_project/redoancestry/afatwoway/Loter/AFA_two_way

/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/07_Loter.sh \
--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.bcf \
--query /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/thin_thinned.recode.vcf \
--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/his_two_way.ref.map \
--out /home/rschubert1/data/Local_ancestry_project/redoancestry/histwoway/Loter/HIS_two_way

/home/rschubert1/data/Local_ancestry_project/paper_run_ASW/run_software/07_Loter.sh \
--ref /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.bcf \
--query /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/thin_thinned.recode.vcf \
--pop /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/his_three_way.ref.map \
--out /home/rschubert1/data/Local_ancestry_project/redoancestry/threeway/Loter/HIS_three_way
