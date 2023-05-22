//
// Contigs abundance and gene abundance
//

include { BOWTIE2 } from '../../modules/local/bowtie2'
include { CONTIG } from '../../modules/local/contig_abundance'
include { GENE } from '../../modules/local/gene_abundance'
include { MERGE } from '../../modules/local/merge_abundance'


workflow ABUNDANCE {
    take:
    clean_reads1    // channel: [ val(id), [ reads1 ] ]
    clean_reads2    // channel: [ val(id), [ reads2 ] ]
    cdhitsfa        // channel: [ val(id), [ cdhitsfa ] ]
    prokka_faa      // channel: [ val(id), [ prokka_faa ] ]

    main:
    
    data  = cdhitsfa.join(clean_reads1).join(clean_reads2)

    BOWTIE2(data)

    CONTIG(BOWTIE2.out.filter_bam)

    GENE(BOWTIE2.out.filter_bam.join(prokka_faa))

    MERGE(CONTIG.out.abundance.collect(), GENE.out.rpkm.collect())

    emit:
    contigs_abundance = MERGE.out.contigs_abundance 
    rpkms = MERGE.out.rpkms     
    
}

