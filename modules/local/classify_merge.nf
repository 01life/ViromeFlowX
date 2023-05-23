process classify_merge {

    label 'process_low'

    container '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'

    publishDir "${params.outdir}/05.classify/6.merge",mode:'copy'

    input:
    path cdhitslen
    path refseq_genome
    path crAssphage
    path refseq_protein
    path pfam
    path demovir

    output:
    path("*.taxonomy.txt")
    path("crAss*")
    path("contigs.taxonomy.txt"),emit:"taxonomy"

    script:
    """
    Rscript /share/app/merge.virus.taxonomy/0.2/merge.virus.taxonomy.R --id ${cdhitslen} --refseq_genome ${refseq_genome} --crAassphage ${crAssphage} --refseq_protein ${refseq_protein} --pfam ${pfam} --demovir ${demovir} --output \$PWD

    """
}