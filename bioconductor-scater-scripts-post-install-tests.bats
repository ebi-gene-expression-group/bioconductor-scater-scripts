#!/usr/bin/env bats

# Extract the test data

@test "Extract .mtx matrix from archive" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$raw_matrix" ]; then
        skip "$raw_matrix exists and use_existing_outputs is set to 'true'"
    fi
   
    run rm -f $raw_matrix && tar -xvzf $test_data_archive --strip-components 2 -C $data_dir
    echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$raw_matrix" ]
}

# Create the SingleCellExperiment

@test "SingleCellExperiment creation from 10x" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$raw_singlecellexperiment_object" ]; then
        skip "$use_existing_outputs $raw_singlecellexperiment_object exists and use_existing_outputs is set to 'true'"
    fi
    
    run rm -f $raw_singlecellexperiment_object && scater-read-10x-results.R -d $data_dir -o $raw_singlecellexperiment_object
    echo "status = ${status}"
    echo "output = ${output}"
    
    [ "$status" -eq 0 ]
    [ -f  "$raw_singlecellexperiment_object" ]
}

# Generate counts per million

@test "Read raw SingleCellExperiment counts and convert to CPM" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$cpm_singlecellexperiment_object" ] && [ -f "$cpm_matrix" ]; then
        skip "$use_existing_outputs $cpm_singlecellexperiment_object $cpm_matrix exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $cpm_singlecellexperiment_object $cpm_matrix && scater-calculate-cpm.R -i $raw_singlecellexperiment_object -s $size_factors -o $cpm_singlecellexperiment_object -t $cpm_matrix
    echo "status = ${status}"
    echo "output = ${output}"
    
    [ "$status" -eq 0 ]
    [ -f  "$cpm_singlecellexperiment_object" ]
    [ -f  "$cpm_matrix" ]
}

# Normalise raw counts

@test "Normalisation of raw SingleCellExperiment counts" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$norm_singlecellexperiment_object" ]; then
        skip "$use_existing_outputs $norm_singlecellexperiment_object exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $norm_singlecellexperiment_object && scater-normalize.R -i $raw_singlecellexperiment_object -e $exprs_values -l $return_log -f $log_exprs_offset -c $centre_size_factors -r $return_norm_as_exprs -o $norm_singlecellexperiment_object
    echo "status = ${status}"
    echo "output = ${output}"
    
    [ "$status" -eq 0 ]
    [ -f  "$norm_singlecellexperiment_object" ]
}

# Generate sets of random genes to test the spike-in functionality

@test "Generate random genes - spikeins" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$spikein_gene_sets_file" ]; then
        skip "$use_existing_outputs $spikein_gene_sets_file exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $spikein_gene_sets_file*
    for i in `seq 1 $n_spikein_gene_sets`;
    do
        rm -f $spikein_gene_sets_file.$i && singlecellexperiment-get-random-genes.R -i $raw_singlecellexperiment_object -o $spikein_gene_sets_file.$i -n $n_spikein_genes -s $i && echo $spikein_gene_sets_file.$i >> $spikein_gene_sets_file
    done     
    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f  "$spikein_gene_sets_file" ]
}

# Calculate some QC metrics

@test "calculate QC metrics" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$qc_singlecellexperiment_object" ]; then
        skip "$use_existing_outputs $qc_singlecellexperiment_object exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $qc_singlecellexperiment_object && scater-calculate-qc-metrics.R -i $raw_singlecellexperiment_object -e $exprs_values -f $spikein_gene_sets_file -c $cell_controls -n $nmads -p $pct_feature_controls_threshold -o $qc_singlecellexperiment_object
    echo "status = ${status}"
    echo "output = ${output}"
    
    [ "$status" -eq 0 ]
    [ -f  "$qc_singlecellexperiment_object" ]
}

# Extract a set of values for a metric to use in outlier detection

@test "Extract metrics from a SingleCellExperiment" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$extracted_metrics_file" ]; then
        skip "$use_existing_outputs $extracted_metrics_file exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $extracted_metrics_file && scater-extract-qc-metric.R -i $qc_singlecellexperiment_object -m $outlier_test_metric -o $extracted_metrics_file
    echo "status = ${status}"
    echo "output = ${output}"
    
    [ "$status" -eq 0 ]
    [ -f  "$extracted_metrics_file" ]
}

# Do outlier detection

@test "Detect outliers" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$outliers_file" ]; then
        skip "$use_existing_outputs $outliers_file exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $outliers_file && scater-is-outlier.R -m $extracted_metrics_file -n $nmads -t $outlier_type -l $outlier_log -d outlier_min_diff -o $outliers_file
    echo "status = ${status}"
    echo "output = ${output}"
    
    [ "$status" -eq 0 ]
    [ -f  "$outliers_file" ]
}

