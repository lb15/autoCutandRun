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
#$ -l h_rt=24:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email


module load CBI bedtools2/2.30.0

basedir=/wynton/group/reiter/lauren/CR34_merge_analysis/CR34_merge/

d4dir=$basedir/Gli2_GFP_d4_merge_vs_Gli2_IgG_d4_merge
d5dir=$basedir/Gli2_GFP_d5_merge_vs_Gli2_IgG_d5_merge
d6dir=$basedir/Gli2_GFP_d6_vs_Gli2_IgG_d6_merge

bedtools intersect \
	-a $basedir/Gli2_GFP_d4_merge_vs_Gli2_GFP_d5_merge_IgGcontroled_intersect.bed \
	-b $d6dir/MACS2/Gli2_GFP_d6_vs_Gli2_IgG_d6_merge_dupmark_peaks.narrowPeak \
	-wo > $basedir/Gli2_GFP_d4_d5_d5_intersect_IgGcontrol.bed

bedtools intersect \
	-a $d4dir/MACS2/Gli2_GFP_d4_merge_vs_Gli2_IgG_d4_merge_dupmark_peaks.narrowPeak \
	-b $d5dir/MACS2/Gli2_GFP_d5_merge_vs_Gli2_IgG_d5_merge_dupmark_peaks.narrowPeak \
	-wo > $basedir/Gli2_GFP_d4_merge_vs_Gli2_GFP_d5_merge_IgGcontroled_intersect.bed

bedtools intersect \
	-a $d4dir/MACS2/Gli2_GFP_d4_merge_vs_Gli2_IgG_d4_merge_dupmark_peaks.narrowPeak \
	-b $d6dir/MACS2/Gli2_GFP_d6_vs_Gli2_IgG_d6_merge_dupmark_peaks.narrowPeak \
	-wo > $basedir/Gli2_GFP_d4_merge_vs_Gli2_GFP_d6_IgGcontroled_intersect.bed

bedtools intersect \
	-a $d5dir/MACS2/Gli2_GFP_d5_merge_vs_Gli2_IgG_d5_merge_dupmark_peaks.narrowPeak \
	-b $d6dir/MACS2/Gli2_GFP_d6_vs_Gli2_IgG_d6_merge_dupmark_peaks.narrowPeak \
	-wo > $basedir/Gli2_GFP_d5_merge_vs_Gli2_GFP_d6_IgGcontroled_intersect.bed

#bedtools intersect \
#	-a "$d4dir"/*d4.bed \
#	-b "$d5dir"/*d5_merge.bed \
#	-wo > $basedir/Gli2_GFP_d4_merge_vs_Gli2_GFP_d5_merge_IgGcontroled_E14_GFP_subtracted_intersect.bed

#bedtools intersect \
#        -a "$d4dir"/*d4.bed \
#        -b "$d6dir"/*d6_merge.bed \
#        -wo > $basedir/Gli2_GFP_d4_merge_vs_Gli2_GFP_d6_IgGcontroled_E14_GFP_subtracted_intersect.bed

#bedtools intersect \
#        -a "$d5dir"/*d5_merge.bed \
#        -b "$d6dir"/*d6_merge.bed \
#        -wo > $basedir/Gli2_GFP_d5_merge_vs_Gli2_GFP_d6_IgGcontroled_E14_GFP_subtracted_intersect.bed



