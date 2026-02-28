# Download Census Population Data

Download American Community Survey population data from the U.S. Census
Bureau.

## Usage

``` r
dcf_load_census(
  year = 2021,
  out_dir = NULL,
  state_only = FALSE,
  age_groups = "9",
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

- age_groups:

  A list mapping lower-level age groups to high-level ones (e.g.,
  `` list(`<10 Years` = c("Under 5 years", "5 to 9 years")) ``). Or the
  name of a standard mapping (`"7"` or `"9"`). If `FALSE`, will return
  the lowest-level age groups.

- overwrite:

  Logical; if `TRUE`, will re-download and overwrite existing data.

- verbose:

  Logical; if `FALSE`, will not display status messages.

## Value

A `data.frame` including `GEOID` and `region_name` for states and
counties, along with their population, in total and within age brackets.

## Examples

``` r
if (file.exists("../../../pophive/census_population_2021.csv.xz")) {
  dcf_load_census(2021, "../../../pophive")[1:10, ]
}
#> ℹ reading in existing file
#> ✔ reading in existing file [143ms]
#> 
#>    GEOID          region_name    Total <10 Years 10-18 Years 18-24 Years
#> 1     01              Alabama  4997675    597446      524935      461491
#> 2     02               Alaska   735951    104061       78673       68835
#> 3     04              Arizona  7079203    852827      761608      672761
#> 4     05             Arkansas  3006309    380228      325557      279234
#> 5     06           California 39455353   4784448     4207984     3665851
#> 6     08             Colorado  5723176    671899      590836      523401
#> 7     09          Connecticut  3605330    378662      365829      345702
#> 8     10             Delaware   981892    110715       96930       83629
#> 9     11 District of Columbia   683154     78027       46995       70406
#> 10    12              Florida 21339762   2266695     1994618     1729159
#>    25-34 Years 35-44 Years 45-54 Years 55-64 Years 65+ Years
#> 1       647247      615110      633931      673088    844427
#> 2       116525       96664       87719       93286     90188
#> 3       966670      882914      838963      859601   1243859
#> 4       388499      376431      364713      386286    505361
#> 5      5941622     5341049     5043403     4801117   5669879
#> 6       889933      805249      712196      710408    819254
#> 7       445861      439098      488283      521716    620179
#> 8       127878      115773      121235      139357    186375
#> 9       155714      106798       73601       68414     83199
#> 10     2742442     2626930     2735230     2897723   4346965
```
