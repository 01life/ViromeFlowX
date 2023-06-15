process DEMOVIR {

    label 'process_single'

    publishDir "${params.outdir}/05.classify/5.Demovir", mode:'copy'

    input:
    path(prodigals)

    output:
    path("Demovir.contig.taxonmy.format"),emit:'format'

    script:
    """
    usearch -ublast ${prodigals} -db ${params.demovir_db} -evalue 1e-5 -threads 16 -trunclabels -blast6out trembl_ublast.viral.txt
    sort -u -k1,1 trembl_ublast.viral.txt | csvtk -H mutate -t -f 1 -p '^(.+)_[0-9]+\$' > trembl_ublast.viral.u.contigID.txt
    Rscript ${params.nfcore_bin}/demovir.R trembl_ublast.viral.u.contigID.txt ${params.demovir_taxa} DemoVir_assignments.txt 

    perl ${params.nfcore_bin}/get_sciname.pl DemoVir_assignments.txt | sed '/no_order/d' | taxonkit name2taxid --data-dir ${params.genome_data} -i 2 | taxonkit lineage --data-dir ${params.genome_data} -i 3 | taxonkit reformat --data-dir ${params.genome_data} -P -i 4 | cut -f 1,5 | sed 's/ /_/g' | grep -v "k__Viruses\$" |sed '1iID\\ttax' > Demovir.contig.taxonmy.format

    """
}