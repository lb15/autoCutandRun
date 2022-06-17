#!/bin/bash                         #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                     #-- the shell for the job
#$ -o /wynton/group/reiter/lauren/CR_log/                         #-- output directory (fill in)
#$ -e /wynton/group/reiter/lauren/CR_log/                        #-- error directory (fill in)
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=10G
#$ -l scratch=10G
#$ -l h_rt=06:00:00
##$ -m ea                           #--email when done
##$-M Lauren.Byrnes@ucsf.edu        #--email

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI fastqc
file=$1

workdir=/wynton/group/reiter/lauren/

################# TRIMMING ############

while IFS=, read project sample R1 R2 control;do
	cd "$workdir"/"$project"/
	fastqc "$sample"_"$R1" "$sample"_"$R2"

done < $file

