nextflow.enable.dsl = 2

params.prodigals = "04.predict/prodigal/viral.pep"
params.cdhitslen = "04.predict/cdhit/virus.cdhit.fa.len"
params.cdhitsfa = "04.predict/cdhit/virus.cdhit.fa"
params.outdir = "05.classify/2.crAss-like_Phage_Detection"

process classify_crAss{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path prodigals
    path cdhitslen
    path cdhitsfa
    path db1
    path db2

    output:
    path("crAss*")
    path("blastp*")
    path("NC_024711.blatn.out")
    path("p-crAssphage.list")

    script:
    """
    /share/app/blast/2.10.0+/blastp -db ${db1} -query ${prodigals} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out
    awk '$4>350' blastp.out > /blastp.out.350AlnLen
    cat blastp.out.350AlnLen | cut -f 1 | awk -F '_' '{print $1"_"$2"_"$3}' > crAss-like.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  crAss-like.list ${cdhitslen} > crAss-like.len.list
    awk '$2>70000' crAss-like.len.list > crAss-like.len70k.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --fformat fasta  crAss-like.len70k.list ${cdhitsfa} > crAss-like.len70k.list.fasta
    echo -e  'test' > crAss-like.len70k.list
    sed -i '1iID\tlength' crAss-like.len70k.list
    sed -i '$d' crAss-like.len70k.list
    /share/app/blast/2.10.0+/blastn -db ${db2} -query crAss-like.len70k.list.fasta -evalue 1e-10 -num_threads 16 -outfmt '6 qseqid qlen sseqid sgi slen pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out NC_024711.blastn.out
    cat NC_024711.blastn.out | awk '$6>95' | awk '$16>80' | cut -f 1 | sort | uniq > p-crAssphage.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --except  p-crAssphage.list crAss-like.len70k.list > crAss-like.phage.list

    """
}


workflow{
    data1 = channel.fromPath(params.prodigals)
    data2 = channel.fromPath(params.cdhitslen)
    data3 = channel.fromPath(params.cdhitsfa)
    db1 = channel.fromPath("/db/classify/crAss-like/crAssphage_polymerase_Terminase/crAssphage_polymerase_Terminase.fa") //请替换此处路径
    db2 = channel.fromPath("/db/classify/crAss-like/NC_024711.1/NC_024711.1.fasta") //请替换此处路径
    classify_crAss(data1,data2,data3,db1,db2)

}
