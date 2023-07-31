process CHECKV {

    tag "$id"

    label 'process_low'

    publishDir "${params.outdir}/03.identify/CheckV",mode:'copy'

    input:
    tuple val(id),path(virus_fa)

    output:
    path("${id}/*")
    path("${id}/${id}_proviruses_viruses.fna"),emit:"viruses"

    script:
    """
    # 合并所有样本中的病毒序列
    cat ${virus} > merge.virus.fa
    gzip merge.virus.fa

    checkv end_to_end ${virus_fa} ${id} -d ${params.checkv_db} -t ${task.cpus}

    cat ${id}/proviruses.fna ${id}/viruses.fna > ${id}/${id}_proviruses_viruses.fna

    rm -rf ${id}/tmp

    """

}