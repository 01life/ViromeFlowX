process PFAM {
    
    label 'process_low'

    publishDir "${params.outdir}/05.classify/4.pfam",mode:'copy'

    input:
    path(prodigals)

    output:
    path("pfam.out.virus.taxonomy.format"),emit:'format'

    script:
    """
    perl ${params.nfcore_bin}/pfam_scan.pl -fasta ${prodigals} -cpu 2 -dir ${params.pfam_data} | grep -v "#" | sed 's/\\s\\+/\\t/g' | cut -f 1,6 | sed 's/.[0-9]\\+\$//g' > pfam.out
    
    csvtk join -f '2;1' -H -t pfam.out ${params.pfam_db} | cut -f 1,4,5 | perl ${params.nfcore_bin}/get_tax.pl - prot 0.5 | sed 's/ /_/g' | grep -v "k__Viruses\$" |sed '1iID\\ttax' > pfam.out.virus.taxonomy.format

    """
}