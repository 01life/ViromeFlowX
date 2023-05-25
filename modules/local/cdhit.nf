process CDHIT {

    label 'process_single'

    publishDir "${params.outdir}/04.predict/cdhit/",mode:'copy'

    input:
    path(virus)

    output:
    path("virus.cdhit.fa"),emit:'fa'
    path("virus.cdhit.fa.len"),emit:'len'
    path("virus.cdhit.fa.clstr")

    script:
    """

    cat ${virus} > merge.virus.fa
    gzip merge.virus.fa

    /ehpcdata/PM/DATA/RD23010035/app/cdhit/4.8.1/cd-hit-v4.8.1-2019-0228/cd-hit-est -i merge.virus.fa.gz -o virus.cdhit.fa -c 0.95 -M 0 -T 0 -d 0
    
    /ehpcdata/PM/DATA/RD23010035/app/seqkit/0.16.1/seqkit fx2tab -l -n virus.cdhit.fa > virus.cdhit.fa.len

    cp merge.virus.fa.gz ${params.outdir}/03.identify/merge/

    """

}