# Run Data Sources

Optionally run the ingestion script for each data source, and collect
metadata.

## Usage

``` r
pophive_process(
  name = NULL,
  source_dir = "data",
  ingest = TRUE,
  is_auto = FALSE,
  force = FALSE
)
```

## Arguments

- name:

  Name of a source project to process. Will

- source_dir:

  Path to the directory containing source projects.

- ingest:

  Logical; if `FALSE`, will re-process standardized data without running
  ingestion scripts.

- is_auto:

  Logical; if `TRUE`, will skip process scripts marked as manual.

- force:

  Logical; if `TRUE`, will ignore process frequencies (will run scripts
  even if recently run).

## Value

A list with processing results:

- `timings`: How many seconds the ingestion script took to run.

- `logs`: The captured output of the ingestion script.

Each entry has an entry for each source.

A \`datapackage.json\` file is also created / update in each source's
\`standard\` directory.

## Examples

``` r
if (FALSE) { # \dontrun{
  # run from a directory containing a `data` directory containing the source
  pophive_process("source_name")

  # run without executing the ingestion script
  pophive_process("source_name", ingest = FALSE)
} # }
```
