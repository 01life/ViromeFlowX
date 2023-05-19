nextflow.enable.dsl = 2

params.cdhitslen = "04.predict/cdhit/virus.cdhit.fa.len"
params.refseq_genome = "05.classify/1.refseq_genome/refseq_genome.contig.taxonomy.format"
params.crAssphage = "05.classify/2.crAss-like_Phage_Detection/crAss-like.len70k.list"
params.refseq_protein = "05.classify/3.refseq_protein/refseq_protein.contig.taxonomy.format"
params.pfam = "05.classify/4.pfam/pfam.out.virus.taxonomy.format"
params.demovir = "05.classify/5.Demovir/Demovir.contig.taxonmy.format"
params.outdir = "05.classify/6.merge"

process classify_merge{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

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

    script:
    """
    Rscript /share/app/merge.virus.taxonomy/0.1/merge.virus.taxonomy.R --id ${cdhitslen} --refseq_genome ${refseq_genome} --crAassphage ${crAssphage} --refseq_protein ${refseq_protein} --pfam ${pfam} --demovir ${demovir} --output $PWD

    """
}


workflow{
    data1 = channel.fromPath(params.cdhitslen)
    data2 = channel.fromPath(params.refseq_genome)
    data3 = channel.fromPath(params.crAssphage)
    data4 = channel.fromPath(params.refseq_protein)
    data5 = channel.fromPath(params.pfam)
    data6 = channel.fromPath(params.demovir)
    classify_merge(data1,data2,data3,data4,data5,data6)

}
