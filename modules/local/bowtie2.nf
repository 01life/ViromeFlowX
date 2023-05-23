process bowtie2{
    
    tag "$id"

    label 'process_single'

    container '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    
    publishDir "${params.outdir}/06.abundance/map/",mode:'copy'

    input:
    path index
    tuple val(id),path(reads1),path(reads2)

    output:    
    tuple val(id),path("${id}.sorted.bam")
    tuple val(id),path("${id}.filter.bam"),emit:"filter_bam"
    tuple val(id),path("${id}.filter.bam.csi"),emit:"filter_bam_csi"

    script:
    """

    /share/app/bowtie2/2.4.1/bowtie2 -p 16 -x ${index}/index -1 ${reads1} -2 ${reads2} -S ${id}.sam

    /share/app/samtools/1.14/samtools-1.14/samtools sort --threads 16 ${id}.sam -o ${id}.sorted.bam
    
    /share/app/coverm/0.6.1/coverm filter --bam-files ${id}.sorted.bam --output-bam-files ${id}.filter.bam --threads 16 --min-read-percent-identity 95
    
    /share/app/samtools/1.14/samtools-1.14/samtools index -@ 16 ${id}.filter.bam
    
    """
}