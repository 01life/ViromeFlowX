process merge_virome {
   
    tag "$id"

    label 'process_low'

    container '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    
    publishDir "${params.outdir}/03.identify/merge/",mode:'copy'

    input:
    tuple val(id),path(contigs),path(virfinderid),path(virsorterid)

    output:
    path("${id}/",type:'dir')
    path("${id}/${id}_virus.fa"),emit:'virus'

    script:
    """
    mkdir ${id}
    cat ${virfinderid} ${virsorterid} | cut -f1 |sort | uniq > uniq.id
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --fformat fasta  uniq.id ${contig} > ${id}_virus.fa
    mv ${id}_virus.fa uniq.id ${id}

    """

}