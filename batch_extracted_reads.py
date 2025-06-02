from pathlib import Path
from Bio import SeqIO
import sys

# This script reads fasta files from a specified input folder, chunks them into bigger files,
# and writes these chunks to an output folder.
# Usage: python batch_extracted_reads.py <path_to_results_folder>

if len(sys.argv) == 1:
    print('Input file paths are missing as command line arguments!!!')
    sys.exit(1)  # optional: exit the script
else:
    results_path = Path(sys.argv[1])  # convert to Path right away
    print(results_path)

input_folder = results_path / "extracted_reads"
output_folder = results_path / "blast_chunks"
output_folder.mkdir(exist_ok=True)

chunk_size = 100
chunk = []
chunk_num = 0

def write_chunk(chunk, chunk_num):
    out_path = output_folder / f"chunk_{chunk_num:04}.fasta"
    SeqIO.write(chunk, out_path, "fasta")
    print(f"Wrote {len(chunk)} reads to {out_path}")



for fasta_file in input_folder.glob("*.fa"):
    file_id = fasta_file.stem  # gets filename without extension
    for i, record in enumerate(SeqIO.parse(fasta_file, "fasta")):
        record.id = f"{file_id}|{record.id}"
        record.description = ""  # clean up long description
        chunk.append(record)

        if len(chunk) >= chunk_size:
            write_chunk(chunk, chunk_num)
            chunk = []
            chunk_num += 1

# write last partial chunk
if chunk:
    write_chunk(chunk, chunk_num)

