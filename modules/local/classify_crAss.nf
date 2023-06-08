process CRASS {

    label 'process_low'

    publishDir "${params.outdir}/05.classify/2.crAss-like_Phage_Detection",mode:'copy'

    input:
    path(prodigals)
    path(cdhitslen)
    path(cdhitsfa)

    output:
    path("crAss*")
    path("blastp*")
    path("NC_024711.blastn.out")
    path("p-crAssphage.list")
    path("crAss-like.len70k.list"),emit:'list'

    script:
    """
    blastp -db ${params.crAss_db1} -query ${prodigals} -evalue 1e-10 -num_threads 2 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out
    
    awk '\$4>350' blastp.out > blastp.out.350AlnLen

    cat blastp.out.350AlnLen | cut -f 1 | awk -F '_' '{print \$1"_"\$2"_"\$3}' > crAss-like.list

    perl ${params.nfcore_bin}/fishInWinter.pl  crAss-like.list ${cdhitslen} > crAss-like.len.list

    awk '\$2>70000' crAss-like.len.list > crAss-like.len70k.list

    perl ${params.nfcore_bin}/fishInWinter.pl  --fformat fasta  crAss-like.len70k.list ${cdhitsfa} > crAss-like.len70k.list.fasta

    #sed -i '1iID\\tlength' crAss-like.len70k.list
    test -s crAss-like.len70k.list  && sed -i '1iID\tlength' crAss-like.len70k.list  || echo -e "ID\tlength" >> crAss-like.len70k.list

    blastn -db ${params.crAss_db2} -query crAss-like.len70k.list.fasta -evalue 1e-10 -num_threads 2 -outfmt '6 qseqid qlen sseqid sgi slen pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out NC_024711.blastn.out

    cat NC_024711.blastn.out | awk '\$6>95' | awk '\$16>80' | cut -f 1 | sort | uniq > p-crAssphage.list
    
    perl ${params.nfcore_bin}/fishInWinter.pl  --except  p-crAssphage.list crAss-like.len70k.list > crAss-like.phage.list

    """
}
