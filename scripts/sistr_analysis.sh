#!/bin/bash
#SBATCH --job-name=sistr_analysis
#SBATCH -A open
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --mem-per-cpu=8G
#SBATCH -t 4:00:00
#SBATCH -o sistr.out
#SBATCH -e sistr.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Initialize conda (ensure conda command is available)
eval "$(conda shell.bash hook)"

# Activate the sistr_env environment
conda activate sistr_env

# Define input directory containing assemblies in FASTA format
assembly_dir="/scratch/mnk5428/kenyans/All_SPAdes_Assembly"

# Define output directory for SISTR analysis
output_dir="/scratch/mnk5428/kenyans/SISTR_Analysis"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Find all contigs.fasta files recursively and analyze each one
find "$assembly_dir" -name "fna" | while read -r fasta_file; do
    # Get the directory name containing the fasta file
    dir_name=$(dirname "$fasta_file")
    
    # Extract genome name from the directory name
    genome_name=$(basename "$dir_name")
    
    # Run SISTR analysis
    sistr --qc -vv --alleles-output "$output_dir"/allele-results.json \
          --novel-alleles "$output_dir"/novel-alleles.fasta \
          --cgmlst-profiles "$output_dir"/cgmlst-profiles.csv \
          -f tab -o "$output_dir"/"$genome_name"_sistr-output.tab "$fasta_file"
done
