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

echo "Starting Analysis"

file=$1

script_dir=/wynton/group/reiter/lauren/cutandrun/
workdir=/wynton/group/reiter/lauren/
tmp=$2

>&2 echo $tmp

mkdir $tmp

cd $tmp

################## PEAK CALLING #######################

while IFS=, read project sample R1 R2 control;do

        if [ "$control" != "none" ]; then
                >&2 echo "Running peaking calling with control samples"
                qsub -N chpskr_"$project"_"$sample" $script_dir/chpskr_v2.sh $project $sample $tmp
                qsub -N chpskr_"$project"_"$sample"_"$control" $script_dir/chpskr_v2.sh $project "$sample"_vs_"$control" $tmp
        else
                >&2 echo "Running peak calling without control samples"
                qsub -N chpskr_"$project"_"$sample" $script_dir/chpskr_v2.sh $project $sample $tmp
        fi
done < $file
