
library("optparse")

option_list = list(
  make_option(c("--tax"), type = "character",help = "taxonomy table"),
  make_option(c("--abun"),type = "character",help = "contigs abundance table"),
  make_option(c("-o","--output"),type = "character",help = "Output file name")
)
opt <- parse_args(OptionParser(option_list=option_list), positional_arguments = TRUE)


taxfile <- opt$options$tax
abun1 <- opt$options$abun
outFile <- opt$options$output

##data
dat <- read.table(taxfile,header = TRUE,sep = '\t',check.names = FALSE)
abun <- read.table(abun1,header = TRUE,sep = '\t',check.names = FALSE)

names(dat)[1] <- "ID"
names(abun)[1] <- "ID"

dat$taxonomy <- gsub(" ","_",dat$taxonomy)
#dat$taxonomy <- gsub("p__;|c__;|o__;|f__;|g__;","",dat$taxonomy)

#Remove rows with abundance values that are all 0
if(ncol(abun)==2){
  	#only one sample
	abun <- abun[abun[,2]>0,]
}else{
	abun <- abun[rowSums(abun[,2:ncol(abun)])>0,]
}

#Merge species annotation table and contigs abundance table
dat_1 <- merge(abun,dat,id="ID",sort = FALSE) 

dat_2 <- data.frame(dat_1[,c("ID","taxonomy")],
                    dat_1[,names(abun)[2:ncol(abun)]],check.names = FALSE)
dat_2 <- subset(dat_2,select = -c(ID))

#Sum the abundance values of species annotations
dat_sum <- aggregate(dat_2[,2:ncol(dat_2)],by=list(dat_2$taxonomy),sum)
names(dat_sum)[1] <- "Taxonomy"
dat_sum <- dat_sum[order(dat_sum$Taxonomy,decreasing = FALSE),]

write.table(dat_1,paste0(outFile,".contig.with.tax.txt"),row.names = F,sep = '\t',quote = F)
write.table(dat_sum,paste0(outFile,".taxonomy.txt"),row.names = F,sep = '\t',quote = F)
