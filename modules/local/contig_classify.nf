process contig_classify{
    
    label 'process_single'

    publishDir "${params.outdir}/08.profile/taxa",mode:'copy'

    input:
    path abundance
    path taxonomy

    output:
    path("virus*")
    path("*.pr")

    script:

    """
    Rscript /share/app/cal_relab/0.1/cal_relab.R ${abundance} virus.contigs.abun.relab.txt
    Rscript /share/app/merge_tax2abun/0.1/merge_tax2abun.R --tax ${taxonomy} --abun virus.contigs.abun.relab.txt --output virus
    cat virus.taxonomy.txt | grep -E "Taxonomy|p__" | grep -E -v "c__|o__|f__|g__|s__" | sed 's/^.*p__//' | sed 's/Taxonomy//' > phylum.pr
    cat virus.taxonomy.txt | grep -E "Taxonomy|c__" | grep -E -v "o__|f__|g__|s__" | sed 's/^.*c__//' | sed 's/Taxonomy//' >  class.pr
    cat virus.taxonomy.txt | grep -E "Taxonomy|o__" | grep -E -v "f__|g__|s__" | sed 's/^.*o__//' | sed 's/Taxonomy//' > order.pr
    cat virus.taxonomy.txt | grep -E "Taxonomy|f__" | grep -E -v "g__|s__" | sed 's/^.*f__//' | sed 's/Taxonomy//' >  family.pr
    cat virus.taxonomy.txt | grep -E "Taxonomy|g__" | grep -E -v "s__" | sed 's/^.*g__//' | sed 's/Taxonomy//' >  genus.pr
    cat virus.taxonomy.txt | grep -E "Taxonomy|s__"  | sed 's/^.*s__//' | sed 's/Taxonomy//' > species.pr

    """

}