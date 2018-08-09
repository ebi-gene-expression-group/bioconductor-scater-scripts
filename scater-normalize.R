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
    help= "character string indicating which slot of the assayData from the ‘SingleCellExperiment’ object should be used to compute log-transformed expression values. Valid options are ‘'counts'’, ‘'tpm'’, ‘'cpm'’ and ‘'fpkm'’. Defaults to the first available value of the options in the order shown."
  ),
  make_option(
    c("-l", "--return-log"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = "logical(1), should normalized values be returned on the log scale? Default is ‘TRUE’. If ‘TRUE’, output is stored as 'logcounts' in the returned object; if ‘FALSE’ output is stored as 'normcounts'."
  ),
  make_option(
    c("-f", "--log-exprs-offset"),
    action = "store",
    default = NULL,
    type = 'numeric',
    help = "scalar numeric value giving the offset to add when taking log2 of normalised values to return as expression values. If NULL, value is taken from metadata(object)$log.exprs.offset if defined, otherwise 1."
  ),

  make_option(
    c("-c", "--centre-size-factors"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = "logical, should size factors centred at unity be stored in the returned object if ‘exprs_values='counts'? Defaults to TRUE. Regardless, centred size factors will always be used to calculate 'exprs' from count data. This argument is ignored for other ‘exprs_values’, where no size factors are used/modified."
  ),
  make_option(
    c("-r", "--return-norm-as-exprs"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help = "logical, should the normalised expression values be returned to the 'exprs' slot of the object? Default is TRUE. If FALSE, values in the 'exprs' slot will be left untouched. Regardless, normalised expression values will be returned in the 'norm_exprs(object)'' slot.'."
  ),
  make_option(
    c("-o", "--output-object-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store serialized R object of type 'Scater'.'"
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('input_object_file', 'exprs_values','return_log','log_exprs_offset','centre_size_factors','return_norm_as_exprs','output_object_file'))

# Check parameter values defined
if ( ! file.exists(opt$input_object_file)){
  stop((paste('File object or matrix', opt$input_object_file, 'does not exist')))
}


# Once arguments are satifcatory, load Scater package
suppressPackageStartupMessages(require(scater))


# Input from serialized R object
SingleCellExperiment <- readRDS(opt$input_object_file)


# calculate CPMs from raw count matrix
SingleCellExperiment  <- normalize(object = SingleCellExperiment, exprs_values = opt$exprs_values, return_log = opt$return_log, log_exprs_offset =opt$log_exprs_offset, centre_size_factors = opt$centre_size_factors, return_norm_as_exprs = opt$return_norm_as_exprs)


# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)

