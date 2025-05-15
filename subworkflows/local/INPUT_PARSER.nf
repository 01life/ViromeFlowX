//
// Parsing input samplesheet and get read channels
//

def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

workflow INPUT_PARSER {
    take:
    samplesheet

    main:
    if(hasExtension(params.input, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input_rows = Channel
            .from(samplesheet)
            .splitCsv(header: true)
            .map { row ->
                        def id = row.id
                        def reads1 = row.reads1 ? file(row.reads1, checkIfExists: true) : false
                        def reads2 = row.reads2 ? file(row.reads2, checkIfExists: true) : false
                        def contig = row.contig ? file(row.contig, checkIfExists: true) : false
                        
                        // Check if given combination is valid
                        if (!reads1 && !params.only_identify) exit 1, "Invalid input samplesheet: reads1 can not be empty."
                        if (!reads2 && !params.only_identify) exit 1, "Invalid input samplesheet: reads2 can not be empty."
                        if (!contig && params.skip_assembly || !contig && params.only_identify) exit 1, "Invalid input samplesheet: contig can not be empty."
                        
                        return [ id, reads1, reads2, contig ]
                
                }

        reads1 = ch_input_rows
            .map { id, reads1, reads2, contig ->
                    return [ id, reads1 ]
                }

        reads2 = ch_input_rows
            .map { id, reads1, reads2, contig ->
                    return [ id, reads2 ]
                }

        contig = ch_input_rows
            .map { id, reads1, reads2, contig ->
                    return [ id, contig ]
                }

    }

    emit:
    reads1
    reads2
    contig

}
