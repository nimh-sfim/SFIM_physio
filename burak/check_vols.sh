#!/bin/bash
ml fsl
# Define the base directory
BASE_DIR="/data/akinb2/allbp"

# Define subjects and runs
subjects=$(seq 10 34)
runs=("bouh.nii" "binh.nii" "rest.nii")

# Temporary file for storing output
output_file="nifti_volumes.txt"

# Clear previous output if exists
> $output_file

# Header row
echo -e "Subjects\tbouh\tbinh\trest" >> $output_file

# Loop through subjects
for subj in $subjects; do
    subj_dir="${BASE_DIR}/bp${subj}"

    # Start row with subject ID
    row="bp${subj}"

    # Loop through runs
    for run in "${runs[@]}"; do
        nifti_file="${subj_dir}/${run}"

        if [ -f "$nifti_file" ]; then
            # Get number of volumes using fslnvols
            volumes=$(fslnvols "$nifti_file")
            row+="\t$volumes"
        else
            row+="\tNA"  # If file is missing, mark as NA
        fi
    done

    # Append row to output file
    echo -e "$row" >> $output_file
done

echo "Volume extraction complete. Results saved in $output_file."

