#!/bin/env bash
#!/bin/bash                         #-- what is the language of this shell

#                                  #-- Any line that starts with #$ is an instruction to SGE

#$ -S /bin/bash                     #-- the shell for the job

#$ -o /wynton/group/reiter/lauren/log_homer                        #-- output directory (fill in)

#$ -e /wynton/group/reiter/lauren/log_homer                        #-- error directory (fill in)

#$ -cwd                            #-- tell the job that it should start in your working directory

#$ -r y                            #-- tell the system that if a job crashes, it should be restarted

#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined

#$ -l mem_free=10G

#$ -l scratch=20G

#$ -l h_rt=6:00:00

#$ -pe smp 4

#$ -m ea                           #--email when done

#$ -M Lauren.Byrnes@ucsf.edu        #--email

INPUTBED=$1
DIRECTORY="${INPUTBED%/*}"
INPUTBEDFILE="${INPUTBED##*/}"
GENOME=$2
motif_num=$3

motif="$DIRECTORY"/"${INPUTBEDFILE%.*}"_50bp/homerResults/"$motif_num".motif

if [ "$GENOME" == "mm10" ]; then
	GENOME_LOC=/wynton/group/reiter/lauren/homer/data/genomes/mm10
else
	GENOME_LOC=$GENOME
fi
echo $GENOME_LOC
echo $DIRECTORY


annotatePeaks.pl $INPUTBED $GENOME_LOC -m $motif >"$DIRECTORY"/"${INPUTBEDFILE%.*}"_"$motif_num".bed
