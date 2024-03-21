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
#$ -l h_rt=24:00:00
#$ -m ea                           #--email when done
#$ -M Lauren.Byrnes@ucsf.edu        #--email

source /wynton/home/reiter/lb13/miniconda3/bin/activate idr

proj1=$1
proj2=$2
sample=$3
control=$4
tmp=$5

proj1dir=$tmp/$proj1/"$sample"_vs_merged_"$control"/MACS2/
proj2dir=$tmp/$proj2/"$sample"_vs_merged_"$control"/MACS2/

peak1=$proj1dir/"$sample"_vs_merged_"$control"_dupmark_idr_peaks.narrowPeak
peak2=$proj2dir/"$sample"_vs_merged_"$control"_dupmark_idr_peaks.narrowPeak

outdir=$tmp/"$proj1"_"$proj2"/"$sample"_vs_merged_"$control"/

mkdir $outdir
mkdir $outdir/idr

cd $outdir/idr


idr --samples "$peak1" "$peak2" \
	--peak-list $tmp/"$proj1"_"$proj2"/"$sample"_vs_Mycl_IgG/"$proj1"_"$proj2"_"$sample"_vs_Mycl_IgG_subtract_nls_GFP_peaks.bed \
	--input-file-type narrowPeak \
	--rank p.value \
	--output-file "$proj1"_"$proj2"_"$sample"_vs_"$control"_subtract_nlsGFP_peaks_idr \
	--plot \
	--log-output-file "$proj1"_"$proj2"_"$sample"_vs_"$control"_subtract_nlsGFP_peaks_idr.log




