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



module load bowtie2/2.4.1
module load cutadapt/4.0
module load kraken2/2.1.2


source WGS_metagenomic_analysis/config.yml

for sample in "${input_list[@]}"; do
bowtie2 \
    -x genome/Phix/NC_001422.1_Escherichia_phage_phiX1 \
    -1 $fastq_directory/$sample\nonhuman_reads.1.fastq -2 $fastq_directory/$sample\nonhuman_reads.2.fastq  \
    --un-conc $fastq_directory/$sample\nonhuman_nonPhix_reads.fastq \
    -S $fastq_directory/$sample\aln-pe_Phix.sam \
    2> $output_dir/$sample\_phix_bowtie.log 
cutadapt  \
    -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -G AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -o $fastq_directory/$sample\nonhuman_nonPhix_reads_5trimmed.1.fastq  \
    -p $fastq_directory/$sample\nonhuman_nonPhix_reads_5trimmed.2.fastq  \
    $fastq_directory/$sample\nonhuman_nonPhix_reads.1.fastq  $fastq_directory/$sample\nonhuman_nonPhix_reads.2.fastq \
    --minimum-length 60 \
    > $output_dir/$sample\nonhuman_nonPhix_reads_cutadapt_report.txt &&
kraken2 \
    --db $kraken2_db \
    --threads 8 \
    --minimum-hit-groups 3  \
    --report-minimizer-data \
    --report $output_dir/$kraken_output_dir/$sample$kraken_output_dir\_nonPhix.k2report  \
    --paired $fastq_directory/$sample\nonhuman_nonPhix_reads_5trimmed.1.fastq $fastq_directory/$sample\nonhuman_nonPhix_reads_5trimmed.2.fastq \
    > $output_dir/$kraken_output_dir/$sample$kraken_output_dir\_nonPhix.kraken2 &&
kraken2 \
    --db $kraken2_db_2 \
    --threads 8 \
    --minimum-hit-groups 3  \
    --report-minimizer-data \
    --report $output_dir/$kraken_output_dir_2/$sample$kraken_output_dir_2\_nonPhix.k2report  \
    --paired $fastq_directory/$sample\nonhuman_nonPhix_reads_5trimmed.1.fastq $fastq_directory/$sample\nonhuman_nonPhix_reads_5trimmed.2.fastq \
    > $output_dir/$kraken_output_dir_2/$sample$kraken_output_dir_2\_nonPhix.kraken2 ; done