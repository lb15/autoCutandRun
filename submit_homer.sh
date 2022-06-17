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
