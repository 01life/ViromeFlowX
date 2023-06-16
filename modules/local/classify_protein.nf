process PROTEIN {
    
    label 'process_single'

    publishDir "${params.outdir}/05.classify/3.refseq_protein",mode:'copy'

    input:
    path(prodigals)

    output:
    path("refseq_protein.contig.taxonomy.format"),emit:'format'

    script:
    """
    blastp -db ${params.protein_db} -query ${prodigals} -evalue 1e-10 -num_threads ${task.cpus} -outfmt '6 qaccver staxid' -out blastp.out
    
    perl ${params.nfcore_bin}/get_blast_top_n.pl blastp.out 3 | taxonkit lineage --data-dir ${params.genome_data} -i 2 | taxonkit reformat --data-dir ${params.genome_data} -P -i 3 -t | cut -f 1,4,5 | perl ${params.nfcore_bin}/get_tax.pl - prot 0.5 | sed 's/ /_/g' | grep -v "k__Viruses\$" |sed '1iID\\ttax' > refseq_protein.contig.taxonomy.format

    """
}