#version:0.1

args <- commandArgs(T)
if (length(args) < 2) {
  stop("Rscript *.R [input_fasta] [outfile]\n")
}

suppressMessages(library(VirFinder))

predResult <- VF.pred(inFaFile = args[1])
predResult$qvalue <- VF.qvalue(predResult$pvalue)

write.table(predResult,file = args[2],sep ="\t", 
				row.names = FALSE, 
				col.names = TRUE, 
				quote = FALSE)

