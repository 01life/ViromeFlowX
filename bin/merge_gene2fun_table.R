##用于合并功能注释表与基因丰度表
library("optparse")

option_list = list(
  make_option(c("--map"), type = "character",help = "functional map table"),
  make_option(c("--rpkm"),type = "character",help = "gene rpkm table"),
  make_option(c("-o","--output"),type = "character",help = "Output file name")
)
opt <- parse_args(OptionParser(option_list=option_list), positional_arguments = TRUE)

funTable <-  opt$options$map
geneAbu <-   opt$options$rpkm
outputFile <- opt$options$output

mapTable <- read.table(funTable)
names(mapTable) <- c("ID","FUNID")

gene_abu <- read.table(geneAbu,header = TRUE,sep = '\t')

if(ncol(gene_abu)==2){
  #只有一个样本的情况，去掉丰度全为0的行
  gene_abu <- gene_abu[gene_abu[,2]>0,]
  #合并、丰度求和
  df <- merge(mapTable,gene_abu,by = "ID",sort = FALSE)
  df_sum <- aggregate(df[,3],
                      by=list(df$FUNID),sum)
  names(df_sum)[2] <- names(gene_abu)[2]
  
}else{
	#多个样本的情况
  gene_abu <- gene_abu[rowSums(gene_abu[,2:ncol(gene_abu)])>0,]
  df <- merge(mapTable,gene_abu,by = "ID",sort = FALSE)
  df_sum <- aggregate(df[,3:ncol(df)],
                      by=list(df$FUNID),sum)
}

names(df_sum)[1] <- ""

write.table(df_sum,outputFile,sep = '\t',quote = F,row.names = F)



