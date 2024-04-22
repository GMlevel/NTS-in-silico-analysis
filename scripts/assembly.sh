#!/bin/bash
#SBATCH --job-name=spades_assembly
#SBATCH -A open
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=16G
#SBATCH -t 48:00:00
#SBATCH -o spades.out
#SBATCH -e spades.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Initialize conda (ensure conda command is available)
eval "$(conda shell.bash hook)"

# Activate the environment
conda activate spades_env

# Define input directory containing trimmed reads
input_dir="/scratch/mnk5428/Kenyan/TrimmedReads"

# Define output directory for SPAdes assembly
output_dir="/scratch/mnk5428/Kenyan/All_SPAdes_Assembly"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Run SPAdes assembly for each pair of trimmed reads
for forward_read in $input_dir/*_1.fastq; do
    reverse_read="${forward_read/_1/_2}"
    output_subdir="$output_dir/$(basename "$forward_read" _1.fastq)_assembly"
    mkdir -p "$output_subdir"
    spades.py -o "$output_subdir" --pe1-1 "$forward_read" --pe1-2 "$reverse_read"
done
