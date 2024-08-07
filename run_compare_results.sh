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

eu_result=kraken2-results_$run\_5prime-trimmed/EuPathDB48
plus_result=kraken2-results_$run\_5prime-trimmed/PlusPF

echo $eu_result
#echo $plus_result

python3 WGS_metagenomic_analysis/compare_results.py  $eu_result

#python3 WGS_metagenomic_analysis/compare_results.py  $plus_result