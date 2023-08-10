
process KRAKEN2 {
    
    tag "$id"

    label 'process_high'
    
    publishDir "${params.outdir}/08.profile/Kraken2/${id}",mode:'copy'

    input:
    tuple val(id),path(reads1)
    tuple val(id),path(reads2)

    output:
    path("${id}*.xls")
    path("${id}_path_mapping.list"),emit:"mapping"

    when:
    task.ext.when == null || task.ext.when

    script:
    """

    kraken2 --db ${params.kraken2_db} --threads ${task.cpus} --report ${id}_kreport.xls --paired ${reads1} ${reads2} > ${id}_kraken.xls

    parallel --xapply "bracken -d ${params.kraken2_db} -i ${id}_kreport.xls -o ${id}_bracken_{2}.xls -l {1} -t ${task.cpus} -r 150 ; python ${params.nfcore_bin}/kreport2mpa.py --no-intermediate-ranks --display-header -r ${id}_kreport_bracken_{2}.xls -o ${id}_bracken_{2}_mpa.xls " ::: D P C O F G S :::  domains phylums classes orders families genuses species

    ls \$PWD/${id}_bracken_*.xls |sed 's/^/${id}\t/g' > ${id}_path_mapping.list

    rm -rf ${id}_kraken.xls

    """

}
