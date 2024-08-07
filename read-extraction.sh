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

for sample in "${input_list[@]}"; do for id in "${id_list[@]}"; do 
python KrakenTools-master/extract_kraken_reads.py -k $output_dir/$db/$sample$db\.kraken2 --include-children -s $read_directory/$sample\nonhuman_reads_5trimmed_dedup.1.fastq -s2 $read_directory/$sample\nonhuman_reads_5trimmed_dedup.2.fastq -t $id\  -r $output_dir/$db/$sample$db\.k2report -o $sample\.tid$id\_all.1.fa  -o2 $sample\.tid$id\_all.2.fa  ; done ; done


