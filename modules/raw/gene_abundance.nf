nextflow.enable.dsl = 2

params.map = "06.abundance/map/${id}/out.sort.filter.bam"
params.prokka = "04.predict/prokka/vir.bed"
params.outdir = "06.abundance/gene"

process gene_abundance{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/${id}"

    input:
    path map
    path prokka

    output:
    path("flagstat")
    path("gene.count")
    path("rp")
    path("rpkm"),emit:rpkm
    path("total.reads")

    script:
    """
    /share/app/bedtools/2.27.1/bedtools multicov -bams ${map} -bed ${prokka} > gene.count
    /share/app/samtools/1.14/samtools-1.14/samtools flagstat  --threads 16   ${map} > flagstat
    perl /share/app/get_stat/0.1/get_stat.pl flagstat    > total.reads
    perl /share/app/cal_RPKM/0.1/cal_RPKM.pl total.reads gene.count flagstat > rp
    cut -f 4,8 rp > rpkm

    """
}

process gene_cp{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir '06.abundance/gene/result'

    input:
    path rpkm

    output:
    path("${id}.rpkm")

    script:
    """
    cp ${rpkm} ${id}.rpkm

    """

}

workflow{

    data1 = channel.fromPath(params.map)
    data2 = channel.fromPath(params.prokka)
    gene_abundance(data1,data2)

    gene_cp(gene_abundance.out.rpkm)

}
