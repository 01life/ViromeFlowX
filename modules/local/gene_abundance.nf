process GENE {
    
    tag "$id"

    label 'process_low'

    publishDir "${params.outdir}/06.abundance/virusGene/${id}",mode:'copy'

    input:
    path(prokka_bed)
    tuple val(id),path(filter_bam),path(index)

    output:
    path("flagstat")
    path("gene.count")
    path("${id}.rpkm"),emit:rpkm
    path("total.reads")

    script:
    """
    bedtools multicov -bams ${filter_bam} -bed ${prokka_bed} > gene.count

    samtools flagstat --threads ${task.cpus} ${filter_bam} > flagstat

    perl ${params.nfcore_bin}/get_stat.pl flagstat > total.reads

    perl ${params.nfcore_bin}/cal_RPKM.pl total.reads gene.count flagstat > ${id}.pr

    cut -f 4,8 ${id}.pr > ${id}.rpkm

    """
}