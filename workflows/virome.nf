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
def checkPathParamList = [ params.input, params.multiqc_config, params.fasta ]
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
include { PREDICT } from '../subworkflows/local/PREDICT'
include { CLASSIFY } from '../subworkflows/local/CLASSIFY'
include { ABUNDANCE } from '../subworkflows/local/ABUNDANCE'
include { FUNCTIONAL } from '../subworkflows/local/FUNCTIONAL'
include { PROFILE } from '../subworkflows/local/PROFILE'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow VIROME {

    QC( ch_input )

    ASSEMBLY( QC.out.clean_reads1, QC.out.clean_reads2 )

    IDENTIFY( ASSEMBLY.out.onek, ASSEMBLY.out.contigs )

    PREDICT ( IDENTIFY.out.all_virus )

    CLASSIFY ( PREDICT.out.virus_fa, PREDICT.out.virus_len, PREDICT.out.viral_cds, PREDICT.out.viral_pep, PREDICT.out.virus_faa )

    ABUNDANCE ( QC.out.clean_reads1, QC.out.clean_reads2, PREDICT.out.virus_fa, PREDICT.out.virus_bed )

    FUNCTIONAL ( PREDICT.out.virus_faa )

    PROFILE ( ABUNDANCE.out.contigs_abundance, CLASSIFY.out.taxonomy, FUNCTIONAL.out.cazy, FUNCTIONAL.out.eggnog, FUNCTIONAL.out.go, FUNCTIONAL.out.ko, FUNCTIONAL.out.level4ec, FUNCTIONAL.out.pfam, ABUNDANCE.out.rpkms)
   
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
