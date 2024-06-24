#!/bin/bash

#SBATCH --job-name=kenya_tree

#SBATCH -A open

#SBATCH -N 1

#SBATCH -n 16

#SBATCH --mem-per-cpu=16G

#SBATCH -t 48:00:00

#SBATCH -o kenya_tree.out

#SBATCH -e kenya_tree.err

#SBATCH --export=ALL

#SBATCH --mail-type=END

#SBATCH --mail-user=mnk5428@psu.edu



# Define input directories and files

tree_file="/scratch/mnk5428/fastree/kenya/kenya_tree.newick"

presence_absence_file="/scratch/mnk5428/fastree/kenya/gene_presence_absence.csv"



# Define output directory

output_dir="/scratch/mnk5428/fastree/finaltree"



# Activate Conda environment

eval "$(conda shell.bash hook)"

conda activate roary_envs



# Run the Python script to generate the phylogenetic tree in SVG format

/storage/work/mnk5428/Anaconda/envs/roary_envs/bin/roary --labels "${tree_file}" "${presence_absence_file}" -o "${output_dir}"



# Deactivate Conda environment

conda deactivate


