process GENE {
    
    tag "$id"

    label 'process_single'

    publishDir "${params.outdir}/06.abundance/gene/${id}"

    input:
    path(prokka_bed)
    tuple val(id),path(filter_bam),path(index)

    output:
    path("flagstat")
    path("gene.count")
    path("${id}.rp")
    path("${id}.rpkm"),emit:rpkm
    path("total.reads")

    script:
    """
    /ehpcdata/PM/DATA/RD23010035/app/bedtools/2.27.1/bedtools multicov -bams ${filter_bam} -bed ${prokka_bed} > gene.count

    /ehpcdata/PM/DATA/RD23010035/app/samtools/1.14/samtools-1.14/samtools flagstat --threads 16 ${filter_bam} > flagstat

    perl /ehpcdata/PM/DATA/RD23010035/app/get_stat/0.1/get_stat.pl flagstat > total.reads

    perl /ehpcdata/PM/DATA/RD23010035/app/cal_RPKM/0.1/cal_RPKM.pl total.reads gene.count flagstat > ${id}.rp

    cut -f 4,8 ${id}.rp > ${id}.rpkm

    """
}