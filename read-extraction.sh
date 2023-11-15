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

id_list=("475")
input_list=("3737_S4_" "3735_S3_")
kraken_results=kraken2-results_run8/PlusPF
read_directory=run8_nonhuman-reads
output_dir=kraken2-results_run14_5prime-trimmed
db=PlusPF
#db_2=EuPathDB48





source WGS_metagenomic_analysis/config_readextraction

for sample in "${input_list[@]}"; do for id in "${$id_list[@]}"; do 
python KrakenTools-master/extract_kraken_reads.py -k $output_dir/$db/$sample\_$db.kraken2 --include-children -s $read_directory/$sample\nonhuman_reads_5trimmed.1.fastq -s2 $read_directory/$sample\nonhuman_reads_5trimmed.2.fastq -t $id\  -r $output_dir/$db/$sample\_$db.k2report -o $sample\.tid$id\.1.fa  -o2 $sample\.tid$id\.2.fa  ; done ; done


