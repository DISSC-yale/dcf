# Download Census Population Data

Download American Community Survey population data from the U.S. Census
Bureau.

## Usage

``` r
pophive_load_census(
  year = 2021,
  out_dir = NULL,
  state_only = FALSE,
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- year:

  Data year.

- out_dir:

  Directory to download the file to.

- state_only:

  Logical; if `TRUE`, will only load state data. Will still download
  county data.

- overwrite:

  Logical; if `TRUE`, will re-download and overwrite existing data.

- verbose:

  Logical; if `FALSE`, will not display status messages.

## Value

A `data.frame` including `GEOID` and `region_name` for states and
counties, along with their population, in total and within age brackets.

## Examples

``` r
if (file.exists("../../resources/census_population_2021.csv.xz")) {
  pophive_load_census(2021, "../../resources")[1:10, ]
}
#> ℹ reading in existing file
#> ✔ reading in existing file [151ms]
#> 
#>    GEOID          region_name    Total <10 Years 10-14 Years 15-19 Years
#> 1     01              Alabama  4997675    597446      329794      329732
#> 2     02               Alaska   735951    104061       49647       47081
#> 3     04              Arizona  7079203    852827      480043      476470
#> 4     05             Arkansas  3006309    380228      203248      203530
#> 5     06           California 39455353   4784448     2658361     2588625
#> 6     08             Colorado  5723176    671899      370266      369984
#> 7     09          Connecticut  3605330    378662      224371      245790
#> 8     10             Delaware   981892    110715       60792       61884
#> 9     11 District of Columbia   683154     78027       31449       36641
#> 10    12              Florida 21339762   2266695     1252281     1227017
#>    20-39 Years 40-64 Years 65+ Years
#> 1      1283943     1612333    844427
#> 2       219748      225226     90188
#> 3      1896688     2129316   1243859
#> 4       779856      934086    505361
#> 5     11341150    12412890   5669879
#> 6      1685156     1806617    819254
#> 7       910996     1225332    620179
#> 8       245190      316936    186375
#> 9       265876      187962     83199
#> 10     5318262     6928542   4346965
```
