nextflow.enable.dsl = 2

params.prodigals = "04.predict/prodigal/viral.pep"
params.outdir = "05.classify/4.pfam"
params.datadir = "/db/classify/pfam/Pfam/"   //请替换此处路径

process classify_pfam{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path prodigals
    path db

    output:
    path("pfam.out*")

    script:
    """
    perl /share/app/miniconda3/bin/pfam_scan.pl -fasta ${prodigals} -cpu 16 -dir ${datadir} -outfile pfam.out
    perl /share/app/get_filter/0.1/get_filter.pl ${db} pfam.out > pfam.out.filter
    awk '$3!=""' pfam.out.filter > pfam.out.virus
    sed 's/Caudovirales tail/Caudovirales tail\tCaudovirales\tViruses;Uroviricota;Caudoviricetes;Caudovirales\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__;g__;s__/g' pfam.out.virus | sed 's/Microviridae capsid/Microviridae capsid\tMicroviridae\tViruses;Phixviricota;Malgrandaviricetes;Petitvirales;Microviridae\tk__Viruses;p__Phixviricota;c__Malgrandaviricetes;o__Petitvirales;f__Microviridae;g__;s__/' | sed 's/Myoviridae tail sheath/Myoviridae tail sheath\tMyoviridae\tViruses;Uroviricota;Caudoviricetes;Caudovirales;Myoviridae\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__Myoviridae;g__;s__/' |  cut -f 1,6 > pfam.out.virus.taxonomy
    cat pfam.out.virus.taxonomy | sed 's/;p__;c__;o__;f__;g__;s__$//' | sed 's/;c__;o__;f__;g__;s__$//' | sed 's/;o__;f__;g__;s__$//' | sed 's/;f__;g__;s__$//' | sed 's/;g__;s__$//' | sed 's/;s__$//' > pfam.out.virus.taxonomy.sed
    perl /share/app/deal_pro2contig/0.1/deal_pro2contig.pl pfam.out.virus.taxonomy.sed > pfam.out.virus.taxonomy.sed.deal
    sed 's/ /_/g' pfam.out.virus.taxonomy.sed.deal > pfam.out.virus.taxonomy.format
    sed -i '1iID\ttax' pfam.out.virus.taxonomy.format

    """
}


workflow{
    data = channel.fromPath(params.prodigals)
    db = channel.fromPath("/db/classify/pfam/virus.pfam") //请替换此处路径
    classify_pfam(data,db)

}
