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

kraken_plus=$output_dir/$kraken_output_dir\/
kraken_eu=$output_dir/$kraken_output_dir_2\/

echo $kraken_eu
echo $kraken_plus

python3 WGS_metagenomic_analysis/compare_results.py  $kraken_eu

python3 WGS_metagenomic_analysis/compare_results.py  $kraken_plus