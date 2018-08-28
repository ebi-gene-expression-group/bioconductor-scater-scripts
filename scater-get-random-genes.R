#!/usr/bin/env Rscript 

# Given an R scater object, fetch a set of random genes. This needs to be random
# but reproducible so we can use it in predictable tests

cl <- commandArgs(trailingOnly = TRUE)

input_object_file <- cl[1]
output_text_file <- cl[2]
nspikeins <- as.numeric(cl[3])
ngenes <- as.numeric(cl[4])

if (! file.exists(input_object_file)){
    stop(paste('File', input_object_file, "does not exist"))
}

# Read SingleCellExperiment object
suppressPackageStartupMessages(require(scater))
SingleCellExperiment <- readRDS(input_object_file)

# Set the seed to make random genes reproducible
set.seed(42)
random_genes=list()
for (spikein in 1:nspikeins){
	random_genes[[spikein]] <- sample(rownames(SingleCellExperiment), ngenes)
    
    # Write to file
    writeLines(con=paste(output_text_file, spikein, sep="_"),random_genes[[spikein]])
    write.table(paste(output_text_file, spikein, sep="_"), file=output_text_file, append=TRUE, quote=FALSE, col.names=FALSE, row.names=FALSE)
}
