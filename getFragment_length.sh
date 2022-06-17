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


workdir="$tmp"/$basedir/$sample/
crtools=~/tools/cutruntools/
trimdir=$tmp/$basedir/$sample/trimmomatic
logdir=$workdir/logs
aligndir=$workdir/alignment
bt2idx=~/resources/mm10/
dupmarkdir=$workdir/dupmarked
dedupdir=$workdir/dedup

>&2 echo "Get Fragment length"
samtools view -h -o  $aligndir/"$sample"_aligned_henikoff_sort.sam $aligndir/"$sample"_aligned_henikoff_sort.bam

samtools view -F 0x04 $aligndir/"$sample"_aligned_henikoff_sort.sam | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' > $logdir/"$sample"_henikoff_fragmentLen.txt

#samtools view -h -o $workdir/dup.marked.120bp/"$sample"_dupmarked_120bp.sam $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam

#samtools view -F 0x04 $workdir/dup.marked.120bp/"$sample"_dupmarked_120bp.sam | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' >$logdir/"$sample"_henikoff_120bp_fragmentLen.txt


>&2 echo "Completed Script"

[[ -n "$JOB_ID" ]] && qstat -j "$JOB_ID"
