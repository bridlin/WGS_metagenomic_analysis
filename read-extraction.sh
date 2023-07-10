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

source WGS_metagenomic_analysis/config_readextraction

for x in "${input_list[@]}"; do for id in "${id_list[@]}"; do 
python KrakenTools-master/extract_kraken_reads.py -k $kraken_results/$x\.kraken2 --include-children -s $read_directory/$x\nonhuman_reads.1.fastq -s2 $read_directory/$x\nonhuman_reads.2.fastq -t $id\  -r $kraken_results/$x\.k2report -o $x\.tid$id\.1.fa  -o2 $x\.tid$id\.2.fa  ; done ; done
