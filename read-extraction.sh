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

source WGS_metagenomic_analysis/config.yml
source WGS_metagenomic_analysis/config_readextraction.txt

for sample in "${input_list[@]}"; do for id in "${$sample\[@]}"; do 
python KrakenTools-master/extract_kraken_reads.py -k $output_dir/$kraken_output_dir/$sample\.kraken2 --include-children -s $read_directory/$sample\nonhuman_reads.1.fastq -s2 $read_directory/$sample\nonhuman_reads.2.fastq -t $id\  -r $output_dir/$kraken_output_dir/$sample\.k2report -o $sample\.tid$id\.1.fa  -o2 $sample\.tid$id\.2.fa  ; done ; done


