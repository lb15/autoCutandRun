library(GenomicRanges)

args=commandArgs(TrailingOnly=T)

sampleInfo=read.table(args, header=T)

repL = unique(sampleInfo$Project)
sampleList=unique(sampleProj$Sample[sampleProj$Type == "Exp"])
peakType=c("control","top0.01")
peakOverlap=c()
for(type in peakType){
	for(hist in sampleList){
    	overlap.gr = GRanges()
    	for(rep in repL){
		projPath=paste0("/wynton/group/reiter/lauren/",rep,"/")
      		peakInfo = read.table(paste0(projPath, hist,"/SEACR/", hist, "_seacr_", type, ".peaks.stringent.bed"), header = FALSE, fill = TRUE)
		peakInfo.gr = GRanges(peakInfo$V1, IRanges(start = peakInfo$V2, end = peakInfo$V3), strand = "*")
      		if(length(overlap.gr) >0){
        		overlap.gr = overlap.gr[findOverlaps(overlap.gr, peakInfo.gr)@from]
      		}else{
        		overlap.gr = peakInfo.gr

      		}	
    	}
    peakOverlap = data.frame(peakReprod = length(overlap.gr), Sample = hist, peakType = type) %>% rbind(peakOverlap, .)
  }
}

