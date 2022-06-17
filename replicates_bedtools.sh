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

proj1=$1
proj2=$2
sample=$3

basedir=/wynton/group/reiter/lauren/cr_test3
narpeak1=$basedir/$proj1/$sample/MACS2/"$sample"_vs_merged_Mycl_CR2_Mycl_CR3_Mycl_IgG_dupmark_peaks.narrowPeak
narpeak2=$basedir/$proj2/$sample/MACS2/"$sample"_vs_merged_Mycl_CR2_Mycl_CR3_Mycl_IgG_dupmark_peaks.narrowPeak

projdir="$basedir"/"$proj1"_"$proj2"
firstdir="$basedir"/"$proj1"_"$proj2"/"$sample"_vs_Mycl_IgG

mkdir $projdir
mkdir $firstdir

bedtools intersect \
	-a "$narpeak1" \
	-b "$narpeak2" \
	-wo > $firstdir/"$proj1"_vs_"$proj2"_"$sample"_merged_Mycl_IgG_bedtools_intersect.bed



