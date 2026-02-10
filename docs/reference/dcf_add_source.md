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

## Project Definition

The **`process.json`** file defines the project with some initial
attributes:

- `type` Always `source` to define this as a source project.

- `name` Name of the project.

- `scripts` List of script definitions.

- `checked` When the project was last checked with
  [`dcf_check`](https://DISSC-yale.github.io/dcf/reference/dcf_check.md).

- `check_results` Results of the last check.

- `standalone` Logical; `TRUE` if the source project does not exist
  within a broader collection project.

- `standard_state` State of the `standard` directory: A list with names
  as the file paths, relative to the overall project root, and values as
  the MD5 hash of those files.

- `raw_state` State of the `raw` directory, if set within a script.

- `vintages` A list with names as names of files found in the `standard`
  directory, and values as dates (of arbitrary format). This is a way to
  provide a date separate from the files dates (e.g., if you have some
  other source for when the data were actually collected), which will be
  included the named file's `datapackage.json`.

Each **`scripts`** entry points to a script to be run, with one default:

- `path` path to the script, relative to this project's root.

- `manual` Logical; if `TRUE`, will only run the script from
  [`dcf_process`](https://DISSC-yale.github.io/dcf/reference/dcf_process.md)
  (not
  [`dcf_build`](https://DISSC-yale.github.io/dcf/reference/dcf_build.md)).

- `frequency` How often to rerun the project, in days. This is checked
  against the last run timestamp when processed; it is a way to skip
  processing, but can only be as frequent as the overall process is run.

- `last_run` Timestamp of the last processing.

- `run_time` How long the script took to run last, in milliseconds.

- `last_status` Status of the last run; a list with entries for
  `success` (logical) and `log` (output of the script).

See the [script
standards](https://dissc-yale.github.io/dcf/articles/standards.html#scripts)
for examples of using this within a sub-project script.

## Project Files

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
