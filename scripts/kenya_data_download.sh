#!/bin/bash
#SBATCH --job-name=kenya_data
#SBATCH -A open
#SBATCH -N 8
#SBATCH -n 12
#SBATCH --mem-per-cpu=48G
#SBATCH -t 48:00:00
#SBATCH -o kenya_data.out
#SBATCH -e kenya_data.err
#SBATCH --export=ALL
#SBATCH --mail-type=END
#SBATCH --mail-user=mnk5428@psu.edu

# Path to the BIOSAMPLE IDs file
biosample_file="/storage/home/mnk5428/scratch/Kenya/Kenya_ids.txt"

# Path to store the downloaded data
data_dir="/storage/home/mnk5428/scratch/Kenya/data"

# Path to the BIOSAMPLE IDs vs. SRA accessions mapping file
biosample_sra_mapping_file="/storage/home/mnk5428/scratch/Kenya/biosample_vs_sra_mapping.txt"

# Path to the SRA Toolkit
sra_toolkit_path="/storage/home/mnk5428/scratch/sratoolkit.3.1.0-ubuntu64/bin"

# Function to fetch SRA IDs for a single BIOSAMPLE ID and save mapping
fetch_sra_id() {
    local biosample_id="$1"
    local sra_id=$(esearch -db sra -query "$biosample_id" </dev/null | efetch -format docsum | xtract -pattern Runs -element Run@acc)
    echo "$biosample_id $sra_id" >> "$biosample_sra_mapping_file"
    echo "$sra_id"
}

# Function to download FASTQ files for a single SRA ID
download_fastq() {
    local sra_id="$1"
    local retry_count=0
    local success=false
    while [ $retry_count -lt 3 ]; do
        echo "Downloading FASTQ files for SRA ID: $sra_id (Attempt $((retry_count+1)))"
        "$sra_toolkit_path/fasterq-dump" -e $retry_count -O "$data_dir" "$sra_id"
        if [ $? -eq 0 ]; then
            success=true
            break
        fi
        ((retry_count++))
        sleep 10  # Wait for 10 seconds before retrying
    done
    if [ "$success" = false ]; then
        echo "Failed to download FASTQ files for SRA ID: $sra_id after multiple attempts."
        return 1
    fi
}

# Iterate over each BIOSAMPLE ID in the input file
while IFS= read -r biosample_id; do
    echo "Fetching SRA IDs for BIOSAMPLE ID: $biosample_id"
    sra_id=$(fetch_sra_id "$biosample_id")
    if [ -n "$sra_id" ]; then
        download_fastq "$sra_id"
    fi
done < "$biosample_file"

echo "FASTQ files downloaded and stored in: $data_dir"

