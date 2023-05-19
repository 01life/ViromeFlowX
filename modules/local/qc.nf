
process QC {
    tag "$id"
    label 'process_single'

    // queue 'meta_mapping2'

    publishDir "${params.outdir}/01.CleanData/",mode:'copy'

    input:
    tuple val(id),path(reads)

    output:
    tuple val(id),path("${id}/*1.fq.gz"),emit:"clean_reads1"
    tuple val(id),path("${id}/*2.fq.gz"),emit:"clean_reads2"
    path ("versions.yml"), emit: "versions"

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    # mkdir ${id}
    java -jar /share/app/SOP/pipeline/qc.jar -s ${id} -i ${reads} -o ${id} -m ${params.QC_mode} -align bowtie2 -db ${params.bowtie2_index} -t 16 -adapters ${params.adapters}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        java: \$(java --version | sed 's/java //g')
    END_VERSIONS
    
    """
    

}
