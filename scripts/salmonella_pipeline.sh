#!/bin/bash

# File:
# Time-stamp <29-Feb-2024>
#
# Author: Martin and Samantha
#
# Description: This pipeline performs quality control on raw reads, trims reads using Trimmomatic,
#              assembles genomes using SPAdes, conducts assembly QC, serotypes using SISTR,
#              and identifies antimicrobial resistance genes and virulence factors using Abricate.

usage() {
  echo "Usage: $0 [-S <SRADataFolder>] [-O <OutputFolder>]

                        -S Path to the SRA data folder
                        -O Path to the output folder
                         Example ./SalmonellaPipeline.sh -S SRADataFolder -O OutputFolder
                                " 1>&2
  exit 1
}

while getopts ":S:O:" option; do
  case "${option}" in
    S)
      S=${OPTARG}
      ;;
    O)
      O=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

shift $((OPTIND - 1))
SRADataFolder="/mnt/c/Users/Martin Njau/Downloads/accessions/sra_data"
SRADataFolder="/mnt/c/Users/Martin Njau/Downloads/accessions/sra_data"
OutputFolder="/mnt/c/Users/Martin Njau/Downloads/accessions/results"

if [ -z "${SRADataFolder}" ] || [ -z "${OutputFolder}" ]; then
  usage
fi

# Create output folders
mkdir -p "${OutputFolder}"
QCOutput="${OutputFolder}/QC"
TrimOutput="${OutputFolder}/TrimmedReads"
AssemblyOutput="${OutputFolder}/Assembly"
QCAssemblyOutput="${OutputFolder}/QCAssembly"
SerotypingOutput="${OutputFolder}/Serotyping"
AMROutput="${OutputFolder}/AMR"

## Perform quality control on raw reads using FastQC
echo "Performing quality control on raw reads..."
mkdir -p "${QCOutput}"
fastqc -o "${QCOutput}" "${SRADataFolder}"/*.fastq.gz
multiqc "${QCOutput}" -o "${QCOutput}"

## Trim reads using Trimmomatic
echo "Trimming reads using Trimmomatic..."
mkdir -p "${TrimOutput}"
for file in "${SRADataFolder}"/*.fastq.gz; do
  base=$(basename "$file" .fastq.gz)
  trimmomatic SE -threads 8 "${SRADataFolder}/${base}.fastq.gz" \
    "${TrimOutput}/${base}_trimmed.fastq.gz" \
    ILLUMINACLIP:TruSeq3-SE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
done

## Assemble genomes using SPAdes
echo "Assembling genomes using SPAdes..."
mkdir -p "${AssemblyOutput}"
for file in "${TrimOutput}"/*_trimmed.fastq.gz; do
  base=$(basename "$file" _trimmed.fastq.gz)
  spades.py -t 8 -s "${TrimOutput}/${base}_trimmed.fastq.gz" \
    -o "${AssemblyOutput}/${base}"
done

## Perform assembly QC
echo "Performing assembly QC..."
mkdir -p "${QCAssemblyOutput}"
for dir in "${AssemblyOutput}"/*; do
  base=$(basename "$dir")
  quast.py "${dir}/scaffolds.fasta" -o "${QCAssemblyOutput}/${base}_QC"
done

## Serotyping using SISTR
echo "Serotyping using SISTR..."
mkdir -p "${SerotypingOutput}"
for dir in "${AssemblyOutput}"/*; do
  base=$(basename "$dir")
  sistr_cmd "${dir}/scaffolds.fasta" --output "${SerotypingOutput}/${base}_SISTR"
done

## Antimicrobial resistance and virulence analysis using Abricate
echo "Antimicrobial resistance and virulence analysis using Abricate..."
mkdir -p "${AMROutput}"
for file in "${QCOutput}"/*.zip; do
  base=$(basename "$file" .zip)
  unzip -q "${file}" -d "${QCOutput}/${base}"
  abricate --db resfinder,vfdb "${AssemblyOutput}/${base}"/*.fasta > "${AMROutput}/${base}_ABRicate_Results.tab"
done

echo "Pipeline finished successfully!"

