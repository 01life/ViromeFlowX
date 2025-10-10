# ViromeFlowX: Usage

## Introduction

ViromeFlowX is a user-friendly Nextflow workflow that automates viral genome assembly, identification, classification, and annotation. This streamlined workflow integrates cutting-edge tools for processing raw sequencing data for taxonomic annotation and functional analysis. ViromeFlowX enables efficient mining of viral genomic data, offering a valuable resource to investigate the gut virome's role in virus-host interactions and virus-related diseases.

## Samplesheet input

You will need to create a samplesheet with information about the samples you would like to analyse before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 or 4 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

The CSV file can support the following column names:
| Column    | Description                                                                                                                                                                            |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`  | Custom sample name. This entry will be identical for multiple sequencing libraries/runs from the same sample. |
| `reads1` | Full path to raw or clean reads 1. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |
| `reads2` | Full path to raw or clean reads 2. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".   
| `contig` | Full path to assembly contigs. File has to have the extension ".fa" or ".fasta".



## Run the whole pipeline with default parameters

If you want to run the whole pipeline with default parameters, there is a strict requirement for the first 3 columns to match those defined in the table below. An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline. The reads1 and reads2 columns in the samplesheet.csv file are used to specify the paths to the corresponding raw sequence files.

```console
id,reads1,read2
sample_2,/PATH/sample_L002_R1.fastq.gz,/PATH/sample_L002_R2.fastq.gz
sample_3,/PATH/sample_L003_R1.fastq.gz,/PATH/sample_L003_R2.fastq.gz
```

```bash
nextflow run ViromeFlowX --input samplesheet.csv --outdir <OUTDIR> -profile slurm
```

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

## Run with special parameters

### 1. skip QC step

If you want to skip QC analysis, run the pipeline with `--skip_qc`. The input samplesheet.csv must include the columns id, reads1, and reads2, which indicate the sample identifiers and the full paths to the cleaned sequence files.

```bash
nextflow run ViromeFlowX --input samplesheet.csv --outdir <OUTDIR> -profile slurm --skip_qc
```


### 2. skip Assembly step

If you want to skip Assembly analysis, run the pipeline with `--skip_assembly`. The input samplesheet.csv must include the following columns: id, reads1, reads2, and contig. The reads1 and reads2 fields indicate the paths to the cleaned sequence files, whereas the contig field contains the full path to the sample's assembled contigs.

```bash
nextflow run ViromeFlowX --input samplesheet.csv --outdir <OUTDIR> -profile slurm --skip_assembly
```


### 3. skip Kraken2 step

If you want to skip Kraken2 analysis, run the pipeline with `--skip_kraken2`. In this case, the input samplesheet.csv should contain three columns: id, reads1, and reads2. These columns are used to provide the sample IDs and the file locations of the raw sequence data.

```bash
nextflow run ViromeFlowX --input samplesheet.csv --outdir <OUTDIR> -profile slurm --skip_kraken2
```


### 4. only run Identify step

If you only want to run the virus identification anlysis of the pipeline, use the `--only_identify` parameter. The input samplesheet.csv must then contain two columns: id for sample names and contig for the full paths to the assembled contig files.

```
nextflow run ViromeFlowX --input samplesheet.csv --outdir <OUTDIR> -profile slurm --only_identify
```