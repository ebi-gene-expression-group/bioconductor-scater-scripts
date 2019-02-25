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
    help = "File name containing serialized SingleCellExperiment object or count matrix."
  ),
  make_option(
    c("-e", "--exprs-values"),
    action = "store",
    default = 'counts',
    type = 'character',
    help = "A string specifying the assay of ‘object’ containing the count matrix, if ‘object’ is a SingleCellExperiment."
  ),
  make_option(
    c("-s", "--size-factors"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = "A logical scalar indicating whether size factors in object should be used to compute effective library sizes. If not, all size factors are deleted and librarysize-based factors are used instead (seelibrarySizeFactors). Alternatively, a numeric vector containing a size factor for each cell, which is used in place ofsizeFactor(object)."
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store serialized R object of type 'Scater'.'"
  ),
  make_option(
    c("-t", "--output-text-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store CPM values."
  )
)

# Parse the arguments
opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'size_factors', 'output_object_file'))

# Check parameter values defined

if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Once arguments are satifcatory, load Scater package
suppressPackageStartupMessages(require(scater))

# Input from serialized R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# calculate CPMs from raw count matrix
cpm(SingleCellExperiment) <- calculateCPM(object = SingleCellExperiment, use_size_factors = opt$size_factors, exprs_values = opt$exprs_values)

# Print introspective information
cat(capture.output(SingleCellExperiment), sep='\n')

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)

# Output cpm matrix to a simple file
write.csv(as.matrix(cpm(SingleCellExperiment)), file = opt$output_text_file, row.names = TRUE)
