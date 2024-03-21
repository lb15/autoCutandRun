### QC metrics for Cut&Run data

library(dplyr)
library(ggplot2)
library(viridis)
library(ggpubr)
library(corrplot)


args = commandArgs(trailingOnly=TRUE)
print(args)
sampleInfo=read.csv(args[1],header = F)
colnames(sampleInfo) <-c("Project","Sample","Read1","Read2","Control")
tmp=args[2]

correlateBins <- function(proj, sampleList,fragCount){
	for(hist in sampleList){

		if(is.null(fragCount)){

    			fragCount = read.table(paste0(projPath,"/",hist, "/dupmarked/",hist,"_henikoff_dupmark_fragmentsCountbin500.bed"), header = FALSE) 
    			colnames(fragCount) = c("chrom", "bin", hist)

  		}else{

    			fragCountTmp = read.table(paste0(projPath,"/",hist, "/dupmarked/",hist,"_henikoff_dupmark_fragmentsCountbin500.bed"), header = FALSE)
    			colnames(fragCountTmp) = c("chrom", "bin", hist)
    			fragCount = full_join(fragCount, fragCountTmp, by = c("chrom", "bin"))

  		}	
	}
	return(fragCount)
}


fragCount=NULL
for(proj in unique(sampleInfo$Project)){
        tryCatch({
                projPath=paste0(tmp,"/",proj,"/")
                proj_samples = sampleInfo[sampleInfo$Project == proj,]
                sampleList=proj_samples$Sample
		fragCount=correlateBins(proj, sampleList,fragCount)
        }, error=function(cond){
                message(paste0("ERROR for project ", proj))
                message(cond)
        })
}


M = cor(fragCount %>% select(-c("chrom", "bin")) %>% log2(), use = "complete.obs") 

pdf(paste0(projPath,"/correlation_bin500.pdf"),height=8.5,width=11,useDingbats=F)
print(corrplot(M, method = "color", outline = T, addgrid.col = "darkgray", order="hclust", addrect = 3, rect.col = "black", rect.lwd = 3,cl.pos = "b", tl.col = "indianred4", tl.cex = 1, cl.cex = 1, addCoef.col = "black", number.digits = 2, number.cex = 1, col = colorRampPalette(c("midnightblue","white","darkred"))(100)))
dev.off()






