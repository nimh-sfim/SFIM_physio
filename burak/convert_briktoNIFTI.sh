#!/bin/bash
ml afni
# Base directory containing the data
BASE_DIR="/data/akinb2/allbp"

# Loop through subjects
for subj in {10..34}; do
    subj_dir="${BASE_DIR}/bp${subj}"

    # Loop through runs
    for run in func_binh func_bouh func_rest; do
        run_dir="${subj_dir}/${run}"

        # Define input and output file paths
        input_prefix="${run_dir}/pb04.bp${subj}.r01.scale+tlrc"
        output_file="${run_dir}/pb04.bp${subj}.r01.scale.nii.gz"

        # Check if output NIfTI file already exists
        if [ -f "$output_file" ]; then
            echo "Skipping bp${subj} ${run}: NIfTI file already exists."
        else
            if [ -f "${input_prefix}.BRIK" ] && [ -f "${input_prefix}.HEAD" ]; then
                echo "Converting bp${subj} ${run} to NIfTI..."
                3dAFNItoNIFTI -prefix "$output_file" "$input_prefix"
            else
                echo "Skipping bp${subj} ${run}: BRIK/HEAD files not found."
            fi
        fi
    done
done

echo "Conversion process completed."

