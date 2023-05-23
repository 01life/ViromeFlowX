process bowtie2{
    
    tag "$id"

    label 'process_single'
    
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

    bowtie2 -p 16 -x ${index}/index -1 ${reads1} -2 ${reads2} -S ${id}.sam

    samtools sort --threads 16 ${id}.sam -o ${id}.sorted.bam
    
    /share/app/coverm/0.6.1/coverm filter --bam-files ${id}.sorted.bam --output-bam-files ${id}.filter.bam --threads 16 --min-read-percent-identity 95
    
    samtools index -@ 16 ${id}.filter.bam
    
    """
}