# Wrapper scripts for components of the Scater toolchain

In order to wrap Scater's internal workflow in any given workflow language, it's important to have scripts to call each of those steps. These scripts are being written here, and will improve in completeness as time progresses. 

## Install

The recommended method for script installation is via a Bioconda recipe called bioconda-scater-scripts. 

With the [Bioconda channels](https://bioconda.github.io/#set-up-channels) configured the latest release version of the package can be installed via the regular conda install command:

```
conda install bioconductor-scater-scripts
```

## Test installation

There is a test script included:

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

### Matrix filtering

```
scater-filter.R -i <input SingleCellExperiment in .rds format> -s <cell QC metric 1>,<cell QC metric 2>,... -l <Lower limit to metric 12,<lower limit for metric 2> -t <feature QC metric 1>,... -m <feature QC metric lower limit 1> -o <filtered SingleCellExperiment in .rds format> -u <output matrix showing filtered cells by metric> -v <output matrix showing filtered features by metric>
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

### scater-extract-qc-metric.R

This script extracts a single column of QC metric data, for example for use with the outlier detection script described above:

```
scater-extract-qc-metric.R -i <input SingleCellExperiment in .rds format> -o <output file> -m <metric name>
```

Output is a two-column csv file with `<cell name>,<metric value>` per line.

