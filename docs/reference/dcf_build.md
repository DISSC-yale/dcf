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
#> ✔ metadata: <https://data.cdc.gov/api/views/3cxc-4k8q> [656ms]
#> 
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> ℹ data: <https://data.cdc.gov/api/views/3cxc-4k8q/rows.csv>
#> ✔ data: <https://data.cdc.gov/api/views/3cxc-4k8q/rows.csv> [24.1s]
#> 
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> ℹ compressing data
#> ✔ compressing data [11.3s]
#> 
#> ⠙ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)
#> ✔ processing source NREVSS (../../../pophive/pophive_demo/data/NREVSS/ingest.R)…
#> 
#> ⠙ processing source epic
#> no staging files found
#> ⠙ processing source epic
#> ✔ processing source epic [1.7s]
#> 
#> ⠙ processing source gtrends (../../../pophive/pophive_demo/data/gtrends/ingest.…
#> ✔ processing source gtrends (../../../pophive/pophive_demo/data/gtrends/ingest.…
#> 
#> ⠙ processing source wastewater (../../../pophive/pophive_demo/data/wastewater/i…
#> ✔ processing source wastewater (../../../pophive/pophive_demo/data/wastewater/i…
#> 
#> ⠙ processing source wisqars
#> ℹ requesting report <https://wisqars.cdc.gov/reports/?o=MORT&i=8&m=20810&s=0&r=0&ry=2&y1=2018&y2=2018&a=ALL&g1=0&g2=199&a1=0&a2=199&r1=MECH&r2=AGEGP&r3=STATE&r4=YEAR&r5=NONE&r6=NONE&g=00&e=0&yp=65&me=0&t=0>
#> ⠙ processing source wisqars
#> ℹ requesting report <https://wisqars.cdc.gov/reports/?o=MORT&i=1&m=20810&s=0&r=0&ry=2&y1=2018&y2=2018&a=ALL&g1=0&g2=199&a1=0&a2=199&r1=MECH&r2=AGEGP&r3=STATE&r4=YEAR&r5=NONE&r6=NONE&g=00&e=0&yp=65&me=0&t=0>
#> ⠙ processing source wisqars
#> ✔ processing source wisqars [6.8s]
#> 
#> ⠙ processing bundle bundle_respiratory (../../../pophive/pophive_demo/data/bund…
#> ✔ processing bundle bundle_respiratory (../../../pophive/pophive_demo/data/bund…
#> 
#> ⠙ processing bundle bundle_tall (../../../pophive/pophive_demo/data/bundle_tall…
#> ✔ processing bundle bundle_tall (../../../pophive/pophive_demo/data/bundle_tall…
#> 
#> 
#> Checking project NREVSS
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/NREVSS/sta…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/NREVSS/sta…
#> 
#> 
#> Checking project bundle_respiratory
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/bundle_res…
#> ✖ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/bundle_res…
#> 
#>   geography column contains NAs
#> 
#> Checking project bundle_tall
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/bundle_tal…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/bundle_tal…
#> 
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/bundle_tal…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/bundle_tal…
#> 
#> 
#> Checking project epic
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> 
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> 
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> 
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> 
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/epic/stand…
#> 
#> 
#> Checking project gtrends
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/gtrends/st…
#> ✖ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/gtrends/st…
#> 
#>   geography column contains NAs
#> 
#> Checking project wastewater
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/wastewater…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/wastewater…
#> 
#> 
#> Checking project wisqars
#> ⠙ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/wisqars/st…
#> ✔ checking file F:/Content/Work/Yale/DISSC/pophive/pophive_demo/data/wisqars/st…
#> 
```
