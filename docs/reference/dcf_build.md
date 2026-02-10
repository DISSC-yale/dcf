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
`project_dir/docs/report.json.gz`.

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
#> ✔ metadata: <https://data.cdc.gov/api/views/3cxc-4k8q> [526ms]
#> 
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> ✔ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)…
#> 
#> ⠙ processing source epic
#> no staging files found
#> ⠙ processing source epic
#> ✔ processing source epic [19ms]
#> 
#> ⠙ processing source gtrends (../../../pophive/pophive_demo/data/gtrends/ingest.…
#> ✔ processing source gtrends (../../../pophive/pophive_demo/data/gtrends/ingest.…
#> 
#> ⠙ processing source wastewater (../../../pophive/pophive_demo/data/wastewater/i…
#> ✔ processing source wastewater (../../../pophive/pophive_demo/data/wastewater/i…
#> 
#> ⠙ processing source wisqars (../../../pophive/pophive_demo/data/wisqars/ingest.…
#> ℹ requesting report <https://wisqars.cdc.gov/reports/?o=MORT&i=8&m=20810&s=0&r=0&ry=2&y1=2018&y2=2018&a=ALL&g1=0&g2=199&a1=0&a2=199&r1=MECH&r2=AGEGP&r3=STATE&r4=YEAR&r5=NONE&r6=NONE&g=00&e=0&yp=65&me=0&t=0>
#> ⠙ processing source wisqars (../../../pophive/pophive_demo/data/wisqars/ingest.…
#> ℹ requesting report <https://wisqars.cdc.gov/reports/?o=MORT&i=1&m=20810&s=0&r=0&ry=2&y1=2018&y2=2018&a=ALL&g1=0&g2=199&a1=0&a2=199&r1=MECH&r2=AGEGP&r3=STATE&r4=YEAR&r5=NONE&r6=NONE&g=00&e=0&yp=65&me=0&t=0>
#> ⠙ processing source wisqars (../../../pophive/pophive_demo/data/wisqars/ingest.…
#> ✔ processing source wisqars (../../../pophive/pophive_demo/data/wisqars/ingest.…
#> 
#> ⠙ processing bundle bundle_respiratory (../../../pophive/pophive_demo/data/bund…
#> ✔ processing bundle bundle_respiratory (../../../pophive/pophive_demo/data/bund…
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
#> ✖ checking file ../../../pophive/pophive_demo/data/gtrends/standard/data.csv.gz…
#> 
#>   geography column contains NAs
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
