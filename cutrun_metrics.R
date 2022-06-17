### QC metrics for Cut&Run data

library(dplyr)
library(ggplot2)
library(viridis)
library(ggpubr)

options(echo=T)

args = commandArgs(trailingOnly=TRUE)
print(args)
sampleInfo=read.csv(args[1],header = F)
colnames(sampleInfo) <-c("Project","Sample","Read1","Read2","Control")
tmp=args[2]

## Collect the alignment results from the bowtie2 alignment summary files
alignStats<- function(proj, sampleList){
	alignResult = c()
	for(hist in sampleList){
        	alignRes = read.table(paste0(projPath,"/", hist, "/logs/",hist,"_bowtie2_stats_henikoff.txt"), header = FALSE, fill = TRUE)
        	alignRate = alignRes$V1[6]
        	alignResult = data.frame(Sample = hist, 
                	                 Project = proj,
                        	         SequencingDepth = alignRes$V1[1] %>% as.character %>% as.numeric, 
					 MappedFragNum_mm10 = alignRes$V1[4] %>% as.character %>% as.numeric + alignRes$V1[5] %>% as.character %>% as.numeric, 
                                	 AlignmentRate_mm10 = alignRate)  %>% rbind(alignResult, .)
}
	alignResult$Sample = factor(alignResult$Sample, levels = sampleList)
	alignResult$SequencingDepthPerMillion = alignResult$SequencingDepth/1000000
	print(head(alignResult))
	return(alignResult)
}


##spike-in alignment

spikeStats <- function(proj, sampleList){
	spikeAlign = c()
	for(hist in sampleList){
  	spikeRes = read.table(paste0(projPath, hist, "/logs/",hist, "_bowtie2_spikeIn.txt"), header = FALSE, fill = TRUE)
  	alignRate = substr(spikeRes$V1[6], 1, nchar(as.character(spikeRes$V1[6]))-1)
  	histInfo = strsplit(hist, "_")[[1]]
  	spikeAlign = data.frame(Sample = hist, Project = proj, 
        	                  SequencingDepth = spikeRes$V1[1] %>% as.character %>% as.numeric, 
                	          MappedFragNum_spikeIn = spikeRes$V1[4] %>% as.character %>% as.numeric + spikeRes$V1[5] %>% as.character %>% as.numeric, 
 	                         AlignmentRate_spikeIn = alignRate %>% as.numeric)  %>% rbind(spikeAlign, .)
	}
	spikeAlign$Sample = factor(spikeAlign$Sample, levels = sampleList)
	spikeAlign %>% mutate(AlignmentRate_spikeIn = paste0(AlignmentRate_spikeIn, "%"))
	return(spikeAlign)
}

alignMerge <- function(alignResult, spikeAlign){
	alignSummary = left_join(alignResult, spikeAlign, by = c("Sample", "Project","SequencingDepth")) %>%
		mutate(AlignmentRate_mm10 = paste0(AlignmentRate_mm10, "%"), 
        	AlignmentRate_spikeIn = paste0(AlignmentRate_spikeIn, "%"))
	print(head(alignSummary))
	return(alignSummary)
}
## Summarize the duplication information from the picard summary outputs.

dupSummary <- function(proj, sampleList){
	dupResult = c()
	for(hist in sampleList){
        	dupRes = read.table(paste0(projPath, hist,"/dupmarked/", hist, "_henikoff_dupmarked_metrics.txt"), header = TRUE, fill = TRUE)

        	dupResult = data.frame(Sample = hist, 
                	               Project=proj,
                        	       MappedFragNum_mm10_picard = dupRes$READ_PAIRS_EXAMINED[1] %>% as.character %>% as.numeric, 
                               	DuplicationRate = dupRes$PERCENT_DUPLICATION[1] %>% as.character %>% as.numeric * 100, 
                               	EstimatedLibrarySize = dupRes$ESTIMATED_LIBRARY_SIZE[1] %>% as.character %>% as.numeric) %>% mutate(UniqueFragNum = MappedFragNum_mm10_picard * (1-DuplicationRate/100))  %>% rbind(dupResult, .)
	}
	dupResult$Sample = factor(dupResult$Sample, levels = sampleList)
	return(dupResult)
}

alignDupMerge <- function(alignSpikeSummary, dupResult,proj){

	alignDupSummary = left_join(alignSpikeSummary, dupResult, by = c("Sample", "Project")) %>% mutate(DuplicationRate = paste0(DuplicationRate, "%"))
	print(head(alignDupSummary))
	return(alignDupSummary)
}


mergeScaleFactor <- function(alignDupSummary, proj,sampleList,projPath){
	scaleFactor=c()
	multiplier=100000
	for(hist in sampleList){
	spikeDepth = read.table(paste0(projPath,"/",hist,"/logs/",hist,"_ecoli_count.txt"))$V1
	scaleFactor = data.frame(scaleFactor = multiplier/spikeDepth, Sample = hist, Project = proj)  %>% rbind(scaleFactor, .)
	}

	scaleFactor$Sample <- factor(scaleFactor$Sample, levels = sampleList)
	return(left_join(alignDupSummary, scaleFactor, by = c("Sample","Project")))
}

## Generate sequencing depth boxplot
alignment_plots <- function(alignDupSummary,projPath,proj){
	fig3A = alignDupSummary %>% ggplot(aes(x = Sample, y = SequencingDepthPerMillion, fill = Sample)) +
    		geom_boxplot() +
    		geom_jitter(aes(color = Project), position = position_jitter(0.15)) +
   		scale_fill_viridis(discrete = TRUE, begin = 0.1, end = 0.9, option = "magma", alpha = 0.8) +
   		scale_color_viridis(discrete = TRUE, begin = 0.1, end = 0.9) +
    		theme_bw(base_size = 18) +
    		ylab("Sequencing Depth per Million") +
    		xlab("") + 
    		ggtitle("A. Sequencing Depth")

	fig3B = alignDupSummary %>% ggplot(aes(x = Sample, y = MappedFragNum_mm10/1000000, fill = Sample)) +
    		geom_boxplot() +
    		geom_jitter(aes(color = Project), position = position_jitter(0.15)) +
    		scale_fill_viridis(discrete = TRUE, begin = 0.1, end = 0.9, option = "magma", alpha = 0.8) +
    		scale_color_viridis(discrete = TRUE, begin = 0.1, end = 0.9) +
    		theme_bw(base_size = 18)+
    		ylab("Mapped Fragments per Million") +
    		xlab("") +
    		ggtitle("B. Alignable Fragment (mm10)")

	fig3C = alignDupSummary %>% ggplot(aes(x = Sample, y = AlignmentRate_mm10, fill = Sample)) +
    		geom_boxplot() +
    		geom_jitter(aes(color = Project), position = position_jitter(0.15)) +
    		scale_fill_viridis(discrete = TRUE, begin = 0.1, end = 0.9, option = "magma", alpha = 0.8) +
    		scale_color_viridis(discrete = TRUE, begin = 0.1, end = 0.9) +
    		theme_bw(base_size = 18) +
		ylab("% of Mapped Fragments") +
    		xlab("") +
    		ggtitle("C. Alignment Rate (mm10)")

	fig3D = alignDupSummary %>% ggplot(aes(x = Sample, y = AlignmentRate_spikeIn, fill = Sample)) +
    		geom_boxplot() +
    		geom_jitter(aes(color = Project), position = position_jitter(0.15)) +
    		scale_fill_viridis(discrete = TRUE, begin = 0.1, end = 0.9, option = "magma", alpha = 0.8) +
    		scale_color_viridis(discrete = TRUE, begin = 0.1, end = 0.9) +
    		theme_bw(base_size = 18)+
		ylab("Spike-in Alignment Rate") +
    		xlab("") +
    		ggtitle("D. Alignment Rate (E.coli)")

	pdf(paste0(projPath,proj,"_alignment_plots.pdf"),height=8.5,width=11,useDingbats=F)
	print(ggarrange(fig3A, fig3B, fig3C, fig3D, ncol = 2, nrow=2, common.legend = TRUE, legend="bottom"))
	dev.off()

}
## Collect the fragment size information
getFragLen <- function(proj, sampleList,type){

	fragLen = c()
	for(hist in sampleList){
        	fragLen = read.table(paste0(projPath, hist,"/logs/", hist, "_henikoff_",type,"fragmentLen.txt"), header = FALSE) %>% mutate(fragLen = V1 %>% as.numeric, fragCount = V2 %>% as.numeric, Weight = as.numeric(V2)/sum(as.numeric(V2)), Sample = hist, Project = proj) %>% rbind(fragLen, .) 
	}	

	fragLen$Sample = factor(fragLen$Sample, levels = sampleList)
	return(fragLen)
}

## Generate the fragment size density plot (violin plot)

fragLenPlots <- function(fragLen,projPath,proj,type){
	fig5A = fragLen %>% ggplot(aes(x = Sample, y = fragLen, weight = Weight, fill = Sample),log=y) +
        	geom_violin(bw = 5) +
        	scale_y_continuous(limits=c(0,800))+
        	scale_fill_viridis(discrete = TRUE, begin = 0.1, end = 0.9, option = "magma", alpha = 0.8) +
        	scale_color_viridis(discrete = TRUE, begin = 0.1, end = 0.9) +
        	theme_bw(base_size = 20) +
        	ylab("Fragment Length") +
        	xlab("")

	fig5B = fragLen %>% ggplot(aes(x = fragLen, y = fragCount, color = Sample, group = Sample, linetype = Sample)) +
        	geom_line(size = 1) +
        	scale_color_viridis(discrete = TRUE, begin = 0.1, end = 0.9, option = "magma") +
        	theme_bw(base_size = 20) +
        	xlab("Fragment Length") +
        	ylab("Count") +
        	coord_cartesian(xlim = c(0, 1000))

	pdf(paste0(projPath, "/",proj,"_henikoff_",type,"fragment_length.pdf"),height=6,width=11,useDingbats = F)
	print(ggarrange(fig5A, fig5B, ncol = 2))
	dev.off()
}

mergeProj <- function(all_proj,tmp, merged_name){

        alignment_plots(all_proj,projPath, merged_name)
        write.csv(all_proj, file=paste0(tmp,"/",merged_name,"_metrics_summary.csv"))
}

all_proj <- c()
for(proj in unique(sampleInfo$Project)){
        tryCatch({
		projPath=paste0(tmp,"/",proj,"/")
        	#projPath=paste0(proj,"/")
        	proj_samples = sampleInfo[sampleInfo$Project == proj,]
        	sampleList=proj_samples$Sample
        	alignResult <- alignStats(proj, sampleList)
        	spikeAlign <- spikeStats(proj, sampleList)
        	alignSpikeSummary <- alignMerge(alignResult, spikeAlign)
        	dupResults <- dupSummary(proj,sampleList)
        	dupAlignSummary <- alignDupMerge(alignSpikeSummary, dupResults)
        	dupAlignScale <- mergeScaleFactor(dupAlignSummary, proj, sampleList,projPath)
		print("saving summary results")
		write.csv(dupAlignScale, file=paste0(projPath, proj,"_dupAlignSummary.csv"))
		alignment_plots(dupAlignSummary, projPath,proj)	
		fragLen <- getFragLen(proj, sampleList,"")
		fragLenPlots(fragLen, projPath, proj,"")
		fragLen <- getFragLen(proj, sampleList, "120bp_")
		fragLenPlots(fragLen, projPath, proj, "120bp_")
		all_proj <- rbind(all_proj, dupAlignScale)
	}, error=function(cond){
		message(paste0("ERROR for project ", proj))
		message(cond)
	})
}

print(head(all_proj))

if(length(unique(sampleInfo$Project))>1){
	print("Merging projects")
	merged_name = paste(unique(sampleInfo$Project),collapse= "_")
	print(merged_name)
	mergedSummary <- mergeProj(all_proj,tmp,merged_name)

}

