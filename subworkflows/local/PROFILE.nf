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


    ch_map_db = cazy.concat(eggnog, go, ko, level4ec, pfam).map{ it -> 
        def db = it.name.split("_")[1]
        return [db, it]
    }

    FUNCTIONAL( ch_map_db.combine(rpkms) )

}