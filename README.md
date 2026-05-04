# WGS_metagenomic_analysis
analysing WGS metagenomic data

This repository contains scripts and files used to analyze shotgun metagenomic sequencing reads to detect pathogens in human samples

The scripts are made to run on a HPC under slurm (Roscoff Bioinformatics platform ABiMS (http://abims.sb-roscoff.fr)).

The script run_complete_analysis.sh will run the complete pipeline.

## outline of the whole analysis
- quality control of the provided fastq files (fastqc 0.11.9)
- trimming of tail and adapter sequences (cutadapt 4.0)
- quality trimming with q20 threshold (trimmomatic 0.39)
- alignment against provided indexed human genome to sepetate non-human reads (bowtie2 2.4.1)
- analysing insert size with Picard
- taxonomic classification of non-human reads using kraken2
- extracting all genus-level classifications from kraken2 report
- extractin 10 reads per genus level classification for secondary validation with blast
- chunking of the extracted reads in 100 read chunks for faster blasting
- chunk remote blasting agains nt NCBI database with output format 6
- parsing of blast results and automatic comparison with kraken2 results
- generation of table with validated results
  

## Parameters

### Parameters for the analysis need to be provided in the config.txt file, that has to be in the same working directory as the script :

run=                       # the name of the run
input_list=                # the sample names as list

read1_postfix="_R1"        # the postfix of the read names, the part between sample name and file extention
read2_postfix="_R2"

kraken2_E=EuPathDB48       # name of Kraken DB 1
kraken2_P=PlusPF           # name of Kraken DB 2
