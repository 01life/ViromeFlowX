//
// Remove redundancy and gene prediction
//

include { CDHIT } from '../../modules/local/cdhit'
include { PRODIGAL } from '../../modules/local/prodigal'
include { PROKKA } from '../../modules/local/prokka'


workflow PREDICT {
    take:
    virus      // channel: [ *_virus.fa ]

    main:
    
    CDHIT( virus )

    PRODIGAL( CDHIT.out.fa )

    PROKKA( CDHIT.out.fa )

    emit:
    virus_fa = CDHIT.out.fa       
    virus_len = CDHIT.out.len
    viral_cds = PRODIGAL.out.cds
    viral_pep = PRODIGAL.out.pep
    virus_faa = PROKKA.out.faa
    virus_bed = PROKKA.out.bed

}