#!/bin/bash                         #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                     #-- the shell for the job
#$ -o /wynton/group/reiter/lauren/CR_log/                        #-- output directory (fill in)
#$ -e /wynton/group/reiter/lauren/CR_log/                        #-- error directory (fill in)
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=40G
#$ -l scratch=10G
#$ -l h_rt=72:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI bowtie2/2.4.2 samtools/1.10

## create bed files
## merge bed files
## call SEACR files
## compute overlap of indivudal bam files

project1=$1
project2=$2
sample=$3
control=$4
tmp=$5

controldir=$tmp/$control
tmpdir=/wynton/scratch/lb13/cr_test3/

mkdir $tmpdir

bam1=$tmp/"$project1"/"$sample"/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam
bam2=$tmp/"$project2"/"$sample"/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam

outdir=$tmp/"$project1"_"$project2"/"$sample"_vs_merged_"$control"/pooled_pseudoreplicates
mkdir $outdir

EXPT="$project1"_"$project2"_"$sample"

#Merge treatment BAMS
echo "Merging BAM files for pseudoreplicates..."
samtools merge -u $tmpdir/"$project1"_"$project2"_"$sample"_merged.bam $bam1 $bam2
samtools view -H $tmpdir/"$project1"_"$project2"_"$sample"_merged.bam > $tmpdir/"$project1"_"$project2"_"$sample"_header.sam

nlines=$(samtools view $tmpdir/${project1}_${project2}_${sample}_merged.bam | wc -l ) # Number of reads in the BAM file
nlines=$(( (nlines + 1) / 2 )) # half that number
samtools view $tmpdir/"$project1"_"$project2"_"$sample"_merged.bam | shuf - | split -d -l ${nlines} - "${tmpdir}/${EXPT}" # This will shuffle the lines in the file and split itinto two SAM files
cat ${tmpdir}/${EXPT}_header.sam ${tmpdir}/${EXPT}00 | samtools view -bS - > ${tmpdir}/${EXPT}00.bam
cat ${tmpdir}/${EXPT}_header.sam ${tmpdir}/${EXPT}01 | samtools view -bS - > ${tmpdir}/${EXPT}01.bam

#Peak calling on pseudoreplicates
echo "Calling peaks for pseudoreplicate1 "
macs2 callpeak -t ${tmpdir}/${EXPT}00.bam -c $controldir/"$control"_120bp_merged.bam  -f BAMPE -g mm -n "$sample"_pr1 --outdir $outdir -B -p 1e-3 --keep-dup all 2> $outdir/"$sample"_pr1_macs2.log

macs2 callpeak -t ${tmpdir}/${EXPT}01.bam -c $controldir/"$control"_120bp_merged.bam  -f BAMPE -g mm -n "$sample"_pr2 --outdir $outdir -B -p 1e-3 --keep-dup all 2> $outdir/"$sample"_pr2_macs2.log

#Sort peak by -log10(p-value)
echo "Sorting peaks..."
sort -k8,8nr $outdir/"$sample"_pr1_peaks.narrowPeak | head -n 100000 > $outdir/"$sample"_pr1_sorted.narrowPeak
sort -k8,8nr $outdir/"$sample"_pr2_peaks.narrowPeak | head -n 100000 > $outdir/"$sample"_pr2_sorted.narrowPeak

source /wynton/home/reiter/lb13/miniconda3/bin/activate idr

#Independent replicate IDR
echo "Running IDR on pseudoreplicates..."
idr --samples $outdir/"$sample"_pr1_sorted.narrowPeak $outdir/"$sample"_pr2_sorted.narrowPeak --input-file-type narrowPeak --output-file $outdir/${EXPT}_pseudorep-idr --rank p.value --plot


