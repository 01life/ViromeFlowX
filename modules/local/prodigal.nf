process PRODIGAL {
    
    label 'process_low'

    publishDir "${params.outdir}/04.predict/prodigal/",mode:'copy'

    input:
    path(cdhits)

    output:
    path("vir.bed"),emit:"bed"
    path("viral.cds"),emit:"cds"
    path("viral.pep"),emit:"pep"
    path("viral.gene.gff")

    script:
    """
    prodigal -a viral.pep -d viral.cds -f gff -i ${cdhits} -o viral.gene.gff -p meta -q

    python ${params.nfcore_bin}/prodigal_gff2beb.py viral.gene.gff vir.bed
    
    """

}