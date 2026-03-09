# View Project Variables

Get a list of measures (a codebook) that are included in a data
collection project.

## Usage

``` r
dcf_variables(project = ".", exclude = c("geography", "time", "age"), ...)
```

## Arguments

- project:

  Path to a local project, or the GitHub account and repository name
  (`"{account_name}/{repo_name}"`) of a remote project. Or a report as
  returned from
  [`dcf_report`](https://DISSC-yale.github.io/dcf/reference/dcf_report.md).

- exclude:

  A character vector of variable names to exclude from the list (usually
  ID columns).

- ...:

  Additional arguments passed to
  [`dcf_report`](https://DISSC-yale.github.io/dcf/reference/dcf_report.md).

## Value

A tibble containing variables:

|  |  |
|----|----|
| `name` | Name of the variable, as it appears in the data file. |
| `type` | The value's storage type. |
| `n` | Number of non-missing observations within the file. |
| `duplicates` | Number of duplicated values within the file. |
| `missing` | Number of missing values within the file. |
| `project_type` | The project type, between `source` and `bundle`. |
| `data_format` | The orientation of the data, between `wide` and `tall`. |
| `file` | The file containing the variable; a path relative to the project root. |
| `short_name` | Short name, if included in measure info. |
| `long_name` | Long name, if included in measure info. |
| `short_decription` | Short description, if included in measure info. |
| `long_description` | Long description, if included in measure info. |
| `measure_type` | Higher-level description of type than storage type (e.g., `count` versus `integer`), if included in measure info. |
| `unit` | How a single value should be interpreted (e.g., `per 100k people` for a rate per 100k people), if included in measure info. |
| `time_resolution` | The measure's collection frequency, if included in measure info. |
| `category` | The measure's category, if included in measure info. |
| `subcategory` | The measure's subcategory, if included in measure info. |

## See also

Other data user interface functions:
[`dcf_data()`](https://DISSC-yale.github.io/dcf/reference/dcf_data.md),
[`dcf_report()`](https://DISSC-yale.github.io/dcf/reference/dcf_report.md)

## Examples

``` r
dcf_variables("dissc-yale/pophive_demo")
#> # A tibble: 47 × 17
#>    name            type      n duplicates missing project_type data_format file 
#>    <chr>           <chr> <int>      <int>   <int> <chr>        <chr>       <chr>
#>  1 epic_all_encou… inte…  7074      21996   20848 bundle       wide        data…
#>  2 epic_covid      inte…  7074      26687   20848 bundle       wide        data…
#>  3 epic_flu        inte…  7074      26676   20848 bundle       wide        data…
#>  4 epic_rsv        inte…  6943      27394   20979 bundle       wide        data…
#>  5 gtrends_rsv_va… float 16744      21685   11178 bundle       wide        data…
#>  6 gtrends_naloxo… float 16744      19454   11178 bundle       wide        data…
#>  7 gtrends_overdo… float 16744      12163   11178 bundle       wide        data…
#>  8 gtrends_rsv     float 16744      14160   11178 bundle       wide        data…
#>  9 wastewater_cov… float 10468      17780   17454 bundle       wide        data…
#> 10 wastewater_flua float  8101      24067   19821 bundle       wide        data…
#> # ℹ 37 more rows
#> # ℹ 9 more variables: short_name <chr>, long_name <chr>,
#> #   short_description <chr>, long_description <chr>, measure_type <chr>,
#> #   unit <chr>, time_resolution <chr>, category <chr>, subcategory <chr>
```
