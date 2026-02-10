# Interact with a Process File

Read or update the current process file.

## Usage

``` r
dcf_process_record(path = "process.json", updated = NULL)
```

## Arguments

- path:

  Path to the process JSON file.

- updated:

  An update version of the process definition. If specified, will write
  this as the new process file, rather than reading any existing file.

## Value

The process definition of the source project.

## Details

See the [script
standards](https://dissc-yale.github.io/dcf/articles/standards.html#scripts)
for examples of using this within a sub-project script.

## Examples

``` r
epic_process_file <- "../../../pophive/pophive_demo/data/epic/process.json"
if (file.exists(epic_process_file)) {
  dcf_process_record(epic_process_file)
}
#> $name
#> [1] "epic"
#> 
#> $type
#> [1] "source"
#> 
#> $scripts
#> $scripts[[1]]
#> $scripts[[1]]$path
#> [1] "ingest.R"
#> 
#> $scripts[[1]]$manual
#> [1] TRUE
#> 
#> $scripts[[1]]$frequency
#> [1] 0
#> 
#> $scripts[[1]]$last_run
#> [1] "2025-11-01 09:31:40"
#> 
#> $scripts[[1]]$run_time
#> [1] 0.12
#> 
#> $scripts[[1]]$last_status
#> $scripts[[1]]$last_status$log
#> $scripts[[1]]$last_status$log[[1]]
#> [1] "\033G3;no staging files found"
#> 
#> $scripts[[1]]$last_status$log[[2]]
#> [1] "\033g\033G3;⠙ processing source \033[1mepic\033[22m (\033[3m./data/epic/ingest.R\033[23m)\r\033g"
#> 
#> 
#> $scripts[[1]]$last_status$success
#> [1] TRUE
#> 
#> 
#> 
#> 
#> $checked
#> [1] "2026-02-10 15:28:15"
#> 
#> $check_results
#> $check_results$`../../../pophive/pophive_demo/data/epic/standard/children.csv.gz`
#> list()
#> 
#> $check_results$`../../../pophive/pophive_demo/data/epic/standard/county_no_time.csv.gz`
#> list()
#> 
#> $check_results$`../../../pophive/pophive_demo/data/epic/standard/no_geo.csv.gz`
#> list()
#> 
#> $check_results$`../../../pophive/pophive_demo/data/epic/standard/state_no_time.csv.gz`
#> list()
#> 
#> $check_results$`../../../pophive/pophive_demo/data/epic/standard/weekly.csv.gz`
#> list()
#> 
#> 
#> $standard_state
#> $standard_state$`../../../pophive/pophive_demo/data/epic/measure_info.json`
#> [1] "f8ca16b6ec149ec601da2fff8c395a14"
#> 
#> $standard_state$`../../../pophive/pophive_demo/data/epic/standard/children.csv.gz`
#> [1] "538f9bfa2a7c012fcf15d9491b5ee60e"
#> 
#> $standard_state$`../../../pophive/pophive_demo/data/epic/standard/county_no_time.csv.gz`
#> [1] "732265db20d823ac6b8cd7e4fa91e184"
#> 
#> $standard_state$`../../../pophive/pophive_demo/data/epic/standard/no_geo.csv.gz`
#> [1] "612347598abc7970631923a099f4aa44"
#> 
#> $standard_state$`../../../pophive/pophive_demo/data/epic/standard/state_no_time.csv.gz`
#> [1] "6712ffbc056f9e635545ce6c75f3e40f"
#> 
#> $standard_state$`../../../pophive/pophive_demo/data/epic/standard/weekly.csv.gz`
#> [1] "29d830af361a067be287c61da0180ad5"
#> 
#> 
#> $vintages
#> $vintages$weekly.csv.gz
#> [1] "2025-07-14"
#> 
#> $vintages$state_no_time.csv.gz
#> [1] "2025-04-11"
#> 
#> $vintages$county_no_time.csv.gz
#> [1] "2025-05-01"
#> 
#> $vintages$no_geo.csv.gz
#> [1] "2025-06-04"
#> 
#> $vintages$children.csv.gz
#> [1] "2025-05-07"
#> 
#> 
```
