# ViromeFlowX: Database

## Introduction

This document describes how to download the required databases for the pipeline.
<!-- TODO nf-core: Write this documentation describing your workflow's databses -->

### host_db

```bash
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
mkdir -p hg38_2bwt_index
gunzip -c hg38.fa.gz > hg38_2bwt_index/hg38.fa

cd hg38_2bwt_index
2bwt-builder hg38.fa
rm -f hg38.fa
cd -

mkdir -p hg38_bowtie2_index
bowtie2-build \
	--verbose \
	--threads 4 \
	hg38.fa.gz \
  hg38_bowtie2_index/hg38.index
```

### virsorter2_db

```bash
wget https://osf.io/v46sc/download -O db.tgz
tar xzvf db.tgz
chmod -R 755 db
```

### checkv_db

```bash
wget https://portal.nersc.gov/CheckV/checkv-db-v1.0.tar.gz
tar -zxvf checkv-db-archived-version.tar.gz 
cd /path/to/checkv-db/genome_db 
diamond makedb --in checkv_reps.faa --db checkv_reps
```

### kraken2_db

```bash
kraken2-build --download-taxonomy --db ./ViralDB
kraken2-build --download-library viral --db ./ViralDB
kraken2-build --build --db ./ViralDB
bracken-build -d ./ViralDB -t 16 -k 35 -l 150
```

### crAss_db

```bash
mkdir -p crAss-like p-crAssphage
#https://www.ncbi.nlm.nih.gov/nuccore/NC_024711.1?report=fasta&format=text
#https://www.ncbi.nlm.nih.gov/protein/YP_009052497.1?report=fasta&format=text
#https://www.ncbi.nlm.nih.gov/protein/YP_009052554.1?report=fasta&format=text
parallel --xapply makeblastdb -dbtype {2} -in {1}.fa -parse_seqids -out {1}/{1} ::: p-crAssphage crAss-like ::: nucl prot
```

### genome_db & protein_db

```bash
https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/
```

### CAZy eggnog go ko level4ev pfam

```bash
http://huttenhower.sph.harvard.edu/humann2_data/full_mapping_v201901.tar.gz
```

### genome_data

```bash
https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/
```

### pfam_data

```bash
https://www.ebi.ac.uk/interpro/download/Pfam/
```

### uniref90_data

```bash
wget http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/uniref90_annotated_v201901.tar.gz
mkdir -p uniprot/uniref_annotated/uniref90 && tar xzvf uniref90_annotated_v201901.tar.gz -C uniprot/uniref_annotated/uniref90
```

### demovir_taxa

```bash
wget https://github.com/feargalr/Demovir/blob/master/TrEMBL_viral_taxa.RDS
```

### pfam_db

The pfam database, referenced in the [`article`](https://doi.org/10.1016/j.chom.2020.06.005), classifies viruses into Caudovirales, Myoviridae, or Microviridae. As the database is no longer updated and relies on the mentioned article, it has been uploaded to GitHub for easy access and download.

```bash
wget https://github.com/01life/flowDB/blob/main/virome/virus.pfam](https://github.com/01life/FlowDB/blob/main/ViromeFlowX/virus.pfam
```

### demovir_db

```bash
wget https://s3-eu-west-1.amazonaws.com/pfigshare-u-files/10442241/nr.95.fasta.bz2
bunzip2 nr.95.fasta.bz2
usearch -makeudb_ublast nr.95.fasta -output uniprot_trembl.viral.udb &> usearch_database.log
```
