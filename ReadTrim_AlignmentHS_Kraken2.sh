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


module load cutadapt/4.5
module load trimmomatic/0.39
module load fastqc/0.12.1
module load bowtie2/2.5.4
module load samtools/1.21
module load kraken2/2.14
module load multiqc/1.29
module load picard/2.23.5


source WGS_metagenomic_analysis/config.txt

echo "run complete analysis"
echo "run= $run"
echo "input_list= ${input_list[@]}"
echo "kraken2_E= $kraken2_E"    
echo "kraken2_P= $kraken2_P"
echo "read1_postfix= $read1_postfix"
echo "read2_postfix= $read2_postfix"



kraken2_db_E=Kraken2_db/$kraken2_E
kraken2_db_P=Kraken2_db/$kraken2_P


fastq_directory=$run\_fastq
output_dir=kraken2-results_$run\_5prime-trimmed
# output_dir=kraken2-results_$run\_5prime-trimmed_clumped
# output_dir=kraken2-results_$run\_5prime-trimmed_chunked
output_dir_E=$output_dir/$kraken2_E
output_dir_P=$output_dir/$kraken2_P


mkdir $output_dir 
mkdir $output_dir_E
mkdir $output_dir_P



### run fastqc, cutadapt and trimmomatic on the raw reads
echo "run fastqc, cutadapt and trimmomatic on the raw reads"

for sample in "${input_list[@]}"; do
fastqc \
    $fastq_directory/$sample$read1_postfix.fastq.gz \
    --outdir $output_dir &&
fastqc \
    $fastq_directory/$sample$read2_postfix.fastq.gz \
    --outdir $output_dir &&
cutadapt  \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  \
    -o $fastq_directory/$sample$read1_postfix\_3trimmed.fastq.gz \
    -p $fastq_directory/$sample$read2_postfix\_3trimmed.fastq.gz  \
    $fastq_directory/$sample$read1_postfix.fastq.gz  $fastq_directory/$sample$read2_postfix.fastq.gz \
    --minimum-length 40 \
    > $output_dir/$sample\_all_cutadapt_report.txt &&
trimmomatic \
    PE \
    -threads 4 \
    -trimlog $output_dir/$sample\trim \
    $fastq_directory/$sample$read1_postfix\_3trimmed.fastq.gz $fastq_directory/$sample$read2_postfix\_3trimmed.fastq.gz \
    $fastq_directory/$sample$read1_postfix\_3trimmed_q20.fastq.gz   $fastq_directory/$sample$read1_postfix\_3trimmed_q20_un.fastq.gz $fastq_directory/$sample$read2_postfix\_3trimmed_q20.fastq.gz  $fastq_directory/$sample$read2_postfix\_3trimmed_q20_un.fastq.gz \
    SLIDINGWINDOW:4:20 \
    MINLEN:40 &&
clumpify.sh \
    in1=$fastq_directory/$sample$read1_postfix\_3trimmed_q20.fastq.gz \
    in2=$fastq_directory/$sample$read2_postfix\_3trimmed_q20.fastq.gz \
    out1=$fastq_directory/$sample$read1_postfix\_3trimmed_q20_clumped.fastq.gz \
    out2=$fastq_directory/$sample$read2_postfix\_3trimmed_q20_clumped.fastq.gz \
    dedupe=t \
    optical=f &&
fastqc \
    $fastq_directory/$sample$read1_postfix\_3trimmed_q20_clumped.fastq.gz \
    --outdir $output_dir &&
fastqc \
    $fastq_directory/$sample$read2_postfix\_3trimmed_q20_clumped.fastq.gz \
    --outdir $output_dir &&
bowtie2 \
    -x ../../bank/bowtie2/Homo_sapiens.GRCh38.dna.toplevel \
    -1 $fastq_directory/$sample$read1_postfix\_3trimmed_q20_clumped.fastq.gz -2 $fastq_directory/$sample$read2_postfix\_3trimmed_q20_clumped.fastq.gz  \
    --un-conc $fastq_directory/$sample\nonhuman_reads.fastq \
    -S $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam \
    2> $output_dir/$sample\_bowtie.log &&
samtools \
    view -S \
    -b $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam  \
    > $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
samtools \
    sort $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam  \
    -o $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
samtools \
    index $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
samtools \
    reheader -c 'grep -v ^@PG' $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam  \
    > $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam &&
picard \
    CollectInsertSizeMetrics   \
    -I $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam  \
    -O $output_dir/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_metrics.txt  \
    -H $output_dir/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_histogram.pdf  \
    -M 0.5  &&
rm -f  $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam &&
rm -f  $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam &&
rm -f  $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
cutadapt  \
    -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -G AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -o $fastq_directory/$sample\nonhuman_reads_5trimmed.1.fastq  \
    -p $fastq_directory/$sample\nonhuman_reads_5trimmed.2.fastq  \
    $fastq_directory/$sample\nonhuman_reads.1.fastq  $fastq_directory/$sample\nonhuman_reads.2.fastq \
    --minimum-length 40 \
    > $output_dir/$sample\nonhuman_reads_cutadapt_report.txt &&
kraken2 \
    --db $kraken2_db_E \
    --threads 8 \
    --minimum-hit-groups 3  \
    --report-minimizer-data \
    --report $output_dir_E/$sample$kraken2_E\.k2report  \
    --paired $fastq_directory/$sample\nonhuman_reads_5trimmed.1.fastq $fastq_directory/$sample\nonhuman_reads_5trimmed.2.fastq \
    > $output_dir_E/$sample$kraken2_E\.kraken2 &&
kraken2 \
    --db $kraken2_db_P \
    --threads 8 \
    --minimum-hit-groups 3  \
    --report-minimizer-data \
    --report $output_dir_P/$sample$kraken2_P\.k2report  \
    --paired $fastq_directory/$sample\nonhuman_reads_5trimmed.1.fastq $fastq_directory/$sample\nonhuman_reads_5trimmed.2.fastq \
    > $output_dir_P/$sample$kraken2_P\.kraken2 ; done

multiqc   \
    $output_dir \
    $output_dir_E \
    $output_dir_P \
    --outdir $output_dir 