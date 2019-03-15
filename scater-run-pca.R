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
    c("-n", "--ncomponents"),
    action = "store",
    default = 2,
    type = 'numeric',
    help = 'Numeric scalar indicating the number of principal components to obtain.'
  ),
  make_option(
    c("-m", "--method"),
    action = "store",
    default = "prcomp",
    type = 'character',
    help = 'String specifying how the PCA should be performed. (default: prcomp)'
  ),
  make_option(
    c("-t", "--ntop"),
    action = "store",
    default = 500,
    type = 'numeric',
    help = 'Numeric scalar specifying the number of most variable features to use for PCA.'
  ),
  make_option(
    c("-e", "--exprs-values"),
    action = "store",
    default = 'logcounts',
    type = 'character',
    help = "Integer scalar or string indicating which assay of object should be used to obtain the expression values for the calculations."
  ),
  make_option(
    c("-f", "--feature-set"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "file (one cell per line) to be used to derive a character vector of row names indicating a set of features to use for PCA. This will override any ntop argument if specified."
  ),
  make_option(
    c("-s", "--scale-features"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = 'Logical scalar, should the expression values be standardised so that each feature has unit variance? This will also remove features with standard deviations below 1e-8.'
  ),
  make_option(
    c("-c", "--use-coldata"),
    action = "store",
    default = FALSE,
    type = 'logical',
    help = 'Logical scalar specifying whether the column data should be used instead of expression values to perform PCA.'
  ),
  make_option(
    c("-l", "--selected-variables"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'Comma-separated list of strings indicating which variables in colData(object) to use for PCA when use_coldata=TRUE.'
  ),
  make_option(
    c("-d", "--detect-outliers"),
    action = "store",
    default = FALSE,
    type = 'logical',
    help = 'Logical scalar, should outliers be detected based on PCA coordinates generated from column-level metadata?'
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "file name in which to store serialized R object of type 'SingleCellExperiment'."
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_object_file'))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Once arguments are satisfcatory, load Scater package
suppressPackageStartupMessages(require(scater))

# Read R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# Read the supplied feature set where provided

feature_set <- opt$feature_set

if ( ! is.null(opt$feature_set)){
  if ( file.exists(opt$feature_set) ){
    feature_set <- readLines(opt$feature_set)
  }else{
    stop(paste('Specified features file', opt$feature_set, 'does not exist.'))
  }
}

# Respond to use_coldata

selected_variables <- opt$selected_variables

if ( opt$use_coldata ){
  if ( ! is.null(opt$selected_variables) ){
    selected_variables <- wsc_split_string( opt$selected_variables )
  }else{
    stop("You set the use_coldata argument without providing column names to use.")
  }
}

# Make the function call 

SingleCellExperiment <- runPCA( SingleCellExperiment, ncomponents = opt$ncomponents, method = opt$method, ntop = opt$ntop, exprs_values = opt$exprs_values, feature_set = feature_set, scale_features = opt$scale_features, selected_variables = opt$selected_variables, detect_outliers = opt$detect_outliers  )

# Print introspective information
cat(capture.output(SingleCellExperiment), sep='\n')

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)

