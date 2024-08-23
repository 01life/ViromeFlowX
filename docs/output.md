# ViromeFlowX: Output

## Introduction

This document describes the output produced by the pipeline.The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

<!-- TODO nf-core: Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [QC](#QC) - Raw read QC
- [Assembly](#Assembly) - Assembly clean reads
- [Identify](#Identify)
- [Geneset](#geneset)
- [Abundance](#Abundance)
- [Funtional](#funtional)
- [Profile](#Profile)
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### QC

<details markdown="1">
<summary>Output files</summary>


- `01.QC/`
  - `Sample ID/`
    - `*_clean_1.fq.gz`: clean reads1
    - `*_clean_2.fq.gz`: clean reads2

</details>

[`Trimmomatic`](https://github.com/usadellab/Trimmomatic) is a fast, multithreaded command line tool that can be used to trim and crop 
Illumina (FASTQ) data as well as to remove adapters. These adapters can pose a real problem depending on the library preparation and downstream application.

[`Bowtie 2`](https://github.com/BenLangmead/bowtie2) is an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences. It is particularly good at aligning reads of about 50 up to 100s or 1,000s of characters, and particularly good at aligning to relatively long (e.g. mammalian) genomes. Bowtie 2 indexes the genome with an FM Index to keep its memory footprint small: for the human genome, its memory footprint is typically around 3.2 GB. Bowtie 2 supports gapped, local, and paired-end alignment modes.


### Assembly

<details markdown="1">
<summary>Output files</summary>

- `02.assembly/`
  - `Sample ID/`
    - `1k.contigs`
    - `input_dataset.yaml`
    - `spades.log`

</details>

[Metaspades](https://github.com/ablab/spades)  SPAdes - St. Petersburg genome assembler - is an assembly toolkit containing various assembly pipelines. This manual will help you to install and run SPAdes. SPAdes version 3.15.5 was released under GPLv2 on July 14th, 2022 and can be downloaded from http://cab.spbu.ru/software/spades/.

### Identify

<details markdown="1">
<summary>Output files</summary>

- `03.identify/`
  - `CheckV`
    - `Sample ID`
      - `*_proviruses_viruses.fna`
      - `complete_genomes.tsv`
      - `completeness.tsv`
      - `contamination.tsv`
      - `proviruses.fna`
      - `quality_summary.tsv`
      - `viruses.fna`
  - `merge/`
    - `Sample ID`
      - `*_virus.fa`
      - `uniq.id`
  - `VirFinder/`
    - `Sample ID/`
      - `VirFinder.out`
      - `VirFinder.out.filter`
      - `VirFinder.out.filter.id`
  - `VirSorter/`
    - `Sample ID/`
      - `final-viral-boundary.tsv`
      - `final-viral-combined.fa`
      - `final-viral-score.tsv`
      - `VirSorter95.filter`
      - `VirSorter.filter.id`
      - `config.yaml`

</details>

[VirFinder](https://github.com/jessieren/VirFinder) R package for identifying viral sequences from metagenomic data using sequence signatures.

[VirSorter2](https://github.com/jiarong/VirSorter2) VirSorter2 applies a multi-classifier, expert-guided approach to detect diverse DNA and RNA virus genomes.

[CheckV](https://bitbucket.org/berkeleylab/checkv/src/master/) is a fully automated command-line pipeline for assessing the quality of single-contig viral genomes, including identification of host contamination for integrated proviruses, estimating completeness for genome fragments, and identification of closed genomes.

### Geneset

<details markdown="1">
<summary>Output files</summary>

- `04.predict/`
  - `cdhit/`
    - `virus.cdhit.fa`
    - `virus.cdhit.fa.clstr`
    - `virus.cdhit.fa.len`
    - `merge.virus.fa.gz`
  - `prodigal/`
    - `viral.cds`
    - `viral.gene.gff`
    - `viral.pep`

- `05.classify/`
  - `1.refseq_genome/`
    - `refseq_genome.contig.taxonomy.format`
  - `2.crAss-like_Phage_Detection/`
    - `crAss-like.list`
  - `3.refseq_protein/`
    - `refseq_protein.contig.taxonomy.format`
  - `4.pfam`
    - `pfam.out.virus.taxonomy.format`
  - `5.Demovir`
    - `Demovir.contig.taxonmy.format`
  - `6.merge`
    - `contigs.taxonomy.txt`
    - `crAss-like.classified.id`
    - `demovir.contigs.taxonomy.txt`
    - `pfam.contigs.taxonomy.txt`
    - `refseq_genome.contigs.taxonomy.txt`
    - `refseq_protein.contigs.taxonomy.txt`

</details>

[Cdhit](https://github.com/weizhongli/cdhit) is a widely used program for clustering biological sequences to reduce sequence redundancy and improve the performance of other sequence analyses.

[Prodigal](https://github.com/hyattpd/Prodigal) Fast, reliable protein-coding gene prediction for prokaryotic genomes.

[taxonkit](https://github.com/shenwei356/taxonkit) A Practical and Efficient NCBI Taxonomy Toolkit.

### Abundance

<details markdown="1">
<summary>Output files</summary>

- `06.abundance/`
  - `contig/`
    - `Sample ID/`
      - `*.contig.abundance`
      - `sort.filter.cov`
      - `sort.filter.cov.contig`
      - `sort.filter.dpmean`
    - `virus.contigs.abun.txt`
  - `gene/`
    - `Sample ID/`
      - `*.rp`
      - `*.rpkm`
      - `flagstat`
      - `gene.count`
      - `total.reads`
    - `virus.gene.rpkm.pr`

</details>

### Functional

<details markdown="1">
<summary>Output files</summary>

- `07.functional/`
  - `gene2uniref.txt`
  - `map_CAZy_uniref90.out`
  - `map_CAZy_uniref90.out.disorder`
  - `map_CAZy_uniref90.out.txt`
  - `map_eggnog_uniref90.out`
  - `map_eggnog_uniref90.out.txt`
  - `map_go_uniref90.out`
  - `map_go_uniref90.out.txt`
  - `map_ko_uniref90.out`
  - `map_ko_uniref90.out.txt`
  - `map_level4ec_uniref90.out`
  - `map_level4ec_uniref90.out.txt`
  - `map_pfam_uniref90.out`
  - `map_pfam_uniref90.out.txt`
  - `vir.faa.diamond.out`
  - `vir.faa.diamond.out.best`
  - `vir.faa.diamond.out.best.filter`

</details>


[DIAMOND](https://github.com/bbuchfink/diamond) is a sequence aligner for protein and translated DNA searches, designed for high performance analysis of big sequence data. 

### Profile

<details markdown="1">
<summary>Output files</summary>

- `08.profile/`
  - `functional`
    - `CAZy.pr`
    - `CAZy_relab.pr`
    - `eggnog.pr`
    - `eggnog_relab.pr`
    - `go.pr`
    - `go_relab.pr`
    - `ko.pr`
    - `ko_relab.pr`
    - `level4ec.pr`
    - `level4ec_relab.pr`
    - `pfam.pr`
    - `pfam_relab.pr`
  - `taxa`
    - `class.pr`
    - `famliy.pr`
    - `genus.pr`
    - `order.pr`
    - `phylum.pr`
    - `species.pr`
    - `virus.contigs.abun.relab.txt`
    - `virus.contig_with_tax.txt`
    - `virus.taxonomy.txt`
  - `Kraken2/`
    - `Sample ID/`
      - `*_bracken_*.xls`
      - `*_kreport_bracken_*.xls`
    - `Kraken2_*.xls`

</details>

[Kraken 2](https://github.com/DerrickWood/kraken2) is the newest version of Kraken, a taxonomic classification system using exact k-mer matches to achieve high accuracy and fast classification speeds.

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
