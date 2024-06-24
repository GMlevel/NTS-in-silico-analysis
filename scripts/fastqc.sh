#!/bin/bash
#SBATCH --job-name=fastqc_multiqc
#SBATCH -A open
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --mem-per-cpu=4G
#SBATCH -t 4:00:00
#SBATCH -o fastqc_multiqc.out
#SBATCH -e fastqc_multiqc.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Initialize conda (ensure conda command is available)
eval "$(conda shell.bash hook)"

# Activate the environment
conda activate multiqc_env

# Path to the directory containing downloaded data
data_dir="/storage/home/mnk5428/scratch/KenyaN/data"

# Create a directory for storing FastQC and MultiQC results
output_dir="/storage/home/mnk5428/scratch/KenyaN/fastqc_multiqc_results"
mkdir -p "$output_dir"
fastqc_output_dir="$output_dir/fastqc_results"
multiqc_output_dir="$output_dir/multiqc_report"

# Create separate folders for FastQC and MultiQC results
mkdir -p "$fastqc_output_dir"
mkdir -p "$multiqc_output_dir"

# Perform FastQC analysis for each pair of downloaded files in each accession folder
for accession_dir in "$data_dir"/*; do
  if [[ -d "$accession_dir" ]]; then
    accession=$(basename "$accession_dir")
    accession_fastqc_output_dir="$fastqc_output_dir/$accession"
    mkdir -p "$accession_fastqc_output_dir"
    if [[ -e "$accession_dir/${accession}_1.fastq" && -e "$accession_dir/${accession}_2.fastq" ]]; then
      echo "Running FastQC for accession: $accession"
      fastqc --outdir "$accession_fastqc_output_dir" "$accession_dir/${accession}_1.fastq" "$accession_dir/${accession}_2.fastq"
    else
      echo "Error: Paired-end files not found for accession $accession"
    fi
  fi
done

# Generate MultiQC report for all FastQC results
multiqc "$fastqc_output_dir" -o "$multiqc_output_dir"

echo "FastQC and MultiQC analysis completed"

