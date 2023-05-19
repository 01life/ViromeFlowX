nextflow.enable.dsl = 2

params.contigs = "02.assembly/${id}/1k.contigs.gz"
params.outdir = "03.identify"

process virsorter {

    container = '093786120757.dkr.ecr.cn-northwest-1.amazonaws.com.cn/flow-virus:v0.1'
    publishDir "${params.outdir}/${id}/VirSorter"

    input:
    path contigs

    output:
    path("VirSorter*")
    path("config.yaml")
    path("final*")

    script:
    """
    source activate vs2
    virsorter config --init-source --db-dir=/db
    virsorter run -w \$PWD -d /virsorterDB/ -i ${contigs}   -j 16      all
    grep -v lt2gene final-viral-score.tsv | awk '\$4>0.95' > VirSorter95.filter
    grep -v seqname VirSorter95.filter |  awk -F '|' '{print $1}'  > VirSorter.filter.id
    rm -rf iter-0 log

    """

}

workflow{
    data = channel.fromPath(params.contigs)
    virsorter(data)

}
