
process spades {
    tag "$id"
    
    label 'process_high'
    
    container '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    
    publishDir "${params.outdir}/02.assembly/",mode:'copy'

    input:
    tuple val(id),path(reads1)
    tuple val(id),path(reads2)

    output:
    tuple val(id),path("${id}/1k.contigs.gz"),emit:"contigs"
    tuple val(id),path("${id}/1k.contigs"),emit:"onek"

    script:
    """
    mkdir ${id}
    python /share/app/SPAdes/3.11.1/bin/spades.py -o \$PWD --meta -1 ${reads1} -2 ${reads2} -t 16
    perl /share/app/deal_fa/0.1/deal_fa.pl contigs.fasta A1 >contigs
    perl /share/app/deal_fa/0.1/deal_fa.pl scaffolds.fasta A1 >scaffolds
    /share/app/seqtk/1.3-r106/seqtk seq -L 1000 contigs >1k.contigs
    pigz contigs scaffolds
    gzip -c 1k.contigs > 1k.contigs.gz
    rm -rf K* corrected misc tmp assembly* before* contigs* dataset* first* input params.txt scaffolds*
    mv 1k* input* spades.log ${id}

    """

}
