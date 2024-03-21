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

samtools view -H $bam1 > $tmpdir/"$project1"_"$sample"_header.sam
samtools view -H $bam2 > $tmpdir/"$project2"_"$sample"_header.sam

outdir=$tmp/"$project1"_"$project2"/"$sample"_vs_merged_"$control"/self_consistency
mkdir $outdir

EXPT1="$project1"_"$sample"_selfconsis
EXPT2="$project2"_"$sample"_selfconsis


#split bams
echo "Splitting bams"
nlines1=$(samtools view $bam1 | wc -l ) # Number of reads in the BAM file
nlines1=$(( (nlines1 + 1) / 2 )) # half that number
samtools view $bam1 | shuf - | split -d -l ${nlines1} - "${tmpdir}/${EXPT1}" # This will shuffle the lines in the file and split itinto two SAM files

cat ${tmpdir}/"$project1"_"$sample"_header.sam ${tmpdir}/${EXPT1}00 | samtools view -bS - > ${tmpdir}/${EXPT1}00.bam
cat ${tmpdir}/"$project1"_"$sample"_header.sam ${tmpdir}/${EXPT1}01 | samtools view -bS - > ${tmpdir}/${EXPT1}01.bam

nlines2=$(samtools view $bam2 | wc -l ) # Number of reads in the BAM file
nlines2=$(( (nlines2 + 1) / 2 )) # half that number
samtools view $bam2 | shuf - | split -d -l ${nlines2} - "${tmpdir}/${EXPT2}" # This will shuffle the lines in the file and split itinto two SAM files

cat ${tmpdir}/"$project2"_"$sample"_header.sam ${tmpdir}/${EXPT2}00 | samtools view -bS - > ${tmpdir}/${EXPT2}00.bam
cat ${tmpdir}/"$project2"_"$sample"_header.sam ${tmpdir}/${EXPT2}01 | samtools view -bS - > ${tmpdir}/${EXPT2}01.bam

#Peak calling on split bams
echo "Calling peaks for "$project1" split bam "
macs2 callpeak -t ${tmpdir}/${EXPT1}00.bam -c $controldir/"$control"_120bp_merged.bam  -f BAMPE -g mm -n "$EXPT1"_split1 --outdir $outdir -B -p 1e-3 --keep-dup all 2> $outdir/"$EXPT1"_split1_macs2.log

macs2 callpeak -t ${tmpdir}/${EXPT1}01.bam -c $controldir/"$control"_120bp_merged.bam  -f BAMPE -g mm -n "$EXPT1"_split2 --outdir $outdir -B -p 1e-3 --keep-dup all 2> $outdir/"$EXPT1"_split2_macs2.log

#Peak calling on split bams
echo "Calling peaks for "$project2" split bam "
macs2 callpeak -t ${tmpdir}/${EXPT2}00.bam -c $controldir/"$control"_120bp_merged.bam  -f BAMPE -g mm -n "$EXPT2"_split1 --outdir $outdir -B -p 1e-3 --keep-dup all 2> $outdir/"$EXPT2"_split1_macs2.log

macs2 callpeak -t ${tmpdir}/${EXPT2}01.bam -c $controldir/"$control"_120bp_merged.bam  -f BAMPE -g mm -n "$EXPT2"_split2 --outdir $outdir -B -p 1e-3 --keep-dup all 2> $outdir/"$EXPT2"_split2_macs2.log

#Sort peak by -log10(p-value)
echo "Sorting peaks..."
sort -k8,8nr $outdir/"$EXPT1"_split1_peaks.narrowPeak | head -n 100000 > $outdir/"$EXPT1"_split1_sorted.narrowPeak
sort -k8,8nr $outdir/"$EXPT1"_split2_peaks.narrowPeak | head -n 100000 > $outdir/"$EXPT1"_split2_sorted.narrowPeak
sort -k8,8nr $outdir/"$EXPT2"_split1_peaks.narrowPeak | head -n 100000 > $outdir/"$EXPT2"_split1_sorted.narrowPeak
sort -k8,8nr $outdir/"$EXPT2"_split2_peaks.narrowPeak | head -n 100000 > $outdir/"$EXPT2"_split2_sorted.narrowPeak

source /wynton/home/reiter/lb13/miniconda3/bin/activate idr

#Independent replicate IDR
echo "Running IDR on pseudoreplicates..."
idr --samples $outdir/"$EXPT1"_split1_sorted.narrowPeak $outdir/"$EXPT1"_split2_sorted.narrowPeak --input-file-type narrowPeak --output-file $outdir/${EXPT1}_selfconsis-idr --rank p.value --plot

idr --samples $outdir/"$EXPT2"_split1_sorted.narrowPeak $outdir/"$EXPT2"_split2_sorted.narrowPeak --input-file-type narrowPeak --output-file $outdir/${EXPT2}_selfconsis-idr --rank p.value --plot
