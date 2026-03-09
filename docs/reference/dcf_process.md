# Run Data Project Processes

Operates over data source and bundle projects, optionally running the
source ingest scripts, then collecting metadata.

## Usage

``` r
dcf_process(
  name = NULL,
  project_dir = ".",
  run_scripts = TRUE,
  is_auto = FALSE,
  force = FALSE,
  clear_state = FALSE
)
```

## Arguments

- name:

  Name of a source project to process. Will default to the name of the
  current working directory.

- project_dir:

  Path to the project directory. If not specified, and being called from
  a source project, this will be assumed to be two steps back from the
  working directory.

- run_scripts:

  Logical; if `FALSE`, will rebuild datapackages without running
  scripts.

- is_auto:

  Logical; if `TRUE`, will skip process scripts marked as manual.

- force:

  Logical; if `TRUE`, will ignore process frequencies (will run scripts
  even if recently run).

- clear_state:

  Logical; if `TRUE`, will clear stored states before processing.

## Value

A list with processing results:

- `timings`: How many seconds the scripts took to run.

- `logs`: The captured output of the scripts.

Each entry has an entry for each project.

A \`datapackage.json\` file is also created / update in each source's
\`standard\` directory and each bundle's \`dist\` directory.

## Examples

``` r
if (FALSE) { # \dontrun{
  # run from a directory containing a `data` directory containing the source
  dcf_process("source_name")

  # run without executing the ingestion script
  dcf_process("source_name", run_scripts = FALSE)
} # }
```
