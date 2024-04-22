#!/bin/bash
#SBATCH --job-name=trimmomatic_trimming
#SBATCH -A open
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=32G
#SBATCH -t 48:00:00
#SBATCH -o trimmomatic.out
#SBATCH -e trimmomatic.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Initialize conda (ensure conda command is available)
eval "$(conda shell.bash hook)"

# Activate the environment
conda activate salmonella_env

# Define paths
InputFolder="/scratch/mnk5428/Kenyan/data"
OutputFolder="/scratch/mnk5428/Kenyan/TrimmedReads"

# Create output directory if it doesn't exist
mkdir -p "${OutputFolder}"

# Start Trimmomatic trimming for each sample
echo "Trimmomatic trimming started at $(date)"
for file in "${InputFolder}"/*_1.fastq; do
    filename=$(basename "$file")
    sample_name="${filename%_1.fastq}"
    echo "Processing sample: $sample_name"
    java -jar trimmomatic-0.39.jar PE \
         -threads 8 \
         -phred33 \
         "${InputFolder}/${sample_name}_1.fastq" \
         "${InputFolder}/${sample_name}_2.fastq" \
         "${OutputFolder}/trimmed_${sample_name}_1.fastq" \
         "${OutputFolder}/unpaired_${sample_name}_1.fastq" \
         "${OutputFolder}/trimmed_${sample_name}_2.fastq" \
         "${OutputFolder}/unpaired_${sample_name}_2.fastq" \
         ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True \
         LEADING:3 \
         TRAILING:3 \
         MINLEN:36
done
echo "Trimmomatic trimming ended at $(date)"

