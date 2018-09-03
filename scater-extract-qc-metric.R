#!/usr/bin/env Rscript 

# Extract the QC metric stored in a SingleCellExperiment object, e.g. for use in
# outlier detection.

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))

# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# parse options
option_list = list(
  make_option(
    c("-i", "--input-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "singleCellExperiment object containing expression values and experimental information. Must have been appropriately prepared."
  ),
  make_option(
    c("-m", "--metric"),
    action = "store",
    default = "both",
    type = 'character',
    help = 'Metric name.'
  ),
  make_option(
    c("-o", "--output-file"),
    action = "store",
    default = "both",
    type = 'character',
    help = 'Output file name, will be comma-separated cell,value.'
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_file'))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Once arguments are satisfcatory, load Scater package
suppressPackageStartupMessages(require(scater))

# Read R object
SingleCellExperiment <- readRDS(opt$input_object_file)

if ( ! opt$metric %in% colnames(colData(SingleCellExperiment)) ){
  stop((paste0('Metric ', opt$metric, ' not present in input object from ', opt$input_object_file,'.')))
}

# Subset the metrics table and write to file
wsc_write_vector(structure(colData(SingleCellExperiment)[, opt$metric], names = rownames(colData(SingleCellExperiment))), filename = opt$output_file)
