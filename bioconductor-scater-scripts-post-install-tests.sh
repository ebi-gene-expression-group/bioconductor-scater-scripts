#!/usr/bin/env bash

# This is a test script designed to test that everything works in the various
# accessory scripts in this package. Parameters used have absolutely NO
# relation to best practice and this should not be taken as a sensible
# parameterisation for a workflow.

function usage {
    echo "usage: r-seurat-workflow-post-install-tests.sh [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] && [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

test_data_url='https://s3-us-west-2.amazonaws.com/10x.files/samples/cell/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz'
test_working_dir=`pwd`/'post_install_tests'
test_data_archive=$test_working_dir/`basename $test_data_url`

# Clean up if specified

if [ "$action" = 'clean' ]; then
    echo "Cleaning up $test_working_dir ..."
    rm -rf $test_working_dir
    exit 0
elif [ "$action" != 'test' ]; then
    echo "Invalid action '$action' supplied"
    exit 1
fi 

# Initialise directories

output_dir=$test_working_dir/outputs
data_dir=$test_working_dir/test_data

mkdir -p $test_working_dir
mkdir -p $output_dir
mkdir -p $data_dir

cd $test_working_dir

################################################################################
# Fetch test data 
################################################################################

if [ ! -e "$test_data_archive" ]; then
    wget $test_data_url
fi

################################################################################
# Accessory functions
################################################################################

function report_status() {
    script=$1
    status=$2

    if [ $status -ne 0 ]; then
        echo "FAIL: $script"
        exit 1
    else
        echo "SUCCESS: $script"
    fi
}

# Run a command, checking the primary output depending on the value of
# 'use_existing_outputs'

run_command() {
    command=$1
    test_output=$2

    echo "$command"
    command_name=`echo "$command" | awk '{print $1}'`

    if [ -e "$test_output" ] && [ "$use_existing_outputs" == "true" ]; then
        echo "Using cached output for $command_name"
    else
        eval $command
        report_status $command_name $?
    fi
}

################################################################################
# List tool outputs/ inputs
################################################################################

raw_singlecellexperiment="$output_dir/raw_sce.rds"

## Test parameters- would form config file in real workflow. DO NOT use these
## as default values without being sure what they mean.


################################################################################
# Test individual scripts
################################################################################

# Extract the test data

echo "Extracting test data from archive"
run_command "tar -xvzf $test_data_archive --strip-components 2 -C test_data" $raw_matrix

# Run read-10x.R

run_command "scater-read-10x-results.R -d test_data -o $raw_singlecellexperiment" $raw_matrix_object

################################################################################
# Finish up
################################################################################

echo "All tests passed"
exit 0
