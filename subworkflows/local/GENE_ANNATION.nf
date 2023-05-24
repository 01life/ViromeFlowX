//
// Gene Annotation
//

include { PROKKA } from '../../modules/local/prokka'
include { FUNCTION } from '../../modules/local/gene_function'


workflow GENE_ANNOTATION {

    take:
    cdhitsfa     // channel: [ [cdhit.out.fa] ]

    main:
    
    PROKKA( cdhitsfa )

    FUNCTION( PROKKA.out.faa )
    
    emit:
    virus_faa = PROKKA.out.faa
    virus_bed = PROKKA.out.bed
    cazy = FUNCTION.out.cazy
    eggnog = FUNCTION.out.eggnog
    go = FUNCTION.out.go
    ko = FUNCTION.out.ko
    level4ec = FUNCTION.out.level4ec
    pfam = FUNCTION.out.pfam
    
}

