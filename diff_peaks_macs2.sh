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
#$ -l h_rt=04:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

workdir=/wynton/group/reiter/lauren
treat1=$1
treat2=$2

path1=${treat1%/*}
path2=${treat2%/*}

name_tmp1=${treat1##*/}
name_tmp2=${treat2##*/}

sample1=${name_tmp1%_treat*}
sample2=${name_tmp2%_treat*}

outdir="$path1"/"$sample1"_vs_"$sample2"
mkdir $outdir
echo $outdir

contr1="$path1"/"$sample1"_control_lambda.bdg
contr2="$path2"/"$sample2"_control_lambda.bdg

echo $contr1
echo $contr2


macs2 bdgdiff --t1 $treat1 \
	--t2 $treat2 \
	--c1 $contr1 \
	--c2 $contr2 \
	--outdir $outdir \
	-C 2 \
	-o unique_"$sample1".bed unique_"$sample2".bed common_"$sample1"_"$sample2".bed  

cat $outdir/unique_"$sample1".bed $outdir/unique_"$sample2".bed $outdir/common_"$sample1"_"$sample2".bed > $outdir/common_unique_"$sample1"_"$sample2".bed

module load CBI r/4.0
echo "Starting Analysis"

peakfile=$outdir/common_unique_"$sample1"_"$sample2".bed
base=${peakfile##*/}
filename=${base%.*}

script_dir=/wynton/group/reiter/lauren/cutandrun/

Rscript $script_dir/chipseeker_general.R $outdir $peakfile $filename

