//
// abundance profile
//

include { CLASSIFY } from '../../modules/local/contig_classify'
include { FUNCTIONAL } from '../../modules/local/functional'


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

    FUNCTIONAL( cazy, eggnog, go, ko, level4ec, pfam, rpkms )

}