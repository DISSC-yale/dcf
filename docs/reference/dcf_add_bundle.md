# Adds a Bundle Project

Establishes a new data bundle project, used to prepare outputs from
standardized datasets.

## Usage

``` r
dcf_add_bundle(
  name,
  project_dir = ".",
  source_files = NULL,
  open_after = interactive(),
  use_git = TRUE,
  use_workflow = FALSE
)
```

## Arguments

- name:

  Name of the bundle

- project_dir:

  Path to the Data Collection Framework project.

- source_files:

  A list or character vector, with names as paths to standard files form
  source projects (relative to the project's data directory), and
  distribution file names as entries. This associates input with output
  files, allowing for calculation of a source state, and metadata
  inheritance from source files.

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

- `type` Always `bundle` to define this as a bundle project.

- `name` Name of the project.

- `scripts` List of script definitions.

- `source_files` A character array of paths to other files used within
  the scripts, relative to the overall project's `data` directory.

- `standard_state` State of the `source_files`: A list with keys as the
  file paths, relative to the overall project root, and values as the
  MD5 hash of those files.

- `dist_state` State of the `dist` directory: A list with keys as the
  file paths, relative to the overall project root, and values as the
  MD5 hash of those files.

- `checked` Timestamp when the project was last checked with
  [`dcf_check`](https://DISSC-yale.github.io/dcf/reference/dcf_check.md).

- `check_results` Results of the last check.

Each **`scripts`** entry points to a script to be run, with one default:

- `path` path to the script, relative to this project's root.

- `last_run` Timestamp of the last processing.

- `run_time` How long the script took to run last, in milliseconds.

- `last_status` Status of the last run; a list with entries for
  `success` (logical) and `log` (output of the script).

## Project Files

Within a bundle project, there are two files to edits:

- **`build.R`**: This is the primary script, which is automatically
  rerun. It should read data from the `standard` directory of source
  projects, and write to it's own `dist` directory.

- **`measure_info.json`**: This should list all non-ID variable names in
  the data files within `dist`. These will inherit the standard measure
  info if found in the source projects referred to in `source_files`. If
  the `dist` name is different, but should still inherit standard
  measure info, a `source_id` entry with the original measure ID will be
  used to identify the original measure info. See
  [`dcf_measure_info`](https://DISSC-yale.github.io/dcf/reference/dcf_measure_info.md).

## Examples

``` r
project_dir <- paste0(tempdir(), "/temp_project")
dcf_init("temp_project", dirname(project_dir))
dcf_add_bundle("bundle_name", project_dir)
list.files(paste0(project_dir, "/data/bundle_name"))
#> [1] "README.md"         "build.R"           "dist"             
#> [4] "measure_info.json" "process.json"      "project.Rproj"    
```
