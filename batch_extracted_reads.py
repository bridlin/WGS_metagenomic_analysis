from pathlib import Path
from Bio import SeqIO

input_folder = Path("../../extracted_reads/")  # folder with your fasta files
output_folder = Path("../../blast_chunks")
output_folder.mkdir(exist_ok=True)

chunk_size = 100
chunk = []
chunk_num = 0

def write_chunk(chunk, chunk_num):
    out_path = output_folder / f"chunk_{chunk_num:04}.fasta"
    SeqIO.write(chunk, out_path, "fasta")
    print(f"Wrote {len(chunk)} reads to {out_path}")


# 2024T_S2_EuPathDB48.tid1463229.1.fa


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

