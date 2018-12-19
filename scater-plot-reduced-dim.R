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
    c("-d", "--use-dimred"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'A string or integer scalar indicating the reduced dimension result in reducedDims(object) to plot.'
  ),
  make_option(
    c("-n", "--ncomponents"),
    action = "store",
    default = '2',
    type = 'character',
    help = 'A numeric scalar indicating the number of dimensions to plot, starting from the first dimension. Alternatively, a comma-separated specifying the dimensions to be plotted.'
  ),
  make_option(
    c("-p", "--percent-var"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'A comma-separated string giving the proportion of variance in expression explained by each reduced dimension. Only expected to be used in PCA settings, e.g., in the plotPCA function.'
  ),
  make_option(
    c("-c", "--colour-by"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'Specification of a column metadata field or a feature to colour by.'
  ),
  make_option(
    c("-s", "--shape-by"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'Specification of a column metadata field or a feature to shape by.'
  ),
  make_option(
    c("-z", "--size-by"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'Specification of a column metadata field or a feature to shape by.'
  ),
  make_option(
    c("-e", "--by_exprs-values"),
    action = "store",
    default = 'logcounts',
    type = 'character',
    help = "A string or integer scalar specifying which assay to obtain expression values from, for use in point aesthetics."
  ),
  make_option(
    c("-b", "--by_show_single"),
    action = "store",
    default = FALSE,
    type = 'logical',
    help = "Logical scalar specifying whether single-level factors should be used for point aesthetics."
  ),
  make_option(
    c("-w", "--png-width"),
    action = "store",
    default = 1000,
    type = 'integer',
    help = "Width of png (px)."
  ),
  make_option(
    c("-j", "--png-height"),
    action = "store",
    default = 1000,
    type = 'integer',
    help = "Height of png file (px)."
  ),
  make_option(
    c("-o", "--output-image-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to save the PCA image"
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_image_file'))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

# Once arguments are satisfcatory, load Scater package
suppressPackageStartupMessages(require(scater))

# Read R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# Make the plot and write to file
png(filename = opt$output_image_file, width = opt$png_width, height = opt$png_height)
plotReducedDim(SingleCellExperiment, use_dimred = opt$use_dimred, ncomponents = wsc_parse_numeric(opt, 'ncomponents'), percentVar = opt$percent_var, colour_by = opt$colour_by, shape_by = opt$shape_by, size_by = opt$size_by, by_exprs_values = opt$by_exprs_values, by_show_single = opt$by_show_single )
dev.off()