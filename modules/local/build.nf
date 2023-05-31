process BUILD {
    
    label 'process_single'
    
    // publishDir "${params.outdir}/06.abundance/map/",mode:'copy'
    
    input:
    path(cdhitsfa)
    
    output:    
    path("virus.fa*"),emit:"index"
    
    script:
    """
    cp ${cdhitsfa} virus.fa
    /ehpcdata/PM/DATA/RD23010035/app/bowtie2/2.4.1/bowtie2-build --threads 16 virus.fa virus.fa
    """
}