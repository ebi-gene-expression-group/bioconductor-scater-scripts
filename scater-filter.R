#!/usr/bin/env Rscript 

# Use metrics produced by calculateQCMetrics to filter out cells and features.
# See
# https://www.rdocumentation.org/packages/scater/versions/1.0.4/topics/calculateQCMetrics
# for available metrics.

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
    help = "A serialized SingleCellExperiment object file in RDS format."
  ),
  make_option(
    c("-s", "--subset-cell-variables"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Comma-separated parameters to subset on. Any variable available in the colData of the supplied object."
  ),
  make_option(
    c("-l", "--low-cell-thresholds"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Comma-separated low cutoffs for the parameters (default is -Inf)."
  ),
  make_option(
    c("-j", "--high-cell-thresholds"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Comma-separated high cutoffs for the parameters (default is Inf)."
  ),
  make_option(
    c("-c", "--cells-use"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "Comma-separated list of cell names to use as a subset. Alternatively, text file with one cell per line providing cell names to use as a subset."
  ),
  make_option(
    c("-t", "--subset-feature-variables"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Comma-separated parameters to subset on. Any variable available in the colData of the supplied object."
  ),
  make_option(
    c("-m", "--low-feature-thresholds"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Comma-separated low cutoffs for the parameters (default is -Inf)."
  ),
  make_option(
    c("-n", "--high-feature-thresholds"),
    action = "store",
    default = NA,
    type = 'character',
    help = "Comma-separated high cutoffs for the parameters (default is Inf)."
  ),
  make_option(
    c("-f", "--features--use"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "Comma-separated list of cell names to use as a subset. Alternatively, text file with one cell per line providing cell names to use as a subset."
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store serialized R object of type 'Seurat'.'"
  ),
  make_option(
    c("-u", "--output-cellselect-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store a matrix showing results of applying individual cell selection criteria."
  ),
  make_option(
    c("-v", "--output-featureselect-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store a matrix showing results of applying individual feature selection criteria."
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_object_file'))

# Check parameter values

if ( ! file.exists(opt$input_object_file)){
  stop((paste('File', opt$input_object_file, 'does not exist')))
}

# Now we're hapy with the arguments, load Scater and do the work

suppressPackageStartupMessages(require(scater))

# Input from serialized R object

SingleCellExperiment <- readRDS(opt$input_object_file)
print(paste("Starting with", ncol(SingleCellExperiment), "cells and", nrow(SingleCellExperiment), "features."))

## Filter to any specified cells/ feature first

col_data <- colData(SingleCellExperiment)
row_data <- rowData(SingleCellExperiment)

################################################################################
# Filter by cells
################################################################################

cell_select_matrix <- data.frame(row.names = colnames(SingleCellExperiment))

# Check the cells_use and select out cells by name

cells_use <- opt$cells_use
if (! is.null(cells_use)){
  if (file.exists(cells_use)){
    cells_use <- readLines(cells_use)
  }else{
    cells_use <- wsc_split_string(cells_use)
  }
  
  # Check for invalid cell spec
  
  invalid_cells <- which(! cells_use %in% colnames(SingleCellExperiment))
  
  if (length(invalid_cells) > 0){
    stop(paste("Cells supplied not present in object: ", paste(cells_use[invalid_cells], collapse = ', ')))
  }
  
  print(paste("Will select out", length(cells_use), "specified cells."))
  
  # Record which cells we've selected in this way
  
  cell_select_matrix$cells_use <- rownames(cell_select_matrix) %in% cells_use
}

# Are cell-wise criteria supplied?

if ( ! is.na(opt$subset_cell_variables) ){
  print("Attempting to filter based on supplied cell-wise criteria")
  
  subset_cell_variables <- wsc_split_string(opt$subset_cell_variables)
  
  # Check for invalid criteria
  
  invalid_cell_variables <- subset_cell_variables[ ! subset_cell_variables %in% colnames(col_data)  ]
  
  if ( length(invalid_cell_variables) > 0 ){
    stop(paste("Invalid variable(s) supplied in cell filtering criteria: ", paste(invalid_cell_variables, collapse=', ')))
  }
  
  # Parse numeric fields
  
  cell_lt <- wsc_parse_numeric(opt, 'low_cell_thresholds', -Inf, length(subset_cell_variables))
  cell_ht <- wsc_parse_numeric(opt, 'high_cell_thresholds', Inf, length(subset_cell_variables))
  
  # Check length 
  
  if ( length(cell_lt) < length(subset_cell_variables) || length(cell_ht) < length(subset_cell_variables) ){
    stop("One of low-cell-thresholds or high-cell-thresholds has length different to subset-cell-variables")
  }
  
  # Now filter by each criterion in turn
  
  # Generate a logical vector for each criterion and record in the selector matrix
  
  for (i in 1:length(subset_cell_variables)){
    cell_select_matrix[subset_cell_variables[i]] <- col_data[[subset_cell_variables[i]]] >=  cell_lt[i] & col_data[[subset_cell_variables[i]]] <= cell_ht[i]
  }
}

# Apply the cell selector matrix if it has any columns (i.e. if any criteria were supplied)

if (ncol(cell_select_matrix) > 0){

  cell_select <- apply(cell_select_matrix, 1, all)

  # If we still have cells, select them
  
  if ( length(cell_select) == 0 ){
    stop("Supplied criteria have excluded all cells")
  }else{
    cell_selected <- paste("Supplied criteria select", length(which(cell_select)), "of", ncol(SingleCellExperiment), "cells.")
    SingleCellExperiment <- SingleCellExperiment[, cell_select]
    print(cell_selected)
  }
}

################################################################################
# Filter by features
################################################################################

feature_select_matrix <- data.frame(row.names = rownames(SingleCellExperiment))

# Check the features_use and select out features by name

features_use <- opt$features_use
if (! is.null(features_use)){
  if (file.exists(features_use)){
    features_use <- readLines(features_use)
  }else{
    features_use <- wsc_split_string(features_use)
  }
  
  # Check for invalid cell spec
  
  invalid_features <- which(! features_use %in% rownames(SingleCellExperiment))
  
  if ( length(invalid_features) > 0){
    stop(paste("Features supplied not present in object: ", paste(features_use[invalid_features], collapse = ', ')))
  }
  
  print(paste("Selecting out", length(features_use), "specified features."))
  
  # Record which cells we've selected in this way
  
  feature_select_matrix$features_use <- rownames(feature_select_matrix) %in% features_use
}

# Are feature-wise criteria supplied?

if ( ! is.na(opt$subset_feature_variables) ){
  subset_feature_variables <- wsc_split_string(opt$subset_feature_variables)
  row_data <- rowData(SingleCellExperiment)
  
  invalid_feature_variables <- subset_feature_variables[ ! subset_feature_variables %in% colnames(row_data)  ]
  
  if ( length(invalid_feature_variables) > 0 ){
    stop(paste("Invalid variable(s) supplied in feature filtering criteria: ", paste(invalid_feature_variables, collapse=', ')))
  }
  
  # Parse numeric fields
  
  feature_lt <- wsc_parse_numeric(opt, 'low_feature_thresholds', -Inf, length(subset_feature_variables))
  feature_ht <- wsc_parse_numeric(opt, 'high_feature_thresholds', Inf, length(subset_feature_variables))
  
  # Check length 
  
  if ( length(feature_lt) < length(subset_feature_variables) || length(feature_ht) < length(subset_feature_variables) ){
    stop("One of low-feature-thresholds or high-feature-thresholds has length different to subset-feature-variables")
  }
  
  # Now filter by each criterion in turn
  
  # Generate a logical vector for each criterion and record in the selector matrix
  
  for (i in 1:length(subset_feature_variables)){
    feature_select_matrix[subset_feature_variables[i]] <- row_data[[subset_feature_variables[i]]] >= feature_lt[i] & row_data[[subset_feature_variables[i]]] <= feature_ht[i]
  }
}

# Apply the cell selector matrix if it has any columns (i.e. if any criteria were supplied)

if (ncol(feature_select_matrix) > 0){
  
  feature_select <- apply(feature_select_matrix, 1, all)
  
  # If we still have cells, select them
  
  if ( length(feature_select) == 0 ){
    stop("Supplied criteria have excluded all features")
  }else{
    feature_selected <- paste("Supplied criteria select", length(which(feature_select)), "of", nrow(SingleCellExperiment), "features.")
    SingleCellExperiment <- SingleCellExperiment[feature_select, ]
    print(feature_selected)
  }
}

# Print an object summary

cat(c(
  '\n# Filtered object summary', 
  capture.output(print(SingleCellExperiment)), 
  '\n# Metadata sample', 
  capture.output(head(colData(SingleCellExperiment)))
), 
sep = '\n')

################################################################################
# Output results
################################################################################

# If specified, output the cell selection matrix

if ( !is.na(opt$output_cellselect_file) ){
  write.csv(cell_select_matrix, file=opt$output_cellselect_file, quote = FALSE)
}

# If specified, output the feature selection matrix

if ( !is.na(opt$output_featureselect_file) ){
  write.csv(feature_select_matrix, file=opt$output_featureselect_file, quote = FALSE)
}

# Output to a serialized R object

saveRDS(SingleCellExperiment, file = opt$output_object_file)
