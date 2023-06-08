#计算相对丰度(功能丰度表)
args <- commandArgs(T)

inputFix <- args[1]
outputFix <- args[2]

dat <- read.table(inputFix,row.names = 1,header = T,sep = '\t')
dat_1 <- t(dat)/colSums(dat)
dat_1 <- t(dat_1)
dat_1[is.na(dat_1)] <- 0 #丰度值全为0的情况，会有NA值，用0替换回来

dat_1 <- data.frame(ID=rownames(dat_1),dat_1)
names(dat_1)[1] <- ""

write.table(dat_1,outputFix,row.names = F,sep = '\t',quote = F)
