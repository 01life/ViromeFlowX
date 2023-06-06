# nf-core/virome: Output

## Introduction

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

<!-- TODO nf-core: Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [QC](#QC) - Raw read QC
- [Assembly](#Assembly) - Assembly clean reads
- [Identify](#Identify)
- [Gene_Predict](#gene_predict)
- [Gene_Annotation](#gene_annotation)
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

[qc.jar](https://www.yuque.com/weiguang-zmv3n/oig0wr/dn0h3dfpw047snx4) is a wrapped jar package , @Author: Yangying.


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

### Gene_Predict

<details markdown="1">
<summary>Output files</summary>

- `04.predict/`
  - `cdhit/`
    - `virus.cdhit.fa`
    - `virus.cdhit.fa.clstr`
    - `virus.cdhit.fa.len`
  - `prodigal/`
    - `viral.cds`
    - `viral.gene.gff`
    - `viral.pep`
  - `prokka/`
    - `vir.bed`
    - `virus.prokka.err`
    - `virus.prokka.faa`
    - `virus.prokka.ffn`
    - `virus.prokka.fna`
    - `virus.prokka.fsa`
    - `virus.prokka.gbk`
    - `virus.prokka.gff`
    - `virus.prokka.log`
    - `virus.prokka.sqn`
    - `virus.prokka.tbl`
    - `virus.prokka.tsv`
    - `virus.prokka.txt`

</details>

### Gene_Annotation

<details markdown="1">
<summary>Output files</summary>

- `05.classify/`
  - `1.refseq_genome/`
    - `blastn.out`
    - `blastn.out.50`
    - `blastn.out.top5`
    - `blastn.out.top5_18`
    - `blastn.out.top5.contig2taxids`
    - `blastn.out.top5.contig2taxids.2`
    - `blastn.out.top5.contig2taxids.lca`
    - `blastn.out.top5.contig2taxids.lca.2`
    - `blastn.out.top5.contig2taxids.lca.2.line`
    - `blastn.out.top5.contig2taxids.lca.2.line.reformat`
    - `contig.tmp`
    - `refseq_genome.contig.taxonomy.format`
  - `2.crAss-like_Phage_Detection/`
    - `blastp.out`
    - `blastp.out.350AlnLen`
    - `crAss-like.len70k.list`
    - `crAss-like.len70k.list.fasta`
    - `crAss-like.len.list`
    - `crAss-like.list`
    - `crAss-like.phage.list`
    - `NC_024711.blastn.out`
    - `p-crAssphage.list`
  - `3.refseq_protein/`
    - `add_contig.txt`
    - `blastp.out`
    - `blastp.out.addTaxid`
    - `blastp.out.addTaxid.nf`
    - `blastp.out.addTaxid.top3`
    - `blastp.out.addTaxid.top3.id2taxid`
    - `blastp.out.addTaxid.top3.id2taxid.2`
    - `blastp.out.addTaxid.top3.id2taxid.2.line`
    - `blastp.out.addTaxid.top3.id2taxid.2.line.reformat`
    - `blastp.out.addTaxid.top3.id2taxid.name2taxdump`
    - `blastp.out.addTaxid.top3.id2taxid.name2taxdump.max`
    - `contig2taxdump.max.txt`
    - `contig2taxdump.txt`
    - `gene2contig.txt`
    - `geneid`
    - `refseq_protein.contig.taxonomy.format`
  - `4.pfam`
    - `pfam.out`
    - `pfam.out.filter`
    - `pfam.out.virus`
    - `pfam.out.virus.taxonomy`
    - `pfam.out.virus.taxonomy.format`
    - `pfam.out.virus.taxonomy.sed`
    - `pfam.out.virus.taxonomy.sed.deal`
  - `5.Demovir`
    - `contig2sciname.txt`
    - `contig2sciname.txt.cut`
    - `contig2sciname.txt.cut.nam2taxid`
    - `contig2sciname.txt.cut.nam2taxid.cut`
    - `contig2sciname.txt.cut.nam2taxid.cut.lineage`
    - `contig2sciname.txt.cut.nam2taxid.cut.lineage.reformat`
    - `DemoVir_assignments.txt`
    - `Demovir.contig.taxonmy`
    - `Demovir.contig.taxonmy.format`
    - `trembl_ublast.viral.txt`
    - `trembl_ublast.viral.u.contigID.txt`
    - `trembl_ublast.viral.u.txt`
  - `6.merge`
    - `contigs.taxonomy.txt`
    - `crAss-like.classified.id`
    - `demovir.contigs.taxonomy.txt`
    - `pfam.contigs.taxonomy.txt`
    - `refseq_genome.contigs.taxonomy.txt`
    - `refseq_protein.contigs.taxonomy.txt`

</details>

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

</details>

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
