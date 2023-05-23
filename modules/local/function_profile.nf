process function_profile{
    
    label 'process_single'

    container '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'

    publishDir "${params.outdir}/08.profile/functional",mode:'copy'

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