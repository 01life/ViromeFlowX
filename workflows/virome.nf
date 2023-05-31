/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowVirome.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.adapters ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { INPUT_QC } from '../subworkflows/local/QC'
include { ASSEMBLY } from '../subworkflows/local/ASSEMBLY'
include { IDENTIFY } from '../subworkflows/local/IDENTIFY'
include { PREDICT } from '../subworkflows/local/GENE_PREDICT'
include { CLASSIFY } from '../subworkflows/local/CLASSIFY'
include { ABUNDANCE } from '../subworkflows/local/ABUNDANCE'
include { ANNOTATION } from '../subworkflows/local/GENE_ANNOTATION'
include { PROFILE } from '../subworkflows/local/PROFILE'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow VIROME {

    //QC和组装已测试完成

    INPUT_QC( ch_input )

    ASSEMBLY( INPUT_QC.out.clean_reads1, INPUT_QC.out.clean_reads2 )

    //序列识别先单独测试
    IDENTIFY( ASSEMBLY.out.onek, ASSEMBLY.out.contigs )

    PREDICT ( IDENTIFY.out.all_virus )


    // input samplesheet must be 3 rows: [sample,reads1,reads2]
    // clean_reads1 = channel.from ( ch_input )
    //                 .splitCsv ( header:true, sep:',' )
    //                 .map { row -> [row.sample, row.reads1] }

    // clean_reads2 = channel.from ( ch_input )
    //                 .splitCsv ( header:true, sep:',' )
    //                 .map { row -> [row.sample, row.reads2] }  

    // all_virus = channel.fromPath("fa/*.fa").collect()
    // PREDICT ( all_virus )

    ANNOTATION ( PREDICT.out.virus_fa )

    CLASSIFY ( PREDICT.out.virus_fa, PREDICT.out.virus_len, PREDICT.out.viral_cds, PREDICT.out.viral_pep )

    ABUNDANCE ( INPUT_QC.out.clean_reads1, INPUT_QC.out.clean_reads2, PREDICT.out.virus_fa, ANNOTATION.out.virus_bed )

    // ABUNDANCE ( clean_reads1, clean_reads2, PREDICT.out.virus_fa, ANNOTATION.out.virus_bed )

    PROFILE ( ABUNDANCE.out.contigs_abundance, CLASSIFY.out.taxonomy, ANNOTATION.out.cazy, ANNOTATION.out.eggnog, ANNOTATION.out.go, ANNOTATION.out.ko, ANNOTATION.out.level4ec, ANNOTATION.out.pfam, ABUNDANCE.out.rpkms)
   
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
