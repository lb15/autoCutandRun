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
################# TRIMMING ############

while IFS=, read project sample R1 R2 control;do
	fastq1=$workdir/$project/"$sample"_"$R1"
	fastq2=$workdir/$project/"$sample"_"$R2"
	mkdir $project
	#cp $fastq1 $project/
	#cp $fastq2 $project/
	qsub -N trim_"$project"_"$sample" $script_dir/trim.sh $project $sample "$fastq1" "$fastq2" $tmp
done < $file

################## ALIGNMENT ##################3
while IFS=, read project sample R1 R2 control;do
	qsub -hold_jid trim_"$project"_"$sample" -N align_"$project"_"$sample" $script_dir/align_dup_filter.sh $project $sample $tmp
done < $file


################ BAMTOBIGWIG #################
while IFS=, read project sample R1 R2 control;do
	qsub -hold_jid align_"$project"_"$sample" -N bamtobigwig_"$project"_"$sample" $script_dir/bamtobigwig_RPGC.sh $project $sample $tmp
done < $file

################### ECOLI ALIGNMENT ##################
while IFS=, read project sample R1 R2 control;do
	qsub -hold_jid trim_"$project"_"$sample" -N ecoli_"$project"_"$sample" $script_dir/align_ecoli2.sh $project $sample $tmp
done < $file


################# SPIKE-IN ##########################3
while IFS=, read project sample R1 R2 control;do
	qsub -hold_jid ecoli_"$project"_"$sample" -N spikein_"$project"_"$sample" $script_dir/getSpikeIn.sh $sample $project $tmp
done < $file

################3 CONVERT FILES and SPIKE-IN CALIBRATION ####################
while IFS=, read project sample R1 R2 control;do
	qsub -hold_jid spikein_"$project"_"$sample",align_"$project"_"$sample" -N calibrate_"$project"_"$sample" $script_dir/calibrate_bedgraph.sh $sample $project $tmp
done < $file


################## PEAK CALLING #######################

while IFS=, read project sample R1 R2 control;do
	
	if [ "$control" != "none" ]; then
		>&2 echo "Running peaking calling with control samples"
		qsub -hold_jid "align_*" -N macs2_"$project"_"$sample" $script_dir/macs2_peaks.sh $project $sample $tmp $control
		qsub -hold_jid macs2_"$project"_"$sample" -N chpskr_"$project"_"$sample" $script_dir/chpskr_v2.sh $project $sample $tmp $control	

		#qsub -hold_jid macs2_"$project"_"$sample" -N chpskr_"$project"_"$sample" $script_dir/chpskr.sh $project $sample $tmp
		#qsub -hold_jid macs2_"$project"_"$sample" -N chpskr_"$project"_"$sample"_"$control" $script_dir/chpskr.sh $project "$sample"_vs_"$control" $tmp
		#qsub -hold_jid calibrate_"$project"_"$sample" -N seacr_"$project"_"$sample" $script_dir/seacr.sh $project $sample $tmp $control
	else
		>&2 echo "Running peak calling without control samples"
		#qsub -hold_jid calibrate_"$project"_"$sample" -N seacr_"$project"_"$sample" $script_dir/seacr.sh $project $sample $tmp 
		qsub -hold_jid align_"$project"_"$sample" -N macs2_"$project"_"$sample" $script_dir/macs2_peaks.sh $project $sample $tmp
                qsub -hold_jid macs2_"$project"_"$sample" -N chpskr_"$project"_"$sample" $script_dir/chpskr_v2.sh $project $sample $tmp
	fi
done < $file


############### HOMER MOTIF FINDING #################

genome=/wynton/group/reiter/lauren/homer/data/genomes/mm10

while IFS=, read project sample R1 R2 control;do
        if [ "$control" != "none" ]; then

        >&2 echo "running '$sample'_vs_'$control' analysis"
               
		inputbed=$tmp/$project/$sample/MACS2/"$sample"_dedup_peaks.narrowPeak
                qsub -hold_jid macs2_"$project"_"$sample" -N homer_"$project"_"$sample" $script_dir/homer.sh $inputbed $genome 50

        	inputbed2=$tmp/$project/$sample/MACS2/"$sample"_dupmark_peaks.narrowPeak
                qsub -hold_jid macs2_"$project"_"$sample" -N homer_dups_"$project"_"$sample" $script_dir/homer.sh $inputbed2 $genome 50

                inputbed3=$tmp/$project/"$sample"_vs_"$control"/MACS2/"$sample"_vs_"$control"_dedup_peaks.narrowPeak
                qsub -hold_jid macs2_"$project"_"$sample" -N homer_control_dedup_"$project"_"$sample" $script_dir/homer.sh $inputbed3 $genome 50

		inputbed4=$tmp/$project/"$sample"_vs_"$control"/MACS2/"$sample"_vs_"$control"_dupmark_peaks.narrowPeak
		qsub -hold_jid macs2_"$project"_"$sample" -N homer_control_dupmark_"$project"_"$sample" $script_dir/homer.sh $inputbed4 $genome 50
        else

                >&2 echo "running without control"
                inputbed=$tmp/$project/$sample/MACS2/"$sample"_dedup_peaks.narrowPeak
                qsub -hold_jid macs2_"$project"_"$sample" -N homer_"$project"_"$sample" $script_dir/homer.sh $inputbed $genome 50

                inputbed2=$tmp/$project/$sample/MACS2/"$sample"_dupmark_peaks.narrowPeak
                qsub -hold_jid macs2_"$project"_"$sample" -N homer_dups_"$project"_"$sample" $script_dir/homer.sh $inputbed2 $genome 50

        fi
done < $file


################ GET METRICS AND COPY RESULTS ##################
qsub -hold_jid "calibrate*" -N metrics $script_dir/sub_metrics.sh $file $tmp
#qsub -hold_jid "seacr*","chpskr*" $script_dir/copy.sh $project $tmp

