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
module load python/3.9
module load blast/2.14.0

source WGS_metagenomic_analysis/config.txt

echo "run complete analysis"
echo "run= $run"
echo "input_list= ${input_list[@]}"
echo "kraken2_E= $kraken2_E"    
echo "kraken2_P= $kraken2_P"

kraken2_db_E=Kraken2_db/$kraken2_E
kraken2_db_P=Kraken2_db/$kraken2_P


fastq_directory=$run\_fastq
output_dir=kraken2-results_$run\_5prime-trimmed_chunked
output_dir_E=$output_dir/$kraken2_E
output_dir_P=$output_dir/$kraken2_P


mkdir $output_dir
mkdir $output_dir_E
mkdir $output_dir_P



# ### run fastqc, cutadapt and trimmomatic on the raw reads
# echo "run fastqc, cutadapt and trimmomatic on the raw reads"

# for sample in "${input_list[@]}"; do
# fastqc \
#     $fastq_directory/$sample\L001_R1_001.fastq.gz \
#     --outdir $output_dir &&
# fastqc \
#     $fastq_directory/$sample\L001_R2_001.fastq.gz \
#     --outdir $output_dir &&
# cutadapt  \
#     -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  \
#     -o $fastq_directory/$sample\L001_R1_001_3trimmed.fastq.gz \
#     -p $fastq_directory/$sample\L001_R2_001_3trimmed.fastq.gz  \
#     $fastq_directory/$sample\L001_R1_001.fastq.gz  $fastq_directory/$sample\L001_R2_001.fastq.gz \
#     --minimum-length 40 \
#     > $output_dir/$sample\_cutadapt_report.txt &&
# trimmomatic \
#     PE \
#     -threads 4 \
#     -trimlog $output_dir/$sample\trim \
#     $fastq_directory/$sample\L001_R1_001_3trimmed.fastq.gz $fastq_directory/$sample\L001_R2_001_3trimmed.fastq.gz \
#     $fastq_directory/$sample\L001_R1_001_3trimmed_q20.fastq.gz   $fastq_directory/$sample\L001_R1_001_3trimmed_q20_un.fastq.gz $fastq_directory/$sample\L001_R2_001_3trimmed_q20.fastq.gz  $fastq_directory/$sample\L001_R2_001_3trimmed_q20_un.fastq.gz \
#     SLIDINGWINDOW:4:20 \
#     MINLEN:40 &&
# fastqc \
#     $fastq_directory/$sample\L001_R1_001_3trimmed_q20.fastq.gz \
#     --outdir $output_dir &&
# fastqc \
#     $fastq_directory/$sample\L001_R2_001_3trimmed_q20.fastq.gz \
#     --outdir $output_dir &&
# bowtie2 \
#     -x ../../bank/bowtie2/Homo_sapiens.GRCh38.dna.toplevel \
#     -1 $fastq_directory/$sample\L001_R1_001_3trimmed_q20.fastq.gz -2 $fastq_directory/$sample\L001_R2_001_3trimmed_q20.fastq.gz  \
#     --un-conc $fastq_directory/$sample\nonhuman_reads.fastq \
#     -S $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam \
#     2> $output_dir/$sample\_bowtie.log &&
# samtools \
#     view -S \
#     -b $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam \   
#     > $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
# samtools \
#     sort $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam \   
#     -o $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
# samtools \
#     index $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam &&
# samtools \
#     reheader -c 'grep -v ^@PG' $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam  \
#     > $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam &&
# picard \
#     CollectInsertSizeMetrics   \
#     -I $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam  \
#     -O $output_dir/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_metrics.txt  \
#     -H $output_dir/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_histogram.pdf  \
#     -M 0.5  &&
# rm -f  $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam &&
# rm -f  $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam &&
# rm -f  $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam.bam &&
# cutadapt  \
#     -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -G AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
#     -o $fastq_directory/$sample\nonhuman_reads_5trimmed.1.fastq  \
#     -p $fastq_directory/$sample\nonhuman_reads_5trimmed.2.fastq  \
#     $fastq_directory/$sample\nonhuman_reads.1.fastq  $fastq_directory/$sample\nonhuman_reads.2.fastq \
#     --minimum-length 40 \
#     > $output_dir/$sample\nonhuman_reads_cutadapt_report.txt &&
# kraken2 \
#     --db $kraken2_db_E \
#     --threads 8 \
#     --minimum-hit-groups 3  \
#     --report-minimizer-data \
#     --report $output_dir_E/$sample$kraken2_E\.k2report  \
#     --paired $fastq_directory/$sample\nonhuman_reads_5trimmed.1.fastq $fastq_directory/$sample\nonhuman_reads_5trimmed.2.fastq \
#     > $output_dir_E/$sample$kraken2_E\.kraken2 &&
# kraken2 \
#     --db $kraken2_db_P \
#     --threads 8 \
#     --minimum-hit-groups 3  \
#     --report-minimizer-data \
#     --report $output_dir_P/$sample$kraken2_P\.k2report  \
#     --paired $fastq_directory/$sample\nonhuman_reads_5trimmed.1.fastq $fastq_directory/$sample\nonhuman_reads_5trimmed.2.fastq \
#     > $output_dir_P/$sample$kraken2_P\.kraken2 ; done

# multiqc   \
#     $output_dir \
#     $output_dir_E \
#     $output_dir_P \
#     --outdir $output_dir 


# ### run python script to extract 10 reads per genus from the kraken2 results
# echo "run python script to extract 10 reads per genus from the kraken2 results"

# mkdir $output_dir_P\/extracted_reads
# mkdir $output_dir_E\/extracted_reads

# ### run the python script to extract 10 reads per genus from the kraken2 results 1. arguments are the fastq directory and the kraken2 results directory
# echo "run the python script to extract 10 reads per genus from the kraken2 results" 

# python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq_directory $output_dir_P\/

# python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq_directory $output_dir_E\/

### batching  the reads for light blasting into 100 reads per fasta file
echo "batching  the reads for light blasting into 100 reads per fasta file"

python3 WGS_metagenomic_analysis/batch_extracted_reads.py $output_dir_E\

python3 WGS_metagenomic_analysis/batch_extracted_reads.py $output_dir_P\

### run blast on the extracted batched reads
echo "run blast on the extracted  batched reads"

cd auto_blast_folder/

mkdir ../$output_dir_E\/blast_result
mkdir ../$output_dir_P\/blast_result

for files in ../$output_dir_E\/blast_chunks/*.fasta ; do 
    file=$(basename "$files") 
    # echo $files && 
    if [ ! -f ../$output_dir_E\/blast_result/$file\_blast ]  
    then 
        echo $file\_blast  
        echo "blasting..." 
        blastn \
        -db nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 
    else 
        echo $file\_blast  
        echo "blast is already done"
    fi 
    if [  -f $file\_blast ] 
    then 
        mv $file\_blast ../$output_dir_E\/blast_result  
    fi 
done


for files in ../$output_dir_P\/blast_chunks/*.fasta ; do 
    file=$(basename "$files")  
    # echo $files && 
    if [ ! -f ../$output_dir_P\/blast_result/$file\_blast ]  
    then 
        echo $file\_blast 
        echo "blasting..." 
        blastn \
        -db nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 
    else 
        echo $file\_blast  
        echo "blast is already done"
    fi 
    if [  -f $file\_blast ]
    then 
        mv $file\_blast ../$output_dir_P\/blast_result
    fi 
done


cd ..

# dechunking the blast results
echo "dechunking the blast results"

python3 WGS_metagenomic_analysis/dechunk_blast_results.py  $output_dir_E\
 
python3 WGS_metagenomic_analysis/dechunk_blast_results.py  $output_dir_P\




### run python script to compare the results of the blast with the kraken2 results
echo "run python script to compare the results of the blast with the kraken2 results"


python3 WGS_metagenomic_analysis/compare_results.py  $output_dir_E\/

python3 WGS_metagenomic_analysis/compare_results.py  $output_dir_P\/