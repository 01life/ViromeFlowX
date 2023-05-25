process BUILD{

    label 'process_single'

    publishDir "${params.outdir}/06.abundance/map/",mode:'copy'

    input:
    path(cdhitsfa)

    output:    
    path("db/",type:'dir'),emit:"index"

    script:
    """
    mkdir db
    /ehpcdata/PM/DATA/RD23010035/app/bowtie2/2.4.1/samtools-1.14/bowtie2-build --threads 16 ${cdhitsfa} db/index

    """
}