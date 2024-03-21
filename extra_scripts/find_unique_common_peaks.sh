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

base=$1
peaks1=$2
peaks2=$3

peaks1_base=${peaks1##*/}
peaks2_base=${peaks2##*/}

basedir=$base/"${peaks1_base%.*}"_vs_"${peaks2_base%.*}"
mkdir $basedir
##### common peaks #####
bedtools intersect \
	-a $peaks1 \
	-b $peaks2 \
	-wa > $basedir/"${peaks1_base%.*}"_intersect_"${peaks2_base%.*}".bed
### unique peak1 #####
bedtools subtract \
	-a $peaks1 \
	-b $peaks2 \
	-A > "$basedir"/"${peaks1_base%.*}"_subtract_"${peaks2_base%.*}".bed

### unique peak2 #####
bedtools subtract \
        -a $peaks2 \
        -b $peaks1 \
        -A > "$basedir"/"${peaks2_base%.*}"_subtract_"${peaks1_base%.*}".bed

add=common
sed -i "s/$/\t$add/" $basedir/"${peaks1_base%.*}"_intersect_"${peaks2_base%.*}".bed

diff1=unique_"${peaks1_base%.*}"
sed -i "s/$/\t$diff1/" $basedir/"${peaks1_base%.*}"_subtract_"${peaks2_base%.*}".bed

diff2=unique_"${peaks2_base%.*}"
sed -i "s/$/\t$diff2/" $basedir/"${peaks2_base%.*}"_subtract_"${peaks1_base%.*}".bed

cat $basedir/"${peaks1_base%.*}"_intersect_"${peaks2_base%.*}".bed $basedir/"${peaks1_base%.*}"_subtract_"${peaks2_base%.*}".bed $basedir/"${peaks2_base%.*}"_subtract_"${peaks1_base%.*}".bed > $basedir/common_unique_"${peaks1_base%.*}"_"${peaks2_base%.*}".bed

##### annotation

script_dir=/wynton/group/reiter/lauren/cutandrun
peakfile=$basedir/common_unique_"${peaks1_base%.*}"_"${peaks2_base%.*}".bed

qsub -N common_unique_"${peaks1_base%.*}"_"${peaks2_base%.*}" $script_dir/chpskr_general.sh $peakfile $basedir

#Rscript $script_dir/chipseeker_general.R $basedir $peakfile common_unique_"${peaks1_base%.*}"_"${peaks2_base%.*}"

#Rscript $script_dir/chipseeker_general.R $basedir "${peaks1_base%.*}"_intersect_"${peaks2_base%.*}".bed common_"${peaks1_base%.*}"_"${peaks2_base%.*}"

#Rscript $script_dir/chipseeker_general.R $basedir $basedir/"${peaks1_base%.*}"_subtract_"${peaks2_base%.*}".bed unique_"${peaks1_base%.*}"

#Rscript $script_dir/chipseeker_general.R $basedir $basedir/"${peaks2_base%.*}"_subtract_"${peaks1_base%.*}".bed unique_"${peaks2_base%.*}"

##### homer peak finding

qsub /wynton/group/reiter/lauren/cutandrun/homer.sh $basedir/"${peaks1_base%.*}"_intersect_"${peaks2_base%.*}".bed mm10 50
qsub /wynton/group/reiter/lauren/cutandrun/homer.sh $basedir/"${peaks1_base%.*}"_subtract_"${peaks2_base%.*}".bed mm10 50
qsub /wynton/group/reiter/lauren/cutandrun/homer.sh $basedir/"${peaks2_base%.*}"_subtract_"${peaks1_base%.*}".bed mm10 50

##### venn diagram making ####

qsub -hold_jid common_unique_"${peaks1_base%.*}"_"${peaks2_base%.*}" -N venn_diag $script_dir/submit_venn.sh $basedir/common_unique_"${peaks1_base%.*}"_"${peaks2_base%.*}"_chipseeker_peakannotations.csv

#Rscript $script_dir/make_venn_diagram.R $basedir/common_unique_"${peaks1_base%.*}"_"${peaks2_base%.*}"_chipseeker_peakannotations.csv $basedir "${peaks1_base%.*}"_"${peaks2_base%.*}"
