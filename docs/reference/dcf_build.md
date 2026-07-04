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
`project_dir/report.json.gz`.

## Examples

``` r
project_file <- "../../../pophive/pophive_demo"
if (file.exists(project_file)) {
  report <- dcf_build(project_file)
}
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> 
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> ── downloading resource <https://data.cdc.gov/resource/3cxc-4k8q> ──────────────
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> ℹ metadata: <https://data.cdc.gov/api/views/3cxc-4k8q>
#> ✔ metadata: <https://data.cdc.gov/api/views/3cxc-4k8q> [1.5s]
#> 
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> ✔ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)…
#> 
#> ⠙ processing source gtrends (../../../pophive/pophive_demo/data/gtrends/ingest.…
#> ✔ processing source gtrends (../../../pophive/pophive_demo/data/gtrends/ingest.…
#> 
#> ⠙ processing source wastewater (../../../pophive/pophive_demo/data/wastewater/i…
#> ✔ processing source wastewater (../../../pophive/pophive_demo/data/wastewater/i…
#> 
#> ⠙ processing bundle bundle_respiratory (../../../pophive/pophive_demo/data/bund…
#> ✔ processing bundle bundle_respiratory (../../../pophive/pophive_demo/data/bund…
#> 
#> ⠙ processing bundle bundle_tall (../../../pophive/pophive_demo/data/bundle_tall…
#> ✔ processing bundle bundle_tall (../../../pophive/pophive_demo/data/bundle_tall…
#> 
#> 
#> Checking project NREVSS
#> ⠙ checking file ../../../pophive/pophive_demo/data/NREVSS/standard/data.csv.gz
#> ✔ checking file ../../../pophive/pophive_demo/data/NREVSS/standard/data.csv.gz …
#> 
#> 
#> Checking project bundle_respiratory
#> ⠙ checking file ../../../pophive/pophive_demo/data/bundle_respiratory/dist/data…
#> ✖ checking file ../../../pophive/pophive_demo/data/bundle_respiratory/dist/data…
#> 
#>   geography column contains NAs
#> 
#> Checking project bundle_tall
#> ⠙ checking file ../../../pophive/pophive_demo/data/bundle_tall/dist/flu.parquet
#> ✔ checking file ../../../pophive/pophive_demo/data/bundle_tall/dist/flu.parquet…
#> 
#> ⠙ checking file ../../../pophive/pophive_demo/data/bundle_tall/dist/rsv.parquet
#> ✖ checking file ../../../pophive/pophive_demo/data/bundle_tall/dist/rsv.parquet…
#> 
#>   geography column contains NAs
#> 
#> Checking project epic
#> ⠙ checking file ../../../pophive/pophive_demo/data/epic/standard/children.csv.gz
#> ✔ checking file ../../../pophive/pophive_demo/data/epic/standard/children.csv.g…
#> 
#> ⠙ checking file ../../../pophive/pophive_demo/data/epic/standard/county_no_time…
#> ✔ checking file ../../../pophive/pophive_demo/data/epic/standard/county_no_time…
#> 
#> ⠙ checking file ../../../pophive/pophive_demo/data/epic/standard/no_geo.csv.gz
#> ✔ checking file ../../../pophive/pophive_demo/data/epic/standard/no_geo.csv.gz …
#> 
#> ⠙ checking file ../../../pophive/pophive_demo/data/epic/standard/state_no_time.…
#> ✔ checking file ../../../pophive/pophive_demo/data/epic/standard/state_no_time.…
#> 
#> ⠙ checking file ../../../pophive/pophive_demo/data/epic/standard/weekly.csv.gz
#> ✔ checking file ../../../pophive/pophive_demo/data/epic/standard/weekly.csv.gz …
#> 
#> 
#> Checking project gtrends
#> ⠙ checking file ../../../pophive/pophive_demo/data/gtrends/standard/data.csv.gz
#> ✔ checking file ../../../pophive/pophive_demo/data/gtrends/standard/data.csv.gz…
#> 
#> 
#> Checking project wastewater
#> ⠙ checking file ../../../pophive/pophive_demo/data/wastewater/standard/data.csv…
#> ✔ checking file ../../../pophive/pophive_demo/data/wastewater/standard/data.csv…
#> 
#> 
#> Checking project wisqars
#> ⠙ checking file ../../../pophive/pophive_demo/data/wisqars/standard/data.csv.gz
#> ✔ checking file ../../../pophive/pophive_demo/data/wisqars/standard/data.csv.gz…
#> 
```
