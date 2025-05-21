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
module load python/3.9

source WGS_metagenomic_analysis/config.txt

cd auto_blast_folder/

mkdir ../kraken2-results_$run\_5prime-trimmed/EuPathDB48/blast_result
for files in ../kraken2-results_$run\_5prime-trimmed/EuPathDB48/*.1.fa ; do 
    file=$( echo $files | cut -d / -f 4) && 
    # echo $files && 
    if [ ! -f ../kraken2-results_$run\_5prime-trimmed/EuPathDB48/blast_result/$file\_blast ] ; then 
        echo $file\_blast && 
        echo "blasting..." &&
        blastn \
        -db nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 
    else 
        echo $file\_blast  && 
        echo "blast is already done"
    fi 
    if [  -f $file\_blast ] ; then 
        mv $file\_blast ../kraken2-results_$run\_5prime-trimmed/EuPathDB48/blast_result ; fi 
done





mkdir ../kraken2-results_$run\_5prime-trimmed/PlusPF/blast_result
for files in ../kraken2-results_$run\_5prime-trimmed/PlusPF/*.1.fa ; do 
    file=$( echo $files | cut -d / -f 4) && 
    # echo $files && 
    if [ ! -f ../kraken2-results_$run\_5prime-trimmed/PlusPF/blast_result/$file\_blast ] ; then 
        echo $file\_blast && 
        echo "blasting..." &&
        blastn \
        -db nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 
    else 
        echo $file\_blast  && 
        echo "blast is already done"
    fi 
    if [  -f $file\_blast ] ; then 
        mv $file\_blast ../kraken2-results_$run\_5prime-trimmed/PlusPF/blast_result ; fi 
done


output_dir=kraken2-results_$run\_5prime-trimmed
kraken_plus=$output_dir/$kraken_output_dir\/
kraken_eu=$output_dir/$kraken_output_dir_2\/

echo $kraken_eu
echo $kraken_plus

cd ..

### run python script to compare the results of the blast with the kraken2 results

python3 WGS_metagenomic_analysis/compare_results.py  $kraken_eu

python3 WGS_metagenomic_analysis/compare_results.py  $kraken_plus

