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

source /wynton/home/reiter/lb13/miniconda3/bin/activate CutRun

basedir=$1
sample=$2
tmp=$3
control=$4

workdir=$tmp/$basedir/$sample/
crtools=~/tools/cutruntools/
logdir=$workdir/logs
aligndir=$workdir/aligndir_crtools
outdir=$workdir/MACS2
dupmarkdir=$workdir/dupmarked
dedupdir=$workdir/dedup

>&2 echo "Peak calling using MACS2... "
mkdir $outdir

macs2 callpeak -t $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam -g mm -f BAMPE -n "$sample"_dupmark --outdir $outdir -q 0.01 -B --SPMR --keep-dup all 2> $logdir/"$sample"_dupmark_120bp.macs2.txt

macs2 callpeak -t $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam -g mm -f BAMPE -n "$sample"_dedup --outdir $outdir -q 0.01 -B --SPMR 2> $logdir/"$sample"_dedup_120bp.macs2.txt

>&2 echo "Converting bedgraph to bigwig... "

source /wynton/home/reiter/lb13/miniconda3/bin/activate base

sort -k1,1 -k2,2n $outdir/"$sample"_dupmark_treat_pileup.bdg > $outdir/"$sample"_dupmark.sort.bdg
bedGraphToBigWig $outdir/"$sample"_dupmark.sort.bdg $crtools/assemblies/chrom.mm10/mm10.chrom.sizes $outdir/"$sample"_dupmark.sorted.bw

sort -k1,1 -k2,2n $outdir/"$sample"_dedup_treat_pileup.bdg > $outdir/"$sample"_dedup.sort.bdg
bedGraphToBigWig $outdir/"$sample"_dedup.sort.bdg $crtools/assemblies/chrom.mm10/mm10.chrom.sizes $outdir/"$sample"_dedup.bw
>&2 echo "Finished"

rm $outdir/"$sample"_dupmark.sort.bdg
rm $outdir/"$sample"_dedup.sort.bdg


if [ "$control" == "" ]
then
>&2 echo "No control run"
else
	mkdir $tmp/$basedir/"$sample"_vs_"$control"
	macsdir=$tmp/$basedir/"$sample"_vs_"$control"/MACS2
	mkdir $macsdir
	controldir=$tmp/$basedir/$control

	## keep dups
        macs2 callpeak -t $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam -c $controldir/dup.marked.120bp/"$control"_henikoff_dupmark_120bp.bam -g mm -f BAMPE -n "$sample"_vs_"$control"_dupmark --outdir $macsdir -q 0.01 -B --SPMR --keep-dup all 2> $logdir/"$sample"_vs_"$control"_dupmark_120bp.macs2.txt

	## no dups
	macs2 callpeak -t $workdir/dup.marked.120bp/"$sample"_henikoff_dupmark_120bp.bam -c $controldir/dup.marked.120bp/"$control"_henikoff_dupmark_120bp.bam -g mm -f BAMPE -n "$sample"_vs_"$control"_dedup --outdir $macsdir -q 0.01 -B --SPMR 2> $logdir/"$sample"_vs_"$control"_dedup_120bp.macs2.txt

        source /wynton/home/reiter/lb13/miniconda3/bin/activate base

	sort -k1,1 -k2,2n $macsdir/"$sample"_vs_"$control"_dupmark_treat_pileup.bdg > $macsdir/"$sample"_vs_"$control"_dupmark.sort.bdg
        bedGraphToBigWig $macsdir/"$sample"_vs_"$control"_dupmark.sort.bdg $crtools/assemblies/chrom.mm10/mm10.chrom.sizes $macsdir/"$sample"_vs_"$control"_dupmark.bw

        sort -k1,1 -k2,2n $macsdir/"$sample"_vs_"$control"_dedup_treat_pileup.bdg > $macsdir/"$sample"_vs_"$control"_dedup.sort.bdg
        bedGraphToBigWig $macsdir/"$sample"_vs_"$control"_dedup.sort.bdg $crtools/assemblies/chrom.mm10/mm10.chrom.sizes $macsdir/"$sample"_vs_"$control"_dedup.bw

	rm $macsdir/"$sample"_vs_"$control"_dedup.sort.bdg
	rm $macsdir/"$sample"_vs_"$control"_dupmark.sort.bdg	

fi


