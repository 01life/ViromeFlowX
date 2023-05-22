//
// Virome sequence recognition
//

include { VIRFINDER } from '../../modules/local/virfinder'
include { VIRSORTER } from '../../modules/local/virsorter'
include { MERGE } from '../../modules/local/merge_virome'


workflow IDENTIFY {
    take:
    contigs      // channel: [ val(id), [ contigs ] ]

    main:
    
    


    emit:
    contigs           // channel: [ val(id), [ contigs ] ]
}
