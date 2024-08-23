
process SPLIT4PFAM {
    
    label 'process_low'

    input:
    path(all_viral_pep)

    output:
    path("split/*"),emit:"split"

    script:
    """
    seqkit split ${all_viral_pep} -s ${params.pfam_pep_chunck_size} -O split
    
    """

}


