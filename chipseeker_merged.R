
library(ChIPseeker)
library(TxDb.Mmusculus.UCSC.mm10.knownGene)
txdb=TxDb.Mmusculus.UCSC.mm10.knownGene

args = commandArgs(trailingOnly=TRUE)

sample = args[1]
sinsam=args[2]
basedir=args[3]
tmp=args[4]

print(paste(tmp,basedir,sinsam,"MACS2", sep="/"))
setwd(paste(tmp,basedir,sinsam,"MACS2", sep="/"))

peak_file =paste0(sample,"_dupmark_peaks.narrowPeak")

peak=readPeakFile(peak_file)

png(paste0(sample,"_dupmark_genomecovplot.png"),height=800,width=1100)
covplot(peak, weightCol="V5")
dev.off()

promoter <- getPromoters(TxDb=txdb, upstream=3000, downstream=3000)
tagMatrix <- getTagMatrix(peak, windows=promoter)

png(paste0(sample,"_dupmark_tssheatmap.png"),height=800,width=1100)
tagHeatmap(tagMatrix, xlim=c(-3000, 3000), color="red")
dev.off()

png(paste0(sample,"_dupmark_tssfrequency.png"),height=800,width=1100)
plotAvgProf(tagMatrix, xlim=c(-3000, 3000),
            xlab="Genomic Region (5'->3')", ylab = "Read Count Frequency")
dev.off()

peakAnno <- annotatePeak(peak_file, tssRegion=c(-3000, 3000),
                         TxDb=txdb, annoDb="org.Mm.eg.db")

pdf(paste0(sample,"_dupmark_annoBar.pdf"))
plotAnnoBar(peakAnno)
dev.off()


write.csv(peakAnno@anno,file=paste0(sample,"_dupmark_chipseeker_peakannotations.csv"))

