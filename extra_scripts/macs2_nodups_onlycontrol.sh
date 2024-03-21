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
#$ -l h_rt=06:00:00
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
outdir=$workdir/MACS2
dupmarkdir=$workdir/dupmarked
dedupdir=$workdir/dedup

mkdir $logdir
mkdir $tmp/$basedir/"$sample"_vs_"$control"
macsdir=$tmp/$basedir/"$sample"_vs_"$control"/MACS2
mkdir $macsdir
controldir=$tmp/$basedir/$control

macs2 callpeak -t $workdir/dedup.120bp/"$sample"_henikoff_dedup_120bp.bam -c $controldir/dedup.120bp/"$control"_henikoff_dedup_120bp.bam -g mm -f BAMPE -n "$sample"_vs_"$control"_nodups --outdir $macsdir -q 0.01 -B --SPMR --keep-dup all 2> $logdir/"$sample"_vs_"$control"_nodups_120bp.macs2.txt

source /wynton/home/reiter/lb13/miniconda3/bin/activate base

sort -k1,1 -k2,2n $macsdir/"$sample"_vs_"$control"_nodups_treat_pileup.bdg > $macsdir/"$sample"_vs_"$control"_nodups.sort.bdg
bedGraphToBigWig $macsdir/"$sample"_vs_"$control"_nodups.sort.bdg $crtools/assemblies/chrom.mm10/mm10.chrom.sizes $macsdir/"$sample"_vs_"$control"_nodups.bw



