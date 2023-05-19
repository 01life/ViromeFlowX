nextflow.enable.dsl = 2

params.reads = "reads/*{1,2}.fastq.gz"
params.outdir = "01.QC"

process trim {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/${meta.id}"

    input:
    tuple val(meta),path(reads)
    path fa
    path index

    output:
    tuple val(meta),path("*_1.fq.gz"),path("*_2.fq.gz"),emit:"reads"
    path("*_single.fq.gz")

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    java -jar /share/app/trimmomatic/0.39/trimmomatic.jar PE  -threads 16 -phred33 ${prefix}1.fastq.gz ${prefix}2.fastq.gz ${prefix}_trim_1.fq ${prefix}_trim_single.fq_1 ${prefix}_trim_2.fq ${prefix}_trim_single.fq_2 ILLUMINACLIP:${fa}:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:15 MINLEN:50
    cat ${prefix}_trim_single.fq_1 ${prefix}_trim_single.fq_2 > ${prefix}_trim_single.fq
    /share/app/soap2/2.22/soap2 -a ${prefix}_trim_1.fq -b ${prefix}_trim_2.fq -D ${index} -o ${prefix}_trim.pe -M 4 -l 32 -r 1 -m 400 -x 600 -2 ${prefix}_trim.se -v 8 -c 0.9 -S -p 16  2> ${prefix}_trimsoap2.pe.log
    /share/app/soap2/2.22/soap2 -a ${prefix}_trim_single.fq  -D ${index} -o ${prefix}_trim.single -M 4 -l 32 -r 1 -v 8 -c 0.9 -S -p 16  2> ${prefix}_trimsoap2.single.log
    parallel ::: "perl /share/app/get_rmhost_reads/0.1/get_rmhost_reads.pl -i ${prefix}_trim_1.fq -r ${prefix}_trim.pe:${prefix}_trim.se -o ${prefix}_trim_rmhost_1.fq -n /1 -z -q " "perl /share/app/get_rmhost_reads/0.1/get_rmhost_reads.pl -i ${prefix}_trim_2.fq -r ${prefix}_trim.pe:${prefix}_trim.se -o ${prefix}_trim_rmhost_2.fq -n /2 -z -q " "perl /share/app/get_rmhost_reads/0.1/get_rmhost_reads.pl -i ${prefix}_trim_single.fq -r ${prefix}_trim.single -o ${prefix}_trim_rmhost_single.fq  -z -q "
    """
    
}

workflow {
    data = channel
        .fromFilePairs(params.reads)
        .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!" }
        .map { row ->
            def meta = [:]
            meta.id           = row[0]
            meta.group        = 0
            return [ meta, row[1] ]
        }
        .view()

    input_rows = channel.empty()
        .map { id, group, sr1, sr2, lr -> id }
        .toList()
        .map { ids -> if( ids.size() != ids.unique().size() ) {exit 1, "ERROR: input samplesheet contains duplicated sample IDs!" } }

    fasta = channel.fromPath("/root/sunysh/data/TruSeq3-PE.fa")
    index = channel.fromPath("/root/sunysh/virus-db/flow_configure_data/hg38_2bwt_index/hg38.fa.index")
    trim(data,fasta,index)
}
