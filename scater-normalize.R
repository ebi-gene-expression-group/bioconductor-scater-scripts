#!/usr/bin/env Rscript 

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
    help = "File name in which a serialized R SingleCellExperiment object where object matrix found"
  ),
  make_option(
    c("-e", "--exprs-values"),
    action = "store",
    default = 'counts',
    type = 'character',
    help= "String indicating which assay contains the count data that should be used to compute log-transformed expression values."
  ),
  make_option(
    c("-l", "--return-log"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = "Logical scalar, should normalized values be returned on the log2 scale?"
  ),
  make_option(
    c("-f", "--log-exprs-offset"),
    action = "store",
    default = 1,
    type = 'numeric',
    help = "Numeric scalar specifying the offset to add when log-transforming expression values. If ‘NULL’, value is taken from ‘metadata(object)$log.exprs.offset’ if defined, otherwise 1."
  ),
  make_option(
    c("-c", "--centre-size-factors"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = " Logical scalar indicating whether size fators should be centred."
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store serialized R object of type 'SingleCellExperiment'.'"
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_object_file'))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Once arguments are satisfcatory, load Scater package
suppressPackageStartupMessages(require(scater))

# Input from serialized R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# calculate CPMs from raw count matrix
SingleCellExperiment  <- normalize(object = SingleCellExperiment, exprs_values = opt$exprs_values, return_log = opt$return_log, log_exprs_offset = opt$log_exprs_offset, centre_size_factors = opt$centre_size_factors)

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)

