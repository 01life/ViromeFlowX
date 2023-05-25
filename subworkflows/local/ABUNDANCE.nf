//
// Contigs abundance and gene abundance
//

include { BUILD } from '../../modules/local/build'
include { BOWTIE2 } from '../../modules/local/bowtie2'
include { CONTIG } from '../../modules/local/contig_abundance'
include { GENE } from '../../modules/local/gene_abundance'
include { MERGE } from '../../modules/local/merge_abundance'


workflow ABUNDANCE {
    
    take:
    clean_reads1    // channel: [ val(id), [ reads1 ] ]
    clean_reads2    // channel: [ val(id), [ reads2 ] ]
    cdhitsfa        // channel: [  [ cdhitsfa ] ]
    prokka_bed      // channel: [  [ prokka_bed ] ]

    main:
    
    data  = clean_reads1.join(clean_reads2)

    BUILD(cdhitsfa)

    index = BUILD.out.index.collect()

    BOWTIE2(index, data)

    CONTIG(BOWTIE2.out.filter_bam)

    GENE( prokka_bed, BOWTIE2.out.filter_bam )

    MERGE(CONTIG.out.abundance.collect(), GENE.out.rpkm.collect())

    emit:
    contigs_abundance = MERGE.out.contigs_abundance 
    rpkms = MERGE.out.rpkms     
    
}

