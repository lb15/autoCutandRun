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
#$ -pe smp 4
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI bowtie2/2.4.2 samtools/1.10

basedir=$1
sample=$2
fastq1=$3
fastq2=$4
tmp=$5

if [[ -z "$TMPDIR" ]]; then
  if [[ -d /scratch ]]; then TMPDIR=/scratch/$USER; else TMPDIR=/tmp/$USER; fi
  mkdir -p "$TMPDIR"
  export TMPDIR
fi

cd $TMPDIR

mkdir $TMPDIR/$basedir

workdir=$TMPDIR/$basedir/$sample/
crtools=~/tools/cutruntools/
trimdir=$workdir/trimmomatic
logdir=$workdir/logs


#trimmomaticbin=/Users/lb/Trimmomatic-0.36/
mkdir $workdir
mkdir $trimdir
mkdir $logdir

>&2 echo "Trimming file $sample ..."

trimmomatic PE -threads "${NSLOTS:-1}" -phred33 -trimlog $trimdir/trimlog.txt $fastq1 $fastq2 $trimdir/"$sample"_1.paired.fastq.gz $trimdir/"$sample"_1.unpaired.fastq.gz $trimdir/"$sample"_2.paired.fastq.gz $trimdir/"$sample"_2.unpaired.fastq.gz ILLUMINACLIP:$crtools/adapters/Truseq3.PE.fa:2:15:4:4:true LEADING:20 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:25

>&2 echo "Second stage trimming $sample ..."

$crtools/kseq_test $trimdir/"$sample"_1.paired.fastq.gz 42 $trimdir/"$sample"_1_kseq_paired.fastq.gz
$crtools/kseq_test $trimdir/"$sample"_2.paired.fastq.gz 42 $trimdir/"$sample"_2_kseq_paired.fastq.gz

>&2 echo "K-seq trimming complete"

rsync -avzr --update --exclude trimlog.txt $TMPDIR/$basedir/$sample $tmp/$basedir/
