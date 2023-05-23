//
// Virome sequence recognition
//

include { VIRFINDER } from '../../modules/local/virfinder'
include { VIRSORTER } from '../../modules/local/virsorter'
include { MERGE } from '../../modules/local/merge_virome'


workflow IDENTIFY {
    take:
    onek
    contigs      // channel: [ val(id), [ contigs ] ]

    main:
    
    VIRFINDER(contigs)

    VIRSORTER(contigs)

    merge_data= onek.join(VIRFINDER.out.virfinderid).join(VIRSORTER.out.virsorterid)

    MERGE(merge_data)

    all_virus = MERGE.out.virus.collect() 

    emit:
    all_virus
    
}
