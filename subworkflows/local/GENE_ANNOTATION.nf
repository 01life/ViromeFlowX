//
// Gene Annotation
//

include { PROKKA } from '../../modules/local/prokka'
include { GENEFUNCTION } from '../../modules/local/gene_function'


workflow ANNOTATION {

    take:
    cdhitsfa     // channel: [ [cdhit.out.fa] ]

    main:
    
    PROKKA( cdhitsfa )

    GENEFUNCTION( PROKKA.out.faa )
    
    emit:
    virus_bed = PROKKA.out.bed
    cazy = FUNCTION.out.cazy
    eggnog = FUNCTION.out.eggnog
    go = FUNCTION.out.go
    ko = FUNCTION.out.ko
    level4ec = FUNCTION.out.level4ec
    pfam = FUNCTION.out.pfam
    
}

