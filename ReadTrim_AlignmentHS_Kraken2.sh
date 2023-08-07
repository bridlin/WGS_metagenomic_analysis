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

mkdir $output_dir
mkdir $output_dir/$kraken_output_dir
mkdir $output_dir/$kraken_output_dir_2
for x in "${input_list[@]}"; do
fastqc $fastq_directory/$x\L001_R1_001.fastq.gz --outdir $output_dir &&
fastqc $fastq_directory/$x\L001_R2_001.fastq.gz --outdir $output_dir &&
cutadapt  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  -o $fastq_directory/$x\L001_R1_001_3trimmed.fastq.gz -p $fastq_directory/$x\L001_R2_001_3trimmed.fastq.gz  $fastq_directory/$x\L001_R1_001.fastq.gz  $fastq_directory/$x\L001_R2_001.fastq.gz --minimum-length 40 > $fastq_directory/$x\report.txt &&
trimmomatic PE -threads 4 -trimlog $fastq_directory/$x\trim $fastq_directory/$x\L001_R1_001_3trimmed.fastq.gz $fastq_directory/$x\L001_R2_001_3trimmed.fastq.gz $fastq_directory/$x\L001_R1_001_3trimmed_q20.fastq.gz   $fastq_directory/$x\L001_R1_001_3trimmed_q20_un.fastq.gz $fastq_directory/$x\L001_R2_001_3trimmed_q20.fastq.gz  $fastq_directory/$x\L001_R2_001_3trimmed_q20_un.fastq.gz SLIDINGWINDOW:4:20 MINLEN:40 &&
fastqc $fastq_directory/$x\L001_R1_001_3trimmed_q20.fastq.gz --outdir $output_dir &&
fastqc $fastq_directory/$x\L001_R2_001_3trimmed_q20.fastq.gz --outdir $output_dir &&
bowtie2 -x ../../bank/bowtie2/Homo_sapiens.GRCh38.dna.toplevel -1 $fastq_directory/$x\L001_R1_001_3trimmed_q20.fastq.gz -2 $fastq_directory/$x\L001_R2_001_3trimmed_q20.fastq.gz  --un-conc $fastq_directory/$x\nonhuman_reads.fastq -S $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam 2> $fastq_directory/$x\.log &&
samtools view -S -b $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam > $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
samtools sort $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam -o $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
samtools index $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
samtools reheader -c 'grep -v ^@PG' $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam  > $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam &&
picard CollectInsertSizeMetrics   -I $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam  -O $output_dir/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_metrics.txt  -H $output_dir/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_histogram.pdf  -M 0.5  &&
rm -f  $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam &&
rm -f  $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam &&
rm -f  $fastq_directory/$x\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
kraken2 --db $kraken2_db --threads 8 --minimum-hit-groups 3  --report-minimizer-data --report $output_dir/$kraken_output_dir/$x\.k2report  --paired $fastq_directory/$x\nonhuman_reads.1.fastq $fastq_directory/$x\nonhuman_reads.2.fastq > $output_dir/$kraken_output_dir/$x\.kraken2 &&
kraken2 --db $kraken2_db_2 --threads 8 --minimum-hit-groups 3  --report-minimizer-data --report $output_dir/$kraken_output_dir_2/$x\.k2report  --paired $fastq_directory/$x\nonhuman_reads.1.fastq $fastq_directory/$x\nonhuman_reads.2.fastq > $output_dir/$kraken_output_dir_2/$x\.kraken2; done

multiqc $fastq_directory $output_dir $output_dir/$kraken_output_dir $output_dir/$kraken_output_dir_2