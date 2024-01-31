process PFAM {

    tag "$basename"
    
    // label 'process_medium'

    // publishDir "${params.outdir}/05.classify/4.pfam",mode:'copy'

    beforeScript "export PERL5LIB=${params.nfcore_bin}/PfamScan:$PERL5LIB"

    input:
    tuple val(basename),path(prodigals)

    output:
    path("${basename}.taxonomy"),emit:'format'

    script:
    """
    
    perl ${params.nfcore_bin}/PfamScan/pfam_scan.pl -fasta ${prodigals} -cpu ${task.cpus} -dir ${params.pfam_data} | grep -v "#" | sed 's/\\s\\+/\\t/g' | cut -f 1,6 | sed 's/.[0-9]\\+\$//g' > pfam.out
    
    csvtk join -f '2;1' -H -t pfam.out ${params.pfam_db} | cut -f 1,4,5 | perl ${params.nfcore_bin}/get_tax.pl - prot 0.5 | sed 's/ /_/g' | grep -v "k__Viruses\$" > ${basename}.taxonomy

    test -s ${basename}.taxonomy && sed -i '1iID\\ttax' ${basename}.taxonomy || echo -e "ID\\ttax" >> ${basename}.taxonomy

    """
}