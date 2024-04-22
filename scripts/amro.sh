#!/bin/bash
#SBATCH --job-name=hamronize_abricate
#SBATCH -A open
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --output=hamronize_abricate_%j.out
#SBATCH --error=hamronize_abricate_%j.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Initialize conda (ensure conda command is available)
eval "$(conda shell.bash hook)"

# Activate the hAMRonization Conda environment
conda activate hamronization

# Define directories
base_dir="/scratch/mnk5428/Kenyan/Abricate_Resultss"
hamronized_output_base_dir="/scratch/mnk5428/Kenyan/hAMRonized_Abricate_Results"

# Create the hAMRonized output base directory if it doesn't exist
mkdir -p "$hamronized_output_base_dir"

# List of databases with their versions
databases=("argannot:Jul_8_2017" "card:Jul_8_2017" "plasmidfinder:Mar_19_2017" "resfinder:Jul_8_2017" "vfdb:Mar_17_2017")

# Analysis software version
analysis_software_version="0.5"

# Iterate over each sample directory
for sample_dir in "$base_dir"/*/; do
    sample_name=$(basename "$sample_dir")
    
    # Create a directory for hAMRonized output for this sample
    sample_hamronized_output_dir="$hamronized_output_base_dir/$sample_name"
    mkdir -p "$sample_hamronized_output_dir"
    
    # Iterate over each database for this sample
    for db_info in "${databases[@]}"; do
        IFS=':' read -r database version <<< "$db_info"
        database_file="$sample_dir/abricate_results_$database.tsv"
        
        # Check if the database file exists for this sample and database
        if [ -f "$database_file" ]; then
            # Run hAMRonization and save hAMRonized output
            output_file="$sample_hamronized_output_dir/abricate_results_${database}_hAMRonized.tsv"
            hamronize abricate "$database_file" --output "$output_file" \
                --analysis_software_version "$analysis_software_version" \
                --reference_database_version "$version"
        else
            echo "No Abricate output file found for database $database in sample $sample_name"
        fi
    done
done

echo "hAMRonization completed."

