nextflow.enable.dsl = 2

params.cdhitsfa = "04.predict/cdhit/virus.cdhit.fa"
params.reads = "01.QC/${id}/*{1,2}.fq.gz"

params.outdir = "06.abundance/map/${id}"

Channel
    .fromFilePairs( params.reads )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .view()

process map{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path cdhitsfa
    tuple val(prefix),path(reads)

    output:
    path("out*")

    script:
    """
    /share/app/bowtie2/2.4.1/bowtie2  -p 16  -x ${cdhitsfa} -1 ${prefix}1.fq.gz -2 ${prefix}2.fq.gz   -S out.sam
    /share/app/samtools/1.14/samtools-1.14/samtools view --threads 16 -b -S out.sam > out.bam
    /share/app/samtools/1.14/samtools-1.14/samtools sort -o out.sort.bam   --threads 16   out.bam
    /share/app/coverm/0.6.1/coverm filter --bam-files out.sort.bam --output-bam-files out.sort.filter.bam --threads 16 --min-read-percent-identity 95
    /share/app/samtools/1.14/samtools-1.14/samtools index    -@ 16 out.sort.filter.bam
    rm -rf out.bam out.sam

    """
}


workflow{

    data1 = channel.fromPath(params.cdhitsfa)
    data2 = channel.fromFilePairs(params.reads)
    map(data1,data2)

}
