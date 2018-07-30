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
    help = "File name in which a serialized R SingleCellExperiment object where object matrix found  "
  ),
  make_option(
    c("-e", "--exprs-values"),
    action = "store",
    default = NA,
    type = 'character',
    help = "A string specifying the assay of object containing the count matrix, if object is a SingleCellExperiment."
  ),
  make_option(
    c("-s", "--size-factors"),
    action = "store",
    default = NA,
    type = 'logical',
    help = "A  logical  scalar  indicating  whether  size  factors  in object should  be  used  to compute effective library sizes.  If not, all size factors are deleted and librarysize-based factors are used instead (seelibrarySizeFactors.  Alternatively, anumeric vector containing a size factor for each cell, which is used in place ofsizeFactor(object)."
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

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'exprs_values', 'size_factors', 'output_object_file', 'output_text_file'))

# Check parameter values defined

if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}

if ( opt$exprs_values != "counts"){
  stop((paste('expression values', opt$exprs_values, 'needs to be counts')))
}

# Once arguments are satifcatory, load Scater package

suppressPackageStartupMessages(require(scater))


# Input from serialized R object

scater_object <- readRDS(opt$input_object_file)


# calculate CPMs from raw count matrix

cpm(scater_object) <- calculateCPM(scater_object, exprs_values = opt$exprs_values, use_size_factors = opt$size_factors)


# Output to a serialized R object

saveRDS(scater_object, file = opt$output_object_file)


# Output cpm matrix to a simple file

write.csv(as.matrix(cpm(scater_object)), file = opt$output_text_file, row.names = TRUE)



