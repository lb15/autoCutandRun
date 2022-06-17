#!/bin/bash                         #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                     #-- the shell for the job
#$ -o /wynton/group/reiter/lauren/CR_log/                        #-- output directory (fill in)
#$ -e /wynton/group/reiter/lauren/CR_log/                        #-- error directory (fill in)
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=20G
#$ -l scratch=10G
#$ -l h_rt=72:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI bedtools2/2.30.0 
module load CBI samtools/1.10

## create bed files
## merge bed files
## call SEACR files
## compute overlap of indivudal bam files

project1=$1
project2=$2
sample1=$3
tmp=$4
control=$5

outdir=$tmp/"$project1"_"$project2"_"$sample1"
mkdir $outdir

chromSize=~/tools/mm10.chrom.sizes

## Convert into bed file format

path1=$tmp/$project1/$sample1/dup.marked.120bp/
path2=$tmp/$project2/$sample1/dup.marked.120bp/

bam1=$path1/"$sample1"_henikoff_dupmark_120bp.bam
bam2=$path2/"$sample1"_henikoff_dupmark_120bp.bam

#bedtools bamtobed -i $bam1 -bedpe | head

samtools sort -n $bam1 | bedtools bamtobed -i stdin -bedpe > $path1/"$sample1"_dupmark_120bp.bed
samtools sort -n $bam2 | bedtools bamtobed -i stdin -bedpe > $path2/"$sample1"_dupmark_120bp.bed

## Only extract the fragment related columns
cut -f 1,2,6 $path1/"$sample1"_dupmark_120bp.bed | sort -k1,1 -k2,2n -k3,3n  >$path1/"$sample1"_fragments_120bp.bed
cut -f 1,2,6 $path2/"$sample1"_dupmark_120bp.bed | sort -k1,1 -k2,2n -k3,3n  >$path2/"$sample1"_fragments_120bp.bed

## merge bed files

cat $path1/"$sample1"_fragments_120bp.bed $path2/"$sample1"_fragments_120bp.bed | sort -k1,1 -k2,2n | bedtools merge -i stdin > $outdir/"$project1"_"$project2"_"$sample1"_merged.bed 

## make bedgraph

bedtools genomecov -bg -i $outdir/"$project1"_"$project2"_"$sample1"_merged.bed -g $chromSize > $outdir/"$project1"_"$project2"_"$sample1"_merged.bedgraph



