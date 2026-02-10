# Download Medicare Disparities Data

Download data from the Centers for Medicare & Medicaid Services (CMS)
[Mapping Medicare Disparities by
Population](https://data.cms.gov/tools/mapping-medicare-disparities-by-population)
(MMD) tool.

## Usage

``` r
dcf_download_cmsmmd(
  measure,
  population = NULL,
  year = NULL,
  geography = NULL,
  adjust = NULL,
  condition = NULL,
  sex = c(1:2, "."),
  age = c(0:4, "."),
  race = c(1:6, "."),
  dual_elig = ".",
  medicare_elig = ".",
  refresh_codebook = FALSE,
  codebook_only = FALSE,
  row_limit = 9999999,
  out_file = NULL,
  state = NULL,
  parquet = FALSE,
  verbose = TRUE
)

dcf_standardize_cmsmmd(raw_data = NULL)
```

## Arguments

- measure:

  Name or letter code of the measure to download.

- population:

  The population code; either `f` (Medicare Fee For Service) or `m`
  (Medicare Advantage).

- year:

  Year(s) to download (e.g., `2015:2020`). If not specified, all
  available years will be included.

- geography:

  Geography code(s) to include, between `n` (national), `s` (state), and
  `c` (county). If not specified, all available geographies will be
  included.

- adjust, condition, sex, age, race, dual_elig, medicare_elig:

  One or more codes indicating the variable levels to include (see
  `dcf_standardize_cmsmmd`). If `"."`, values will be across all levels,
  whereas if `NULL`, all available levels will be included (aggregated
  and disaggregated). See the Making Requests section.

- refresh_codebook:

  Logical; if `TRUE`, will re-download the codebook even if it exists in
  the temporary location (which is cleared each R session).

- codebook_only:

  Logical; if `TRUE`, will return the codebook without downloading data.

- row_limit:

  Maximum number of rows to return in each request. The API limit
  appears to be 100,000.

- out_file:

  Path to the CSV or Parquet file to write data to.

- state:

  The codebook state (MD5 hash) recorded during a previous download; if
  provided, will only download if the new state does not match.

- parquet:

  Logical; if `TRUE`, will convert the downloaded CSV file to Parquet.

- verbose:

  Logical; if `FALSE`, will not display status messages.

- raw_data:

  The raw data as downloaded with `dcf_download_cmsmmd` to be
  standardized.

## Value

`dcf_download_cmsmmd`: A list:

- **`codebook`**: The codebook.

- **`codebook_state`**: MD5 hash of the codebook.

- **`data`**: The downloaded data.

`dcf_standardize_cmsmmd`: If `raw_data` is `NULL`, a list with an entry
for each API parameter, containing named vectors with level codes as
names mapping to level values (as they appear in the tool's menus).
Otherwise, a version of `raw_data` with coded values converted to
labels.

## Making Requests

The API operates over several large files, partitioned by measure, year,
adjust, and dual and medicaid eligibility. These are identified with the
codebook (`dcf_download_cmsmmd(codebook_only = TRUE)`).

The files are larger than the API's limit, so requests for each file
have to be broken up by the other variables within them (sex, age, race,
and condition).

For best performance, make requests as big as possible while staying
under 100,000 rows each (e.g., by setting `sex`, `age`, or `race` to
`NULL`).

## Examples

``` r
# find the codes associated with menu values
variable_codes <- dcf_standardize_cmsmmd()
variable_codes[c(
  "sex", "age", "race",
  "adjust", "dual_elig", "medicare_elig"
)]
#> $sex
#>        1        2 
#>   "Male" "Female" 
#> 
#> $age
#>       0       1       2       3       4 
#>   "<65" "65-74" "75-84"   "85+"   "65+" 
#> 
#> $race
#>                               1                               2 
#>                         "White"                         "Black" 
#>                               3                               4 
#>                         "Other"        "Asian/Pacific Islander" 
#>                               5                               6 
#>                      "Hispanic" "American Indian/Alaska Native" 
#> 
#> $adjust
#>                             1                             2 
#>           "Unsmoothed actual" "Unsmoothed age standardized" 
#>                             3                             4 
#>             "Smoothed actual"   "Smoothed age standardized" 
#> 
#> $dual_elig
#>               0               1 
#> "Medicare only"     "Dual only" 
#> 
#> $medicare_elig
#>                                             0 
#>              "Old Age / Survivor's Insurance" 
#>                                             1 
#>               "Disability Insurance Benefits" 
#>                                             2 
#>                     "End-Stage Renal Disease" 
#>                                             3 
#> "Both Disability and End-Stage Renal Disease" 
#> 

# look at the codebook which defines source files
codebook <- dcf_download_cmsmmd(codebook_only = TRUE)
#> ℹ retrieving codebook
#> ✔ retrieving codebook [107ms]
#> 
codebook
#> # A tibble: 1,537 × 13
#>    File    File.Name Number.of.observations population measure description  year
#>    <chr>   <chr>                      <dbl> <chr>      <chr>   <chr>       <dbl>
#>  1 ""      Mdcr_pmt…                7497844 f          b       medicare r…     2
#>  2 "dual … Dschrg_F…                9424772 f          d       discharge …     2
#>  3 "dual … Dschrg_F…                8122052 f          d       discharge …     2
#>  4 "dual … Dschrg_F…                6318880 f          d       discharge …     2
#>  5 ""      Ipdays_F…                7497844 f          i       inpatient …     2
#>  6 ""      Mortalit…                3944721 f          m       mortality       2
#>  7 "dual … Admsn_Fi…                9425012 f          n       admission …     2
#>  8 "dual … Admsn_Fi…                8122188 f          n       admission …     2
#>  9 "dual … Admsn_Fi…                6319016 f          n       admission …     2
#> 10 "year … Principa…               11686440 f          p       principal …     2
#> # ℹ 1,527 more rows
#> # ℹ 6 more variables: elig <chr>, race_code <chr>, sex_code <chr>,
#> #   adjust <chr>, dual <chr>, url <chr>

if (FALSE) { # \dontrun{
  # download data
  downloaded <- dcf_download_cmsmmd(
    "preventive care",
    population = "f",
    race = ".",
    sex = ".",
    age = NULL,
    condition = c(83, 85, 86, 88, 89, 95, 101, 102, 104, 105:107),
    adjust = 1
  )

  # convert codes to levels
  data_standard <- dcf_standardize_cmsmmd(downloaded$data)
} # }
```
