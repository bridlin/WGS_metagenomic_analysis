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

id_list=( \
"5052" \
"5500" \
"5036" \
"5480" \
"5305" \
"5658" \
"5691" \
"1463229" \
"237895" \
"5754"  )
input_list=("MC1-2_S2_")
kraken_results=kraken2-results_run8
read_directory=fastq_run8

for x in "${input_list[@]}"; do for id in "${id_list[@]}"; do 
python KrakenTools-master/extract_kraken_reads.py -k $kraken_results/$x\.kraken2 --include-children -s $read_directory/$x\L001_R1_001_3trimmed_q20.fastq.gz -s2 $read_directory/$x\L001_R2_001_3trimmed_q20.fastq.gz -t $id\  -r $kraken_results/$x\.k2report -o $x\.tid$id\.1.fa  -o2 $x\.tid$id\.2.fa  ; done ; done