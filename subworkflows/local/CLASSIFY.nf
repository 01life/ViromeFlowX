//
// Virome sequence classification
//

include { GENOME } from '../../modules/local/classify_genome'
include { DEMOVIR } from '../../modules/local/classify_Demovir'
include { PFAM } from '../../modules/local/classify_pfam'
include { PROTEIN } from '../../modules/local/classify_protein'
include { CRASS } from '../../modules/local/classify_crAss'
include { MERGE } from '../../modules/local/classify_merge'
include { SPLIT4PFAM } from '../../modules/local/split4pfam'


workflow CLASSIFY {

    take:
    virus_fa     // channel: [ val(id), [ contigs ] ]
    virus_len
    viral_cds
    viral_pep

    main:

    SPLIT4PFAM(viral_pep)
    
    // split data to run pfam
    ch_pfam_pep = SPLIT4PFAM.out.split.collect()
        .flatten()
        .map{ chunk ->
        [ chunk.baseName,chunk ]                                            
    } 
    
    PFAM( ch_pfam_pep )
    
    // merge results of several pfam tasks，and pulish the merged result in MERGE task
    ch_pfam_result = PFAM.out.format.collectFile(name:"pfam.out.virus.taxonomy.format", keepHeader:true)

    GENOME( virus_fa )
    DEMOVIR( viral_cds )
    PROTEIN( viral_pep )
    CRASS( viral_pep, virus_len, virus_fa )
    
    MERGE( virus_len, GENOME.out.format, CRASS.out.list, PROTEIN.out.format, ch_pfam_result, DEMOVIR.out.format)

    emit:
    taxonomy = MERGE.out.taxonomy
    
}
