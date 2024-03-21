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

file=$1
tmp=$2

script_dir=/wynton/group/reiter/lauren/cutandrun/
workdir=/wynton/group/reiter/lauren/

>&2 echo $tmp

mkdir $tmp

cd $tmp

cp $file .
################# TRIMMING ############

while IFS=, read project sample1 sample2 dups;do
        if [ "$dups" == "nodups" ]; then

        >&2 echo "running '$sample1'_vs_'$sample2' analysis using dedup peaks"
		basedir=/wynton/group/reiter/lauren/$project
		peak1=$basedir/"$sample1"/MACS2/"$sample1"_nodups_peaks.narrowPeak
		peak2=$basedir/"$sample2"/MACS2/"$sample2"_nodups_peaks.narrowPeak
                qsub -N find_common_"$sample1"_"$sample2" $script_dir/find_unique_common_peaks.sh $basedir $peak1 $peak2
        else

                >&2 echo "running '$sample1'_vs_'$sample2' analysis using dupmarked peaks"
                basedir=/wynton/group/reiter/lauren/$project
		peak1=$basedir/"$sample1"/MACS2/"$sample1"_dupmark_peaks.narrowPeak
                peak2=$basedir/"$sample2"/MACS2/"$sample2"_dupmark_peaks.narrowPeak
                qsub -N find_common_"$sample1"_"$sample2" $script_dir/find_unique_common_peaks.sh $basedir $peak1 $peak2

        fi
done < $file
