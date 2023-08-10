process PROKKA {

    label 'process_medium'

    publishDir "${params.outdir}/04.predict/prokka",mode:'copy'

    input:
    path(cdhits)

    output:
    path("vir.bed"),emit:"bed"
    path("virus.prokka*")
    path("virus.prokka.faa"),emit:"faa"

    script:
    """
    prokka --outdir \$PWD --force --prefix virus.prokka --metagenome --cpus ${task.cpus} ${cdhits}
    cat virus.prokka.gff | grep CDS | cut -f 1,4,5,9 | awk -F ';' '{print \$1}' | sed 's/ID=//' > vir.bed

    """

}