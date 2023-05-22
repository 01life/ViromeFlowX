//
// Virome sequence recognition
//

include { GENOME } from '../../modules/local/classify_genome'
include { DEMOVIR } from '../../modules/local/classify_demovir'
include { PFAM } from '../../modules/local/classify_pfam'
include { PROTEIN } from '../../modules/local/classify_protein'
include { CRASS } from '../../modules/local/classify_crAss'
include { MERGE } from '../../modules/local/classify_merge'


workflow CLASSIFY {

    take:
    virus_fa     // channel: [ val(id), [ contigs ] ]
    virus_len
    viral_cds
    viral_pep
    virus_faa

    main:
    
    GENOME( virus_fa )
    DEMOVIR( viral_cds )
    PFAM( viral_pep )
    PROTEIN( viral_pep )
    CRASS( viral_pep, virus_len, virus_fa )
    MERGE( virus_len, GENOME.out.format, CRASS.out.list,PROTEIN.out.format, PFAM.out.format, DEMOVIR.out.format)

    emit:
    taxonomy = MERGE.out.taxonomy
    
}
