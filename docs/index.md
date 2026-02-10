# Data Collection Framework

An R package to establish and work within a data collection framework.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("dissc-yale/dcf")
```

## Get Started

### Projects

#### Full Projects

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

#### Standalone projects

`source` and `bundle` projects can also exist on their own, outside of a
full project.

This might be useful if a `source` project is particularly big, takes a
while to run, or has some special processes you want to build up outside
of a full project.

Standalone `bundle` projects might be useful as a way to make more
independent and/or varied outputs from a single full collection project.

The `dcf_add_source` and `dcf_add_bundle` functions can be used to
initialize these standalone projects, and the `dcf_build`,
`dcf_process`, and `dcf_check` functions work the same on them.

### Processing

Once the `source` and `bundle` scripts have been written, the project
can be built:

``` r
dcf_build("collection_project")
```

This runs `dcf_process` and `dcf_check` on each sub-project, then writes
a report to `collection_project/report.json.gz`, which includes
processing details (like logs and timing) and metadata from the
standardized data files.
