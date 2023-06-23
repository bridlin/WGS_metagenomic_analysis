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
bowtie2 -x $genome -f -p 8  -1 $inputlist\\.1.fq  -2 $inputlist\\.2.fq  -S $inputlist\\_aligned.sam &&
samtools view -S -b $inputlist\_aligned.sam > $inputlist\_aligned.bam  &&
samtools sort  $inputlist\_aligned.bam  -o  $inputlist\_aligned_sorted.bam  &&
samtools index $inputlist\_aligned_sorted.bam   &&
rm -f $inputlist\\_aligned.sam &&
rm -f $inputlist\_aligned.bam ; done