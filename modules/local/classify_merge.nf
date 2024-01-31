process MERGE {

    label 'process_low'

    publishDir(
        path: "${params.outdir}/05.classify/4.pfam",
        pattern: "pfam.out.virus.taxonomy.format",
        mode: "copy",
        failOnError: true
    )
    
    publishDir(
        path: "${params.outdir}/05.classify/6.merge",
        saveAs: {filename -> {
                if ( filename.contains("pfam.out.virus.taxonomy.format") ) {
                    return null;
                }
                def out = file(filename)
                return "${out.name}";
            }
        },
        mode: "copy",
        failOnError: true
    )

    input:
    path(cdhitslen)
    path(refseq_genome)
    path(crAssphage)
    path(refseq_protein)
    path(pfam)
    path(demovir)

    output:
    path("*.taxonomy.txt")
    path("crAss*")
    path("contigs.taxonomy.txt"),emit:"taxonomy"
    path("pfam.out.virus.taxonomy.format")

    script:
    """
    Rscript ${params.nfcore_bin}/merge.virus.taxonomy.R --id ${cdhitslen} --refseq_genome ${refseq_genome} --crAassphage ${crAssphage} --refseq_protein ${refseq_protein} --pfam ${pfam} --demovir ${demovir} --output \$PWD

    """
}