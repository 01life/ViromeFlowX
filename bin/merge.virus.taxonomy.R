
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

#get data
all.id <- read.table(virus.id,sep = '\t') 

refseq_genome <- read.table(refseq_genome, header = T,sep = '\t')
crAss.id <- read.table(crAassphage, header = T,sep = '\t')

refseq_protein <- read.table(refseq_protein, header = T,sep = '\t')
pfam <- read.table(pfam, header = T,sep = '\t')
demovir <- read.table(demovir, header = T,sep = '\t',check.names = F)

#1、refseq_genome
#2、crAssphage checking
#3、refseq_protein database
#4、pfam(Selection from refseq_protein results)
#5、Demovir database
#merge result of 1、3、4、5

#-------------------------------------------
#1、refseq_genome
#Pick out the contigs IDs that are not annotated in the refseq_genome database for step 2
all.id_1 <- all.id[!all.id$V1 %in% refseq_genome$ID,1]
df_genome <- refseq_genome
names(df_genome) <- c("ID","taxonomy")
write.table(df_genome,paste0(output,"/refseq_genome.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#-------------------------------------------
#2、crAssphage checking
#Based on the results of step 1, take the intersection of the two sets and pick out the annotated IDs as the final result for crAssphage detection
crAss.class.id <- intersect(all.id_1,crAss.id$ID)
write.table(crAss.class.id,paste0(output,"/crAss-like.classified.id"),row.names = F,col.names = F,quote = F)
#Pick out the unannotated IDs for the next step (step 3)
all.id_2 <- all.id_1[!all.id_1 %in% crAss.class.id]

#-------------------------------------------
#3、refseq_protein database
#Based on the results of step 2, take the intersection of the two sets and pick out the annotated IDs as the result for refseq_protein
protein.class.id <- intersect(all.id_2,refseq_protein$ID)

#The annotated IDs will be used for the next step (step 5, i.e., Demovir database)
all.id_3 <- all.id_2[!all.id_2 %in% protein.class.id]

#3.1、pfam(Selection from refseq_protein results)
#Based on the annotation results from step 3, take the intersection of the two sets and pick out the annotated IDs as the final result for pfam
pfam.class.id <- intersect(protein.class.id,pfam$ID)
df_pfam <- pfam[match(pfam.class.id,pfam$ID),]
names(df_pfam) <- c("ID","taxonomy")
write.table(df_pfam,paste0(output,"/pfam.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#3.2、refseq_protein result
#Pick out the contigs that were not annotated in the pfam database, which will be the final result for the protein database
protein.class.id_1 <- protein.class.id[!protein.class.id %in% pfam.class.id]
df_protein <- refseq_protein[match(protein.class.id_1,refseq_protein$ID),]
names(df_protein) <- c("ID","taxonomy")
write.table(df_protein,paste0(output,"/refseq_protein.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#-------------------------------------------
#4、Demovir database
#According to the annotation results of step 3, take the intersection of both and select the annotated IDs as the final result for the Demovir database
demovir.class.id <- intersect(all.id_3,demovir$ID)
df_demovir <- demovir[match(demovir.class.id,demovir$ID),]
names(df_demovir) <- c("ID","taxonomy")
write.table(df_demovir,paste0(output,"/demovir.contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)

#-------------------------------------------
#contigs id that have not been annotated in any database
#all.id_4 <- all.id_3[!all.id_3 %in% demovir.class.id]

#Merge the results of 1, 3.1, 3.2, and 4
merge_df <- rbind(df_genome,df_pfam,df_protein,df_demovir)
write.table(merge_df,paste0(output,"/contigs.taxonomy.txt"),row.names = F,sep = '\t',quote = F)
print("Output：contigs.taxonomy.txt")






