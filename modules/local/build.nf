process build{

    label 'process_single'

    container '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'

    publishDir "${params.outdir}/06.abundance/map/",mode:'copy'

    input:
    path(cdhitsfa)

    output:    
    path("db/",type:'dir'),emit:"index"

    script:
    """
    mkdir db
    /share/app/bowtie2/2.4.1/bowtie2-build --threads 16 ${cdhitsfa} db/index

    """
}