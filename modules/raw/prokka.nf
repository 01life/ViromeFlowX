nextflow.enable.dsl = 2

params.cdhits = "04.predict/cdhit/virus.cdhit.fa"
params.outdir = "04.predict/prokka"

process prokka {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path cdhits

    output:
    path("vir.bed")
    path("virus.prokka*")

    script:
    """
    prokka   --outdir $PWD --force --prefix virus.prokka   --metagenome   --cpus 16   ${cdhits}
    cat virus.prokka.gff | grep CDS | cut -f 1,4,5,9 | awk -F ';' '{print $1}' | sed 's/ID=//' > vir.bed

    """

}

workflow{
    data = channel.fromPath(params.cdhits)
    prokka(data)

}
