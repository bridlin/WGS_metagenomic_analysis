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

echo $run\_fastq/kraken2-results_$run\_5prime-trimmed/PlusPF/

argument1=$run\_fastq/kraken2-results_$run\_5prime-trimmed/PlusPF/
argument2=$run\_fastq/kraken2-results_$run\_5prime-trimmed/EuPathDB48/

echo $argument1
echo $argument2

python3 WGS_metagenomic_analysis/auto_read-Extraction.py $argument1

python3 WGS_metagenomic_analysis/auto_read-Extraction.py $argument2