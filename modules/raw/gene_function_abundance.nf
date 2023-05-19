nextflow.enable.dsl = 2

params.map_caz = "07.functional/map_CAZy_uniref90.out.txt"
params.map_egg = "07.functional/map_eggnog_uniref90.out.txt"
params.map_go = "07.functional/map_go_uniref90.out.txt"
params.map_ko = "07.functional/map_ko_uniref90.out.txt"
params.map_level = "07.functional/map_level4ec_uniref90.out.txt"
params.map_pfam = "07.functional/map_pfam_uniref90.out.txt"
params.rpkms = "06.abundance/gene/virus.gene.rpkm.pr"
params.outdir = "08.profile/functional"


process gene_function_abundance{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path map_caz
    path map_egg
    path map_go
    path map_ko
    path map_level
    path map_pfam
    path rpkms

    output:
    path("*.pr")

    script:

    """
    Rscript /share/app/merge_gene2fun_table/0.1/merge_gene2fun_table.R --map ${map_caz} --rpkm ${rpkms} -o CAZy.pr
    Rscript /share/app/cal_relab_gene/0.1/cal_relab_gene.R CAZy.pr CAZy_relab.pr
    Rscript /share/app/merge_gene2fun_table/0.1/merge_gene2fun_table.R --map ${map_egg} --rpkm ${rpkms} -o eggnog.pr
    Rscript /share/app/cal_relab_gene/0.1/cal_relab_gene.R eggnog.pr eggnog_relab.pr
    Rscript /share/app/merge_gene2fun_table/0.1/merge_gene2fun_table.R --map ${map_go} --rpkm ${rpkms} -o go.pr
    Rscript /share/app/cal_relab_gene/0.1/cal_relab_gene.R go.pr go_relab.pr
    Rscript /share/app/merge_gene2fun_table/0.1/merge_gene2fun_table.R --map ${map_ko} --rpkm ${rpkms} -o ko.pr
    Rscript /share/app/cal_relab_gene/0.1/cal_relab_gene.R ko.pr ko_relab.pr
    Rscript /share/app/merge_gene2fun_table/0.1/merge_gene2fun_table.R --map ${map_level} --rpkm ${rpkms} -o level4ec.pr
    Rscript /share/app/cal_relab_gene/0.1/cal_relab_gene.R level4ec.pr level4ec_relab.pr
    Rscript /share/app/merge_gene2fun_table/0.1/merge_gene2fun_table.R --map ${map_pfam} --rpkm ${rpkms} -o pfam.pr
    Rscript /share/app/cal_relab_gene/0.1/cal_relab_gene.R pfam.pr pfam_relab.pr


    """

}


workflow{

    data1 = channel.fromPath(params.map_caz)
    data2 = channel.fromPath(params.map_egg)
    data3 = channel.fromPath(params.map_go)
    data4 = channel.fromPath(params.map_ko)
    data5 = channel.fromPath(params.map_level)
    data6 = channel.fromPath(params.map_pfam)
    data7 = channel.fromPath(params.rpkms)

    gene_function_abundance(data1,data2,data3,data4,data5,data6,data7)

}
