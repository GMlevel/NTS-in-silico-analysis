#!/bin/bash
#SBATCH --job-name=sistr_analysis
#SBATCH -A open
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=8G
#SBATCH -t 24:00:00
#SBATCH -o sistr.out
#SBATCH -e sistr.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Initialize conda (ensure conda command is available)
eval "$(conda shell.bash hook)"

# Activate the environment
conda activate sistr_env

# Define input directory containing assembly files
assembly_dir="/scratch/mnk5428/kenyans/data"

# Define output directory for SISTR analysis
sistr_output="/scratch/mnk5428/kenyans/SISTR_Analysis"

# Create output directory if it doesn't exist
mkdir -p "$sistr_output"

# Perform SISTR analysis for each assembly
for assembly_file in "$assembly_dir"/*.fna; do
    if [ -f "$assembly_file" ]; then
        assembly_name=$(basename "$assembly_file" .fna)
        echo "Running SISTR analysis for assembly: $assembly_name"
        sistr -i "$assembly_file" -o "$sistr_output/$assembly_name"
    fi
done

echo "SISTR analysis completed"

