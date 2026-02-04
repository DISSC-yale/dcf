# Adds a Source Project

Establishes a new data source project, used to collect and prepare data
from a new source.

## Usage

``` r
dcf_add_source(
  name,
  project_dir = ".",
  open_after = interactive(),
  use_git = TRUE,
  use_workflow = FALSE
)
```

## Arguments

- name:

  Name of the source.

- project_dir:

  Path to the Data Collection Framework project.

- open_after:

  Logical; if `FALSE`, will not open the project.

- use_git:

  Logical; if `TRUE`, will initialize a git repository.

- use_workflow:

  Logical; if `TRUE`, will add a GitHub Actions workflow.

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
  [`dcf_measure_info`](https://DISSC-yale.github.io/dcf/reference/dcf_measure_info.md).

## Examples

``` r
project_dir <- paste0(tempdir(), "/temp_project")
dcf_init("temp_project", dirname(project_dir))
dcf_add_source("source_name", project_dir)
list.files(paste0(project_dir, "/data/source_name"))
#> [1] "README.md"         "ingest.R"          "measure_info.json"
#> [4] "process.json"      "project.Rproj"     "raw"              
#> [7] "standard"         
```
