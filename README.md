# WGS_metagenomic_analysis
analysing WGS metagenomic data

This repository contains scripts and files used to analyze shotgun metagenomic sequencing reads to detect pathogens in human samples

The scripts are made to run on a HPC under slurm (Roscoff Bioinformatics platform ABiMS (http://abims.sb-roscoff.fr)).

The  run_whole_analysis.sh will run the complete pipeline.



## The first script qc_mqpping.sh uses raw paired-end stranded sequencing reads from SNS-seq experiments and performs quality check, adapter and quality trimming and read mapping.
- quality control of the provided fastq files (fastqc 0.11.9)
- trimming of tail and adapter sequences (cutadapt 4.0)
- quality trimming with q20 threshold (trimmomatic 0.39)
- alignment against provided indexed human genome to sepetate non-human reads (bowtie2 2.4.1)
- 

## Parameters

### Parameters for the analysis need to be provided in the config.txt file, that has to be in the same working directory as the script :


