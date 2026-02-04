# Run a Project's Build Process

Build a Data Collection Framework project, which involves processing and
checking all data projects.

## Usage

``` r
dcf_build(
  project_dir = ".",
  is_auto = TRUE,
  ...,
  make_diagram = TRUE,
  make_file_log = TRUE
)
```

## Arguments

- project_dir:

  Path to the Data Collection Framework project to be built.

- is_auto:

  Logical; if `FALSE`, will run
  [`dcf_process`](https://DISSC-yale.github.io/dcf/reference/dcf_process.md)
  as if it were run manually.

- ...:

  Passes arguments to
  [`dcf_process`](https://DISSC-yale.github.io/dcf/reference/dcf_process.md).

- make_diagram:

  Logical; if `FALSE`, will not make a `status.md` diagram.

- make_file_log:

  Logical; if `FALSE`, will not make a `file_log.json` output.

## Value

A version of the project report, which is also written to
`project_dir/docs/report.json.gz`.

## Examples

``` r
project_file <- "../../../pophive"
if (file.exists(project_file)) {
  report <- dcf_build(project_file)
}
#> Error in dcf_process(project_dir = project_dir, is_auto = TRUE, ...): missing process file: ../../../pophive/process.json
```
