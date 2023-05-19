nextflow.enable.dsl = 2

params.map = "06.abundance/map/${id}/out.sort.filter.bam"
params.outdir = "06.abundance/contig"

process contig_abundance{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/${id}"

    input:
    path map

    output:
    path("sort.filter.cov")
    path("sort.filter.cov.contig")
    path("sort.filter.dpmean")
    path("sort.filter.cov.contig.abundance"),emit:abundance

    script:
    """
    /share/app/coverm/0.6.1/coverm contig  -b ${map}  -m trimmed_mean -t 16 --output-file sort.filter.dpmean
    /share/app/bedtools/2.27.1/bedtools genomecov -ibam ${map}  -bga   -pc   > sort.filter.cov
    perl /share/app/filter_contig_cov/0.1/filter_contig_cov.pl sort.filter.cov > sort.filter.cov.contig
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  sort.filter.cov.contig  sort.filter.dpmean > sort.filter.cov.contig.abundance

    """
}

process contig_cp{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir '06.abundance/contig/result'

    input:
    path abundance

    output:
    path("${id}*")

    script:
    """
    cp ${abundance} ${id}.sort.filter.cov.contig.abundance

    """

}

workflow{

    data = channel.fromPath(params.map)
    contig_abundance(data)

    contig_cp(contig_abundance.out.abundance)

}
