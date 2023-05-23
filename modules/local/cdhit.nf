process cdhit {

    publishDir "${params.outdir}/04.predict/cdhit/",mode:'copy'

    input:
    path virus

    output:
    path("virus.cdhit.fa"),emit:'fa'
    path("virus.cdhit.fa.len"),emit:'len'
    path("virus.cdhit.fa.clstr")

    script:
    """

    cat ${virus} > merge.virus.fa
    gzip merge.virus.fa

    cd-hit-est -i merge.virus.fa.gz -o virus.cdhit.fa -c 0.95 -M 0 -T 0 -d 0
    seqkit fx2tab -l -n virus.cdhit.fa > virus.cdhit.fa.len

    cp merge.virus.fa.gz ${params.outdir}/03.identify/merge/

    """

}