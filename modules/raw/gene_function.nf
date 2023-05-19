nextflow.enable.dsl = 2

params.prokka = "04.predict/prokka/virus.prokka.faa"
params.outdir = "07.functional"


process gene_function{

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir params.outdir

    input:
    path prokka
    path db1
    path db2
    path db3
    path db4
    path db5
    path db6
    path db7

    output:
    path("map_*")
    path("vir.faa*")
    path("gene2uniref.txt")

    script:

    """
    /share/app/diamond/0.9.30.131/diamond blastp -q ${prokka} -d ${db1} -p 20 -e 1e-10 --sensitive --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovhsp scovhsp -t $PWD/tmp -o vir.faa.diamond.out
    perl /share/app/get_blast_top_n/0.1/get_blast_top_n.pl vir.faa.diamond.out 1 > vir.faa.diamond.out.best
    awk '$3>50' vir.faa.diamond.out.best |  awk '$16>80' > vir.faa.diamond.out.best.filter
    cat vir.faa.diamond.out.best.filter | awk -F '|' '{print $1}' > gene2uniref.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db2} > map_CAZy_uniref90.out.disorder
    less map_CAZy_uniref90.out.disorder | sort | uniq > map_CAZy_uniref90.out
    cut -f 1,2 map_CAZy_uniref90.out > /map_CAZy_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db3} > map_eggnog_uniref90.out
    cut -f 1,2 map_eggnog_uniref90.out > map_eggnog_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db4} > map_go_uniref90.out
    cut -f 1,2 map_go_uniref90.out > map_go_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db5} > map_ko_uniref90.out
    cut -f 1,2 map_ko_uniref90.out > map_ko_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db6} > map_level4ec_uniref90.out
    cut -f 1,2 map_level4ec_uniref90.out > map_level4ec_uniref90.out.txt
    perl /share/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${db7} > map_pfam_uniref90.out
    cut -f 1,2 map_pfam_uniref90.out > map_pfam_uniref90.out.txt

    """

}


workflow{

    data = channel.fromPath(params.prokka)
    db1 = channel.fromPath("/db/uniprot/uniref_annotated/uniref90/uniref90_201901")
    db2 = channel.fromPath("/db/humann/full_mapping/map_CAZy_uniref90.txt.gz")
    db3 = channel.fromPath("/db/humann/full_mapping/map_eggnog_uniref90.txt.gz")
    db4 = channel.fromPath("/db/humann/full_mapping/map_go_uniref90.txt.gz")
    db5 = channel.fromPath("/db/humann/full_mapping/map_ko_uniref90.txt.gz")
    db6 = channel.fromPath("/db/humann/full_mapping/map_level4ec_uniref90.txt.gz")
    db7 = channel.fromPath("/db/humann/full_mapping/map_pfam_uniref90.txt.gz")
    gene_function(data,db1,db2,db3,db4,db5,db6,db7)

}
