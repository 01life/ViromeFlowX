//
// kraken2
//

include { KRAKEN2 } from '../../modules/local/kraken2'
include { MERGEKRAKEN2 } from '../../modules/local/merge_kraken2'

workflow RAPID_TAXONOMIC_PROFILING { 
    take:
    clean_reads1      // channel: [ val(id), [ reads1 ] ]
    clean_reads2      // channel: [ val(id), [ reads2 ] ]

    main:

    KRAKEN2( clean_reads1.join(clean_reads2) )
    
    MERGEKRAKEN2( KRAKEN2.out.mapping.collect() )
    
}

