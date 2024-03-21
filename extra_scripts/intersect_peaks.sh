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
#$ -l h_rt=24:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email


module load CBI bedtools2/2.30.0


peaks1=$1
peaks2=$2
basedir=$3


peaks1_base=${peaks1##*/}
peaks2_base=${peaks2##*/}

bedtools intersect \
	-a $peaks1 \
	-b $peaks2 \
	-wo > $basedir/"${peaks1_base%.*}"_intersect_"${peaks2_base%.*}".bed

