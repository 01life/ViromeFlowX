//
// Gene function
//

include { FUNCTION } from '../../modules/local/gene_function'


workflow ASSEMBLY {

    take:
    prodigal_faa      // channel: [ ]


    main:
    
    FUNCTION( prodigal_faa )
    
    
}

