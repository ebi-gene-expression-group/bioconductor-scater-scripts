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
    c("-t", "--ntop"),
    action = "store",
    default = 500,
    type = 'numeric',
    help = 'Numeric scalar specifying the number of most variable features to use for PCA.'
  ),
  make_option(
    c("-f", "--feature-set"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "file (one cell per line) to be used to derive a character vector of row names, indicating a set of features to use for t-SNE. This will override any ntop argument if specified."
  ),
  make_option(
    c("-e", "--exprs-values"),
    action = "store",
    default = 'logcounts',
    type = 'character',
    help = "Integer scalar or string indicating which assay of object should be used to obtain the expression values for the calculations."
  ),
  make_option(
    c("-s", "--scale-features"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = 'Logical scalar, should the expression values be standardised so that each feature has unit variance?'
  ),
  make_option(
    c("-d", "--use-dimred"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'String or integer scalar specifying the entry of reducedDims(object) to use as input to Rtsne. Default is to not use existing reduced dimension results.'
  ),
  make_option(
    c("-m", "--n-dimred"),
    action = "store",
    default = NULL,
    type = 'integer',
    help = 'Integer scalar, number of dimensions of the reduced dimension slot to use when use_dimred is supplied. Defaults to all available dimensions.'
  ),
  make_option(
    c("-p", "--perplexity"),
    action = "store",
    default = NULL,
    type = 'numeric',
    help = 'Numeric scalar defining the perplexity parameter, see ?Rtsne for more details.'
  ),
  make_option(
    c("-q", "--pca"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = 'Logical scalar passed to Rtsne, indicating whether an initial PCA step should be performed. This is ignored if use_dimred is specified.'
  ),
  make_option(
    c("-g", "--initial-dims"),
    action = "store",
    default = 50,
    type = 'numeric',
    help = 'Integer scalar passed to Rtsne, specifying the number of principal components to be retained if pca=TRUE.'
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

# Deal with perplexity

perplexity <- opt$perplexity

if ( is.null(opt$perplexity) ){
  perplexity = min(50, floor(ncol(SingleCellExperiment)/5))
}

# Make the function call 

SingleCellExperiment <- runTSNE( SingleCellExperiment, ncomponents = opt$ncomponents, ntop = opt$ntop, feature_set = feature_set, exprs_values = opt$exprs_values, scale_features = opt$scale_features, use_dimred = opt$use_dimred, n_dimred = opt$n_dimred, perplexity = perplexity, pca = opt$pca, initial_dims = opt$initial_dims  )

# Print introspective information
cat(capture.output(SingleCellExperiment), sep='\n')

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)

