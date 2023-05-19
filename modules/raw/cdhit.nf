nextflow.enable.dsl = 2

params.merges = "03.identify/merge/merge.virus.fa.gz"
params.outdir = "04.predict/cdhit"

process cdhit {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path merges

    output:
    path("virus.cdhit*")

    script:
    """
    /share/app/cdhit/4.8.1/cd-hit-v4.8.1-2019-0228/cd-hit-est -i ${merges}  -o virus.cdhit.fa  -c 0.95   -M 0 -T 0   -d 0
    /share/app/seqkit/0.16.1/seqkit fx2tab -l -n virus.cdhit.fa >virus.cdhit.fa.len

    """

}

workflow{
    data = channel.fromPath(params.merges)
    cdhit(data)

}
