//
// Gene function
//

include { FUNCTION } from '../../modules/local/gene_function'


workflow ASSEMBLY {

    take:
    prodigal_faa      // channel: [ ]


    main:
    
    FUNCTION( prodigal_faa )
    
    emit:
    map_cazy = FUNCTION.out.map_cazy
    map_eggnog = FUNCTION.out.map_eggnog
    map_go = FUNCTION.out.map_go
    map_ko = FUNCTION.out.map_ko
    map_level4ec = FUNCTION.out.map_level4ec
    map_pfam = FUNCTION.out.map_pfam
    
}

