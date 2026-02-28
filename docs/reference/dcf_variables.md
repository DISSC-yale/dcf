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
| `unit` | Unit (what the value represents), if included in measure info. |
| `category` | The measure's category, if included in measure info. |

## Examples

``` r
dcf_variables("dissc-yale/pophive_demo")
#> # A tibble: 73 × 11
#>    name                type      n duplicates missing file  short_name long_name
#>    <chr>               <chr> <int>      <int>   <int> <chr> <chr>      <chr>    
#>  1 geography           stri… 27447      27711     320 data… NA         NA       
#>  2 time                stri… 27767      27230       0 data… NA         NA       
#>  3 epic_all_encounters inte…  7074      21841   20693 data… All Patie… All Emer…
#>  4 epic_covid          inte…  7074      26532   20693 data… COVID Pat… COVID Em…
#>  5 epic_flu            inte…  7074      26521   20693 data… FLU Patie… FLU Emer…
#>  6 epic_rsv            inte…  6943      27239   20824 data… RSV Patie… RSV Emer…
#>  7 gtrends_rsv_vaccine float 16640      21634   11127 data… NA         NA       
#>  8 gtrends_naloxone    float 16640      19404   11127 data… NA         NA       
#>  9 gtrends_overdose    float 16640      12112   11127 data… NA         NA       
#> 10 gtrends_rsv         float 16640      14109   11127 data… NA         NA       
#> # ℹ 63 more rows
#> # ℹ 3 more variables: short_description <chr>, long_description <chr>,
#> #   unit <chr>
```
