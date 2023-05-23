process merge_abundance{
    
    label 'process_low'

    publishDir "${params.outdir}/06.abundance/",mode:'copy'

    input:
    path contigs
    path rpkms

    output:
    path("contig/virus.contigs.abun.txt"),emit:"contigs_abundance"
    path("gene/virus.gene.rpkm.pr"),emit:"rpkms"

    script:

    """
    mkdir contigs
    python /share/app/merge_tables/0.1/merge_tables.py ${contigs} > contigs/virus.contigs.abun.txt
    sed -i 's/.sort.filter.cov.contig//g' contigs/virus.contigs.abun.txt

    mkdir gene
    python /share/app/merge_tables/0.1/merge_tables.py ${rpkms} > gene/virus.gene.rpkm.pr
    """

}
