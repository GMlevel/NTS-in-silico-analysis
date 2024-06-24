#!/bin/bash



#SBATCH --job-name=prokka

#SBATCH -A open

#SBATCH -N 1

#SBATCH -n 8

#SBATCH --mem-per-cpu=24G

#SBATCH -t 12:00:00

#SBATCH -o prokka.out

#SBATCH -e prokka.err

#SBATCH --export=ALL

#SBATCH --mail-type=END

#SBATCH --mail-user=mnk5428@psu.edu



# Activate Conda environment for Prokka

eval "$(conda shell.bash hook)"

conda activate prokka_env



# Define assembly directory

assembly_dir="/scratch/mnk5428/KenyaN/SPAdes_Assembly"

assembly_file="SRR28784414.fasta"



# Define output directory for Prokka annotation

prokka_output_dir="/scratch/mnk5428/KenyaN/Prokka_Annotation"



# Create output directory if it doesn't exist

mkdir -p "$prokka_output_dir"



# Function to run Prokka annotation

run_prokka() {

    local assembly_file="$1"

    local prokka_output_dir="$2"



    # Run Prokka annotation

    sample_name=$(basename "$assembly_file" .fasta)

    prokka --outdir "$prokka_output_dir/$sample_name" --prefix "$sample_name" --force --centre X --compliant "$assembly_file"

    echo "Prokka annotation completed for $sample_name"

}



# Run Prokka annotation

run_prokka "$assembly_dir/$assembly_file" "$prokka_output_dir"



# Deactivate Conda environment

conda deactivate


