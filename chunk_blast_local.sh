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

output_dir=kraken2-results_$run\_5prime-trimmed_chunked
output_dir_P=$output_dir/$kraken2_P

echo "run auto blast and compare results"
echo "run= $run"
echo "input_list= ${input_list[@]}"
echo "kraken2_E= $kraken2_E"    
echo "kraken2_P= $kraken2_P"
echo "output_dir_E is " $output_dir_E
echo "output_dir_P is " $output_dir_P

mkdir $output_dir_E\/blast_result
mkdir $output_dir_P\/blast_result


# batching  the reads for light blasting into 100 reads per fasta file

# python3 WGS_metagenomic_analysis/batch_extracted_reads.py $output_dir_E\

# python3 WGS_metagenomic_analysis/batch_extracted_reads.py $output_dir_P\


# cd auto_blast_folder/

mkdir $output_dir_E\/blast_result
mkdir $output_dir_P\/blast_result

for files in $output_dir_E\/blast_chunks/*.fasta ; do 
    file=$(basename "$files")  
    # echo $files  
    if [ ! -f $output_dir_E\/blast_result/$file\_blast ]  
    then 
        echo $file\_blast 
        echo "blasting..." 
        blastn \
        -db ../bank/nt/current/blast/nt \
        -query $files \
        -out $file\_blast  \
        -max_target_seqs 5 \
        -max_hsps 5   \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" 
    else 
        echo $file\_blast   
        echo "blast is already done"
    fi 
    if [  -f $file\_blast ]  
    then 
        mv $file\_blast $output_dir_E\/blast_result  
    fi 
done


# for files in ../$output_dir_P\/blast_chunks/*.fasta ; do 
#     file=$(basename "$files")  
#     # echo $files && 
#     if [ ! -f ../$output_dir_P\/blast_result/$file\_blast ]  
#     then 
#         echo $file\_blast  
#         echo "blasting..." 
#         blastn \
#         -db ../../bank/nt/current/blast/nt \
#         -query $files \
#         -out $file\_blast  \
#         -max_target_seqs 5 \
#         -max_hsps 5   \
#         -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" 
#     else 
#         echo $file\_blast   
#         echo "blast is already done"
#     fi 
#     if [  -f $file\_blast ]  
#     then 
#         mv $file\_blast ../$output_dir_P\/blast_result/$file\_blast  
#     fi 
# done

# cd ..

# dechunking the blast results

 python3 WGS_metagenomic_analysis/dechunk_blast_results.py  $output_dir_E\
 
 python3 WGS_metagenomic_analysis/dechunk_blast_results.py  $output_dir_P\
