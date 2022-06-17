#!/bin/bash                         #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                     #-- the shell for the job
#$ -o /wynton/group/reiter/lauren/CR_log/                        #-- output directory (fill in)
#$ -e /wynton/group/reiter/lauren/CR_log/                        #-- error directory (fill in)
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=50G
#$ -l scratch=10G
#$ -l h_rt=72:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email


module load CBI bedtools2/2.30.0 
module load CBI samtools/1.10
module load CBI picard/2.24.0



peaks=$1
controlpeaks=$2
out=${peaks%/*}
base=${peaks##*/}
filename=${base%.*}
controlbase=${controlpeaks##*/}
controlname=${controlbase%.*}

bedtools subtract -a $peaks -b $controlpeaks -A > "$out"/"$filename"_subtract_"$controlname".bed

