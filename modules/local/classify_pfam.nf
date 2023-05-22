process classify_pfam {

    publishDir "${params.outdir}/05.classify/4.pfam",mode:'copy'

    input:
    path prodigals

    output:
    path("pfam.out*")
    path("pfam.out.virus.taxonomy.format"),emit:'format'

    script:
    """
    perl /share/app/miniconda3/bin/pfam_scan.pl -fasta ${prodigals} -cpu 16 -dir ${params.datadir2} -outfile pfam.out
    perl /share/app/get_filter/0.1/get_filter.pl ${params.pfam_db} pfam.out > pfam.out.filter
    awk '\$3!=""' pfam.out.filter > pfam.out.virus
    sed 's/Caudovirales tail/Caudovirales tail\\tCaudovirales\\tViruses;Uroviricota;Caudoviricetes;Caudovirales\\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__;g__;s__/g' pfam.out.virus | sed 's/Microviridae capsid/Microviridae capsid\\tMicroviridae\\tViruses;Phixviricota;Malgrandaviricetes;Petitvirales;Microviridae\\tk__Viruses;p__Phixviricota;c__Malgrandaviricetes;o__Petitvirales;f__Microviridae;g__;s__/' | sed 's/Myoviridae tail sheath/Myoviridae tail sheath\\tMyoviridae\\tViruses;Uroviricota;Caudoviricetes;Caudovirales;Myoviridae\\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__Myoviridae;g__;s__/' |  cut -f 1,6 > pfam.out.virus.taxonomy
    
    cat pfam.out.virus.taxonomy | sed 's/;p__;c__;o__;f__;g__;s__\$//' | sed 's/;c__;o__;f__;g__;s__\$//' | sed 's/;o__;f__;g__;s__\$//' | sed 's/;f__;g__;s__\$//' | sed 's/;g__;s__\$//' | sed 's/;s__\$//' > pfam.out.virus.taxonomy.sed
    perl /share/app/deal_pro2contig/0.1/deal_pro2contig.pl pfam.out.virus.taxonomy.sed > pfam.out.virus.taxonomy.sed.deal
    sed 's/ /_/g' pfam.out.virus.taxonomy.sed.deal > pfam.out.virus.taxonomy.format
    sed -i '1iID\\ttax' pfam.out.virus.taxonomy.format

    """
}