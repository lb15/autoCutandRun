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
#$ -l h_rt=04:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

cd /wynton/group/reiter/lauren/deeptool-env/
. bin/activate

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

project=$1
sample=$2
tmp=$3

#bam=$tmp/$project/$sample/dedup.120bp/"$sample"_henikoff_dedup_120bp.bam
#out=$tmp/$project/$sample/dedup.120bp/"$sample"_dedup_120bp_RPGC.bw

bam=$tmp/$project/$sample/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam
out=$tmp/$project/$sample/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp_RPGC.bw

bamCoverage -b $bam -o $out \
	--normalizeUsing RPGC \
	--effectiveGenomeSize 2652783500 \
	--extendReads \
	--binSize 10

bam2=$tmp/$project/$sample/dedup.120bp/"$sample"_henikoff_dedup_120bp.bam
out2=$tmp/$project/$sample/dedup.120bp/"$sample"_henikoff_dedup_120bp_RPGC.bw

bamCoverage -b $bam2 -o $out2 \
        --normalizeUsing RPGC \
        --effectiveGenomeSize 2652783500 \
        --extendReads \
        --binSize 10





