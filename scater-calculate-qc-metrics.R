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
    help = "singleCellExperiment object containing expression values and experimental information. Must have been appropriately prepared."
  ),
  make_option(
    c("-e", "--exprs-values"),
    action = "store",
    default = 'counts',
    type = 'character',
    help= "A string indicating which ‘assays’ in the ‘object’ should be used to define expression."
  ),
  make_option(
    c("-f", "--feature-controls"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "file containing a list of the control files with one file per line. Each control file should have one feature (e.g. gene) per line. A named list is created (names derived from control file names) containing one or more vectors to identify feature controls (for example, ERCC spike-in genes, mitochondrial genes, etc)"
  ),
  make_option(
    c("-c", "--cell-controls"),
    action = "store",
    default = NULL,
    type = 'character',
    help = "file (one cell per line) to be used to derive a vector of cell (sample) names used to identify cell controls (for example, blank wells or bulk controls)."
  ),
  make_option(
    c("-p", "--percent-top"),
    action = "store",
    default = '50,100,200,500',
    type = 'character',
    help= "Comma-separated list of integers. Each element is treated as a number of top genes to compute the percentage of library size occupied by the most highly expressed genes in each cell." 
  ),
  make_option(
    c("-d", "--detection-limit"),
    action = "store",
    default = 0,
    type = 'numeric',
    help= "A numeric scalar to be passed to 'nexprs', specifying the lower detection limit for expression."
  ),
  make_option(
    c("-s", "--use-spikes"),
    action = "store",
    default = TRUE,
    type = 'logical',
    help= "A logical scalar indicating whether existing spike-in sets in ‘object’ should be automatically added to 'feature_controls', see '?isSpike'."
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

# Check feature_controls
if (! is.null(opt$feature_controls) && opt$feature_controls != 'NULL'){
    feature_control_files <- readLines(opt$feature_controls)
    
    # Check the files one-by-one
    for (fileName in feature_control_files){
        if (! file.exists(fileName)){
          stop((paste('Supplied feature_controls file', fileName, 'does not exist')))
        }
    }
    
    # Read the list of files into a list of vectors
    feature_controls <- lapply(feature_control_files, readLines)
    
    #Give the list names derived from the individual file names
    names(feature_controls) <- basename(feature_control_files)
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

# Parse out percent_top

percent_top <- wsc_parse_numeric(opt, 'percent_top')

# Once arguments are satisfactory, load Scater package
suppressPackageStartupMessages(require(scater))

# Input from serialized R object
SingleCellExperiment <- readRDS(opt$input_object_file)

# calculate CPMs from raw count matrix
SingleCellExperiment  <- calculateQCMetrics(object = SingleCellExperiment, exprs_values = opt$exprs_values, feature_controls = feature_controls, cell_controls = cell_controls, percent_top = percent_top, detection_limit = opt$detection_limit, use_spikes = opt$use_spikes)

# Output to a serialized R object
saveRDS(SingleCellExperiment, file = opt$output_object_file)

