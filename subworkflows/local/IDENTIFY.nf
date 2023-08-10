//
// Virome sequence recognition
//

include { VIRFINDER } from '../../modules/local/virfinder'
include { VIRSORTER } from '../../modules/local/virsorter'
include { MERGE } from '../../modules/local/merge_virome'
include { CHECKV } from '../../modules/local/checkv'


workflow IDENTIFY {
    take:
    contigs      // channel: [ val(id), [ contigs ] ]

    main:
    
    VIRFINDER(contigs)

    VIRSORTER(contigs)

    merge_data= contigs.join(VIRFINDER.out.virfinderid).join(VIRSORTER.out.virsorterid)

    MERGE(merge_data)

    CHECKV(MERGE.out.virus)

    all_virus = CHECKV.out.viruses.collect() 

    emit:
    all_virus
    
}
