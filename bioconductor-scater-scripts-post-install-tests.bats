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

    run rm -f $cpm_singlecellexperiment_object $cpm_matrix && scater-calculate-cpm.R -i $raw_singlecellexperiment_object -s $size_factors -o $cpm_singlecellexperiment_object -t $cpm_matrix
    
    [ "$status" -eq 0 ]
    [ -f  "$cpm_singlecellexperiment_object" ]
    [ -f  "$cpm_matrix" ]
}

@test "Normalisation of raw SingleCellExperiment counts" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$norm_singlecellexperiment_object" ]; then
        skip "$use_existing_outputs $norm_singlecellexperiment_object exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $norm_singlecellexperiment_object && scater-normalize.R -i $raw_singlecellexperiment_object -e $exprs_values -l $return_log -f $log_exprs_offset -c $centre_size_factors -r $return_norm_as_exprs -o $norm_singlecellexperiment_object
    
    [ "$status" -eq 0 ]
    [ -f  "$norm_singlecellexperiment_object" ]
}

@test "Generate random genes - spikeins" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$test_genes" ]; then
        skip "$use_existing_outputs $test_genes exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $test_genes && scater-get-random-genes.R $raw_singlecellexperiment_object $test_genes $n_spike_ins $n_genes

    [ "$status" -eq 0 ]
    [ -f  "$test_genes" ]
}

@test "calculate QC metrics" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$qc_singlecellexperiment_object" ]; then
        skip "$use_existing_outputs $qc_singlecellexperiment_object exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $qc_singlecellexperiment_object && scater-calculate-qc-metrics.R -i $raw_singlecellexperiment_object -e $exprs_values -f $feature_controls -c $cell_controls -n $nmads -p $pct_feature_controls_threshold -o $qc_singlecellexperiment_object
    
    [ "$status" -eq 0 ]
    [ -f  "$qc_singlecellexperiment_object" ]
}

