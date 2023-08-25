#!/bin/bash
#
#SBATCH -o slurm.%N.%j.out
#SBATCH -e slurm.%N.%j.err
#SBATCH --mail-type END
#SBATCH --mail-user b-barckmann@chu-montpellier.fr
#
#
#SBATCH --partition fast
#SBATCH --cpus-per-task 4
#SBATCH --mem  128GB

module load blast/2.14.0

kraken_file_path= '../Kraken2_results_run9_5prime-trimmed_test/EuPathDB48/'

mkdir $kraken_file_path\blast_results

for files in $kraken_file_path\*.1.fa; do
blastn -db nt -query $file -out $kraken_file_path\blast_results/$file_blast  -max_target_seqs 5 -max_hsps 5   -outfmt "7 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" -remote ;done