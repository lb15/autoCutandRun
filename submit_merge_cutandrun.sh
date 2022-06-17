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
tmp=/wynton/scratch/lb13/cr_test3

>&2 echo $tmp

mkdir $tmp

cd $tmp

cp $file .


################# MAKE SEACR BEDGRAPHS ######################
while IFS=, read project1 project2 sample control;do
	>&2 echo "Making merged bedgraph files"
	qsub -N merge_bedgraphs_"$sample" $script_dir/merge_bedgraphs.sh $project1 $project2 $sample $tmp
done < $file

################## SEACR PEAK CALLING #######################

while IFS=, read project1 project2 sample control;do
	
	if [ "$control" != "none" ]; then
		>&2 echo "Running peaking calling with control samples"
		qsub -hold_jid "merge_bedgraphs*" -N merge_seacr_"$sample" $script_dir/merge_seacr.sh "$project1" "$project2" $sample $tmp $control
	else
		>&2 echo "Running peak calling without control samples"
		qsub -hold_jid "merge_bedgraphs*" -N merge_seacr_"$sample" $script_dir/merge_seacr.sh "$project1" "$project2" $sample $tmp
	fi
done < $file

###################### MERGING BAMS FOR MACS2 #################

while IFS=, read project1 project2 sample control;do
	>&2 echo "Merging BAMs for MACS2"
	qsub -N merge_bam_"$sample" $script_dir/merge_bam.sh $project1 $project2 $sample $tmp
done < $file

#################### MACS2 ##################################

while IFS=, read project1 project2 sample control;do
	if [ "$control" != "none" ]; then
		>&2 echo "Running MACS2 on merged bams with control"
		qsub -hold_jid "merge_bam*" -N merge_macs_"$sample" $script_dir/merge_macs2.sh $project1 $project2 $sample $tmp $control
	else
		>&2 echo "Running MACS2 on merged bams without control"
		qsub -hold_jid "merge_bam*" -N merge_macs_"$sample" $script_dir/merge_macs2.sh $project1 $project2 $sample $tmp
	fi
done < $file

################## CHIPSEEKER ANNOTATION #####################3
