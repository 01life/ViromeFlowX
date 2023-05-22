process merge_virome {
    tag "$id"

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

//合并到cdhit!
// process merge_out{

//     publishDir "${params.outdir}/03.identify/merge/",mode:'copy'

//     input:
//     path virus

//     output:
//     path("merge.virus.fa.gz")

//     script:
//     """
//     cat ${virus} > merge.virus.fa
//     gzip merge.virus.fa

//     """


// }