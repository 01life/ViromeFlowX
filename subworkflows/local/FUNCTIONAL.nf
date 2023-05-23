//
// Gene function
//

include { FUNCTION } from '../../modules/local/gene_function'


workflow FUNCTIONAL {

    take:
    prodigal_faa      // channel: [ [prodigal_faa] ]


    main:
    
    FUNCTION( prodigal_faa )
    
    emit:
    cazy = FUNCTION.out.cazy
    eggnog = FUNCTION.out.eggnog
    go = FUNCTION.out.go
    ko = FUNCTION.out.ko
    level4ec = FUNCTION.out.level4ec
    pfam = FUNCTION.out.pfam
    
}

