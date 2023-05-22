process virsorter {
    tag "$id"

    publishDir "${params.outdir}/03.identify/VirSorter",mode:'copy'

    input:
    tuple val(id),path(contigs)

    output:
    tuple val(id),path("${id}/VirSorter.filter.id"),emit:"virsorterid"

    script:
    """
    mkdir ${id}
    source activate vs2
    virsorter run -w \$PWD -i ${contigs} -j 16 -d /virsort/db all
    grep -v lt2gene final-viral-score.tsv | awk '\$4>0.95' > VirSorter95.filter
    grep -v seqname VirSorter95.filter |  awk -F '|' '{print \$1}'  > VirSorter.filter.id
    rm -rf iter-0 log
    mv VirSorter* final* ${id}

    """

}