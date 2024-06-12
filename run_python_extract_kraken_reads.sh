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

echo kraken2-results_$run\_5prime-trimmed/PlusPF/

kraken_plus=kraken2-results_$run\_5prime-trimmed/PlusPF/
kraken_eu=kraken2-results_$run\_5prime-trimmed/EuPathDB48/
fastq=fastq_$run


echo $kraken_plus
echo $kraken_eu

python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq $kraken_plus

python3 WGS_metagenomic_analysis/auto_read-Extraction.py $fastq $kraken_eu