library(eulerr)
library(reshape2)
library(ggplot2)

args = commandArgs(trailingOnly=TRUE)

peakfile = args[1]
outdir=args[2]
filename=args[3]

###### venn diagram peaks #######

peaks=read.csv(peakfile)

peak_venn = melt(table(peaks$V11))
peak_venn$Var1 <- as.character(peak_venn$Var1)

x <- c(A=peak_venn$value[2], B=peak_venn$value[3],"A&B"=peak_venn$value[1])

fit <- euler(x)
pdf(paste0(outdir,"/",filename,"_venn.pdf"),height=8,width=11,useDingbats = F)
plot(fit,quantities = T, labels=c(peak_venn$Var1[2],peak_venn$Var1[3]),adjust_labels = F, fills = c("skyblue","goldenrod1"))
dev.off()       

########## region annotation #########

combine_regions <- function(peak_list){
                peaks$region <- peaks$annotation
                peaks$region[grep("([0-9]-[0-9]kb)",peaks$annotation)]  <- "Promoter (<=10kb)"
                peaks$region[grep("([0-9]-[0-9][0-9]kb)",peaks$annotation)]  <- "Promoter (<=10kb)"
                peaks$region[grep("Intron",peaks$annotation)] <- "Intron"
                peaks$region[grep("Exon",peaks$annotation)] <- "Exon"
        return(peaks)
}

new_peaks=combine_regions(peaks)

tab=as.data.frame(table(new_peaks$region,new_peaks$V11))
colnames(tab) <- c("Region","Sample","Freq")

tab$Region <- factor(tab$Region, levels=c("Promoter (<=1kb)","Promoter (<=10kb)","3' UTR","5' UTR","Downstream (<1kb)","Exon","Intron","Distal Intergenic"))

pdf(paste0(outdir,"/",filename,"_region.pdf"),height=6,width=8,useDingbats = F)
ggplot(tab, aes(x=Sample,y=Freq,fill=Region))+geom_col(position = "fill")+
        scale_fill_brewer(palette = "Dark2") +
        coord_flip() + 
        theme_classic()+
        xlab("")+
        ylab("Percentage")+
        theme(legend.title = element_blank())
dev.off()
