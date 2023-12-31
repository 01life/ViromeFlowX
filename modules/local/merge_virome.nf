process MERGE {
   
    tag "$id"

    label 'process_low'

    publishDir "${params.outdir}/03.identify/merge/",mode:'copy'

    input:
    tuple val(id),path(contigs),path(virfinderid),path(virsorterid)

    output:
    path("${id}/",type:'dir')
    tuple val(id),path("${id}/${id}_virus.fa"),emit:'virus'

    script:
    """
    mkdir ${id}
    cat ${virfinderid} ${virsorterid} | cut -f1 |sort | uniq > uniq.id
    perl ${params.nfcore_bin}/fishInWinter.pl  --fformat fasta  uniq.id ${contigs} > ${id}_virus.fa
    mv ${id}_virus.fa uniq.id ${id}

    """

}