//
// Assembly
//

include { MEGAHIT } from '../../modules/local/megahit'
include { METASPADES } from '../../modules/local/metaspades'


workflow ASSEMBLY {
    take:
    clean_reads1      // channel: [ val(id), [ reads1 ] ]
    clean_reads2      // channel: [ val(id), [ reads2 ] ]

    main:
    
    if (!params.megahit){
        METASPADES ( clean_reads1,clean_reads2 )
        contigs = METASPADES.out.contigs
                .map{ id,file -> [ id,[file] ]}
    } else {
        MEGAHIT ( clean_reads1,clean_reads2 )
        contigs = MEGAHIT.out.contigs
                .map{ id,file -> [ id,[file] ]}
    }


    emit:
    contigs           // channel: [ val(id), [ contigs ] ]
}

