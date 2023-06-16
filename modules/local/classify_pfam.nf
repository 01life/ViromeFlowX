process PFAM {
    
    label 'process_low'

    publishDir "${params.outdir}/05.classify/4.pfam",mode:'copy'

    beforeScript "export PERL5LIB=${params.pfam_data}/PfamScan:$PERL5LIB"

    input:
    path(prodigals)

    output:
    path("pfam.out.virus.taxonomy.format"),emit:'format'

    script:
    """

    perl pfam_scan.pl -fasta ${prodigals} -cpu ${task.cpus} -dir ${params.pfam_data} | grep -v "#" | sed 's/\\s\\+/\\t/g' | cut -f 1,6 | sed 's/.[0-9]\\+\$//g' > pfam.out
    
    csvtk join -f '2;1' -H -t pfam.out ${params.pfam_db} | cut -f 1,4,5 | perl ${params.nfcore_bin}/get_tax.pl - prot 0.5 | sed 's/ /_/g' | grep -v "k__Viruses\$" > pfam.out.virus.taxonomy.format

    test -s pfam.out.virus.taxonomy.format && sed -i '1iID\\ttax' pfam.out.virus.taxonomy.format || echo -e "ID\\ttax" >> pfam.out.virus.taxonomy.format

    """
}