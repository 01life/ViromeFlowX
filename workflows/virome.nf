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

include { INPUT_PARSER } from '../subworkflows/local/INPUT_PARSER'
include { QC } from '../subworkflows/local/QC'
include { ASSEMBLY } from '../subworkflows/local/ASSEMBLY'
include { RAPID_TAXONOMIC_PROFILING } from '../subworkflows/local/RAPID_TAXONOMIC_PROFILING'
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

    //输入解析
    INPUT_PARSER(ch_input)

    ch_reads1 = INPUT_PARSER.out.reads1
    ch_reads2 = INPUT_PARSER.out.reads2
    ch_contig = INPUT_PARSER.out.contig

    ch_clean_reads1 = Channel.empty()
    ch_clean_reads2 = Channel.empty()

    //跳过组装或QC，输入：clean_reads
    if(params.skip_qc || params.skip_assembly){
        ch_clean_reads1 = ch_reads1
        ch_clean_reads2 = ch_reads2
    }else{
        //执行QC
        if( !params.skip_qc ){
            QC( ch_reads1, ch_reads2 )
            ch_clean_reads1 = QC.out.clean_reads1
            ch_clean_reads2 = QC.out.clean_reads2
        }
    }

    //执行组装
    if(!params.skip_assembly){
        ASSEMBLY( ch_clean_reads1, ch_clean_reads2 )
        ch_contig = ASSEMBLY.out.contigs
    }

    //执行kraken2
    if(!params.skip_kraken2){
        RAPID_TAXONOMIC_PROFILING(ch_clean_reads1, ch_clean_reads2)
    }
   
    //序列识别先单独测试
    IDENTIFY( ch_contig )

    PREDICT ( IDENTIFY.out.all_virus )

    ANNOTATION ( PREDICT.out.virus_fa )

    CLASSIFY ( PREDICT.out.virus_fa, PREDICT.out.virus_len, PREDICT.out.viral_cds, PREDICT.out.viral_pep )

    ABUNDANCE ( ch_clean_reads1, ch_clean_reads2, PREDICT.out.virus_fa, ANNOTATION.out.virus_bed )

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
