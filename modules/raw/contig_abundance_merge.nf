nextflow.enable.dsl = 2

params.contigs = "06.abundance/contig/result/*.abundance"
params.outdir = "06.abundance/contig"


process contig_merge{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path contigs

    output:
    path("virus.contigs.abun.txt")

    script:

    """
    python /share/app/merge_tables/0.1/merge_tables.py ${contigs} > virus.contigs.abun.txt
    sed -i 's/.sort.filter.cov.contig//g' virus.contigs.abun.txt

    """

}


workflow{
    data = channel.fromPath(params.contigs)
    contig_merge(data)

}
