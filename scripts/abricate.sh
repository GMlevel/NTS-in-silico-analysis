#!/bin/bash
#SBATCH --job-name=abricate_analysis
#SBATCH -A open
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --mem-per-cpu=8G
#SBATCH -t 48:00:00
#SBATCH -o abricate_analysis_%j.out
#SBATCH -e abricate_analysis_%j.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Initialize conda (ensure conda command is available)
eval "$(conda shell.bash hook)"

# Define directories
base_dir="/scratch/mnk5428/kenyans/data"
abricate_output_base_dir="/scratch/mnk5428/kenyans/Abricate_Results"

# Activate abricate_env Conda environment
conda activate abricate_env

# Create the Abricate output base directory if it doesn't exist
mkdir -p "$abricate_output_base_dir"

# List of databases
databases=("argannot" "card" "plasmidfinder" "resfinder" "vfdb")

# Iterate over directories containing trimmed assembly results
for assembly_file in "$base_dir"/*.fna; do
    if [ -f "$assembly_file" ]; then
        assembly_filename=$(basename "$assembly_file")
        assembly_name="${assembly_filename%.*}"

        # Create directory for Abricate results for this assembly
        assembly_output_dir="$abricate_output_base_dir/$assembly_name"
        mkdir -p "$assembly_output_dir"

        # Perform Abricate analysis for each database
        for database in "${databases[@]}"; do
            abricate --db "$database" "$assembly_file" > "$assembly_output_dir/$database.tsv"
        done
    fi
done

