process prodigal {
    
    label 'process_low'

    container '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'

    publishDir "${params.outdir}/04.predict/prodigal/",mode:'copy'

    input:
    path cdhits

    output:
    path("viral.cds"),emit:"cds"
    path("viral.pep"),emit:"pep"
    path("viral.gene.gff")

    script:
    """
    /share/app/prodigal/2.6.3/prodigal -a viral.pep -d viral.cds -f gff -i ${cdhits} -o viral.gene.gff -p meta -q

    """

}