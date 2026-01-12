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

# output_dir=kraken2-results_$run\_5prime-trimmed
output_dir=kraken2-results_$run\_5prime-trimmed_clumped
# output_dir=kraken2-results_$run\_5prime-trimmed_chunked   
output_dir_E=$output_dir/$kraken2_E
output_dir_P=$output_dir/$kraken2_P

echo "run auto blast and compare results"
echo "run= $run"
echo "input_list= ${input_list[@]}"
echo "kraken2_E= $kraken2_E"    
echo "kraken2_P= $kraken2_P"
echo "output_dir_E is " $output_dir_E
echo "output_dir_P is " $output_dir_P




### batching  the reads for light blasting into 100 reads per fasta file
echo "batching  the reads for light blasting into 100 reads per fasta file"

python3 WGS_metagenomic_analysis/batch_extracted_reads.py $output_dir_E  $run $kraken2_E

python3 WGS_metagenomic_analysis/batch_extracted_reads.py $output_dir_P  $run $kraken2_P

### run blast on the extracted batched reads
echo "run blast on the extracted  batched reads"

cd auto_blast_folder/

mkdir ../$output_dir_E\/blast_result
mkdir ../$output_dir_P\/blast_result


# Output log file
logfile="../$output_dir_E/blast_${run}_E.log"
touch "$logfile"

echo "=== Starting BLAST run: $(date) ===" >> "$logfile"

# Loop through all chunked query files
for files in ../$output_dir_E/blast_chunks/*.fasta ; do 
    file=$(basename "$files")
    outfile="${file}_blast"
    full_outpath="../$output_dir_E/blast_result/$outfile"

    # Skip if output already exists
    if [ -f "$full_outpath" ]; then 
        echo "$outfile - already exists, skipping" | tee -a "$logfile"
        continue
    fi

    echo "$outfile - blasting..." | tee -a "$logfile"

    # Run BLAST and capture stderr to temp file
    tmp_stderr=$(mktemp)
    blastn -db nt \
        -query "$files" \
        -out "$outfile" \
        -max_target_seqs 5 \
        -max_hsps 5 \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 2> "$tmp_stderr"

    # Check success
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        if [ -s "$outfile" ]; then
            mv "$outfile" "$full_outpath"
            echo "$outfile - success" | tee -a "$logfile"
        else
            echo "$outfile - BLAST completed but file is empty (no hits?)" | tee -a "$logfile"
            mv "$outfile" "$full_outpath"
        fi
    else
        echo "$outfile - BLAST FAILED (exit code $exit_code)" | tee -a "$logfile"
        echo "--- STDERR ---" >> "$logfile"
        cat "$tmp_stderr" >> "$logfile"
        echo "--------------" >> "$logfile"
        # Optionally: touch empty file so downstream doesn't re-run
        touch "$full_outpath.failed"
    fi

    rm "$tmp_stderr"
done

echo "=== Finished BLAST run: $(date) ===" >> "$logfile"





# Output log file
logfile="../$output_dir_P/blast_${run}_P.log"
touch "$logfile"

echo "=== Starting BLAST run: $(date) ===" >> "$logfile"

# Loop through all chunked query files
for files in ../$output_dir_P/blast_chunks/*.fasta ; do 
    file=$(basename "$files")
    outfile="${file}_blast"
    full_outpath="../$output_dir_P/blast_result/$outfile"

    # Skip if output already exists
    if [ -f "$full_outpath" ]; then 
        echo "$outfile - already exists, skipping" | tee -a "$logfile"
        continue
    fi

    echo "$outfile - blasting..." | tee -a "$logfile"

    # Run BLAST and capture stderr to temp file
    tmp_stderr=$(mktemp)
    blastn -db nt \
        -query "$files" \
        -out "$outfile" \
        -max_target_seqs 5 \
        -max_hsps 5 \
        -outfmt "6 qseqid sseqid sscinames pident qcovs qcovhsp length mismatch gapopen qstart qend sstart send evalue bitscore staxids" \
        -remote 2> "$tmp_stderr"

    # Check success
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        if [ -s "$outfile" ]; then
            mv "$outfile" "$full_outpath"
            echo "$outfile - success" | tee -a "$logfile"
        else
            echo "$outfile - BLAST completed but file is empty (no hits?)" | tee -a "$logfile"
            mv "$outfile" "$full_outpath"
        fi
    else
        echo "$outfile - BLAST FAILED (exit code $exit_code)" | tee -a "$logfile"
        echo "--- STDERR ---" >> "$logfile"
        cat "$tmp_stderr" >> "$logfile"
        echo "--------------" >> "$logfile"
        # Optionally: touch empty file so downstream doesn't re-run
        touch "$full_outpath.failed"
    fi

    rm "$tmp_stderr"
done

echo "=== Finished BLAST run: $(date) ===" >> "$logfile"




cd ..

# dechunking the blast results
echo "dechunking the blast results"

python3 WGS_metagenomic_analysis/dechunk_blast_results.py  $output_dir_E\
 
python3 WGS_metagenomic_analysis/dechunk_blast_results.py  $output_dir_P\
