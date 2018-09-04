#!/usr/bin/env Rscript 

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))

# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# parse options
option_list = list(
  make_option(
    c("-m", "--metric-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File with one value per line used to define a numeric or integer vector of values for a metric."
  ),
  make_option(
    c("-n", "--nmads"),
    action = "store",
    default = 5,
    type = 'numeric',
    help = "scalar, number of median-absolute-deviations away from median required for a value to be called an outlier."
  ), 
  make_option(
    c("-t", "--type"),
    action = "store",
    default = "both",
    type = 'character',
    help = 'character scalar, choice indicate whether outliers should be looked for at both tails (default: "both") or only at the lower end ("lower") or the higher end ("higher").'
  ), 
  make_option(
    c("-l", "--log"),
    action = "store",
    default = FALSE,
    type = 'logical',
    help = 'logical, should the values of the metric be transformed to the log10 scale before computing median-absolute-deviation for outlier detection?'
  ), 
  make_option(
    c("-d", "--min-diff"),
    action = "store",
    default = 5,
    type = 'numeric',
    help = "numeric scalar indicating the minimum difference from the median to consider as an outlier. The outlier threshold is defined from the larger of nmads MADs and min.diff, to avoid calling many outliers when the MAD is very small. If NA, it is ignored."
  ), 
  make_option(
    c("-o", "--output-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = "File name in which to store the output vector of outliers (one value per line)"
  )
)

opt <- wsc_parse_args(option_list, mandatory = c('metric_file', 'output_file'))

# Check parameter values defined
if ( ! file.exists(opt$metric_file)){
  stop((paste('File', opt$metric_file, 'does not exist')))
}

# Once arguments are satisfactory, load Scater package
suppressPackageStartupMessages(require(scater))

metric_vector <- wsc_read_vector(opt$metric_file)

# Write those elements to file that qualify as outliers
wsc_write_vector(metric_vector[isOutlier(metric_vector)], opt$output_file)