#!/bin/bash

# Function to fetch SRA IDs for a single BIOSAMPLE ID
fetch_sra_id() {
    local biosample_id="$1"
    epost -db biosample -id "$biosample_id" | elink -target sra | efetch -format docsum | xtract -pattern DocumentSummary -element Run@acc > temp_sra.txt
}

# Function to download data for a single SRA accession
download_sra_data() {
    local accession="$1"
    local output_dir="$2"
    echo "Downloading SRA data for accession: $accession"
    prefetch "$accession" -O "$output_dir"
    fasterq-dump "$accession" --outdir "$output_dir"
    echo "Download of SRA data for accession $accession completed"
}

# Path to the file containing sample IDs
sample_ids_file="/mnt/c/Users/Martin Njau/Downloads/accessions/biosamples/Eastafrica_biosamples.txt"

# Path to store the final SRA accessions file
output_file="/mnt/c/Users/Martin Njau/Downloads/accessions/sraaccessions/sraaccessions.txt"

# Path to store the mapping between BIOSAMPLE IDs and SRA accessions
biosample_mapping_file="/mnt/c/Users/Martin Njau/Downloads/accessions/sraaccessions/biosample_mapping.txt"

# Path to store the downloaded data
output_directory="/mnt/c/Users/Martin Njau/Downloads/accessions/sra_data"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Initialize the output files
> "$output_file"
> "$biosample_mapping_file"

# Read sample IDs from the file line by line
while IFS= read -r biosample_id; do
    # Fetch SRA ID for each BIOSAMPLE ID
    fetch_sra_id "$biosample_id"
    # Write mapping between BIOSAMPLE ID and SRA accessions to the mapping file
    while read -r accession; do
        if [[ -n "$accession" ]]; then
            echo "$biosample_id $accession" >> "$biosample_mapping_file"
        fi
    done < "temp_sra.txt"
    # Create a folder for each SRA accession
    accession_folder="$output_directory/$biosample_id"
    mkdir -p "$accession_folder"
    # Download data for each SRA accession
    while read -r accession; do
        if [[ -n "$accession" ]]; then
            download_sra_data "$accession" "$accession_folder"
            # Append the accession to the output file
            echo "$accession" >> "$output_file"
        fi
    done < "temp_sra.txt"
done < "$sample_ids_file"

# Remove temporary file
rm temp_sra.txt

# Compress downloaded files
gzip "$output_directory"/*/*.fastq

echo "All SRA data downloads completed!"

# Record job end time
echo "Job ended at $(date)"

