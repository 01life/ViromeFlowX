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
    sort -u -k1,1 trembl_ublast.viral.txt > trembl_ublast.viral.u.txt
    cut -f 1,2 trembl_ublast.viral.u.txt | sed 's/_[0-9]\\+\\t/\\t/' | cut -f 1 | paste trembl_ublast.viral.u.txt - > trembl_ublast.viral.u.contigID.txt

    Rscript ${params.nfcore_bin}/demovir.R trembl_ublast.viral.u.contigID.txt DemoVir_assignments.txt

    perl ${params.nfcore_bin}/get_sciname.pl DemoVir_assignments.txt > contig2sciname.txt
    sed -i '/no_order/d' contig2sciname.txt
    cut -f 2 contig2sciname.txt > contig2sciname.txt.cut

    taxonkit name2taxid --data-dir ${params.genome_data} contig2sciname.txt.cut > contig2sciname.txt.cut.nam2taxid
    cut -f 2 contig2sciname.txt.cut.nam2taxid > contig2sciname.txt.cut.nam2taxid.cut

    taxonkit lineage --data-dir ${params.genome_data} contig2sciname.txt.cut.nam2taxid.cut > contig2sciname.txt.cut.nam2taxid.cut.lineage
    taxonkit reformat --data-dir ${params.genome_data} contig2sciname.txt.cut.nam2taxid.cut.lineage -P > contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat

    paste contig2sciname.txt contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat | cut -f 1,5 > Demovir.contig.taxonmy
    cat Demovir.contig.taxonmy  | sed 's/;p__;c__;o__;f__;g__;s__\$//' | sed 's/;c__;o__;f__;g__;s__\$//' | sed 's/;o__;f__;g__;s__\$//' | sed 's/;f__;g__;s__\$//' | sed 's/;g__;s__\$//' | sed 's/;s__\$//' | sed 's/ /_/g' > Demovir.contig.taxonmy.format
    sed -i '1iID\\ttax' Demovir.contig.taxonmy.format

    """
}