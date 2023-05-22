//
// abundance profile
//

include { CLASSIFY } from '../../modules/local/contig_classify'
include { FUNCTION } from '../../modules/local/function_profile'


workflow PROFILE {
    take:
    abundance
    taxonomy
    cazy
    eggnog
    go
    ko
    level4ec
    pfam
    rpkms

    main:
    
    CLASSIFY( abundance, taxonomy )

    FUNCTION( cazy, eggnog, go, ko, level4ec, pfam, rpkms )

}