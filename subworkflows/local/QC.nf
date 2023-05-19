//
// SUBWORKFLOW: Read in samplesheet, validate and stage input files
//

include { QC } from '../../modules/local/qc'

workflow INPUT_QC {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:

    data = channel.from ( samplesheet )
        .splitCsv ( header:true, sep:',' )
        .map { row ->
                if(row.size()==3){
                    def id = row.sample
                    def reads1 = row.reads1
                    def reads2 = row.reads2
                    // Check if given combination is valid
                    if (!reads1) exit 1, "Invalid input samplesheet: reads1 can not be empty."
                    return [ id, [reads1, reads2] ]
                }else{
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 3."
                }
            }
        .view()
        .set { reads }


    QC(reads)


    emit:
    clean_reads1 = QC.out.clean_reads1          // channel: [ val(id), [ reads1 ] ]
    clean_reads2 = QC.out.clean_reads2          // channel: [ val(id), [ reads2 ] ]
    versions = QC.out.versions                  // channel: [ versions.yml ]
}

