
process virfinder {

    tag "$id"

    label 'process_single'
    
    publishDir "${params.outdir}/03.identify/VirFinder",mode:'copy'

    input:
    tuple val(id),path(contigs)

    output:
    path("${id}/",type:'dir')
    tuple val(id),path("${id}/VirFinder.out.filter.id"),emit:"virfinderid"

    script:
    """
    mkdir ${id}
    Rscript /share/app/VirFinder/0.1/VirFinder.R ${contigs} VirFinder.out
    awk '\$3>0.7' VirFinder.out | awk '\$4<0.05' > VirFinder.out.filter
    cut -f1 VirFinder.out.filter > VirFinder.out.filter.id
    mv VirFinder.out* ${id}

    """

}