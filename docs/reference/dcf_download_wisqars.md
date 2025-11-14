# Download CDC WISQARS Reports

Download reports data from the CDC's [Web-based Injury Statistics Query
and Reporting System](https://wisqars.cdc.gov/reports).

## Usage

``` r
dcf_download_wisqars(
  file,
  fatal_outcome = TRUE,
  brain_injury_only = FALSE,
  year_start = 2018,
  year_end = year_start,
  geography = "00",
  intent = "all",
  disposition = "all",
  mechanism = if (fatal_outcome) 20810 else 3000,
  group_ages = NULL,
  age_min = 0,
  age_max = 199,
  sex = "all",
  race = "all",
  race_reporting = "single",
  ethnicity = "all",
  YPLL = 65,
  metro = NULL,
  group_by = NULL,
  include_total = FALSE,
  verbose = TRUE
)
```

## Arguments

- file:

  File to save the report to (`csv` or `parquet`).

- fatal_outcome:

  Logical; if `FALSE`, will return non-fatal results.

- year_start:

  Earliest year to include.

- year_end:

  Latest year to include.

- geography:

  State or region code.

- intent:

  Intent ID or name:

  |     |                  |                                 |
  |-----|------------------|---------------------------------|
  | `0` | `all`            | All                             |
  | `1` | `unintentional`  | Unintentional                   |
  | `2` | `suicide`        | Suicide                         |
  | `3` | `homicide`       | Homicide                        |
  | `4` | `homicide_legal` | Homicide and Legal Intervention |
  | `5` | `undetermined`   | Undetermined                    |
  | `6` | `legal`          | Legal Intervention              |
  | `8` | `violence`       | Violence-related                |

- disposition:

  Patient disposition given nonfatal: one or multiple of `all` (0),
  `treated` (1; treated and released), `transfered` (2), `hospitalized`
  (3), or `observed` (4; observed/left AMA/unknown).

- mechanism:

  Mechanism code; default to `20810` (all injury). Other codes appear in
  the URL in the `m` parameter when submitting the filter.

- group_ages:

  Logical; if `FALSE`, will not group ages into 5-year bins.

- age_min:

  Youngest age to include.

- age_max:

  Oldest age to include.

- sex:

  Sex groups to include: one or multiple of `all` (0), `male` (1),
  `female` (2), or `unknown` (3)..

- race:

  Race groups to include: one or multiple of `all` (0), `white` (1),
  `black` (2), `aa` (3; American Indian or Alaska Native), `asian` (4),
  `pi` (5; Hawaiian Native or Pacific Islander), `more` (6; more than
  one race). These levels apply if `race_reporting` is `single`
  (default) – provide these by index for other `race_reporting` levels.

- race_reporting:

  How to group race groups, between `none` (0), `bridge` (1), `single`
  (2), or `aapi` (3).

- ethnicity:

  Which ethnic groups to include: one or multiple of `all` (0),
  `non_hispanic` (1), `hispanic` (2), or `unknown` (3).

- YPLL:

  Age to use when calculating Years of Potential Life Lost.

- metro:

  Region type filter: `TRUE` for only metropolitan / urban, or `FALSE`
  for only non-metropolitan / rural. Will include all region types if
  `NULL` (default).

- group_by:

  One or more variables to group by. These are uppercased and sometimes
  abbreviated or encoded; see the `r1` through `r4` URL parameters.

- include_total:

  Logical; if `FALSE`, will not include totals.

- verbose:

  Logical; if `FALSE`, will not display status messages.

- brain_ingury_only:

  Logical; if `TRUE`, will return only traumatic brain injury results.

## Value

A list containing the parameters of the request. The returned data are
written to `file`.

## Examples

``` r
file <- "../../../wisqars.csv.xz"
if (file.exists(file)) {
  dcf_download_wisqars(file, verbose = FALSE)
  vroom::vroom(file)
}
#> Rows: 1 Columns: 21
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> dbl (21): SupressFlag, Population, medCost, workCost, MedCostAAR, workCostAA...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 1 × 21
#>   SupressFlag Population     medCost    workCost MedCostAAR workCostAAR CombCost
#>         <dbl>      <dbl>       <dbl>       <dbl>      <dbl>       <dbl>    <dbl>
#> 1           0  326838199 3840756047.     2.32e12       10.5       7008.  2.33e12
#> # ℹ 14 more variables: CombCostAAR <dbl>, CombCostRate <dbl>,
#> #   MedCostRate <dbl>, workCostRate <dbl>, CombCostAvg <dbl>,
#> #   WorkCostAvg <dbl>, MedCostAvg <dbl>, race_yr <dbl>, deaths <dbl>,
#> #   ypll <dbl>, CrudeRate <dbl>, CrudeRateypll <dbl>, ageadj <dbl>,
#> #   ageadjypll <dbl>
```
