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
    
    bowtie2 -p 16 -x virus.fa -1 ${reads1} -2 ${reads2} -S ${id}.sam

    samtools sort --threads 16 ${id}.sam -o ${id}.sorted.bam
    
    /ehpcdata/PM/DATA/RD23010035/app/coverm/0.6.1/coverm filter --bam-files ${id}.sorted.bam --output-bam-files ${id}.filter.bam --threads 16 --min-read-percent-identity 95
    
    samtools index -@ 16 ${id}.filter.bam
    
    """
}