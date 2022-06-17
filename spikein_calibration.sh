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

#source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

module load CBI bedtools

sample=$1
proj=$2
tmp=$3
projPath=$tmp/"$proj"/"$sample"/
chromSize=~/tools/crtools/assemblies/chrom.mm10/mm10.chrom.sizes
count=$(head -n 1 "$projPath"/logs/"$sample"_ecoli_count.txt)

if [[ "$count" -gt "1" ]]; then

    scale_factor=`echo "100000 / $count" | bc -l`
    echo "Scaling factor for $sample is: $scale_factor!"
    bedtools genomecov -bg -scale $scale_factor -i $projPath/alignment/"$sample"_bowtie2.fragments.bed -g $chromSize > $projPath/alignment/"$sample"_bowtie2.fragments.normalized.bedgraph

fi
