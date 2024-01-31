//
// Assembly
//

include { METASPADES } from '../../modules/local/metaspades'


workflow ASSEMBLY {
    take:
    clean_reads1      // channel: [ val(id), [ reads1 ] ]
    clean_reads2      // channel: [ val(id), [ reads2 ] ]

    main:
    
    METASPADES(clean_reads1.join(clean_reads2))

    contigs = METASPADES.out.contigs
                .map{ id,file -> [ id,[file] ]}

    emit:
    contigs           // channel: [ val(id), [ contigs ] ]
    
}

