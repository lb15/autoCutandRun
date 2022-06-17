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

project1=$1
project2=$2
sample1=$3
tmp=$4
control=$5

projPath=$tmp/"$proj"/"$sample"
seacr=/wynton/home/reiter/lb13/tools/SEACR_1_3
outdir=$tmp/"$project1"_"$project2"_"$sample1"
seacrdir=$outdir/SEACR
mkdir $seacrdir

controldir=$tmp/"$project1"_"$project2"_"$control"

>&2 echo "Starting SEACR without control"
source $seacr/SEACR_1.3.sh $outdir/"$project1"_"$project2"_"$sample1"_merged.bedgraph 0.01 "norm" "stringent" $seacrdir/"$project1"_"$project2"_"$sample1"_120bp_seacr_top0.01.peaks
source $seacr/SEACR_1.3.sh $outdir/"$project1"_"$project2"_"$sample1"_merged.bedgraph 0.01 "norm" "relaxed" $seacrdir/"$project1"_"$project2"_"$sample1"_120bp_seacr_top0.01.peaks

if [ "$control" == "" ]
then
>&2 echo "No control run"
else
        >&2 echo "Starting control run"

        source $seacr/SEACR_1.3.sh $outdir/"$project1"_"$project2"_"$sample1"_merged.bedgraph $controldir/"$project1"_"$project2"_"$control"_merged.bedgraph "norm" "stringent" $seacrdir/"$project1"_"$project2"_"$sample1"_vs_"$control"_seacr_control.peaks

        source $seacr/SEACR_1.3.sh $outdir/"$project1"_"$project2"_"$sample1"_merged.bedgraph $controldir/"$project1"_"$project2"_"$control"_merged.bedgraph "norm" "relaxed" $seacrdir/"$project1"_"$project2"_"$sample1"_vs_"$control"_seacr_control.peaks

fi


