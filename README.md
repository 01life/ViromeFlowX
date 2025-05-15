# ![ViromeFlowX](docs/images/nf-core-virome_logo_light.png#gh-light-mode-only)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with slurm](https://img.shields.io/badge/run%20with-slurm-1AAEE8.svg?labelColor=000000)](https://www.schedmd.com)

## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->

**ViromeFlowX** is a comprehensive Nextflow-based automated workflow for mining viral genomes from metagenomic sequencing Data. Understanding the link between the human gut virome and diseases has garnered significant interest in the research community. Extracting virus-related information from metagenomic sequencing data is crucial for unravelling virus composition, host interactions, and disease associations. However, current metagenomic analysis workflows for viral genomes vary in effectiveness, posing challenges for researchers seeking the most up-to-date tools. To address this, we present ViromeFlowX, a user-friendly Nextflow workflow that automates viral genome assembly, identification, classification, and annotation. This streamlined workflow integrates cutting-edge tools for processing raw sequencing data for taxonomic annotation and functional analysis. Application to a dataset of 200 metagenomic samples yielded high-quality viral genomes. ViromeFlowX enables efficient mining of viral genomic data, offering a valuable resource to investigate the gut virome’s role in virus-host interactions and virus-related diseases.

<p align="center">
    <img src="docs/images/workflow.jpg" alt="ViromeFlowX workflow overview" width="90%">
</p>

## Pipeline summary

<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Quality Control ( [`trimmomatic`](https://github.com/usadellab/Trimmomatic) [`bowtie2`](https://github.com/BenLangmead/bowtie2) )
2. Assembly ( [`metaspades`](https://github.com/ablab/spades) )
3. Viral Taxonomic Classify ( [`Kraken2`](https://github.com/DerrickWood/kraken2) )
4. Viral Contigs Identification ( [`VirFinder`](https://github.com/jessieren/VirFinder) [`VirSorter2`](https://github.com/jiarong/VirSorter2) [`CheckV`](https://bitbucket.org/berkeleylab/checkv/src/master/) [`Cdhit`](https://github.com/weizhongli/cdhit) ) 
5. Gene Prediction & Functional Annotation ( [`Prodigal`](https://github.com/hyattpd/Prodigal) [`bedtools2`](https://github.com/arq5x/bedtools2) [`DIAMOND`](https://github.com/bbuchfink/diamond) )
6. Viral Taxonomic Classify Assignment ( [`usearch`](https://drive5.com/usearch) [`Blast`](https://blast.ncbi.nlm.nih.gov/Blast.cgi) [`taxonkit`](https://github.com/shenwei356/taxonkit) [`CoverM`](https://github.com/wwood/CoverM) )


## Getting Start

### Pre-requisites

To ensure the smoothest possible analysis using ViromeFlowX, we recommend taking the time to pre-build both the software components and the reference databases before you begin your analysis. This preparatory step will help guarantee a more efficient and hassle-free experience.

- **Environment Setup**: Most of the tools required by the pipeline can be conveniently installed using a Conda environment. Use the command below to create a new Conda environment based on the [environment.yml](environment.yml) configuration file.

   ```bash
   conda env create -f environment.yml
   ```
   > Notes: The [`usearch`](http://www.drive5.com/usearch/) tool is not supported for installation through conda. You need to manually download and install it. Please refer to the official [`documentation`](http://www.drive5.com/usearch/manual/install.html) for installation instructions.

- **Database Setup**: Refer to the [`Database Installation and Configuration`](docs/database.md) for downloading and configuring required databases.


### Install and Usage

1. Clone the repository
   ```
   git clone https://github.com/01life/ViromeFlowX
   ```

2. Prepare a samplesheet `samplesheet.csv` with your input data that looks as follows
   ```csv
   id,reads1,read2
   sample_2,/PATH/sample_L002_R1.fastq.gz,/PATH/sample_L002_R2.fastq.gz
   sample_3,/PATH/sample_L003_R1.fastq.gz,/PATH/sample_L003_R2.fastq.gz
   ```

3. Start running the pipeline
   ```
   nextflow run ViromeFlowX \
      -profile <docker/singularity/conda/.../institute> \
      --input samplesheet.csv \
      --outdir <OUTDIR>
   ```

   > If you are new to Nextflow and nf-core, check the [Nextflow installation guide](https://nf-co.re/docs/usage/installation). Ensure your setup passes the `-profile test` before processing real data.

4. Advance usage

   The pipeline will run QC -> Metaspades(min_len=1k) -> Identify(VirFinder、VirSorter2、CheckV) -> Taxonomic Classify(Kraken2) -> Geneset -> Taxonomic Classify Assignment (demovir、pfam、protein、crAss、genome) -> Abundance. You can also use `--help` to see the parameters. For comprehensive tutorials and implementation guidelines, please refer to our [Usage Documentation](docs/usage.md).

   ```bash
   nextflow run /path/to/project/ViromeFlowX --help
   ```

5. Output information

   To better understand the output files generated by ViromeFlowX and how to interpret them, refer to the [Output Documentation](docs/output.md).

## Citation

If you found ViromeFlowX usefull in your research, please cite the publication: [ViromeFlowX: a Comprehensive Nextflow-based Automated Workflow for Mining Viral Genomes from Metagenomic Sequencing Data.](https://www.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.001202)

> Wang X, Ding Z, Yang Y, et al. ViromeFlowX: a Comprehensive Nextflow-based Automated Workflow for Mining Viral Genomes from Metagenomic Sequencing Data[J]. Microbial Genomics, 2024, 10(2): 001202.

