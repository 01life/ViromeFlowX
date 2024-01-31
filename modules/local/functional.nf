process FUNCTIONAL {
    
    label 'process_low'

    publishDir "${params.outdir}/08.profile/functional",mode:'copy'

    input:
    tuple val(db),path(map_db),path(rpkms)

    output:
    path("*.pr")

    when: 
    map_db.size() > 0

    script:

    """
    Rscript ${params.nfcore_bin}/merge_gene2fun_table.R --map ${map_db} --rpkm ${rpkms} -o ${db}.pr
    Rscript ${params.nfcore_bin}/cal_relab_gene.R ${db}.pr ${db}_relab.pr

    """

}