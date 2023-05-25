//
// Remove redundancy and gene prediction
//

include { CDHIT } from '../../modules/local/cdhit'
include { PRODIGAL } from '../../modules/local/prodigal'



workflow PREDICT {
    take:
    virus      // channel: [ *_virus.fa ]

    main:
    
    CDHIT( virus )

    PRODIGAL( CDHIT.out.fa )

    emit:
    virus_fa = CDHIT.out.fa       
    virus_len = CDHIT.out.len
    viral_cds = PRODIGAL.out.cds
    viral_pep = PRODIGAL.out.pep


}