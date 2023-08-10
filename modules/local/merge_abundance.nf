process MERGE {
    
    label 'process_low'

    publishDir "${params.outdir}/06.abundance/",mode:'copy'

    input:
    path(contigs)
    path(rpkms)

    output:
    path("contig/virus.contigs.abun.txt"),emit:"contigs_abundance"
    path("gene/virus.gene.rpkm.pr"),emit:"rpkms"

    script:

    """
    mkdir contig
    python ${params.nfcore_bin}/merge_tables.py ${contigs} > contig/virus.contigs.abun.txt
    sed -i 's/.sort.filter.cov.contig//g' contig/virus.contigs.abun.txt

    mkdir gene
    python ${params.nfcore_bin}/merge_tables.py ${rpkms} > gene/virus.gene.rpkm.pr
    """

}
