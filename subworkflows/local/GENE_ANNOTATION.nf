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
    cazy = GENEFUNCTION.out.cazy
    eggnog = GENEFUNCTION.out.eggnog
    go = GENEFUNCTION.out.go
    ko = GENEFUNCTION.out.ko
    level4ec = GENEFUNCTION.out.level4ec
    pfam = GENEFUNCTION.out.pfam
    
}

