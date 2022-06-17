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
tmp=$2

script_dir=/wynton/group/reiter/lauren/cutandrun/
workdir=/wynton/group/reiter/lauren/

>&2 echo $tmp

mkdir $tmp

cd $tmp

cp $file .

################## GET FRAGMENT LENGTH  ##################3
while IFS=, read project sample R1 R2 control;do
	qsub -N fraglength_"$project"_"$sample" $script_dir/getFragment_length.sh $project $sample $tmp
done < $file


