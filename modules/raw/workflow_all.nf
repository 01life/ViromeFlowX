nextflow.enable.dsl = 2

//以下参数需要对针对每次运行的样本生成csv列表:python inital.py
params.input = "reads/normal/sample.csv"

params.datadir1 = "/data/db/db/classify/refseq_genome/taxdump"
params.datadir2 = "/db/classify/pfam/Pfam/"
params.datadir3 = "/db/uniprot/uniref_annotated/uniref90/uniref90_201901"

process trim {
    tag "$id"
    cpus 16

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "01.QC/",mode:'copy'

    input:
    tuple val(id), path(reads),path(fasta),path(index)

    output:
    tuple val(id),path("${id}/*fq.gz"),emit:"reads"
    path("${id}/",type:'dir')

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${id}"
    """
    mkdir ${id}
    java -jar /share/app/trimmomatic/0.39/trimmomatic.jar PE  -threads 16 -phred33 ${prefix}_1.fastq.gz ${prefix}_2.fastq.gz ${prefix}_trim_1.fq ${prefix}_trim_single.fq_1 ${prefix}_trim_2.fq ${prefix}_trim_single.fq_2 ILLUMINACLIP:${fasta}:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:15 MINLEN:50
    cat ${prefix}_trim_single.fq_1 ${prefix}_trim_single.fq_2 > ${prefix}_trim_single.fq
    /share/app/soap2/2.22/soap2 -a ${prefix}_trim_1.fq -b ${prefix}_trim_2.fq -D ${index}/hg38.fa.index -o ${prefix}_trim.pe -M 4 -l 32 -r 1 -m 400 -x 600 -2 ${prefix}_trim.se -v 8 -c 0.9 -S -p 16  2> ${prefix}_trimsoap2.pe.log
    /share/app/soap2/2.22/soap2 -a ${prefix}_trim_single.fq  -D ${index}/hg38.fa.index -o ${prefix}_trim.single -M 4 -l 32 -r 1 -v 8 -c 0.9 -S -p 16  2> ${prefix}_trimsoap2.single.log
    parallel ::: "perl /share/app/get_rmhost_reads/0.1/get_rmhost_reads.pl -i ${prefix}_trim_1.fq -r ${prefix}_trim.pe:${prefix}_trim.se -o ${prefix}_trim_rmhost_1.fq -n /1 -z -q " "perl /share/app/get_rmhost_reads/0.1/get_rmhost_reads.pl -i ${prefix}_trim_2.fq -r ${prefix}_trim.pe:${prefix}_trim.se -o ${prefix}_trim_rmhost_2.fq -n /2 -z -q " "perl /share/app/get_rmhost_reads/0.1/get_rmhost_reads.pl -i ${prefix}_trim_single.fq -r ${prefix}_trim.single -o ${prefix}_trim_rmhost_single.fq  -z -q "
    mv ${prefix}_trim_rmhost_*.fq.gz ${id}
    """

}


process assembly {
    tag "$id"

    memory {16.GB*task.attempt}
    cpus 16

    errorStrategy{'retry'}
    maxRetries 3

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "02.assembly/",mode:'copy'

    input:
    tuple val(id),path(reads)

    output:
    path("${id}/",type:'dir')
    tuple val(id),path("${id}/1k.contigs.gz"),emit:"contigs"
    //path("1k*")

    script:
    def prefix = task.ext.prefix ?: "${id}"
    //这里用\$PWD 获取当前目录替代了特定的绝对路径。反斜杠转义系统变量
    """
    mkdir ${id}
    python /share/app/SPAdes/3.11.1/bin/spades.py -o \$PWD --meta -1 ${prefix}_trim_rmhost_1.fq.gz -2 ${prefix}_trim_rmhost_2.fq.gz -t 32
    perl /share/app/deal_fa/0.1/deal_fa.pl contigs.fasta A1 >contigs
    perl /share/app/deal_fa/0.1/deal_fa.pl scaffolds.fasta A1 >scaffolds
    /share/app/seqtk/1.3-r106/seqtk seq -L 1000 contigs >1k.contigs
    pigz contigs scaffolds
    gzip -c 1k.contigs > 1k.contigs.gz
    rm -rf K* corrected misc tmp assembly* before* contigs* dataset* first* input params.txt scaffolds*
    mv 1k* input* spades.log ${id}

    """

}


process virfinder {
    tag "$id"
    cpus 16

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "03.identify/VirFinder",mode:'copy'

    input:
    tuple val(id),path(contigs)

    output:
    //    path("VirFinder.out*")
    path("${id}/",type:'dir')
    tuple val(id),path("${id}/VirFinder.out.filter.id"),emit:"virfinderid"

    script:
    """
    mkdir ${id}
    Rscript /share/app/VirFinder/0.1/VirFinder.R ${contigs} VirFinder.out
    awk '\$3>0.7' VirFinder.out | awk '\$4<0.05' > VirFinder.out.filter
    cut -f1 VirFinder.out.filter > VirFinder.out.filter.id
    mv VirFinder.out* ${id}

    """

}


process virsorter {
    tag "$id"

    publishDir "03.identify/VirSorter",mode:'copy'

    input:
    tuple val(id),path(contigs)
    //tuple val(id),path(contigs)

    output:
    path("${id}/",type:'dir')
    tuple val(id),path("${id}/VirSorter.filter.id"),emit:"virsorterid"
    //    path("VirSorter*")
    //    path("config.yaml")
    //    path("final*")

    script:
    """
    mkdir ${id}
    source activate vs2
    virsorter config --init-source --db-dir=/data/db/db
    virsorter run -w \$PWD -i ${contigs}   -j 16      all
    grep -v lt2gene final-viral-score.tsv | awk '\$4>0.95' > VirSorter95.filter
    grep -v seqname VirSorter95.filter |  awk -F '|' '{print \$1}'  > VirSorter.filter.id
    rm -rf iter-0 log
    mv VirSorter* contig.yaml final* ${id}

    """

}

process merge_in {
    tag "$id"

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "03.identify/merge/",mode:'copy'

    input:
    tuple val(id),path (contigs)
    tuple val(id),path (virfinderid)
    tuple val(id),path (virsorterid)

    output:
    path("${id}/",type:'dir')
    path("${id}/${id}_virus.fa"),emit:'virus'
 //   path("virus.fa"),emit=virus
 //   path("uniq.id")

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
    publishDir "03.identify/merge/",mode:'copy'

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
    publishDir "04.predict/cdhit/",mode:'copy'

    input:
    path merges

    output:
    path("virus.cdhit.fa"),emit:'fa'
    path("virus.cdhit.fa.len"),emit:'len'
    path("virus.cdhit.fa.clstr")

    script:
    """
    /share/app/cdhit/4.8.1/cd-hit-v4.8.1-2019-0228/cd-hit-est -i ${merges}  -o virus.cdhit.fa  -c 0.95   -M 0 -T 0   -d 0
    /share/app/seqkit/0.16.1/seqkit fx2tab -l -n virus.cdhit.fa > virus.cdhit.fa.len

    """

}

process prodigal {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "04.predict/prodigal/",mode:'copy'

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
    publishDir "04.predict/prokka",mode:'copy'

    input:
    path cdhits

    output:
    path("vir.bed")
    path("virus.prokka*")
    path("virus.prokka.faa"),emit:'faa'

    script:
    """
    prokka   --outdir \$PWD --force --prefix virus.prokka   --metagenome   --cpus 16   ${cdhits}
    cat virus.prokka.gff | grep CDS | cut -f 1,4,5,9 | awk -F ';' '{print \$1}' | sed 's/ID=//' > vir.bed

    """

}


process classify_genome {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "05.classify/1.refseq_genome/",mode:'copy'

    input:
    path cdhits
    path db
    path datadir1

    output:
    path("blastn*")
    path("contig.tmp")
    path("refseq_genome.contig.taxonomy.format"),emit:'format'

    script:
    """
    /share/app/blast/2.10.0+/blastn -db ${db} -query ${cdhits} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus staxid sscinames scomnames' -out blastn.out
    awk '\$15>50' blastn.out > blastn.out.50
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl blastn.out.50 5 > blastn.out.top5
    cut -f 1,18 blastn.out.top5 > blastn.out.top5_18
    perl /share/app/get_lca_input/0.1/get_lca_input.pl blastn.out.top5_18 > blastn.out.top5.contig2taxids
    cut -f 2 blastn.out.top5.contig2taxids > blastn.out.top5.contig2taxids.2
    export BLASTDB="/db/classify/refseq_genome/taxdb"
    /share/app/taxonkit/0.7.2/taxonkit lca --data-dir ${datadir1} blastn.out.top5.contig2taxids.2 > contig.tmp
    paste blastn.out.top5.contig2taxids contig.tmp |cut -f 1,4 > blastn.out.top5.contig2taxids.lca
    cut -f 2 blastn.out.top5.contig2taxids.lca > blastn.out.top5.contig2taxids.lca.2
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${datadir1} blastn.out.top5.contig2taxids.lca.2 > blastn.out.top5.contig2taxids.lca.2.line
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${datadir1} blastn.out.top5.contig2taxids.lca.2.line -P > blastn.out.top5.contig2taxids.lca.2.line.reformat
    paste blastn.out.top5.contig2taxids.lca blastn.out.top5.contig2taxids.lca.2.line.reformat | cut -f 1,5 | awk '\$2!="k__Viruses;p__;c__;o__;f__;g__;s__"' | awk '\$2!="k__;p__;c__;o__;f__;g__;s__"'  | sed 's/;p__;c__;o__;f__;g__;s__$//' | sed 's/;c__;o__;f__;g__;s__$//' | sed 's/;o__;f__;g__;s__$//' | sed 's/;f__;g__;s__$//' | sed 's/;g__;s__$//' | sed 's/;s__$//' | sed 's/ /_/g' > refseq_genome.contig.taxonomy.format
    """
}


process classify_demovir {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "05.classify/5.Demovir",mode:'copy'

    input:
    path prodigals
    path db
    path datadir1

    output:
    path("contig2sciname*")
    path("Demovir.contig.taxonmy")
    path("DemoVir_assignments.txt")
    path("trembl_ublast*")
    path("Demovir.contig.taxonmy.format"),emit:'format'

    //注意反转义
    script:
    """
    /share/app/usearch/11.0.667/usearch -ublast ${prodigals} -db ${db} -evalue 1e-5 -threads 16 -trunclabels -blast6out trembl_ublast.viral.txt
    sort -u -k1,1 trembl_ublast.viral.txt > trembl_ublast.viral.u.txt
    cut -f 1,2 trembl_ublast.viral.u.txt | sed 's/_[0-9]\\+\\t/\\t/' | cut -f 1 | paste trembl_ublast.viral.u.txt - > trembl_ublast.viral.u.contigID.txt
    Rscript /share/app/Demovir/0.1/demovir.R trembl_ublast.viral.u.contigID.txt DemoVir_assignments.txt
    perl /share/app/get_sciname/0.1/get_sciname.pl DemoVir_assignments.txt > contig2sciname.txt
    sed -i '/no_order/d' contig2sciname.txt
    cut -f 2 contig2sciname.txt > contig2sciname.txt.cut
    /share/app/taxonkit/0.7.2/taxonkit name2taxid --data-dir ${datadir1} contig2sciname.txt.cut > contig2sciname.txt.cut.nam2taxid
    cut -f 2 contig2sciname.txt.cut.nam2taxid > contig2sciname.txt.cut.nam2taxid.cut
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${datadir1} contig2sciname.txt.cut.nam2taxid.cut > contig2sciname.txt.cut.nam2taxid.cut.lineage
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${datadir1} contig2sciname.txt.cut.nam2taxid.cut.lineage -P > contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat
    paste contig2sciname.txt contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat | cut -f 1,5 > Demovir.contig.taxonmy
    cat Demovir.contig.taxonmy  | sed 's/;p__;c__;o__;f__;g__;s__$//' | sed 's/;c__;o__;f__;g__;s__$//' | sed 's/;o__;f__;g__;s__$//' | sed 's/;f__;g__;s__$//' | sed 's/;g__;s__$//' | sed 's/;s__$//' | sed 's/ /_/g' > Demovir.contig.taxonmy.format
    sed -i '1iID\\ttax' Demovir.contig.taxonmy.format

    """
}

process classify_pfam {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "05.classify/4.pfam",mode:'copy'

    input:
    path prodigals
    path db
    path datadir2

    output:
    path("pfam.out*")
    path("pfam.out.virus.taxonomy.format"),emit:'format'

    script:
    """
    perl /share/app/miniconda3/bin/pfam_scan.pl -fasta ${prodigals} -cpu 16 -dir ${datadir2} -outfile pfam.out
    perl /share/app/get_filter/0.1/get_filter.pl ${db} pfam.out > pfam.out.filter
    awk '\$3!=""' pfam.out.filter > pfam.out.virus
    sed 's/Caudovirales tail/Caudovirales tail\\tCaudovirales\\tViruses;Uroviricota;Caudoviricetes;Caudovirales\\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__;g__;s__/g' pfam.out.virus | sed 's/Microviridae capsid/Microviridae capsid\\tMicroviridae\\tViruses;Phixviricota;Malgrandaviricetes;Petitvirales;Microviridae\\tk__Viruses;p__Phixviricota;c__Malgrandaviricetes;o__Petitvirales;f__Microviridae;g__;s__/' | sed 's/Myoviridae tail sheath/Myoviridae tail sheath\\tMyoviridae\\tViruses;Uroviricota;Caudoviricetes;Caudovirales;Myoviridae\\tk__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__Myoviridae;g__;s__/' |  cut -f 1,6 > pfam.out.virus.taxonomy
    cat pfam.out.virus.taxonomy | sed 's/;p__;c__;o__;f__;g__;s__$//' | sed 's/;c__;o__;f__;g__;s__$//' | sed 's/;o__;f__;g__;s__$//' | sed 's/;f__;g__;s__$//' | sed 's/;g__;s__$//' | sed 's/;s__$//' > pfam.out.virus.taxonomy.sed
    perl /share/app/deal_pro2contig/0.1/deal_pro2contig.pl pfam.out.virus.taxonomy.sed > pfam.out.virus.taxonomy.sed.deal
    sed 's/ /_/g' pfam.out.virus.taxonomy.sed.deal > pfam.out.virus.taxonomy.format
    sed -i '1iID\\ttax' pfam.out.virus.taxonomy.format

    """
}


process classify_protein {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "05.classify/3.refseq_protein",mode:'copy'

    input:
    path prodigals
    path db1
    path db2
    path datadir1

    output:
    path("contig2taxdump*")
    path("blastp*")
    path("gene*")
    path("add_contig.txt")
    path("refseq_protein.contig.taxonomy.format"),emit:'format'

    script:
    """
    /share/app/blast/2.10.0+/blastp -db ${db1} -query ${prodigals} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out
    perl /share/app/add_taxid/0.1/add_taxid.pl ${db2} blastp.out > blastp.out.addTaxid
    awk '\$NF!=""' blastp.out.addTaxid > blastp.out.addTaxid.nf
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl blastp.out.addTaxid.nf 3 > blastp.out.addTaxid.top3
    cat blastp.out.addTaxid.top3 | cut -f 1,18 > blastp.out.addTaxid.top3.id2taxid
    cut -f 2 blastp.out.addTaxid.top3.id2taxid > blastp.out.addTaxid.top3.id2taxid.2
    /share/app/taxonkit/0.7.2/taxonkit lineage --data-dir ${datadir1} blastp.out.addTaxid.top3.id2taxid.2 > blastp.out.addTaxid.top3.id2taxid.2.line
    /share/app/taxonkit/0.7.2/taxonkit reformat --data-dir ${datadir1} blastp.out.addTaxid.top3.id2taxid.2.line -P > blastp.out.addTaxid.top3.id2taxid.2.line.reformat
    paste blastp.out.addTaxid.top3.id2taxid blastp.out.addTaxid.top3.id2taxid.2.line.reformat | cut -f 1,5 > blastp.out.addTaxid.top3.id2taxid.name2taxdump
    perl /share/app/get_max_tax/0.1/get_max_tax.pl blastp.out.addTaxid.top3.id2taxid.name2taxdump > blastp.out.addTaxid.top3.id2taxid.name2taxdump.max
    grep "^>" ${prodigals} | sed 's/>//'| cut -d " " -f1 > geneid
    cat geneid | cut -d "_" -f1-3 | paste geneid - > gene2contig.txt
    perl /share/app/add_contig/0.1/add_contig.pl gene2contig.txt blastp.out.addTaxid.top3.id2taxid.name2taxdump.max > add_contig.txt
    awk -F '\\t' '{print \$3"\\t"\$2}' add_contig.txt > contig2taxdump.txt
    perl /share/app/get_max_tax/0.1/get_max_tax.pl contig2taxdump.txt > contig2taxdump.max.txt
    cat contig2taxdump.max.txt  | sed 's/;\\+$//g' | awk '\$2!=""' | awk '\$2!="k__Viruses"' | sed 's/ /_/g' > refseq_protein.contig.taxonomy.format
    sed -i '1iID\\ttax' refseq_protein.contig.taxonomy.format

    """
}



process classify_crAss {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "05.classify/2.crAss-like_Phage_Detection",mode:'copy'

    input:
    path prodigals
    path cdhitslen
    path cdhitsfa
    path db1
    path db2

    output:
    path("crAss*")
    path("blastp*")
    path("NC_024711.blatn.out")
    path("p-crAssphage.list"),emit:'list'

    script:
    """
    /share/app/blast/2.10.0+/blastp -db ${db1} -query ${prodigals} -evalue 1e-10 -num_threads 16 -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out blastp.out
    awk '\$4>350' blastp.out > /blastp.out.350AlnLen
    cat blastp.out.350AlnLen | cut -f 1 | awk -F '_' '{print \$1"_"\$2"_"\$3}' > crAss-like.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  crAss-like.list ${cdhitslen} > crAss-like.len.list
    awk '\$2>70000' crAss-like.len.list > crAss-like.len70k.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --fformat fasta  crAss-like.len70k.list ${cdhitsfa} > crAss-like.len70k.list.fasta
    echo -e  'test' > crAss-like.len70k.list
    sed -i '1iID\\tlength' crAss-like.len70k.list
    sed -i '\$d' crAss-like.len70k.list
    /share/app/blast/2.10.0+/blastn -db ${db2} -query crAss-like.len70k.list.fasta -evalue 1e-10 -num_threads 16 -outfmt '6 qseqid qlen sseqid sgi slen pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out NC_024711.blastn.out
    cat NC_024711.blastn.out | awk '\$6>95' | awk '\$16>80' | cut -f 1 | sort | uniq > p-crAssphage.list
    perl /share/app/fishInWinter/0.1/fishInWinter.pl  --except  p-crAssphage.list crAss-like.len70k.list > crAss-like.phage.list

    """
}

process classify_merge {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "05.classify/6.merge",mode:'copy'

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
    Rscript /share/app/merge.virus.taxonomy/0.1/merge.virus.taxonomy.R --id ${cdhitslen} --refseq_genome ${refseq_genome} --crAassphage ${crAssphage} --refseq_protein ${refseq_protein} --pfam ${pfam} --demovir ${demovir} --output \$PWD

    """
}

process gene_function {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "07.functional",mode:'copy'

    input:
    path prokka
    path db1
    path db2
    path db3
    path db4
    path db5
    path db6
    path datadir3

    output:
    path("map_*")
    path("vir.faa*")
    path("gene2uniref.txt")

    script:

    """
    /share/app/diamond/0.9.30.131/diamond blastp -q ${prokka} -d ${datadir3} -p 20 -e 1e-10 --sensitive --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovhsp scovhsp -t \$PWD/tmp -o vir.faa.diamond.out
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl vir.faa.diamond.out 1 > vir.faa.diamond.out.best
    awk '\$3>50' vir.faa.diamond.out.best |  awk '\$16>80' > vir.faa.diamond.out.best.filter
    cat vir.faa.diamond.out.best.filter | awk -F '|' '{print \$1}' > gene2uniref.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db1} > map_CAZy_uniref90.out.disorder
    less map_CAZy_uniref90.out.disorder | sort | uniq > map_CAZy_uniref90.out
    cut -f 1,2 map_CAZy_uniref90.out > /map_CAZy_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db2} > map_eggnog_uniref90.out
    cut -f 1,2 map_eggnog_uniref90.out > map_eggnog_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db3} > map_go_uniref90.out
    cut -f 1,2 map_go_uniref90.out > map_go_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db4} > map_ko_uniref90.out
    cut -f 1,2 map_ko_uniref90.out > map_ko_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db5} > map_level4ec_uniref90.out
    cut -f 1,2 map_level4ec_uniref90.out > map_level4ec_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db6} > map_pfam_uniref90.out
    cut -f 1,2 map_pfam_uniref90.out > map_pfam_uniref90.out.txt

    """

}

workflow {
    

    data = channel.from(file(params.input))
        .splitCsv(header:true)
        .map{ row ->
                if(row.size()==5){
                    def id = row.sample
                    def reads1 = row.reads1
                    def reads2 = row.reads2
                    def fasta = row.fasta
                    def index = row.index
                    // Check if given combination is valid
                    if (!reads1) exit 1, "Invalid input samplesheet: short_reads_1 can not be empty."
                    return [ id, reads1, reads2, fasta, index ]
                }else{
                     exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 5."
                }

        }
        .view()

    reads = data
        .map { id, reads1, reads2, fasta, index ->
            return [ id, [ reads1, reads2 ] ,fasta,index ]
        }

    trim(reads)

    assembly(trim.out.reads)

    virfinder(assembly.out.contigs)
 /*
    dataDir = channel.from(file(params.dataDir))
        .splitCsv(header:true)
        .map{ row ->
                def id = row.sample
                def dataDir = row.dataDir
                return [id,dataDir]
        }
        .view()
    assembly.out.contigs.join(dataDir).view()
    virsorter(assembly.out.contigs.join(dataDir))
    
    //virsorter(assembly.out.contigs)

    merge_in(assembly.out.contigs,virfinder.out.virfinderid,virsorter.out.virsorterid)
    merge_out(merge_in.out.virus.collect())

    cdhit(merge_out.out)

    prodigal(cdhit.out.fa)

    prokka(cdhit.out.fa)

    datadir1 = channel.fromPath(params.datadir1)
    datadir2 = channel.fromPath(params.datadir2)
    datadir3 = channel.fromPath(params.datadir3)

    genome_db = channel.fromPath("/db/classify/refseq_genome/refseq_virus_filter.fasta")
   
    classify_genome(cdhit.out.fa,genome_db,datadir1)

    demovir_db = channel.fromPath("/db/classify/Demovir/uniprot_trembl.viral.udb") 
    classify_demovir(prodigal.out.cds,demovir_db,datadir1)

    pfam_db = channel.fromPath("/db/classify/pfam/virus.pfam") 
    classify_pfam(prodigal.out.pep,pfam_db,datadir2)

    protein_db1 = channel.fromPath("/db/classify/refseq_protein/virus.pep.filter.fasta")
    protein_db2 = channel.fromPath("/db/classify/refseq_protein/protID2taxid.txt")
    classify_protein(prodigal.out.pep,protein_db1,protein_db2,datadir1)

    crAss_db1 = channel.fromPath("/db/classify/crAss-like/crAssphage_polymerase_Terminase/crAssphage_polymerase_Terminase.fa") 
    crAss_db2 = channel.fromPath("/db/classify/crAss-like/NC_024711.1/NC_024711.1.fasta") 
    classify_crAss(prodigal.out.pep,cdhit.out.len,cdhit.out.fa,crAss_db1,crAss_db2)

    classify_merge(cdhit.out.len,classify_genome.out.format,classify_crAss.out.list,classify_protein.out.format,classify_pfam.out.format,classify_demovir.out.format)

    db1 = channel.fromPath("/db/humann/full_mapping/map_CAZy_uniref90.txt.gz")
    db2 = channel.fromPath("/db/humann/full_mapping/map_eggnog_uniref90.txt.gz")
    db3 = channel.fromPath("/db/humann/full_mapping/map_go_uniref90.txt.gz")
    db4 = channel.fromPath("/db/humann/full_mapping/map_ko_uniref90.txt.gz")
    db5 = channel.fromPath("/db/humann/full_mapping/map_level4ec_uniref90.txt.gz")
    db6 = channel.fromPath("/db/humann/full_mapping/map_pfam_uniref90.txt.gz")
    gene_function(prokka.out.faa,db1,db2,db3,db4,db5,db6,datadir3)
*/
}
