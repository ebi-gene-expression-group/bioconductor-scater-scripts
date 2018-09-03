#!/usr/bin/env Rscript 

# Given an R scater object, fetch a set of random genes. This needs to be random
# but reproducible so we can use it in predictable tests

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
    c("-o", "--output-text-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which a text file of randomly selected genes (one per line) should be stored."
  ), 
  make_option(
    c("-n", "--n_features"),
    action = "store",
    default = NA,
    type = 'integer',
    help = "Number of features to randomly sample."
  ), 
  make_option(
    c("-s", "--seed"),
    action = "store",
    default = 42,
    type = 'integer',
    help = "Number of features to randomly sample."
  )
)

# Parse the arguments
opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'output_text_file', 'n_features'))

if (! file.exists(opt$input_object_file)){
    stop(paste('File', opt$input_object_file, "does not exist"))
}

# Read SingleCellExperiment object
suppressPackageStartupMessages(require(scater))
SingleCellExperiment <- readRDS(opt$input_object_file)

# Set the seed to make random genes reproducible
set.seed(opt$seed)

# Select random genes
random_genes <- sample(rownames(SingleCellExperiment), opt$n_features)

# Write to file

writeLines(con = opt$output_text_file, random_genes)
