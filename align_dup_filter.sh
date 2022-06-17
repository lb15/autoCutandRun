#!/bin/bash                         #-- what is the language of this shell
#                                  #-- Any line that starts with #$ is an instruction to SGE
#$ -S /bin/bash                     #-- the shell for the job
#$ -o /wynton/group/reiter/lauren/CR_log/                        #-- output directory (fill in)
#$ -e /wynton/group/reiter/lauren/CR_log/                        #-- error directory (fill in)
#$ -cwd                            #-- tell the job that it should start in your working directory
#$ -r y                            #-- tell the system that if a job crashes, it should be restarted
#$ -j y                            #-- tell the system that the STDERR and STDOUT should be joined
#$ -l mem_free=20G
#$ -l scratch=500G
#$ -l h_rt=72:00:00
#$ -m ea                           #--email when done
#$ -pe smp 4
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI bowtie2/2.4.2 samtools/1.10 picard/2.24.0

basedir=$1
sample=$2
tmp=$3

if [[ -z "$TMPDIR" ]]; then
  if [[ -d /scratch ]]; then TMPDIR=/scratch/$USER; else TMPDIR=/tmp/$USER; fi
  mkdir -p "$TMPDIR"
  export TMPDIR
fi

cd "$TMPDIR"

mkdir "$TMPDIR"/$basedir

workdir="$TMPDIR"/$basedir/$sample/
crtools=~/tools/cutruntools/
trimdir=$tmp/$basedir/$sample/trimmomatic
logdir=$workdir/logs
aligndir=$workdir/alignment
bt2idx=~/resources/mm10/
dupmarkdir=$workdir/dupmarked
dedupdir=$workdir/dedup

mkdir $workdir
mkdir $aligndir
mkdir $dupmarkdir
mkdir $dedupdir
mkdir  $logdir


>&2 echo "Starting bowtie alignment"


#bowtie2 -p "${NSLOTS:-1}" --dovetail --phred33 -x $bt2idx/mm10 -1 $trimdir/"$sample"_1_kseq_paired.fastq.gz -2 $trimdir/"$sample"_2_kseq_paired.fastq.gz -S $aligndir/"$sample"_aligned_crtools.sam 2> $logdir/"$sample"_bowtie2_stats_crtools.txt  

#samtools view -bS $aligndir/"$sample"_aligned_crtools.sam  > $aligndir/"$sample"_aligned_crtools.bam
#rm $aligndir/"$sample"_aligned_crtools.sam

bowtie2 -p "${NSLOTS:-1}" --local --very-sensitive-local --no-unal --no-mixed --no-discordant --phred33 -I 10 -X 700 -x $bt2idx/mm10 -1 $trimdir/"$sample"_1_kseq_paired.fastq.gz -2 $trimdir/"$sample"_2_kseq_paired.fastq.gz -S $aligndir/"$sample"_aligned_henikoff.sam 2> $logdir/"$sample"_bowtie2_stats_henikoff.txt

samtools view -bS $aligndir/"$sample"_aligned_henikoff.sam > $aligndir/"$sample"_aligned_henikoff.bam

>&2 echo "alignment complete"
>&2 echo "Starting sorting and marking duplicates"

mkdir $workdir/tmpor

java -Xmx8g -Djava.io.tmpdir=$workdir/tmpor -jar $PICARD_HOME/picard.jar SortSam \
INPUT=$aligndir/"$sample"_aligned_henikoff.bam OUTPUT=$aligndir/"$sample"_aligned_henikoff_sort.bam SORT_ORDER=coordinate TMP_DIR=$workdir/tmpor

picard MarkDuplicates \
INPUT=$aligndir/"$sample"_aligned_henikoff_sort.bam \
OUTPUT=$dupmarkdir/"$sample"_henikoff_dupmarked.bam \
METRICS_FILE=$dupmarkdir/"$sample"_henikoff_dupmarked_metrics.txt

picard MarkDuplicates \
INPUT=$aligndir/"$sample"_aligned_henikoff_sort.bam \
OUTPUT=$dedupdir/"$sample"_henikoff_dedup.bam \
METRICS_FILE=$dedupdir/"$sample"_henikoff_dedup_metrics.txt \
REMOVE_DUPLICATES=true


>&2 echo "Filtering to <120bp..."

mkdir  $workdir/dup.marked.120bp $workdir/dedup.120bp
samtools view -h $dupmarkdir/"$sample"_henikoff_dupmarked.bam |awk -f $crtools/filter_below.awk | samtools view -Sb - > $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam
samtools view -h $dedupdir/"$sample"_henikoff_dedup.bam |awk -f $crtools/filter_below.awk | samtools view -Sb - > $workdir/dedup.120bp/"$sample"_henikoff_dedup_120bp.bam

>&2 echo "Creating bam index files... "
samtools index $dupmarkdir/"$sample"_henikoff_dupmarked.bam
samtools index $dedupdir/"$sample"_henikoff_dedup.bam
samtools index $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam
samtools index $workdir/dedup.120bp/"$sample"_henikoff_dedup_120bp.bam

>&2 echo "Get Fragment length"

samtools view -F 0x04 $aligndir/"$sample"_aligned_henikoff.sam | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' > $logdir/"$sample"_henikoff_fragmentLen.txt

samtools view -h -o $workdir/dup.marked.120bp/"$sample"_dupmarked_120bp.sam $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam

samtools view -F 0x04 $workdir/dup.marked.120bp/"$sample"_dupmarked_120bp.sam | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' >$logdir/"$sample"_henikoff_120bp_fragmentLen.txt


rsync -avrz --update --exclude "*.sam" $TMPDIR/$basedir/$sample $tmp/$basedir

>&2 echo "Completed Script"

[[ -n "$JOB_ID" ]] && qstat -j "$JOB_ID"
