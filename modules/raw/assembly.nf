nextflow.enable.dsl = 2

params.reads = "01.QC/${meta.id}/*{1,2}.fq.gz"
params.outdir = "02.assembly"

Channel
    .fromFilePairs( params.reads )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .view()

process assembly {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/${meta.id}"

    input:
    tuple val(meta),path(reads)

    output:
    path("1k*")

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
//这里用\$PWD 获取当前目录替代了特定的绝对路径。因为nextflow有自己的工作目录work/
    python /share/app/SPAdes/3.11.1/bin/spades.py -o \$PWD --meta -1 ${prefix}1.fq.gz -2 ${prefix}2.fq.gz -t 32
    perl /share/app/deal_fa/0.1/deal_fa.pl contigs.fasta A1 >contigs
    perl /share/app/deal_fa/0.1/deal_fa.pl scaffolds.fasta A1 >scaffolds
    /share/app/seqtk/1.3-r106/seqtk seq -L 1000 contigs >1k.contigs
    pigz contigs scaffolds
    gzip -c 1k.contigs > 1k.contigs.gz
    rm -rf K* corrected misc tmp assembly* before* contigs* dataset* first* input params.txt scaffolds*

    """

}

workflow{
    data = channel.fromFilePairs(params.reads) //此处如何衔接，能否调用其他nf的过程结果qc.out，还是直接读取文件
//  data = channel.fromFilePairs(qc_rmhost.out.reads)
    assembly(data)
}
