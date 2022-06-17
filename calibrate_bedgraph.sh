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

module load CBI bedtools2/2.30.0

sample=$1
project=$2
tmp=$3
projPath=$tmp/"$project"/"$sample"/
aligndir=$projPath/
fulldir=$projPath/dupmarked/
tfdir=$projPath/dup.marked.120bp/
chromSize=~/tools/crtools/assemblies/chrom.mm10/mm10.chrom.sizes
count=$(head -n 1 "$projPath"/logs/"$sample"_ecoli_count.txt)

if [[ "$count" -gt "1" ]]; then

    scale_factor=`echo "100000 / $count" | bc -l`
    echo "Scaling factor for $sample is: $scale_factor!"
    bedtools genomecov -bg -pc -scale $scale_factor -ibam $fulldir/"$sample"_henikoff_dupmarked.bam > $fulldir/"$sample"_henikoff_dupmark_fragments_normalized.bedgraph
    bedtools genomecov -bg -pc -scale $scale_factor -ibam $tfdir/"$sample"_henikoff_dupmark_120bp.bam > $tfdir/"$sample"_henikoff_dupmark_120bp_fragments_normalized.bedgraph	

fi

bedtools genomecov -bg -pc -ibam $fulldir/"$sample"_henikoff_dupmarked.bam > $fulldir/"$sample"_henikoff_dupmark_fragments.bedgraph
bedtools genomecov -bg -pc -ibam $tfdir/"$sample"_henikoff_dupmark_120bp.bam > $tfdir/"$sample"_henikoff_dupmark_120bp_fragments.bedgraph
		
## We use the mid point of each fragment to infer which 500bp bins does this fragment belong to.
binLen=500
awk -v w=$binLen '{print $1, int(($2 + $3)/(2*w))*w + w/2}' $fulldir/"$sample"_henikoff_dupmark_fragments.bedgraph | sort -k1,1V -k2,2n | uniq -c | awk -v OFS="\t" '{print $2, $3, $1}' |  sort -k1,1V -k2,2n  >$fulldir/"$sample"_henikoff_dupmark_fragmentsCountbin"$binLen".bed

awk -v w=$binLen '{print $1, int(($2 + $3)/(2*w))*w + w/2}' $tfdir/"$sample"_henikoff_dupmark_120bp_fragments.bedgraph | sort -k1,1V -k2,2n | uniq -c | awk -v OFS="\t" '{print $2, $3, $1}' |  sort -k1,1V -k2,2n  >$tfdir/"$sample"_henikoff_dupmark_120bp_fragmentsCountbin"$binLen".bed
