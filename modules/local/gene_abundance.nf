process gene_abundance{

    
    publishDir "${params.outdir}/06.abundance/gene/${id}"

    input:
    tuple val(id),path(filter_bam),path(prokka_faa)

    output:
    path("flagstat")
    path("gene.count")
    path("rp")
    path("rpkm"),emit:rpkm
    path("total.reads")

    script:
    """
    bedtools multicov -bams ${filter_bam} -bed ${prokka_faa} > gene.count
    samtools flagstat --threads 16 ${filter_bam} > flagstat
    perl /share/app/get_stat/0.1/get_stat.pl flagstat > total.reads
    perl /share/app/cal_RPKM/0.1/cal_RPKM.pl total.reads gene.count flagstat > rp
    cut -f 4,8 rp > rpkm

    """
}