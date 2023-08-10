process FUNCTIONAL {
    
    label 'process_low'

    publishDir "${params.outdir}/08.profile/functional",mode:'copy'

    input:
    path(map_caz)
    path(map_egg)
    path(map_go)
    path(map_ko)
    path(map_level)
    path(map_pfam)
    path(rpkms)

    output:
    path("*.pr")

    script:

    """
    Rscript ${params.nfcore_bin}/merge_gene2fun_table.R --map ${map_caz} --rpkm ${rpkms} -o CAZy.pr
    Rscript ${params.nfcore_bin}/cal_relab_gene.R CAZy.pr CAZy_relab.pr

    Rscript ${params.nfcore_bin}/merge_gene2fun_table.R --map ${map_egg} --rpkm ${rpkms} -o eggnog.pr
    Rscript ${params.nfcore_bin}/cal_relab_gene.R eggnog.pr eggnog_relab.pr

    Rscript ${params.nfcore_bin}/merge_gene2fun_table.R --map ${map_go} --rpkm ${rpkms} -o go.pr
    Rscript ${params.nfcore_bin}/cal_relab_gene.R go.pr go_relab.pr

    Rscript ${params.nfcore_bin}/merge_gene2fun_table.R --map ${map_ko} --rpkm ${rpkms} -o ko.pr
    Rscript ${params.nfcore_bin}/cal_relab_gene.R ko.pr ko_relab.pr

    Rscript ${params.nfcore_bin}/merge_gene2fun_table.R --map ${map_level} --rpkm ${rpkms} -o level4ec.pr
    Rscript ${params.nfcore_bin}/cal_relab_gene.R level4ec.pr level4ec_relab.pr
    
    Rscript ${params.nfcore_bin}/merge_gene2fun_table.R --map ${map_pfam} --rpkm ${rpkms} -o pfam.pr
    Rscript ${params.nfcore_bin}/cal_relab_gene.R pfam.pr pfam_relab.pr


    """

}