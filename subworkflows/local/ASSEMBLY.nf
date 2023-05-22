//
// Assembly
//

include { SPADES } from '../../modules/local/spades'


workflow ASSEMBLY {
    take:
    clean_reads1      // channel: [ val(id), [ reads1 ] ]
    clean_reads2      // channel: [ val(id), [ reads2 ] ]

    main:
    
    SPADES(clean_reads1, clean_reads2)

    contigs = SPADES.out.contigs
                .map{ id,file -> [ id,[file] ]}
    
    onek = SPADES.out.onek
                .map{ id,file -> [ id,[file] ]}

    emit:
    onek
    contigs           // channel: [ val(id), [ contigs ] ]
}

