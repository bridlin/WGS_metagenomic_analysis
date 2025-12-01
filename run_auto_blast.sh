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

module load blast/2.16.0
module load python/3.12

source WGS_metagenomic_analysis/config.txt

output_dir=kraken2-results_$run\_5prime-trimmed_test_test
output_dir_E=$output_dir/$kraken2_E
output_dir_P=$output_dir/$kraken2_P

echo "run auto blast and compare results"
echo "run= $run"
echo "input_list= ${input_list[@]}"
echo "kraken2_E= $kraken2_E"    
echo "kraken2_P= $kraken2_P"
echo "output_dir_E is " $output_dir_E
echo "output_dir_P is " $output_dir_P

mkdir ../$output_dir_E\/blast_result
mkdir ../$output_dir_P\/blast_result

cd auto_blast_folder/


for files in ../$output_dir_E\/extracted_reads/*.1.fa ; do 
    file=$(basename "$files")  
    # echo $files  
    if [ ! -f ../$output_dir_E\/blast_result/$file\_blast ]  
    then 
        echo $file\_blast 
        echo "blasting..." 
        blastn \
        -db nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 
    else 
        echo $file\_blast   
        echo "blast is already done"
    fi 
    if [  -f $file\_blast ]  
    then 
        mv $file\_blast ../$output_dir_E\/blast_result  
    fi 
done






for files in ../$output_dir_P\/extracted_reads/*.1.fa ; do 
    file=$(basename "$files")  
    # echo $files && 
    if [ ! -f ../$output_dir_P\/blast_result/$file\_blast ]  
    then 
        echo $file\_blast  
        echo "blasting..." 
        blastn \
        -db nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 
    else 
        echo $file\_blast   
        echo "blast is already done"
    fi 
    if [  -f $file\_blast ]  
    then 
        mv $file\_blast ../$output_dir_P\/blast_result/$file\_blast  
    fi 
done




cd ..

### run python script to compare the results of the blast with the kraken2 results
echo "run python script to compare the results of the blast with the kraken2 results"


python3 WGS_metagenomic_analysis/compare_results.py  $output_dir_E\/

python3 WGS_metagenomic_analysis/compare_results.py  $output_dir_P\/
