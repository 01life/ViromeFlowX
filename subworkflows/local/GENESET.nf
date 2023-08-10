//
// Remove redundancy and gene prediction
//

include { CDHIT } from '../../modules/local/cdhit'
include { PRODIGAL } from '../../modules/local/prodigal'
include { PROKKA } from '../../modules/local/prokka'
include { GENEFUNCTION } from '../../modules/local/gene_function'


workflow GENESET {
    take:
    virus      // channel: [ *_virus.fa ]

    main:
    
    CDHIT( virus )

    PRODIGAL( CDHIT.out.fa )

    //PROKKA( cdhitsfa )

    GENEFUNCTION( PRODIGAL.out.pep)

    emit:
    virus_fa = CDHIT.out.fa       
    virus_len = CDHIT.out.len
    viral_cds = PRODIGAL.out.cds
    viral_pep = PRODIGAL.out.pep
    
    virus_bed = PRODIGAL.out.bed
    cazy = GENEFUNCTION.out.cazy
    eggnog = GENEFUNCTION.out.eggnog
    go = GENEFUNCTION.out.go
    ko = GENEFUNCTION.out.ko
    level4ec = GENEFUNCTION.out.level4ec
    pfam = GENEFUNCTION.out.pfam


}