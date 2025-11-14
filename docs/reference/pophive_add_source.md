# Adds a source project structure

Establishes a new data source project, used to collect and prepare data
from a new source.

## Usage

``` r
pophive_add_source(name, base_dir = "data", open_after = interactive())
```

## Arguments

- name:

  Name of the source.

- base_dir:

  Path to the directory containing sources.

- open_after:

  Logical; if `FALSE`, will not open the project.

## Value

Nothing; creates default files and directories.

## Project

Within a source project, there are two files to edits:

- **`ingest.R`**: This is the primary script, which is automatically
  rerun. It should store raw data and resources in `raw/` where
  possible, then use what's in `raw/` to produce standard-format files
  in `standard/`. This file is sourced from its location during
  processing, so any system paths must be relative to itself.

- **`measure_info.json`**: This is where you can record information
  about the variables included in the standardized data files. See
  [`data_measure_info`](https://miserman.github.io/community/reference/data_measure_info.html).

## Examples

``` r
data_source_dir <- tempdir()
pophive_add_source("source_name", data_source_dir)
list.files(paste0(data_source_dir, "/source_name"))
#> [1] "README.md"         "ingest.R"          "measure_info.json"
#> [4] "project.Rproj"     "raw"               "standard"         
```
