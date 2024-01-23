library('ComplexHeatmap')
library("circlize")
library('cowplot')
library('grid')

corr <- read.table("merge.exit.order.txt",header=T,check.names=F,row.names=1,sep="\t")

colors = structure(c("#f0f0f0","#31a354"),
		 names = c("0","1"))

colOrder <- colnames(corr)


pdf("Exit.Heatmap.pdf",width=14,height=5)

#as.matrix(corr)
sample_order <- Heatmap(as.matrix(corr),
    col=colors,
    width = unit(0.3*ncol(corr), "cm"), height = unit(0.3*nrow(corr), "cm"),
    show_heatmap_legend = FALSE,
     row_names_gp = gpar(fontsize = 10),
     column_names_gp = gpar(fontsize = 10),
    cluster_columns = FALSE)

sample_order
dev.off()
