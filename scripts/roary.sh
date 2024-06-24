#!/bin/bash



# Add roary_envs/bin directory to PATH temporarily

export PATH="/storage/home/mnk5428/work/Anaconda/envs/roary_envs/bin:$PATH"



# Activate the Conda environment

eval "$(conda shell.bash hook)"



# Define input directories for each country

uganda_prokka_dir="/scratch/mnk5428/uganda/Prokka_Annotation"

ethiopia_prokka_dir="/scratch/mnk5428/ethiopia/Prokka_Annotation"

tanzania_prokka_dir="/scratch/mnk5428/tanzania/Prokka_Annotation"

kenya_prokka_dir="/scratch/mnk5428/KenyaN/Prokka_Annotation"



# Create output directories if they don't exist

mkdir -p "./uganda_roary"

mkdir -p "./ethiopia_roary"

mkdir -p "./tanzania_roary"

mkdir -p "./kenya_roary"



# Run Roary analysis for each country

roary -f "./uganda_roary" -e -n -v "$uganda_prokka_dir"/*/*.gff

echo "Roary analysis completed for Uganda"



roary -f "./ethiopia_roary" -e -n -v "$ethiopia_prokka_dir"/*/*.gff

echo "Roary analysis completed for Ethiopia"



roary -f "./tanzania_roary" -e -n -v "$tanzania_prokka_dir"/*/*.gff

echo "Roary analysis completed for Tanzania"



roary -f "./kenya_roary" -e -n -v "$kenya_prokka_dir"/*/*.gff

echo "Roary analysis completed for Kenya"



# Deactivate Conda environment

conda deactivate


