##### 
library(dplyr)

args=commandArgs(trailingOnly=T)

dir=args[1]
proj1=args[2]
proj2=args[3]
sample=args[4]

nt=paste(dir,"idr",sep="/")
np=paste(dir,"pooled_pseudoreplicates",sep="/")
n1=paste0(dir,"/self_consistency/",proj1,"_",sample)
n2=paste0(dir,"/self_consistency/",proj2,"_",sample)

nt_tab=read.table(paste0(nt,"/",proj1,"_",proj2,"_",sample,"_idr"))
np_tab=read.table(paste0(np,"/",proj1,"_",proj2,"_",sample,"_pseudorep-idr"))
n1_tab=read.table(paste0(n1,"_selfconsis_selfconsis-idr"))
n2_tab=read.table(paste0(n2,"_selfconsis_selfconsis-idr"))

nt_tab_filt=filter(nt_tab, nt_tab$V5 > 540) ## threshold 0.05
np_tab_filt=filter(np_tab, np_tab$V5 > 830) ## threshold 0.01
n1_tab_filt=filter(n1_tab, n1_tab$V5 > 540) 
n2_tab_filt=filter(n2_tab, n2_tab$V5 > 540)

df=as.data.frame(nrow(nt_tab_filt))
df=rbind(df,nrow(np_tab_filt))
df=rbind(df,nrow(n1_tab_filt))
df=rbind(df,nrow(n2_tab_filt))

colnames(df) <- c("Number of peaks")

df=rbind(df,df[3,]/df[4,])
df=rbind(df,df[2,]/df[1,])

rownames(df) <- c("NT","NP","N1","N2","N1/N2", "NP/NT")

write.csv(df,paste0(dir,"/",proj1,"_",proj2,"_",sample,"_idr_results.csv"))
