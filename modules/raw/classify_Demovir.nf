nextflow.enable.dsl = 2

params.prodigals = "04.predict/prodigal/viral.cds"
params.outdir = "05.classify/5.Demovir"
params.datadir = "/db/classify/refseq_genome/taxdump"   //请替换此处路径

process classify_demovir{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path prodigals
    path db

    output:
    path("contig2sciname*")
    path("Demovir.contig*")
    path("DemoVir_assignments.txt")
    path("trembl_ublast*")

    script:
    """
    /share/app/usearch/11.0.667/usearch -ublast ${prodigals} -db ${db} -evalue 1e-5 -threads 16 -trunclabels -blast6out trembl_ublast.viral.txt
    sort -u -k1,1 trembl_ublast.viral.txt > trembl_ublast.viral.u.txt
    cut -f 1,2 trembl_ublast.viral.u.txt | sed 's/_[0-9]\+\t/\t/' | cut -f 1 | paste trembl_ublast.viral.u.txt - > trembl_ublast.viral.u.contigID.txt
    Rscript /share/app/Demovir/0.1/demovir.R trembl_ublast.viral.u.contigID.txt DemoVir_assignments.txt
    perl /share/app/get_sciname/0.1/get_sciname.pl DemoVir_assignments.txt > contig2sciname.txt
    sed -i '/no_order/d' contig2sciname.txt
    cut -f 2 contig2sciname.txt > contig2sciname.txt.cut
    /share/app/taxonkit/0.7.2/taxonkit name2taxid --data-dir ${datadir} contig2sciname.txt.cut > contig2sciname.txt.cut.nam2taxid
    cut -f 2 contig2sciname.txt.cut.nam2taxid > contig2sciname.txt.cut.nam2taxid.cut
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${datadir} contig2sciname.txt.cut.nam2taxid.cut > contig2sciname.txt.cut.nam2taxid.cut.lineage
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${datadir} contig2sciname.txt.cut.nam2taxid.cut.lineage -P > contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat
    paste contig2sciname.txt contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat | cut -f 1,5 > Demovir.contig.taxonmy
    cat Demovir.contig.taxonmy  | sed 's/;p__;c__;o__;f__;g__;s__$//' | sed 's/;c__;o__;f__;g__;s__$//' | sed 's/;o__;f__;g__;s__$//' | sed 's/;f__;g__;s__$//' | sed 's/;g__;s__$//' | sed 's/;s__$//' | sed 's/ /_/g' > Demovir.contig.taxonmy.format
    sed -i '1iID\ttax' Demovir.contig.taxonmy.format

    """
}


workflow{
    data = channel.fromPath(params.prodigals)
    db = channel.fromPath("/db/classify/Demovir/uniprot_trembl.viral.udb") //请替换此处路径
    classify_demovir(data,db)

}
