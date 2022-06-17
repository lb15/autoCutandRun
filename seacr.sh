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

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

proj=$1
sample=$2
tmp=$3
control=$4

projPath=$tmp/"$proj"/"$sample"
seacr=/wynton/home/reiter/lb13/tools/SEACR_1_3
seacrdir=$projPath/SEACR

mkdir $seacrdir

>&2 echo "Starting SEACR without control"
source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments_normalized.bedgraph 0.01 "non" "stringent" $seacrdir/"$sample"_120bp_seacr_top0.01_norm.peaks
source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments_normalized.bedgraph 0.01 "non" "relaxed" $seacrdir/"$sample"_120bp_seacr_top0.01_norm.peaks
source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments.bedgraph 0.01 "norm" "stringent" $seacrdir/"$sample"_120bp_seacr_top0.01.peaks
source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments.bedgraph 0.01 "norm" "relaxed" $seacrdir/"$sample"_120bp_seacr_top0.01.peaks

if [ "$control" == "" ]
then
	>&2 echo "No control run"
else
	>&2 echo "Starting SEACR with control:"
	controldir=$tmp/$proj/$control
	>&2 echo $control
	>&2 echo $controldir	
	source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments_normalized.bedgraph $controldir/dup.marked.120bp/"$control"_henikoff_dupmark_120bp_fragments_normalized.bedgraph "non" "stringent" $seacrdir/"$sample"_seacr_control.peaks

	source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments_normalized.bedgraph $controldir/dup.marked.120bp/"$control"_henikoff_dupmark_120bp_fragments_normalized.bedgraph "non" "relaxed" $seacrdir/"$sample"_seacr_control.peaks

	source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments.bedgraph $controldir/dup.marked.120bp/"$control"_henikoff_dupmark_120bp_fragments.bedgraph "norm" "stringent" $seacrdir/"$sample"_seacr_control.peaks

        source $seacr/SEACR_1.3.sh $projPath/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_fragments.bedgraph $controldir/dup.marked.120bp/"$control"_henikoff_dupmark_120bp_fragments.bedgraph "norm" "relaxed" $seacrdir/"$sample"_seacr_control.peaks
fi







