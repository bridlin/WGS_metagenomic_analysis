#!/bin/bash
#
#SBATCH -o slurm.%N.%j.out
#SBATCH -e slurm.%N.%j.err
#SBATCH --mail-type END
#SBATCH --mail-user b-barckmann@chu-montpellier.fr
#
#
#SBATCH --partition fast
#SBATCH --cpus-per-task 6
#SBATCH --mem 64GB

module load python/3.9
module load blast/2.14.0



source WGS_metagenomic_analysis/config.txt

# kraken_plus=kraken2-results_$run\_5prime-trimmed/PlusPF/
# kraken_eu=kraken2-results_$run\_5prime-trimmed/EuPathDB48/
# fastq=$run\_fastq
# eu_blast_result=kraken2-results_$run\_5prime-trimmed/EuPathDB48/blast_result
# plus_blast_result=kraken2-results_$run\_5prime-trimmed/PlusPF/blast_result

kraken_plus=kraken2-results_$run\_5prime-trimmed_dedup/PlusPF/
kraken_eu=kraken2-results_$run\_5prime-trimmed_dedup/EuPathDB48/
fastq=$run\_fastq
#eu_blast_result=kraken2-results_$run\_5prime-trimmed_dedup/EuPathDB48/blast_result
#plus_blast_result=kraken2-results_$run\_5prime-trimmed_dedup/PlusPF/blast_result

### run python script to extract 10 reads per genus from the kraken2 results

#python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq $kraken_plus

python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq $kraken_eu


### run blast on the extracted reads

cd auto_blast_folder/

mkdir ../$kraken_eu\blast_result
for files in ../$kraken_eu\*.1.fa ; do \
    file=$( echo $files | cut -d / -f 4) && \
    echo $files && \
    echo $file  && \
    echo $file\_blast && \
    blastn \
        -db nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote &&\
mv $file\_blast ../$kraken_eu\blast_result ; done


# mkdir ../$kraken_plus\blast_result
# for files in .../$kraken_plus\*.1.fa ; do \
#     file=$( echo $files | cut -d / -f 4) && \
#     echo $files && \
#     echo $file  && \
#     echo $file\_blast && \
#     blastn \
#         -db nt \
#         -query $files \
#         -out $file\_blast  \
#         -max_target_seqs 5 \
#         -max_hsps 5   \
#         -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
#         -remote && \
# mv $file\_blast ../$kraken_plus\blast_result ; done

cd ..

### run python script to compare the results of the blast with the kraken2 results

python3 WGS_metagenomic_analysis/compare_results.py  $kraken_eu

#python3 WGS_metagenomic_analysis/compare_results.py  $kraken_plus