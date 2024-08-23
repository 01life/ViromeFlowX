//
// SUBWORKFLOW: Read in samplesheet, validate and stage input files
//

include { CLEAN } from '../../modules/local/qc'

workflow QC {
    take:
    raw_reads1
    raw_reads2

    main:

    CLEAN(raw_reads1.join(raw_reads2))

    emit:
    clean_reads1 = CLEAN.out.clean_reads1          // channel: [ val(id), [ reads1 ] ]
    clean_reads2 = CLEAN.out.clean_reads2          // channel: [ val(id), [ reads2 ] ] 
   
}

