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

eu_blast_result=kraken2-results_$run\_5prime-trimmed/EuPathDB48/blast_result
plus_blast_result=kraken2-results_$run\_5prime-trimmed/PlusPF/blast_result

echo $eu_blast_result
echo $plus_blast_result

python3 WGS_metagenomic_analysis/compare_results.py  $eu_blast_result

python3 WGS_metagenomic_analysis/compare_results.py  $plus_blast_result