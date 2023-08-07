process CHECKV {

    tag "$id"

    label 'process_low'

    conda '/home/yangying/tools/checkv'

    publishDir "${params.outdir}/03.identify/CheckV",mode:'copy'

    input:
    tuple val(id),path(virus_fa)

    output:
    path("${id}/*")
    path("${id}/${id}_proviruses_viruses.fna"),emit:"viruses"

    script:
    """
    checkv end_to_end ${virus_fa} ${id} -d ${params.checkv_db} -t ${task.cpus}

    cat ${id}/proviruses.fna ${id}/viruses.fna > ${id}/${id}_proviruses_viruses.fna

    rm -rf ${id}/tmp

    """

}