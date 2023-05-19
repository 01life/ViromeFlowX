nextflow.enable.dsl = 2

params.contigs = "02.assembly/${id}/1k.contigs.gz"
params.outdir = "03.identify"

process virfinder {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/${id}/VirFinder"

    input:
    path contigs

    output:
    path("VirFinder.out*")

    script:
    """
    Rscript /share/app/VirFinder/0.1/VirFinder.R ${contigs} VirFinder.out
    awk '\$3>0.7' VirFinder.out | awk '\$4<0.05' > VirFinder.out.filter
    cut -f1 VirFinder.out.filter > VirFinder.out.filter.id

    """

}

workflow{
    data = channel.fromPath(params.contigs)
    virfinder(data)

}
