#!/bin/bash
#
#SBATCH -o slurm.%N.%j.out
#SBATCH -e slurm.%N.%j.err
#SBATCH --mail-type END
#SBATCH --mail-user b-barckmann@chu-montpellier.fr
#
#
#SBATCH --partition fast
#SBATCH --cpus-per-task 4
#SBATCH --mem  128GB


module load cutadapt/4.0
module load trimmomatic/0.39
module load fastqc/0.11.9
module load  bowtie2/2.4.1
module load  samtools/1.13
module load  kraken2/2.1.2


source WGS_metagenomic_analysis/config.yml

mkdir $output_dir
mkdir $kraken_output_dir
mkdir $kraken_output_dir_2
for x in "${input_list[@]}"; do
fastqc $directory/$x\L001_R1_001.fastq.gz --outdir $output_dir &&
fastqc $directory/$x\L001_R2_001.fastq.gz --outdir $output_dir &&
cutadapt  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  -o $directory/$x\L001_R1_001_3trimmed.fastq.gz -p $directory/$x\L001_R2_001_3trimmed.fastq.gz  $directory/$x\L001_R1_001.fastq.gz  $directory/$x\L001_R2_001.fastq.gz --minimum-length 40 > $directory/$x\report.txt &&
trimmomatic PE -threads 4 -trimlog $directory/$x\trim $directory/$x\L001_R1_001_3trimmed.fastq.gz $directory/$x\L001_R2_001_3trimmed.fastq.gz $directory/$x\L001_R1_001_3trimmed_q20.fastq.gz   $directory/$x\L001_R1_001_3trimmed_q20_un.fastq.gz $directory/$x\L001_R2_001_3trimmed_q20.fastq.gz  $directory/$x\L001_R2_001_3trimmed_q20_un.fastq.gz SLIDINGWINDOW:4:20 MINLEN:40 &&
fastqc $directory/$x\L001_R1_001_3trimmed_q20.fastq.gz &&
fastqc $directory/$x\L001_R2_001_3trimmed_q20.fastq.gz &&
bowtie2 -x ../../bank/bowtie2/Homo_sapiens.GRCh38.dna.toplevel -1 $directory/$x\L001_R1_001_3trimmed_q20.fastq.gz -2 $directory/$x\L001_R2_001_3trimmed_q20.fastq.gz  --un-conc $directory/$x\nonhuman_reads.fastq -S $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam 2> $directory/$x\.log &&
samtools view -S -b $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam > $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
samtools sort $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam -o $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
samtools index $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
rm -f  $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam &&
rm -f  $directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
kraken2 --db $kraken2_db --threads 8 --minimum-hit-groups 3  --report-minimizer-data --report $kraken_output_dir/$x\.k2report  --paired $directory/$x\nonhuman_reads.1.fastq $directory/$x\nonhuman_reads.2.fastq > $kraken_output_dir/$x\.kraken2 &&
kraken2 --db $kraken2_db_2 --threads 8 --minimum-hit-groups 3  --report-minimizer-data --report $kraken_output_dir_2/$x\.k2report  --paired $directory/$x\nonhuman_reads.1.fastq $directory/$x\nonhuman_reads.2.fastq > $kraken_output_dir_2/$x\.kraken2; done
