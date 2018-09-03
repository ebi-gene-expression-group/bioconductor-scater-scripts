# Wrapper scripts for components of the Scater toolchain

In order to wrap Scater's internal workflow in any given workflow language, it's important to have scripts to call each of those steps. These scripts are being written here, and will improve in completeness as time progresses. 

## Install

The recommended method for script installation is via a Bioconda recipe called bioconda-scater-scripts. 

With the [Bioconda channels](https://bioconda.github.io/#set-up-channels) configured the latest release version of the package can be installed via the regular conda install command:

```
conda install bioconductor-scater-scripts
```

## Test installation

There is a test script included which can be used to undertake a dummy run through all the commands below:

```
bioconductor-scater-scripts-post-install-tests.sh
```

This downloads [a well-known test 10X dataset]('https://s3-us-west-2.amazonaws.com/10x.files/samples/cell/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz) and executes all of the scripts described below.

## Commands

Currently wrapped Scater functions are described below. Each script has usage insructions available via --help, consult function documentation in Scater for further details.

### read10XResults()

```
scater-read-10x-results.R -d <10X data directory> -o <output SingleCellExperiment in .rds format>
```    

### calculateCPM() 

```
scater-calculate-cpm.R -i <input SingleCellExperiment in .rds format> -s <size_factors> -o <output SingleCellExperiment in .rds format> -t <output matrix in .csv format>
```

### normalize()

```
scater-normalize.R -i <input SingleCellExperiment in .rds format> -e <exprs_values> -l <return_log> -f <log_exprs_offset> -c <centre_size_factors> -r <return_norm_as_exprs> -o <output SingleCellExperiment in .rds format>
```

### calculateQCMetrics()

```
scater-calculate-qc-metrics.R -i <input SingleCellExperiment in .rds format> -e <exprs_values> -f <feature_controls> -c <cell_controls> -n <nmads> -p <pct_feature_controls_threshold> -o <output SingleCellExperiment in .rds format>
``` 

### isOutlier()

```
scater-is-outlier.R -m <metrics file> -n <nmads> -t <type> -l <log> -d <min.diff> -o <outliers file>
```

## Accessory scripts

In addition to the function wrappers above the following accessory scripts are provided:

### scater-get-random-genes.R 

This script is used to generate random subsets of feature names from a SingleCellExperiment object. It is called like:

```
scater-get-random-genes.R -i <input SingleCellExperiment in .rds format> -o <output file> -n <numbe of features> -s <random seed>
```

Output is a text file with one feature per line.

### scater-extract-qc-metric.R

This script extracts a single column of QC metric data, for example for use with the outlier detection script described above:

```
scater-extract-qc-metric.R -i <input SingleCellExperiment in .rds format> -o <output file> -m <metric name>
```

Output is a two-column csv file with `<cell name>,<metric value>` per line.

