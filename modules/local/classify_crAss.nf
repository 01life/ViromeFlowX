process CRASS {

    label 'process_low'

    publishDir "${params.outdir}/05.classify/2.crAss-like_Phage_Detection",mode:'copy'

    input:
    path(prodigals)
    path(cdhitslen)
    path(cdhitsfa)

    output:
    path("crAss-like.list"),emit:'list'

    script:
    """
    awk '\$2>70000{print"^"\$1"_";}' ${cdhitslen} > pep_filter.list
    seqkit grep -r -f pep_filter.list ${prodigals} | blastp -db ${params.crAss_db1} -evalue 1e-10 -num_threads 2 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out

    awk '\$4>350{print\$1;}' blastp.out | sed 's/_[^_]*\$//' > crAss-like.list

    seqkit grep -f crAss-like.list ${cdhitsfa} | blastn -db ${params.crAss_db2} -evalue 1e-10 -num_threads 2 -outfmt '6 qseqid qlen sseqid sgi slen pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out p-crAssphage.blastn.out

    cat p-crAssphage.blastn.out | awk '\$6>95' | awk '\$16>80' | cut -f 1 | sort | uniq > p-crAssphage.list

    cat crAss-like.list | csvtk grep -H -v -P p-crAssphage.list -o crAss-like.list
    sed -i '1iID\\ttax' crAss-like.list

    """
}
