process classify_protein {

    publishDir "${params.outdir}/05.classify/3.refseq_protein",mode:'copy'

    input:
    path prodigals

    output:
    path("contig2taxdump*")
    path("blastp*")
    path("gene*")
    path("add_contig.txt")
    path("refseq_protein.contig.taxonomy.format"),emit:'format'

    script:
    """
    /share/app/blast/2.10.0+/blastp -db ${params.protein_db1} -query ${prodigals} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out

    perl /share/app/add_taxid/0.1/add_taxid.pl ${params.protein_db2} blastp.out > blastp.out.addTaxid
    awk '\$NF!=""' blastp.out.addTaxid > blastp.out.addTaxid.nf
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl blastp.out.addTaxid.nf 3 > blastp.out.addTaxid.top3
    cat blastp.out.addTaxid.top3 | cut -f 1,18 > blastp.out.addTaxid.top3.id2taxid
    cut -f 2 blastp.out.addTaxid.top3.id2taxid > blastp.out.addTaxid.top3.id2taxid.2

    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${params.datadir1} blastp.out.addTaxid.top3.id2taxid.2 > blastp.out.addTaxid.top3.id2taxid.2.line
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${params.datadir1} blastp.out.addTaxid.top3.id2taxid.2.line -P > blastp.out.addTaxid.top3.id2taxid.2.line.reformat
    paste blastp.out.addTaxid.top3.id2taxid blastp.out.addTaxid.top3.id2taxid.2.line.reformat | cut -f 1,5 > blastp.out.addTaxid.top3.id2taxid.name2taxdump
    perl /share/app/get_max_tax/0.1/get_max_tax.pl blastp.out.addTaxid.top3.id2taxid.name2taxdump > blastp.out.addTaxid.top3.id2taxid.name2taxdump.max

    grep "^>" ${prodigals} | sed 's/>//'| cut -d " " -f1 > geneid
    cat geneid | cut -d "_" -f1-3 | paste geneid - > gene2contig.txt

    perl /share/app/add_contig/0.1/add_contig.pl gene2contig.txt blastp.out.addTaxid.top3.id2taxid.name2taxdump.max > add_contig.txt
    awk -F '\\t' '{print \$3"\\t"\$2}' add_contig.txt > contig2taxdump.txt
    
    perl /share/app/get_max_tax/0.1/get_max_tax.pl contig2taxdump.txt > contig2taxdump.max.txt
    cat contig2taxdump.max.txt  | sed 's/;\\+\$//g' | awk '\$2!=""' | awk '\$2!="k__Viruses"' | sed 's/ /_/g' > refseq_protein.contig.taxonomy.format
    sed -i '1iID\\ttax' refseq_protein.contig.taxonomy.format

    """
}