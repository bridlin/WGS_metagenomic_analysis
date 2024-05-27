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


python3 WGS_metagenomic_analysis/compare_results.py  '../../run22/EuPathDB/'

python3 WGS_metagenomic_analysis/compare_results.py  '../../run22/PlusPF/'