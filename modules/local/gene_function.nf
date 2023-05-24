process gene_function {

    label 'process_single'

    publishDir "${params.outdir}/07.functional",mode:'copy'

    input:
    path prokka

    output:
    path("map_*")
    path("vir.faa*")
    path("gene2uniref.txt")
    path("map_CAZy_uniref90.out.txt"),emit:"cazy"
    path("map_eggnog_uniref90.out.txt"),emit:"eggnog"
    path("map_go_uniref90.out.txt"),emit:"go"
    path("map_ko_uniref90.out.txt"),emit:"ko"
    path("map_level4ec_uniref90.out.txt"),emit:"level4ec"
    path("map_pfam_uniref90.out.txt"),emit:"pfam"

    script:

    """
    mkdir tmp
    /ehpcdata/PM/DATA/RD23010035/app/diamond/0.9.30.131/diamond blastp -q ${prokka} -d ${params.uniref90_data} -p 16 -e 1e-10 --sensitive --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovhsp scovhsp -t \$PWD/tmp -o vir.faa.diamond.out

    perl /ehpcdata/PM/DATA/RD23010035/app/get_blast_top_n/0.1/get_blast_top_n.pl vir.faa.diamond.out 1 > vir.faa.diamond.out.best
    awk '\$3>50' vir.faa.diamond.out.best |  awk '\$16>80' > vir.faa.diamond.out.best.filter
    cat vir.faa.diamond.out.best.filter | awk -F '|' '{print \$1}' > gene2uniref.txt

    perl /ehpcdata/PM/DATA/RD23010035/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.CAZy} > map_CAZy_uniref90.out.disorder
    less map_CAZy_uniref90.out.disorder | sort | uniq > map_CAZy_uniref90.out
    cut -f 1,2 map_CAZy_uniref90.out > map_CAZy_uniref90.out.txt

    perl /ehpcdata/PM/DATA/RD23010035/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.eggnog} > map_eggnog_uniref90.out
    cut -f 1,2 map_eggnog_uniref90.out > map_eggnog_uniref90.out.txt

    perl /ehpcdata/PM/DATA/RD23010035/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.go} > map_go_uniref90.out
    cut -f 1,2 map_go_uniref90.out > map_go_uniref90.out.txt

    perl /ehpcdata/PM/DATA/RD23010035/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.ko} > map_ko_uniref90.out
    cut -f 1,2 map_ko_uniref90.out > map_ko_uniref90.out.txt

    perl /ehpcdata/PM/DATA/RD23010035/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.level4ec} > map_level4ec_uniref90.out
    cut -f 1,2 map_level4ec_uniref90.out > map_level4ec_uniref90.out.txt

    perl /ehpcdata/PM/DATA/RD23010035/app/get_path2virgene2/0.1/get_path2virgene2.pl gene2uniref.txt ${params.pfam} > map_pfam_uniref90.out
    cut -f 1,2 map_pfam_uniref90.out > map_pfam_uniref90.out.txt
    
    """

}
