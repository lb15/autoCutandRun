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
#$ -pe smp 4
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate deeptools

project1=Mycl_CR2
project2=Mycl_CR3
sample1=Mycl_GFP
sample2=Mycl_IgG
sample3=nls_GFP
tmp=/wynton/group/reiter/lauren/cr_test3
peaks=$tmp/Mycl_CR2_Mycl_CR3/Mycl_GFP_vs_Mycl_IgG/Mycl_CR2_Mycl_CR3_Mycl_GFP_vs_Mycl_IgG_subtract_nls_GFP_peaks.bed

corr=spearman
name=nlsSubtracted

bam1=$tmp/"$project1"/"$sample1"/dup.marked.120bp/"$sample1"_henikoff_dupmark_120bp.bam
bam2=$tmp/"$project2"/"$sample1"/dup.marked.120bp/"$sample1"_henikoff_dupmark_120bp.bam
bam3=$tmp/"$project1"/"$sample2"/dup.marked.120bp/"$sample2"_henikoff_dupmark_120bp.bam
bam4=$tmp/"$project2"/"$sample2"/dup.marked.120bp/"$sample2"_henikoff_dupmark_120bp.bam
bam5=$tmp/"$project1"/"$sample3"/dup.marked.120bp/"$sample3"_henikoff_dupmark_120bp.bam
bam6=$tmp/"$project2"/"$sample3"/dup.marked.120bp/"$sample3"_henikoff_dupmark_120bp.bam

outdir=$tmp/"$project1"_"$project2"/

multiBamSummary BED-file --BED $peaks --bamfiles $bam1 $bam2 $bam3 $bam4 $bam5 $bam6 \
	-o $outdir/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_bamcoverage_"$name"_peaks.npz \
	--labels "$project1"_"$sample1" "$project2"_"$sample1" "$project1"_"$sample2" "$project2"_"$sample2" "$project1"_"$sample3" "$project2"_"$sample3"
	 -p "${NSLOTS:-1}"

plotCorrelation -in $outdir/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_bamcoverage_"$name"_peaks.npz \
	--corMethod $corr --whatToPlot heatmap \
	--colorMap coolwarm --plotNumbers \
	-o "$outdir"/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_"$name"_peaks_plotCorr_"$corr"_heatmap.png \
	--outFileCorMatrix "$outdir"/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_"$name"_peaks_plotCorr_"$corr"_counts.tab \
	--labels "$project1"_"$sample1" "$project2"_"$sample1" "$project1"_"$sample2" "$project2"_"$sample2" "$project1"_"$sample3" "$project2"_"$sample3"

#multiBamSummary bins --binSize 1000 --bamfiles $bam1 $bam2 $bam3 $bam4 $bam5 $bam6 \
#       -o $outdir/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_bamcoverage_bins1000.npz \
#       --labels "$project1"_"$sample1" "$project2"_"$sample1" "$project1"_"$sample2" "$project2"_"$sample2" "$project1"_"$sample3" "$project2"_"$sample3" \
#	-p "${NSLOTS:-1}"

#plotCorrelation -in $outdir/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_bamcoverage_bins1000.npz \
#        --corMethod $corr --whatToPlot heatmap \
#        --colorMap coolwarm --plotNumbers \
#        -o "$outdir"/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_plotCorr_bins_"$corr"_heatmap.png \
#        --outFileCorMatrix "$outdir"/"$project1"_"$project2"_"$sample1"_"$sample2"_"$sample3"_plotCorr_bins_"$corr"_counts.tab \
#        --labels "$project1"_"$sample1" "$project2"_"$sample1" "$project1"_"$sample2" "$project2"_"$sample2" "$project1"_"$sample3" "$project2"_"$sample3"
