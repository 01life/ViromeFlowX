process contig_abundance{

    publishDir "${params.outdir}/06.abundance/contig/${id}",mode:'copy'

    input:
    path filter_bam

    output:
    path("sort.filter.cov")
    path("sort.filter.cov.contig")
    path("sort.filter.dpmean")
    path("sort.filter.cov.contig.abundance"),emit:"abundance"

    script:
    """
    /share/app/coverm/0.6.1/coverm contig  -b ${filter_bam}  -m trimmed_mean -t 16 --output-file sort.filter.dpmean
    /share/app/bedtools/2.27.1/bedtools genomecov -ibam ${filter_bam}  -bga   -pc   > sort.filter.cov
    perl /share/app/filter_contig_cov/0.1/filter_contig_cov.pl sort.filter.cov > sort.filter.cov.contig
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  sort.filter.cov.contig  sort.filter.dpmean > sort.filter.cov.contig.abundance

    """
}