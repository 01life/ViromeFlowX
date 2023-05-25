process PROKKA {

    label 'process_single'

    publishDir "${params.outdir}/04.predict/prokka",mode:'copy'

    input:
    path cdhits

    output:
    path("vir.bed"),emit:"bed"
    path("virus.prokka*")
    path("virus.prokka.faa"),emit:"faa"

    script:
    """
    /ehpcdata/PM/DATA/RD23010035/app/prokka/1.14.6/prokka --outdir \$PWD --force --prefix virus.prokka --metagenome --cpus 16 ${cdhits}
    cat virus.prokka.gff | grep CDS | cut -f 1,4,5,9 | awk -F ';' '{print \$1}' | sed 's/ID=//' > vir.bed

    """

}