
library(ChIPseeker)
library(TxDb.Mmusculus.UCSC.mm10.knownGene)
txdb=TxDb.Mmusculus.UCSC.mm10.knownGene

args = commandArgs(trailingOnly=TRUE)

sample = args[1]
basedir=args[2]
tmp=args[3]

setwd(paste(tmp,"/",basedir,"/",sample,"/MACS2/", sep=""))

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
                         TxDb=txdb, annoDb="org.Mm.eg.db",addFlankGeneInfo=T, flankDistance=5000)

annotations_orgDb <- AnnotationDbi::select(org.Mm.eg.db, # database
                                           keys = keys(org.Mm.eg.db),  # data to use for retrieval
                                           columns = c("SYMBOL", "ENTREZID","GENENAME") # information to retreive for given data
                                           )
ens_flanks = peakAnno@anno$flank_geneIds
gene_flanks=list()
for(x in 1:length(ens_flanks)){
        if(is.na(ens_flanks[x])){
                gene_flanks[x]<-NA}
        else{
                gene_list=as.data.frame(strsplit(ens_flanks[x],";",fixed=T)[[1]])
                colnames(gene_list) <- c("GeneID")
                
                annotate_genes=annotations_orgDb$SYMBOL[match(gene_list$GeneID,annotations_orgDb$ENTREZID)]
                gene_flanks[[x]] <- paste(unique(annotate_genes),collapse = " ; ")
                
        }
        
}

peakAnno@anno$gene_flank_symbol <- gene_flanks

pdf(paste0(sample,"_dupmark_annoBar.pdf"))
plotAnnoBar(peakAnno)
dev.off()


write.csv(peakAnno@anno,file=paste0(sample,"_dupmark_chipseeker_peakannotations.csv"))

