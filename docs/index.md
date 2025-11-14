# Data Collection Framework

An R package to establish and work within a data collection framework.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("dissc-yale/dcf")
```

## Get Started

### Projects

A data collection project ultimately consists of `source` and `bundle`
projects:

``` md
- collection_project
  - data
    - source_a
    - bundle_a
```

Start by initializing the overall project:

``` r
dcf_init("collection_project")
```

Then add a `source` project, which will ingest data from a single
source, and produce a standardized data file:

``` r
dcf_add_source("source_a", "collection_project")
```

And add a `bundle` project, which will use the standardized `source`
files to produce a data product:

``` r
dcf_add_bundle("bundle_a", "collection_project")
```

### Processing

Once the `source` and `bundle` scripts have been written, the project
can be built:

``` r
dcf_build("collection_project")
```

This runs `dcf_process` on each sub-project, and `dcf_check_source` on
each source, then writes a report to
`collection_project/report.json.gz`, which includes processing details
(like logs and timing) and metadata from the standardized data files.
