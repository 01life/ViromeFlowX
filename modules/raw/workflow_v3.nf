
nextflow.enable.dsl = 2

params.contigs = "contigs.csv"
params.virfinder = "VirFinder.csv"
params.virsorter = "VirSorter.csv"

params.input = "/out/03.identify/merge/merge.virus.fa.gz"

params.datadir1 = "/data/db/flow_configure_data/classify/refseq_genome/taxdump"
params.datadir2 = "/data/db/flow_configure_data/classify/pfam/Pfam/"
params.datadir3 = "/data/db/flow_configure_data/uniprot/uniref_annotated/uniref90/uniref90_201901"

params.genome_db = "/data/db/flow_configure_data/classify/refseq_genome/refseq_virus_filter.fasta"
params.demovir_db = "/data/db/flow_configure_data/classify/Demovir/uniprot_trembl.viral.udb"
params.pfam_db = "/data/db/flow_configure_data/classify/pfam/virus.pfam"
params.protein_db1 ="/data/db/flow_configure_data/classify/refseq_protein/virus.pep.filter.fasta"
params.protein_db2 ="/data/db/flow_configure_data/classify/refseq_protein/protID2taxid.txt"
params.crAss_db1 = "/data/db/flow_configure_data/classify/crAss-like/crAssphage_polymerase_Terminase/crAssphage_polymerase_Terminase.fa"
params.crAss_db2 = "/data/db/flow_configure_data/classify/crAss-like/NC_024711.1/NC_024711.1.fasta"
params.db1 = "/data/db/flow_configure_data/humann/full_mapping/map_CAZy_uniref90.txt.gz"
params.db2 = "/data/db/flow_configure_data/humann/full_mapping/map_eggnog_uniref90.txt.gz"
params.db3 = "/data/db/flow_configure_data/humann/full_mapping/map_go_uniref90.txt.gz"
params.db4 = "/data/db/flow_configure_data/humann/full_mapping/map_ko_uniref90.txt.gz"
params.db5 = "/data/db/flow_configure_data/humann/full_mapping/map_level4ec_uniref90.txt.gz"
params.db6 = "/data/db/flow_configure_data/humann/full_mapping/map_pfam_uniref90.txt.gz"


params.outdir = "/out/"

process merge_in {
    tag "$id"

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/03.identify/merge/",mode:'copy'

    input:
    tuple val(id),path(contigs),path(virfinderid),path(virsorterid)

    output:
    path("${id}/",type:'dir')
    path("${id}/${id}_virus.fa"),emit:'virus'

    script:
    """
    mkdir ${id}
    cat ${virfinderid} ${virsorterid} | cut -f1 |sort | uniq > uniq.id
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --fformat fasta  uniq.id ${contigs} > ${id}_virus.fa
    mv ${id}_virus.fa uniq.id ${id}

    """

}

process merge_out{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/03.identify/merge/",mode:'copy'

    input:
    path virus

    output:
    path("merge.virus.fa.gz")

    script:
    """
    cat ${virus} > merge.virus.fa
    gzip merge.virus.fa

    """


}

process cdhit {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/04.predict/cdhit/",mode:'copy'

    cpus = 32

    input:
    path merges

    output:
    path("virus.cdhit.fa"),emit:'fa'
    path("virus.cdhit.fa.len"),emit:'len'
    path("virus.cdhit.fa.clstr")

    script:
    """
    /share/app/cdhit/4.8.1/cd-hit-v4.8.1-2019-0228/cd-hit-est -i ${merges}  -o virus.cdhit.fa  -c 0.95   -M 0 -T 0   -d 0
    /share/app/seqkit/0.16.1/seqkit fx2tab -j 32 -l -n virus.cdhit.fa > virus.cdhit.fa.len

    """

}

process prodigal {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/04.predict/prodigal/",mode:'copy'

    input:
    path cdhits

    output:
    path("viral.cds"),emit:"cds"
    path("viral.pep"),emit:"pep"
    path("viral.gene.gff")

    script:
    """
    /share/app/prodigal/2.6.3/prodigal -a viral.pep  -d viral.cds -f gff   -i ${cdhits}   -o viral.gene.gff -p meta -q

    """

}

process prokka {
    
    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/04.predict/prokka",mode:'copy'

    cpus = 32

    input:
    path cdhits

    output:
    path("vir.bed")
    path("virus.prokka*")
    path("virus.prokka.faa"),emit:'faa'

    script:
    """
    prokka   --outdir \$PWD --force --prefix virus.prokka   --metagenome   --cpus 32   ${cdhits}
    cat virus.prokka.gff | grep CDS | cut -f 1,4,5,9 | awk -F ';' '{print \$1}' | sed 's/ID=//' > vir.bed

    """

}


process classify_genome {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/05.classify/1.refseq_genome/",mode:'copy'

    input:
    path cdhits

    output:
    path("blastn*")
    path("contig.tmp")
    path("refseq_genome.contig.taxonomy.format"),emit:'format'

    script:
    """
    /share/app/blast/2.10.0+/blastn -db ${params.genome_db} -query ${cdhits} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus staxid sscinames scomnames' -out blastn.out
    awk '\$15>50' blastn.out > blastn.out.50
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl blastn.out.50 5 > blastn.out.top5
    cut -f 1,18 blastn.out.top5 > blastn.out.top5_18
    perl /share/app/get_lca_input/0.1/get_lca_input.pl blastn.out.top5_18 > blastn.out.top5.contig2taxids
    cut -f 2 blastn.out.top5.contig2taxids > blastn.out.top5.contig2taxids.2
    export BLASTDB="/db/classify/refseq_genome/taxdb"
    /share/app/taxonkit/0.7.2/taxonkit lca --data-dir ${params.datadir1} blastn.out.top5.contig2taxids.2 > contig.tmp
    paste blastn.out.top5.contig2taxids contig.tmp |cut -f 1,4 > blastn.out.top5.contig2taxids.lca
    cut -f 2 blastn.out.top5.contig2taxids.lca > blastn.out.top5.contig2taxids.lca.2
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${params.datadir1} blastn.out.top5.contig2taxids.lca.2 > blastn.out.top5.contig2taxids.lca.2.line
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${params.datadir1} blastn.out.top5.contig2taxids.lca.2.line -P > blastn.out.top5.contig2taxids.lca.2.line.reformat
    paste blastn.out.top5.contig2taxids.lca blastn.out.top5.contig2taxids.lca.2.line.reformat | cut -f 1,5 | awk '\$2!="k__Viruses;p__;c__;o__;f__;g__;s__"' | awk '\$2!="k__;p__;c__;o__;f__;g__;s__"'  | sed 's/;p__;c__;o__;f__;g__;s__\$//' | sed 's/;c__;o__;f__;g__;s__\$//' | sed 's/;o__;f__;g__;s__\$//' | sed 's/;f__;g__;s__\$//' | sed 's/;g__;s__\$//' | sed 's/;s__\$//' | sed 's/ /_/g' > refseq_genome.contig.taxonomy.format
    """
}


process classify_demovir {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/05.classify/5.Demovir",mode:'copy'

    cpus = 32

    input:
    path prodigals

    output:
    path("contig2sciname*")
    path("Demovir.contig.taxonmy")
    path("DemoVir_assignments.txt")
    path("trembl_ublast*")
    path("Demovir.contig.taxonmy.format"),emit:'format'

    //注意反转义
    script:
    """
    /share/app/usearch/11.0.667/usearch -ublast ${prodigals} -db ${params.demovir_db} -evalue 1e-5 -threads 32 -trunclabels -blast6out trembl_ublast.viral.txt
    sort -u -k1,1 trembl_ublast.viral.txt > trembl_ublast.viral.u.txt
    cut -f 1,2 trembl_ublast.viral.u.txt | sed 's/_[0-9]\\+\\t/\\t/' | cut -f 1 | paste trembl_ublast.viral.u.txt - > trembl_ublast.viral.u.contigID.txt
    Rscript /share/app/Demovir/0.1/demovir.R trembl_ublast.viral.u.contigID.txt DemoVir_assignments.txt
    perl /share/app/get_sciname/0.1/get_sciname.pl DemoVir_assignments.txt > contig2sciname.txt
    sed -i '/no_order/d' contig2sciname.txt
    cut -f 2 contig2sciname.txt > contig2sciname.txt.cut
    /share/app/taxonkit/0.7.2/taxonkit name2taxid --data-dir ${params.datadir1} contig2sciname.txt.cut > contig2sciname.txt.cut.nam2taxid
    cut -f 2 contig2sciname.txt.cut.nam2taxid > contig2sciname.txt.cut.nam2taxid.cut
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${params.datadir1} contig2sciname.txt.cut.nam2taxid.cut > contig2sciname.txt.cut.nam2taxid.cut.lineage
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${params.datadir1} contig2sciname.txt.cut.nam2taxid.cut.lineage -P > contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat
    paste contig2sciname.txt contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat | cut -f 1,5 > Demovir.contig.taxonmy
    cat Demovir.contig.taxonmy  | sed 's/;p__;c__;o__;f__;g__;s__\$//' | sed 's/;c__;o__;f__;g__;s__\$//' | sed 's/;o__;f__;g__;s__\$//' | sed 's/;f__;g__;s__\$//' | sed 's/;g__;s__\$//' | sed 's/;s__\$//' | sed 's/ /_/g' > Demovir.contig.taxonmy.format
    sed -i '1iID\\ttax' Demovir.contig.taxonmy.format

    """
}

process classify_pfam {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/05.classify/4.pfam",mode:'copy'

    cpus = 32
    memory = '32 GB'

    input:
    path prodigals

    output:
    path("pfam.out*")
    path("pfam.out.virus.taxonomy.format"),emit:'format'

    script:
    """
    perl /share/app/miniconda3/bin/pfam_scan.pl -fasta ${prodigals} -cpu 32 -dir ${params.datadir2} -outfile pfam.out
    perl /share/app/get_filter/0.1/get_filter.pl ${params.pfam_db} pfam.out > pfam.out.filter
    awk '\$3!=""' pfam.out.filter > pfam.out.virus
    sed 's/Caudovirales tail/Caudovirales tail\\tCaudovirales\\tViruses;Uroviricota;Caudoviricetes;Caudovirales\\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__;g__;s__/g' pfam.out.virus | sed 's/Microviridae capsid/Microviridae capsid\\tMicroviridae\\tViruses;Phixviricota;Malgrandaviricetes;Petitvirales;Microviridae\\tk__Viruses;p__Phixviricota;c__Malgrandaviricetes;o__Petitvirales;f__Microviridae;g__;s__/' | sed 's/Myoviridae tail sheath/Myoviridae tail sheath\\tMyoviridae\\tViruses;Uroviricota;Caudoviricetes;Caudovirales;Myoviridae\\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__Myoviridae;g__;s__/' |  cut -f 1,6 > pfam.out.virus.taxonomy
    cat pfam.out.virus.taxonomy | sed 's/;p__;c__;o__;f__;g__;s__\$//' | sed 's/;c__;o__;f__;g__;s__\$//' | sed 's/;o__;f__;g__;s__\$//' | sed 's/;f__;g__;s__\$//' | sed 's/;g__;s__\$//' | sed 's/;s__\$//' > pfam.out.virus.taxonomy.sed
    perl /share/app/deal_pro2contig/0.1/deal_pro2contig.pl pfam.out.virus.taxonomy.sed > pfam.out.virus.taxonomy.sed.deal
    sed 's/ /_/g' pfam.out.virus.taxonomy.sed.deal > pfam.out.virus.taxonomy.format
    sed -i '1iID\\ttax' pfam.out.virus.taxonomy.format

    """
}


process classify_protein {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/05.classify/3.refseq_protein",mode:'copy'

    cpus = 32

    input:
    path prodigals

    output:
    path("contig2taxdump*")
    path("blastp*")
    path("gene*")
    path("add_contig.txt")
    path("refseq_protein.contig.taxonomy.format"),emit:'format'

    script:
    """
    /share/app/blast/2.10.0+/blastp -db ${params.protein_db1} -query ${prodigals} -evalue 1e-10 -num_threads 32 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out
    perl /share/app/add_taxid/0.1/add_taxid.pl ${params.protein_db2} blastp.out > blastp.out.addTaxid
    awk '\$NF!=""' blastp.out.addTaxid > blastp.out.addTaxid.nf
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl blastp.out.addTaxid.nf 3 > blastp.out.addTaxid.top3
    cat blastp.out.addTaxid.top3 | cut -f 1,18 > blastp.out.addTaxid.top3.id2taxid
    cut -f 2 blastp.out.addTaxid.top3.id2taxid > blastp.out.addTaxid.top3.id2taxid.2
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${params.datadir1} blastp.out.addTaxid.top3.id2taxid.2 > blastp.out.addTaxid.top3.id2taxid.2.line
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${params.datadir1} blastp.out.addTaxid.top3.id2taxid.2.line -P > blastp.out.addTaxid.top3.id2taxid.2.line.reformat
    paste blastp.out.addTaxid.top3.id2taxid blastp.out.addTaxid.top3.id2taxid.2.line.reformat | cut -f 1,5 > blastp.out.addTaxid.top3.id2taxid.name2taxdump
    perl /share/app/get_max_tax/0.1/get_max_tax.pl blastp.out.addTaxid.top3.id2taxid.name2taxdump > blastp.out.addTaxid.top3.id2taxid.name2taxdump.max
    grep "^>" ${prodigals} | sed 's/>//'| cut -d " " -f1 > geneid
    cat geneid | cut -d "_" -f1-3 | paste geneid - > gene2contig.txt
    perl /share/app/add_contig/0.1/add_contig.pl gene2contig.txt blastp.out.addTaxid.top3.id2taxid.name2taxdump.max > add_contig.txt
    awk -F '\\t' '{print \$3"\\t"\$2}' add_contig.txt > contig2taxdump.txt
    perl /share/app/get_max_tax/0.1/get_max_tax.pl contig2taxdump.txt > contig2taxdump.max.txt
    cat contig2taxdump.max.txt  | sed 's/;\\+\$//g' | awk '\$2!=""' | awk '\$2!="k__Viruses"' | sed 's/ /_/g' > refseq_protein.contig.taxonomy.format
    sed -i '1iID\\ttax' refseq_protein.contig.taxonomy.format

    """
}



process classify_crAss {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/05.classify/2.crAss-like_Phage_Detection",mode:'copy'

    input:
    path prodigals
    path cdhitslen
    path cdhitsfa

    output:
    path("crAss*")
    path("blastp*")
    path("NC_024711.blastn.out")
    path("p-crAssphage.list")
    path("crAss-like.len70k.list"),emit:'list'

    script:
    """
    /share/app/blast/2.10.0+/blastp -db ${params.crAss_db1} -query ${prodigals} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out
    awk '\$4>350' blastp.out > blastp.out.350AlnLen
    cat blastp.out.350AlnLen | cut -f 1 | awk -F '_' '{print \$1"_"\$2"_"\$3}' > crAss-like.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  crAss-like.list ${cdhitslen} > crAss-like.len.list
    awk '\$2>70000' crAss-like.len.list > crAss-like.len70k.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --fformat fasta  crAss-like.len70k.list ${cdhitsfa} > crAss-like.len70k.list.fasta
    sed -i '1iID\\tlength' crAss-like.len70k.list
    /share/app/blast/2.10.0+/blastn -db ${params.crAss_db2} -query crAss-like.len70k.list.fasta -evalue 1e-10 -num_threads 16 -outfmt '6 qseqid qlen sseqid sgi slen pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out NC_024711.blastn.out
    cat NC_024711.blastn.out | awk '\$6>95' | awk '\$16>80' | cut -f 1 | sort | uniq > p-crAssphage.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --except  p-crAssphage.list crAss-like.len70k.list > crAss-like.phage.list

    """
}

process classify_merge {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/05.classify/6.merge",mode:'copy'

    input:
    path cdhitslen
    path refseq_genome
    path crAssphage
    path refseq_protein
    path pfam
    path demovir

    output:
    path("*.taxonomy.txt")
    path("crAss*")

    script:
    """
    Rscript /share/app/merge.virus.taxonomy/0.2/merge.virus.taxonomy.R --id ${cdhitslen} --refseq_genome ${refseq_genome} --crAassphage ${crAssphage} --refseq_protein ${refseq_protein} --pfam ${pfam} --demovir ${demovir} --output \$PWD

    """
}

process gene_function {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/07.functional",mode:'copy'

    input:
    path prokka

    output:
    path("map_*")
    path("vir.faa*")
    path("gene2uniref.txt")

    script:

    """
    mkdir tmp
    /share/app/diamond/0.9.30.131/diamond blastp -q ${prokka} -d ${params.datadir3} -p 20 -e 1e-10 --sensitive --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovhsp scovhsp -t \$PWD/tmp -o vir.faa.diamond.out
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl vir.faa.diamond.out 1 > vir.faa.diamond.out.best
    awk '\$3>50' vir.faa.diamond.out.best |  awk '\$16>80' > vir.faa.diamond.out.best.filter
    cat vir.faa.diamond.out.best.filter | awk -F '|' '{print \$1}' > gene2uniref.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.db1} > map_CAZy_uniref90.out.disorder
    less map_CAZy_uniref90.out.disorder | sort | uniq > map_CAZy_uniref90.out
    cut -f 1,2 map_CAZy_uniref90.out > /map_CAZy_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.db2} > map_eggnog_uniref90.out
    cut -f 1,2 map_eggnog_uniref90.out > map_eggnog_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.db3} > map_go_uniref90.out
    cut -f 1,2 map_go_uniref90.out > map_go_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.db4} > map_ko_uniref90.out
    cut -f 1,2 map_ko_uniref90.out > map_ko_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.db5} > map_level4ec_uniref90.out
    cut -f 1,2 map_level4ec_uniref90.out > map_level4ec_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.db6} > map_pfam_uniref90.out
    cut -f 1,2 map_pfam_uniref90.out > map_pfam_uniref90.out.txt

    """

}

workflow {
/*
    contigs = channel.from(file(params.contigs))
        .splitCsv(header:true)
        .map{ row ->
                if(row.size()==2){
                    def id = row.sample
                    def contigs = row.file
                    return [ id, contigs]
                }else{
                     exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 2."
                }

        }

    virfinder = channel.from(file(params.virfinder))
        .splitCsv(header:true)
        .map{ row ->
                if(row.size()==2){
                    def id = row.sample
                    def virfinderid = row.file
                    return [ id, virfinderid]
                }else{
                     exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 2."
                }

        }

    virsorter = channel.from(file(params.virsorter))
        .splitCsv(header:true)
        .map{ row ->
                if(row.size()==2){
                    def id = row.sample
                    def virsorterid = row.file
                    return [ id, virsorterid]
                }else{
                     exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 2."
                }

        }
       

    data = contigs.join(virfinder).join(virsorter).view()
    merge_in(data)
    merge_out(merge_in.out.virus.collect())
    cdhit(merge_out.out)
    */
    data = channel.fromPath(params.input)
    cdhit(data)
    prodigal(cdhit.out.fa)
    prokka(cdhit.out.fa)

    classify_genome(cdhit.out.fa)
    classify_demovir(prodigal.out.cds)
    classify_pfam(prodigal.out.pep)
    classify_protein(prodigal.out.pep)
    classify_crAss(prodigal.out.pep,cdhit.out.len,cdhit.out.fa)
    classify_merge(cdhit.out.len,classify_genome.out.format,classify_crAss.out.list,classify_protein.out.format,classify_pfam.out.format,classify_demovir.out.format)

    gene_function(prokka.out.faa)

}
