//
// abundance profile
//

include { CLASSIFY } from '../../modules/local/contig_classify'
include { FUNCTION } from '../../modules/local/function_profile'


workflow PROFILE {
    take:
    abundance
    taxonomy
    map_cazy
    map_eggnog
    map_go
    map_ko
    map_level4ec
    map_pfam
    rpkms

    main:
    
    CLASSIFY( abundance, taxonomy )

    FUNCTION( map_cazy, map_eggnog, map_go, map_ko, map_level4ec, map_pfam, rpkms )

}