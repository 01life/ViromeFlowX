process VIRSORTER {
    
    tag "$id"

    label 'process_single'

    publishDir "${params.outdir}/03.identify/VirSorter",mode:'copy'

    input:
    tuple val(id),path(contigs)

    output:
    path("${id}/*")
    tuple val(id),path("${id}/VirSorter.filter.id"),emit:"virsorterid"


    script:
    """
    mkdir ${id}
    #source activate vs2
    virsorter run --use-conda-off -w \$PWD -i ${contigs} -j ${task.cpus} -d ${params.virsorter2_db} all
    
    #grep -v lt2gene final-viral-score.tsv | awk -F "\t"  '{if(\$4>0.95 && \$6>5000 && \$7 >1 )print\$0}' > VirSorter95.filter

    grep -v lt2gene final-viral-score.tsv | awk '\$4>0.95' > VirSorter95.filter

    grep -v seqname VirSorter95.filter |  awk -F '|' '{print \$1}'  > VirSorter.filter.id
    rm -rf iter-0 log
    mv VirSorter* final* config.yaml ${id}

    """

}