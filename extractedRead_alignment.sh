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


module load bowtie2/2.5.1
module load  samtools/1.13

source WGS_metagenomic_analysis/config-align.txt


for x in "${input_list[@]}"; do
bowtie2 -x $genome -f -p 8  -1 $read_directory\$inputlist\.1.fq  -2 $read_directory\$inputlist\.2.fq  -S $read_directory\$inputlist\_aligned.sam &&
samtools view -S -b $read_directory\$inputlist\_aligned.sam > $read_directory\$inputlist\_aligned.bam  &&
samtools sort  $read_directory\$inputlist\_aligned.bam  -o  $read_directory\$inputlist\_aligned_sorted.bam  &&
samtools index $read_directory\$inputlist\_aligned_sorted.bam   &&
rm -f $read_directory\$inputlist\_aligned.sam &&
rm -f $read_directory\$inputlist\_aligned.bam ; done
