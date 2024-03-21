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
#$ -l h_rt=72:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI bedtools2/2.30.0 
module load CBI samtools/1.10
module load CBI picard/2.24.0

## create bed files
## merge bed files
## call SEACR files
## compute overlap of indivudal bam files

project1=$1
project2=$2
sample1=$3
tmp=$4
control=$5

crtools=~/tools/cutruntools/

outdir=$tmp/"$project1"_"$project2"/"$sample1"
macsdir=$outdir/MACS2
mkdir $macsdir

macs2 callpeak -t "$outdir"/"$project1"_"$project2"_"$sample1"_120bp_merged.bam -g mm -f BAMPE -n "$project1"_"$project2"_"$sample1"_120bp_merged --outdir $macsdir -q 0.01 -B --SPMR --keep-dup all 2> $macsdir/"$project1"_"$project2"_"$sample1"_merged_120bp.macs2.txt

source /wynton/home/reiter/lb13/miniconda3/bin/activate base

sort -k1,1 -k2,2n $macsdir/"$project1"_"$project2"_"$sample1"_120bp_merged_treat_pileup.bdg > $macsdir/"$project1"_"$project2"_"$sample1"_120bp_merged_pileup.sort.bdg
bedGraphToBigWig $macsdir/"$project1"_"$project2"_"$sample1"_120bp_merged_pileup.sort.bdg "$crtools"/assemblies/chrom.mm10/mm10.chrom.sizes $macsdir/"$project1"_"$project2"_"$sample1"_120bp_merged_pileup.bw


if [ "$control" == "" ]
then
>&2 echo "No control run"
else
	source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun
        mkdir $tmp/"$project1"_"$project2"/"$sample1"_vs_"$control"
        conmacsdir=$tmp/"$project1"_"$project2"/"$sample1"_vs_"$control"/MACS2
        mkdir $conmacsdir
        controldir=$tmp/"$project1"_"$project2"/"$control"

	macs2 callpeak -t "$outdir"/"$project1"_"$project2"_"$sample1"_120bp_merged.bam -c $controldir/"$project1"_"$project2"_"$control"_120bp_merged.bam -g mm -f BAMPE -n "$sample1"_vs_"$control"_120bp_merged --outdir $conmacsdir -q 0.01 -B --SPMR --keep-dup all 2> $conmacsdir/"$sample1"_vs_"$control"_merged_120bp.macs2.txt

	source /wynton/home/reiter/lb13/miniconda3/bin/activate base

	sort -k1,1 -k2,2n $conmacsdir/"$sample1"_vs_"$control"_120bp_merged_treat_pileup.bdg > $conmacsdir/"$sample1"_vs_"$control"_120bp_merged_pileup.sort.bdg
	bedGraphToBigWig $conmacsdir/"$sample1"_vs_"$control"_120bp_merged_pileup.sort.bdg $crtools/assemblies/chrom.mm10/mm10.chrom.sizes $conmacsdir/"$sample1"_vs_"$control"_120bp_merged_pileup.bw

fi
