process cdhit {

    publishDir "${params.outdir}/04.predict/cdhit/",mode:'copy'

    input:
    path merges

    output:
    path("virus.cdhit.fa"),emit:'fa'
    path("virus.cdhit.fa.len"),emit:'len'
    path("virus.cdhit.fa.clstr")

    script:
    """
    /share/app/cdhit/4.8.1/cd-hit-v4.8.1-2019-0228/cd-hit-est -i ${merges}  -o virus.cdhit.fa  -c 0.95   -M 0 -T 0   -d 0
    /share/app/seqkit/0.16.1/seqkit fx2tab -l -n virus.cdhit.fa > virus.cdhit.fa.len

    """

}