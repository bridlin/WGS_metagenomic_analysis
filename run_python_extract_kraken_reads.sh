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

module load python/3.12

source WGS_metagenomic_analysis/config.txt



echo "run= $run"
echo "input_list= ${input_list[@]}"
echo "kraken2_E= $kraken2_E"    
echo "kraken2_P= $kraken2_P"
echo "read1_postfix= $read1_postfix"
echo "read2_postfix= $read2_postfix"

fastq_directory=$run\_fastq
output_dir=kraken2-results_$run\_5prime-trimmed
output_dir_E=$output_dir/$kraken2_E
output_dir_P=$output_dir/$kraken2_P


### run the python script to extract 10 reads per genus from the kraken2 results 1. arguments are the fastq directory and the kraken2 results directory
echo "run the python script to extract 10 reads per genus from the kraken2 results" 

python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq_directory $output_dir_P\/

python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq_directory $output_dir_E\/