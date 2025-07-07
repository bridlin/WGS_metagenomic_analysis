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

source WGS_metagenomic_analysis/config.txt

echo "run compare results"
echo "run= $run"
echo "input_list= ${input_list[@]}"
echo "kraken2_E= $kraken2_E"    
echo "kraken2_P= $kraken2_P"

kraken2_db_E=Kraken2_db/$kraken2_E
kraken2_db_P=Kraken2_db/$kraken2_P


fastq_directory=$run\_fastq
output_dir=kraken2-results_$run\_5prime-trimmed
output_dir_E=$output_dir/$kraken2_E
output_dir_P=$output_dir/$kraken2_P
 echo "output_dir_E is " $output_dir_E
 echo "output_dir_P is " $output_dir_P





python3 WGS_metagenomic_analysis/compare_results.py  $output_dir_E\/

# python3 WGS_metagenomic_analysis/compare_results.py  $output_dir_P\/