
process CLEAN {

    tag "$id"
    
    label 'process_single'

    // queue 'meta_mapping2'

    publishDir "${params.outdir}/01.QC/",mode:'copy'

    input:
    tuple val(id),path(reads1)
    tuple val(id),path(reads2)

    output:
    tuple val(id),path("${id}/*1.fq.gz"),emit:"clean_reads1"
    tuple val(id),path("${id}/*2.fq.gz"),emit:"clean_reads2"

    script:
    def trim_options = params.trim_options ?: ""

    """
    java -jar ${params.nfcore_bin}/trimmomatic.jar PE -threads ${task.cpus} ${reads1} ${reads2} ${id}_paired_1.fq ${id}_unpaired_1.fq ${id}_paired_2.fq ${id}_unpaired_2.fq ${trim_options}

    python ${params.nfcore_bin}/rmhost_with_bowtie2.py -i1 ${id}_paired_1.fq -i2 ${id}_paired_2.fq -db ${params.host_db} -t ${task.cpus} -o ${id}/${id}

    rm -rf ${id}*.fq

    rename rmhost clean ${id}/${id}_rmhost_*.fq
    
    pigz ${id}/${id}*.fq
    
    """
    

}
