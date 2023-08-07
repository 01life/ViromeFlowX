process CONTIG {

    tag "$id"

    label 'process_low'

    publishDir "${params.outdir}/06.abundance/virusContig/${id}",mode:'copy'

    input:
    tuple val(id),path(filter_bam)

    output:
    path("sort.filter.cov")
    path("sort.filter.cov.contig")
    path("sort.filter.dpmean")
    path("${id}.contig.abundance"),emit:"abundance"

    script:
    """
    coverm contig  -b ${filter_bam}  -m trimmed_mean -t ${task.cpus} --output-file sort.filter.dpmean
    
    bedtools genomecov -ibam ${filter_bam} -bga -pc > sort.filter.cov
    
    perl ${params.nfcore_bin}/filter_contig_cov.pl sort.filter.cov > sort.filter.cov.contig
    perl ${params.nfcore_bin}/fishInWinter.pl sort.filter.cov.contig  sort.filter.dpmean > ${id}.contig.abundance

    """
}