process BUILD {
    
    label 'process_single'
        
    input:
    path(cdhitsfa)
    
    output:    
    path("virus.fa*"),emit:"index"
    
    script:
    """
    cp ${cdhitsfa} virus.fa
    bowtie2-build --threads ${task.cpus} virus.fa virus.fa

    """
}