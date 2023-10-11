#Calculate relative abundance
args <- commandArgs(T)

inputFix <- args[1]
outputFix <- args[2]

dat <- read.table(inputFix,row.names = 1,header = T,sep = '\t',check.names = FALSE)
dat_1 <- t(dat)/colSums(dat)*100
dat_1 <- t(dat_1)

dat_1 <- data.frame(ID=rownames(dat_1),dat_1,check.names = FALSE)

write.table(dat_1,outputFix,row.names = F,sep = '\t',quote = F)
