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
    help= "character string indicating which slot of the assayData from the 'SingleCellExperiment' object should be used to compute log-transformed expression values. Valid options are 'counts', 'tpm', 'cpm' and 'fpkm'. Defaults to the first available value of the options in the order shown."
  ),
  make_option(
    c("-f", "--feature-controls"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "comma-separated list of files with one feature per line. A named list is created containing one or more vectors to identify feature controls (for example, ERCC spike-in genes, mitochondrial genes, etc)"
  ),
  make_option(
    c("-c", "--cell-controls"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "a character vector of cell (sample) names, or a logical vector, or a numeric vector of indices used to identify cell controls (for example, blank wells or bulk controls)."
  ),
  make_option(
    c("-n", "--nmads"),
    action = "store",
    default = 5,
    type = 'numeric',
    help = "numeric scalar giving the number of median absolute deviations to be used to flag potentially problematic cells based on total counts (total number of counts for the cell, or library size) and total_features (number of features with non-zero expression). For total_features, cells are flagged for filtering only if total_features is 'nmads' below the median"
  ), 
  make_option(
    c("-p", "--pct-feature-controls-threshold"),
    action = "store",
    default = 80,
    type = 'numeric',
    help = "numeric scalar giving a threshold for percentage of expression values accounted for by feature controls. Used as to flag cells that may be filtered based on high percentage of expression from feature controls."
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store serialized R object of type 'SingleCellExperiment'."
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_object_file'))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Check feature_controls
if (! is.null(opt$feature_controls) && opt$feature_controls != 'NULL'){
  if (! file.exists(opt$feature_controls)){
    stop((paste('Supplied feature_controls file', opt$feature_controls, 'does not exist')))
  }else{
    feature_controls_files <- readLines(opt$feature_controls)
    feature_controls<-list()
    for (fileNames in feature_controls_files){
        feature_controls_files_path <- paste(dirname(opt$feature_controls),fileNames, sep="/")
        feature_controls[[fileNames]] <- as.numeric(read.csv(feature_controls_files_path, header=FALSE, stringsAsFactors = FALSE))
       } 
  }
}else{
  feature_controls <- NULL
}

# Check cell_controls
if (! is.null(opt$cell_controls) && opt$cell_controls != 'NULL'){
  if (! file.exists(opt$cell_controls)){
    stop((paste('Supplied feature_controls file', opt$cell_controls, 'does not exist')))
  }else{
    cell_controls <- readLines(opt$cell_controls)
  }
}else{
  cell_controls <- NULL
}

# Once arguments are satisfcatory, load Scater package
suppressPackageStartupMessages(require(scater))

# Input from serialized R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# calculate CPMs from raw count matrix
SingleCellExperiment  <- calculateQCMetrics(object = SingleCellExperiment, exprs_values = opt$exprs_values, feature_controls = feature_controls, cell_controls = cell_controls, nmads = opt$nmads, pct_feature_controls_threshold = opt$pct_feature_controls_threshold)

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)

