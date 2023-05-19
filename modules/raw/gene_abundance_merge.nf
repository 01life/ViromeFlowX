nextflow.enable.dsl = 2

params.rpkms = "06.abundance/gene/result/*.rpkm"
params.outdir = "06.abundance/gene"


process gene_merge{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path rpkms

    output:
    path("virus.gene.rpkm.pr")

    script:

    """
    python /share/app/merge_tables/0.1/merge_tables.py ${rpkms} > virus.gene.rpkm.pr

    """

}


workflow{

    data = channel.fromPath(params.rpkms)
    gene_merge(data)

}
