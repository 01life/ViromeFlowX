process BOWTIE2 {
    
    tag "$id"

    label 'process_single'
    
    input:
    path(index)
    tuple val(id),path(reads1),path(reads2)

    output:    
    tuple val(id),path("${id}.filter.bam"),emit:"filter_bam"
    tuple val(id),path("${id}.filter.bam.bai"),emit:"filter_bam_bai"

    script:
    """
    
    bowtie2 -p ${task.cpus} -x virus.fa -1 ${reads1} -2 ${reads2} -S ${id}.sam

    samtools sort --threads ${task.cpus} ${id}.sam -o ${id}.sorted.bam
    
    coverm filter --bam-files ${id}.sorted.bam --output-bam-files ${id}.filter.bam --threads ${task.cpus} --min-read-percent-identity 95
    
    samtools index -@ ${task.cpus} ${id}.filter.bam
    
    """
}