#!/usr/bin/env bats

# Extract the test data

@test "Extract .mtx matrix from archive" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$raw_matrix" ]; then
        skip "$raw_matrix exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $raw_matrix && tar -xvzf $test_data_archive --strip-components 2 -C $data_dir
 
    [ "$status" -eq 0 ]
    [ -f  "$raw_matrix" ]
}

# Create the SingleCellExperiment

@test "SingleCellExperiment creation from 10x" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$raw_singlecellexperiment_object" ]; then
        skip "$use_existing_outputs $raw_singlecellexperiment_object exists and use_existing_outputs is set to 'true'"
    fi
    
    run rm -f $raw_singlecellexperiment_object && scater-read-10x-results.R -d $data_dir -o $raw_singlecellexperiment_object
    
    [ "$status" -eq 0 ]
    [ -f  "$raw_singlecellexperiment_object" ]
}


@test "Read raw SingleCellExperiment counts and convert to CPM" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$cpm_singlecellexperiment_object" ] && [ -f "$cpm_matrix" ]; then
        skip "$use_existing_outputs $cpm_singlecellexperiment_object $cpm_matrix exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $cpm_singlecellexperiment_object $cpm_matrix && scater-calculate-cpm-from-counts.R -i $raw_singlecellexperiment_object -e "counts" -s FALSE -o $cpm_singlecellexperiment_object -t $cpm_matrix
    
    [ "$status" -eq 0 ]
    [ -f  "$cpm_singlecellexperiment_object" ]
    [ -f  "$cpm_matrix" ]
}