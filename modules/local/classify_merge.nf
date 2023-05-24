process classify_merge {

    label 'process_low'

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
    Rscript /ehpcdata/PM/DATA/RD23010035/app/merge.virus.taxonomy/0.2/merge.virus.taxonomy.R --id ${cdhitslen} --refseq_genome ${refseq_genome} --crAassphage ${crAssphage} --refseq_protein ${refseq_protein} --pfam ${pfam} --demovir ${demovir} --output \$PWD

    """
}