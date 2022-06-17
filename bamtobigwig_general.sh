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
#$ -l h_rt=24:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

cd /wynton/group/reiter/lauren/deeptool-env/
. bin/activate

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

dir=$1
bam=$2
out=$3
scale=$4

bamCoverage -b $dir/$bam -o $dir/$out \
	--normalizeUsing RPGC \
	--effectiveGenomeSize 2652783500 \
	--extendReads \
	--binSize 10 \
	--scaleFactor $scale



