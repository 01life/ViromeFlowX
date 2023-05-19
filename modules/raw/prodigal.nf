nextflow.enable.dsl = 2

params.cdhits = "04.predict/cdhit/virus.cdhit.fa"
params.outdir = "04.predict/prodigal"

process prodigal {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path cdhits

    output:
    path("viral*")

    script:
    """
    /share/app/prodigal/2.6.3/prodigal -a viral.pep  -d viral.cds -f gff   -i ${cdhits}   -o viral.gene.gff -p meta -q

    """

}

workflow{
    data = channel.fromPath(params.cdhits)
    prodigal(data)

}
