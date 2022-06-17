#!/bin/bash                         #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                     #-- the shell for the job
#$ -o /wynton/group/reiter/lauren/CR_log/                         #-- output directory (fill in)
#$ -e /wynton/group/reiter/lauren/CR_log/                        #-- error directory (fill in)
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=50G
#$ -l scratch=10G
#$ -l h_rt=4:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI r/4.0
echo "Starting Analysis"

basedir=$1
sample=$2
tmp=$3

script_dir=/wynton/group/reiter/lauren/cutandrun/

Rscript $script_dir/chipseeker_annotation.R $sample $basedir $tmp

