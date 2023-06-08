
library("optparse")

option_list <- list(
  make_option(c("--id"), type = "character",
              help = "virus contigs id"),
  make_option(c("--refseq_genome"), type = "character",
              help = "taxonomy format "),
  make_option(c("--crAassphage"), type = "character",
              help = "taxonomy id "),
  make_option(c("--refseq_protein"), type = "character",
              help = "taxonomy format "),
  make_option(c("--pfam"), type = "character",
              help = "taxonomy format "),
  make_option(c("--demovir"), type = "character",
              help = "taxonomy format "),
  make_option(c("--output"), type = "character",default = ".",
              help = "output dir ")
)
opt <- parse_args(OptionParser(option_list=option_list), positional_arguments = TRUE)

virus.id <- opt$options$id
refseq_genome  <- opt$options$refseq_genome
crAassphage  <- opt$options$crAassphage
refseq_protein  <- opt$options$refseq_protein
pfam  <- opt$options$pfam
demovir <- opt$options$demovir
output <- opt$options$output

dir.create(output,showWarnings = FALSE)

#获取数据
all.id <- read.table(virus.id,sep = '\t') 

refseq_genome <- read.table(refseq_genome, header = T,sep = '\t')
crAss.id <- read.table(crAassphage, header = T,sep = '\t')

refseq_protein <- read.table(refseq_protein, header = T,sep = '\t')
pfam <- read.table(pfam, header = T,sep = '\t')
demovir <- read.table(demovir, header = T,sep = '\t',check.names = F)

#1、refseq_genome
#2、crAssphage检测
#3、refseq_protein数据库
#4、pfam(从refseq_protein结果中筛选)
#5、Demovir数据库
#合并1、3、4、5结果

#-------------------------------------------
#1、refseq_genome
#挑出未注释到refseq_genome数据库的contigs id用于步骤2
all.id_1 <- all.id[!all.id$V1 %in% refseq_genome$ID,1]
df_genome <- refseq_genome
names(df_genome) <- c("ID","taxonomy")
write.table(df_genome,paste0(output,"/refseq_genome.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#-------------------------------------------
#2、crAssphage检测
#根据步骤1的结果，取两者交集，挑出已注释的id作为crAssphage检测的最终结
crAss.class.id <- intersect(all.id_1,crAss.id$ID)
write.table(crAss.class.id,paste0(output,"/crAss-like.classified.id"),row.names = F,col.names = F,quote = F)
#挑出未注释的id用于下一步(步骤3)
all.id_2 <- all.id_1[!all.id_1 %in% crAss.class.id]

#-------------------------------------------
#3、refseq_protein数据库
#根据步骤2的结果,取两者交集，挑出注释的id，作为refseq_protein的结果
protein.class.id <- intersect(all.id_2,refseq_protein$ID)

#挑出未注释的id用于下一步(步骤5，即Demovir数据库)
all.id_3 <- all.id_2[!all.id_2 %in% protein.class.id]

#3.1、pfam(从refseq_protein结果中筛选)
#根据步骤3的注释结果，取两者交集，挑出注释的id作为pfam的最终结果
pfam.class.id <- intersect(protein.class.id,pfam$ID)
df_pfam <- pfam[match(pfam.class.id,pfam$ID),]
names(df_pfam) <- c("ID","taxonomy")
write.table(df_pfam,paste0(output,"/pfam.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#3.2、refseq_protein的结果
#挑出未注释到pfam数据库的contigs,即作为protein数据库的最终结果
protein.class.id_1 <- protein.class.id[!protein.class.id %in% pfam.class.id]
df_protein <- refseq_protein[match(protein.class.id_1,refseq_protein$ID),]
names(df_protein) <- c("ID","taxonomy")
write.table(df_protein,paste0(output,"/refseq_protein.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#-------------------------------------------
#4、Demovir数据库
#根据步骤3的注释结果，取两者交集，挑出注释的id作为demovir数据库的最终结果
demovir.class.id <- intersect(all.id_3,demovir$ID)
df_demovir <- demovir[match(demovir.class.id,demovir$ID),]
names(df_demovir) <- c("ID","taxonomy")
write.table(df_demovir,paste0(output,"/demovir.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#-------------------------------------------
#剩余没注释到任何数据库的contigs id
#all.id_4 <- all.id_3[!all.id_3 %in% demovir.class.id]

#合并1、3.1、3.2、4结果
merge_df <- rbind(df_genome,df_pfam,df_protein,df_demovir)
write.table(merge_df,paste0(output,"/contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)
print("Output：contigs.taxonomy.txt")






