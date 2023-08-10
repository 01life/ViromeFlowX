#Calculate relative abundance (functional abundance table)
args <- commandArgs(T)

inputFix <- args[1]
outputFix <- args[2]

dat <- read.table(inputFix,row.names = 1,header = T,sep = '\t')
dat_1 <- t(dat)/colSums(dat)
dat_1 <- t(dat_1)
dat_1[is.na(dat_1)] <- 0 #When all abundance values are 0, there will be NA values, which can be replaced with 0.

dat_1 <- data.frame(ID=rownames(dat_1),dat_1)
names(dat_1)[1] <- ""

write.table(dat_1,outputFix,row.names = F,sep = '\t',quote = F)
