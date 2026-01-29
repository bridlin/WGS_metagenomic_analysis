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


module load bowtie2/2.5.4
module load  samtools/1.21

source WGS_metagenomic_analysis/config-align.txt

echo $read_directory
echo $inputlist
echo $genome_prefix

if [[ ! -f "${genome_prefix}.1.bt2" && ! -f "${genome_prefix}.1.bt2l" ]]; then
    echo "Bowtie2 index not found for ${genome_prefix}. Building index..."
    bowtie2-build "$genome_prefix" "$genome_prefix" || {
        echo "ERROR: bowtie2-build failed"
        exit 1
    }
else
    echo "Bowtie2 index found for ${genome_prefix}"
fi
for x in "${inputlist[@]}"; do
echo $read_directory\/$x\.1.fa &&
echo $read_directory\/$x\.2.fa &&
bowtie2 -x $genome_prefix /
    -f -p 8  \
    -1 $read_directory\/$x\.1.fa  \
    -2 $read_directory\/$x\.2.fa  \
    -S $read_directory\/$x\_aligned.sam &&
samtools \
    view \
    -S \
    -b $read_directory\/$x\_aligned.sam \
    > $read_directory\/$x\_aligned.bam  &&
samtools \
    sort  \
    $read_directory\/$x\_aligned.bam  \
    -o  $read_directory\/$x\_aligned_sorted.bam  &&
samtools \
    index $read_directory\/$x\_aligned_sorted.bam   &&
rm -f $read_directory\/$x\_aligned.sam &&
rm -f $read_directory\/$x\_aligned.bam ; done


