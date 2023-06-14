process GENOME {
    
    label 'process_low'

    publishDir "${params.outdir}/05.classify/1.refseq_genome/",mode:'copy'

    input:
    path(cdhits)

    output:
    path("refseq_genome.contig.taxonomy.format"),emit:'format'

    script:
    """
    blastn -db ${params.genome_db} -query ${cdhits} -evalue 1e-10 -num_threads 2 -outfmt '6 qaccver qcovs staxid' | awk '\$2>50' | cut -f 1,3 > blastn.out

    perl ${params.nfcore_bin}/get_blast_top_n.pl blastn.out 5 | taxonkit lineage --data-dir ${params.genome_data} -i 2 | taxonkit reformat --data-dir ${params.genome_data} -P -i 3 -t | cut -f 1,4,5 | perl ${params.nfcore_bin}/get_tax.pl - nucl 0.999 | sed 's/ /_/g' | grep -v "k__Viruses\$" |sed '1iID\\ttax' > refseq_genome.contig.taxonomy.format

    """
}