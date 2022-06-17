#!/bin/bash                         #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                     #-- the shell for the job
#$ -o /wynton/group/reiter/lauren/CR_log/                        #-- output directory (fill in)
#$ -e /wynton/group/reiter/lauren/CR_log/                        #-- error directory (fill in)
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=10G
#$ -l scratch=10G
#$ -l h_rt=04:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

cd /wynton/group/reiter/lauren/deeptool-env/
. bin/activate

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

ref=/wynton/home/reiter/lb13/resources/mm10/fasta/default/mm10.fa
bed_targ=$1
dir="${bed_targ%/*}"
INPUTBEDFILE="${bed_targ##*/}"
out_fasta=$dir/"${INPUTBEDFILE%.*}".fa


bedtools getfasta -fi $ref -bed $bed_targ -fo $out_fasta
