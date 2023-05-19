nextflow.enable.dsl = 2

params.cdhits = "04.predict/cdhit/virus.cdhit.fa"
params.outdir = "04.predict/cdhit/index"

process mapindex{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path cdhits

    output:
    path("virus.cdhit*")

    script:
    """
    /share/app/bowtie2/2.4.1/bowtie2-build  --threads 16  ${cdhits} ${cdhits}

    """
}


workflow{
    data = channel.fromPath(params.cdhits)
    mapindex(data)

}
