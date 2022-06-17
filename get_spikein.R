
library(dplyr)

args=commandArgs(trailingOnly=T)

proj=args[1]
sample=args[2]
tmp=args[3]

dir=paste0(tmp,"/",proj,"/",sample,"/logs/")

spikeRes = read.table(paste0(dir,sample,"_bowtie2_spikeIn.txt"),header=F, fill=T)

mapped_frag = spikeRes$V1[4] %>% as.character %>% as.numeric + spikeRes$V1[5] %>% as.character %>% as.numeric
print(mapped_frag)
write.table(mapped_frag, file=paste0(dir,sample,"_ecoli_count.txt"),quote=F,row.names=F,col.names=F)
