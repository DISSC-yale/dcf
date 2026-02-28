# Retrieve Project Report

Retrieve the report file from a local or remote project.

Retrieve the report file from a local or remote project.

## Usage

``` r
dcf_get_report(
  project = "dissc-yale/pophive_demo",
  branch = "main",
  commit = NULL,
  provider = "https://github.com",
  cache = tempdir(),
  refresh = FALSE
)

dcf_get_report(
  project = "dissc-yale/pophive_demo",
  branch = "main",
  commit = NULL,
  provider = "https://github.com",
  cache = tempdir(),
  refresh = FALSE
)
```

## Arguments

- project:

  Path to a local project, or the GitHub account and repository name
  (`"{account_name}/{repo_name}"`) of a remote project.

- branch:

  Name of the remote repository branch.

- commit:

  Commit hash; overrides `branch`.

- provider:

  Base URL of the remote repository provider.

- cache:

  Directory to store retrieved report in (at
  `{cache}/{project}/report.json.gz`).

- refresh:

  Logical; if `TRUE`, will always retrieve a fresh copy of the report,
  even if a copy exists in `cache`.

## Value

A data collection project report:

- date:

  Timestamp when the report was created.

- settings:

  The project's settings file.

- source_times:

  A list with entries for each subproject, containing the number of
  milliseconds it took to run the project's scripts.

- issues:

  A list with entries for each subproject, containing issues flagged by
  [`dcf_check`](https://DISSC-yale.github.io/dcf/reference/dcf_check.md),
  within a list with `data` and/or `measure` entries, containing
  character vectors of issue labels.

- logs:

  A list with entries for each subproject, containing the logged output
  of their scripts.

- metadata:

  A list with entries for each subproject, containing the datapackage of
  their output, as created by
  [`dcf_measure_info`](https://DISSC-yale.github.io/dcf/reference/dcf_measure_info.md).

- processes:

  A list with entries for each subproject, containing their process
  definitions (see
  [`dcf_add_source`](https://DISSC-yale.github.io/dcf/reference/dcf_add_source.md)
  and/or
  [`dcf_add_bundle`](https://DISSC-yale.github.io/dcf/reference/dcf_add_bundle.md)).

A data collection project report:

- date:

  Timestamp when the report was created.

- settings:

  The project's settings file.

- source_times:

  A list with entries for each subproject, containing the number of
  milliseconds it took to run the project's scripts.

- issues:

  A list with entries for each subproject, containing issues flagged by
  [`dcf_check`](https://DISSC-yale.github.io/dcf/reference/dcf_check.md),
  within a list with `data` and/or `measure` entries, containing
  character vectors of issue labels.

- logs:

  A list with entries for each subproject, containing the logged output
  of their scripts.

- metadata:

  A list with entries for each subproject, containing the datapackage of
  their output, as created by
  [`dcf_measure_info`](https://DISSC-yale.github.io/dcf/reference/dcf_measure_info.md).

- processes:

  A list with entries for each subproject, containing their process
  definitions (see
  [`dcf_add_source`](https://DISSC-yale.github.io/dcf/reference/dcf_add_source.md)
  and/or
  [`dcf_add_bundle`](https://DISSC-yale.github.io/dcf/reference/dcf_add_bundle.md)).

## Examples

``` r
report <- dcf_get_report("dissc-yale/pophive_demo")
report$date
#> [1] "2026-02-27 03:02:32"
jsonlite::toJSON(report$settings)
#> {"name":["pophive"],"data_dir":["data"],"github_account":["dissc-yale"],"branch":["main"],"repo_name":["pophive_demo"]} 
report <- dcf_get_report("dissc-yale/pophive_demo")
report$date
#> [1] "2026-02-27 03:02:32"
jsonlite::toJSON(report$settings, auto_unbox = TRUE, pretty = TRUE)
#> {
#>   "name": "pophive",
#>   "data_dir": "data",
#>   "github_account": "dissc-yale",
#>   "branch": "main",
#>   "repo_name": "pophive_demo"
#> } 
```
