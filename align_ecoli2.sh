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
#$ -l h_rt=02:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI bowtie2/2.4.2 samtools/1.10

basedir=$1
sample=$2
tmp=$3

workdir=$tmp/$basedir/$sample/
crtools=~/tools/cutruntools/
trimdir=$workdir/trimmomatic
logdir=$workdir/logs
aligndir=$workdir/alignment
#bt2idx=~/resources/ecoli/Escherichia_coli_K_12_DH10B/Ensembl/EB1/Sequence/Bowtie2Index/
bt2idx=~/resources/ecoli_bl21_de3/bowtie2_index/ecoli_bl21_de3
mkdir $aligndir

bowtie2 -p "${NSLOTS:-1}" --end-to-end --very-sensitive --no-overlap --no-dovetail --no-mixed --no-discordant --phred33 -I 10 -X 700 -x $bt2idx -1 $trimdir/"$sample"_1_kseq_paired.fastq.gz -2 $trimdir/"$sample"_2_kseq_paired.fastq.gz -S $aligndir/"$sample"_bowtie2_spikeIn.sam 2> $logdir/"$sample"_bowtie2_spikeIn.txt

samtools view -bS $aligndir/"$sample"_bowtie2_spikeIn.sam > $aligndir/"$sample"_bowtie2_spikeIn.bam

