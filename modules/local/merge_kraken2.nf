
process MERGEKRAKEN2 {

    label 'process_low'

    publishDir "${params.outdir}/02.Kraken2",mode:'copy'
    
    input:
    path(mapping)

    output:
    path("*.xls")
    // path("kraken.report.list"),emit:"kraken2_species"

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    
    cat ${mapping} > tmp.txt
    grep "mpa" tmp.txt > tmp_mpa.txt
    
    parallel "grep {1} tmp_mpa.txt > {1}.list.mpa; python ${params.nfcore_bin}/merge_multi_matrix_XY_0.py {1}.list.mpa Kraken2_{2}.xls" ::: domains phylums classes orders families genuses species ::: domain phylum class order family genus species

    python ${params.nfcore_bin}/paste_mpa2sunburst.py Kraken2_species.xls kraken.sunburst.txt
    
    echo krakenspeciesT \$PWD/Kraken2_species.xls >> kraken.report.list
    echo krakenspecies \$PWD/kraken.sunburst.txt >> kraken.report.list

    """

}
