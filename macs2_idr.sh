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
#$ -l h_rt=24:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

basedir=$1
sample=$2
tmp=$3
control=$4


workdir=$tmp/$basedir/$sample/
crtools=~/tools/cutruntools/
logdir=$workdir/logs
aligndir=$workdir/aligndir_crtools

mkdir $tmp/$basedir/"$sample"_vs_merged_"$control"
outdir=$tmp/$basedir/"$sample"_vs_merged_"$control"/MACS2

mkdir $outdir

controldir=$tmp/$control/


macs2 callpeak -t $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam -c $controldir/"$control"_120bp_merged.bam -g mm -f BAMPE -n "$sample"_vs_merged_"$control"_dupmark_idr --outdir $outdir -p 1e-3 -B --keep-dup all 2> $logdir/"$sample"_vs_merged_"$control"_dupmark_120bp_idr.macs2.txt

sort -k8,8nr $outdir/"$sample"_vs_merged_"$control"_dupmark_idr_peaks.narrowPeak > $outdir/"$sample"_vs_merged_"$control"_dupmark_sortidr_peaks.narrowPeak 


