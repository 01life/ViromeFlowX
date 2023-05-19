nextflow.enable.dsl = 2

params.cdhits = "04.predict/cdhit/virus.cdhit.fa"
params.outdir = "05.classify/1.refseq_genome"
params.datadir = "/db/classify/refseq_genome/taxdump"   //请替换此处路径

process classify_genome{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path cdhits
    path db

    output:
    path("blastn*")
    path("contig.tmp")
    path("refseq_genome.contig.taxonomy.format")

    script:
    """
    /share/app/blast/2.10.0+/blastn -db ${db} -query ${cdhits} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus staxid sscinames scomnames' -out blastn.out
    awk '$15>50' blastn.out > blastn.out.50
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl blastn.out.50 5 > blastn.out.top5
    cut -f 1,18 blastn.out.top5 > blastn.out.top5_18
    perl /share/app/get_lca_input/0.1/get_lca_input.pl blastn.out.top5_18 > blastn.out.top5.contig2taxids
    cut -f 2 blastn.out.top5.contig2taxids > blastn.out.top5.contig2taxids.2
    export BLASTDB="/db/classify/refseq_genome/taxdb"
    /share/app/taxonkit/0.7.2/taxonkit lca --data-dir ${params.datadir} blastn.out.top5.contig2taxids.2 > contig.tmp
    paste blastn.out.top5.contig2taxids contig.tmp |cut -f 1,4 > blastn.out.top5.contig2taxids.lca
    cut -f 2 blastn.out.top5.contig2taxids.lca > blastn.out.top5.contig2taxids.lca.2
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${params.datadir} blastn.out.top5.contig2taxids.lca.2 > blastn.out.top5.contig2taxids.lca.2.line
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${params.datadir} blastn.out.top5.contig2taxids.lca.2.line -P > blastn.out.top5.contig2taxids.lca.2.line.reformat
    paste blastn.out.top5.contig2taxids.lca blastn.out.top5.contig2taxids.lca.2.line.reformat | cut -f 1,5 | awk '$2!="k__Viruses;p__;c__;o__;f__;g__;s__"' | awk '$2!="k__;p__;c__;o__;f__;g__;s__"'  | sed 's/;p__;c__;o__;f__;g__;s__$//' | sed 's/;c__;o__;f__;g__;s__$//' | sed 's/;o__;f__;g__;s__$//' | sed 's/;f__;g__;s__$//' | sed 's/;g__;s__$//' | sed 's/;s__$//' | sed 's/ /_/g' > refseq_genome.contig.taxonomy.format

    """
}


workflow{
    data = channel.fromPath(params.cdhits)
    db = channel.fromPath("/db/classify/refseq_genome/refseq_virus_filter.fasta") //请替换此处路径
    classify_genome(data,db)

}
