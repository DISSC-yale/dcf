# View Project Variables

Get a list of measures (a codebook) that are included in a data
collection project.

## Usage

``` r
dcf_variables(project = ".", ...)
```

## Arguments

- project:

  Path to a local project, or the GitHub account and repository name
  (`"{account_name}/{repo_name}"`) of a remote project.

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

## Examples

``` r
dcf_variables("dissc-yale/pophive_demo")
#> # A tibble: 73 × 15
#>    name                type      n duplicates missing file  short_name long_name
#>    <chr>               <chr> <int>      <int>   <int> <chr> <chr>      <chr>    
#>  1 geography           stri… 27498      27763     321 data… NA         NA       
#>  2 time                stri… 27819      27281       0 data… NA         NA       
#>  3 epic_all_encounters inte…  7074      21893   20745 data… All Patie… All Emer…
#>  4 epic_covid          inte…  7074      26584   20745 data… COVID Pat… COVID Em…
#>  5 epic_flu            inte…  7074      26573   20745 data… FLU Patie… FLU Emer…
#>  6 epic_rsv            inte…  6943      27291   20876 data… RSV Patie… RSV Emer…
#>  7 gtrends_rsv_vaccine float 16692      21634   11127 data… gtrends_r… NA       
#>  8 gtrends_naloxone    float 16692      19403   11127 data… gtrends_n… NA       
#>  9 gtrends_overdose    float 16692      12112   11127 data… gtrends_o… NA       
#> 10 gtrends_rsv         float 16692      14109   11127 data… gtrends_r… NA       
#> # ℹ 63 more rows
#> # ℹ 7 more variables: short_description <chr>, long_description <chr>,
#> #   measure_type <chr>, unit <chr>, time_resolution <chr>, category <chr>,
#> #   subcategory <chr>
```
