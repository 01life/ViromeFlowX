process build{

    publishDir "${params.outdir}/06.abundance/map/",mode:'copy'

    input:
    path(cdhitsfa)

    output:    
    path("db/",type:'dir'),emit:"index"

    script:
    """
    mkdir db
    bowtie2-build --threads 16 ${cdhitsfa} db/index

    """
}