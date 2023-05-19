nextflow.enable.dsl = 2

params.contigs = "02.assembly/${id}/1k.contigs"
params.virsorterid = "03.identify/${id}/VirSorter/VirSorter.filter.id"
params.virfinderid = "03.identify/${id}/VirFinder/VirFinder.out.filter.id"
params.outdir = "03.identify/merge"

process merge_in {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/${id}"

    input:
    path contigs
    path virfinderid
    path virsorterid

    output:
    path("virus.fa"),emit=virus
    path("uniq.id")

    script:
    """
    cat ${virfinderid} ${virsorterid} | cut -f1 |sort | uniq > uniq.id
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --fformat fasta  uniq.id ${contigs} > virus.fa

    """

}

process merge_out{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path virus

    output:
    path("merge.virus.fa.gz")

    script:
    """
    cat ${virus} > merge.virus.fa
    gzip merge.virus.fa

    """


}

workflow{
    data = channel.fromPath(params.contigs)
    data1 = channel.fromPath(params.virfinderid)
    data2 = channel.fromPath(params.virsorterid)
    merge_in(data,data1,data2)
    merge_out(merge_in.out.virus)
}
