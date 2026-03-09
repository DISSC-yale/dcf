# Use Data from a Data Collection Project

Load the standard or distribution data from a local or remote data
collection project.

## Usage

``` r
dcf_data(
  project = ".",
  variables = NULL,
  data_format = NULL,
  project_type = "bundle",
  ...,
  unify = TRUE,
  only_selected = FALSE,
  cache = tempdir(),
  refresh = FALSE,
  verbose = TRUE
)
```

## Arguments

- project:

  Path to a local project, or the GitHub account and repository name
  (`"{account_name}/{repo_name}"`) of a remote project.

- variables:

  A character vector of variable names to be loaded.

- data_format:

  The data format to select, between `tall` and `wide`. Useful if there
  are duplicate measure names between files of different formats.

- project_type:

  Project type to select, between `bundle` and `source`.

- ...:

  Additional arguments passed to
  [`dcf_report`](https://DISSC-yale.github.io/dcf/reference/dcf_report.md).

- unify:

  Logical; if `FALSE`, will return `data` as a list with entries for
  each file. Otherwise (by default), will attempt to combine the loaded
  data.

- only_selected:

  Logical; if `TRUE`, will drop columns that were not included in
  `variables`, other than ID columns.

- cache:

  Path to a directory in which to store downloaded files. Within this
  directory, the repository structure will be recreated within an
  account-named directory.

- refresh:

  Logical; if `TURE`, will download files even if they exist in the
  `cache`.

- verbose:

  Logical; if `FALSE`, will not show status messages.

## Value

A list with entries for metadata (the datapackage resource entry for
each file loaded) and data (a tibble or list of tibbles of the unified
or separately loaded files).

## See also

Other data user interface functions:
[`dcf_report()`](https://DISSC-yale.github.io/dcf/reference/dcf_report.md),
[`dcf_variables()`](https://DISSC-yale.github.io/dcf/reference/dcf_variables.md)

## Examples

``` r
dcf_data("dissc-yale/pophive_demo", "epic_flu", verbose = FALSE)$data
#> # A tibble: 27,922 × 14
#>    geography time       epic_all_encounters epic_covid epic_flu epic_rsv
#>    <chr>     <date>                   <dbl>      <dbl>    <dbl>    <dbl>
#>  1 0         2023-01-01              854874      31915    18547     2582
#>  2 0         2023-01-08              804025      22817     8609     1659
#>  3 0         2023-01-15              808560      20621     5843     1254
#>  4 0         2023-01-22              806785      19119     4221     1069
#>  5 0         2023-01-29              801378      17960     3595      852
#>  6 0         2023-02-05              847500      18044     3195      780
#>  7 0         2023-02-12              841271      17158     2637      727
#>  8 0         2023-02-19              849373      15781     2513      618
#>  9 0         2023-02-26              848735      14249     2109      544
#> 10 0         2023-03-05              857291      12385     1959      469
#> # ℹ 27,912 more rows
#> # ℹ 8 more variables: gtrends_rsv_vaccine <dbl>, gtrends_naloxone <dbl>,
#> #   gtrends_overdose <dbl>, gtrends_rsv <dbl>, wastewater_covid <dbl>,
#> #   wastewater_flua <dbl>, wastewater_rsv <dbl>, source_file <chr>
```
