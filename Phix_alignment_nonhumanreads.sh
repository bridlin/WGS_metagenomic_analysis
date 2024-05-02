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
module load bowtie2/2.4.1
module load samtools/1.13
module load kraken2/2.1.2
module load multiqc/1.13
module load picard/2.23.5

source WGS_metagenomic_analysis/config.yml

for sample in "${input_list[@]}"; do
bowtie2 \
    -x genome/Phix/NC_001422.1_Escherichia_phage_phiX1 \
    -1 $fastq_directory/$sample\nonhuman_reads.1.fastq -2 $fastq_directory/$sample\nonhuman_reads.2.fastq  \
    --un-conc $fastq_directory/$sample\nonhuman_nonPhix_reads.fastq \
    -S $fastq_directory/$sample\aln-pe_Phix.sam \
    2> $output_dir/$sample\_phix_bowtie.log &&
