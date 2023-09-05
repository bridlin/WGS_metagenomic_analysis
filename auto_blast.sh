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


#kraken_file_path=../kraken2-results_run12_5prime-trimmed/EuPathDB48/
mkdir ../kraken2-results_run12_5prime-trimmed/EuPathDB48/blast_result
for files in ../kraken2-results_run12_5prime-trimmed/EuPathDB48/extracted_reads/*.1.fa ; do file=$( echo $files | cut -d / -f 5) && echo $files && echo $file  && echo $file\_blast && blastn -db nt -query $files -out $file\_blast  -max_target_seqs 5 -max_hsps 5   -outfmt "7 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" -remote && mv $file\_blast ../kraken2-results_run9_5prime-trimmed/EuPathDB48/blast_result ; done


