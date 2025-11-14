# Interact with a Source Process File

Read or update the current source process file.

## Usage

``` r
pophive_source_process(path = "process.json", updated = NULL)
```

## Arguments

- path:

  Path to the process JSON file.

- updated:

  An update version of the process definition. If specified, will write
  this as the new process file, rather than reading any existing file.

## Value

The process definition of the source project.

## Examples

``` r
epic_process_file <- "../../data/epic/process.json"
if (file.exists(epic_process_file)) {
  pophive_source_process(path = epic_process_file)
}
#> $name
#> [1] "epic"
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
#> [1] "2025-07-01 15:07:34"
#> 
#> $scripts[[1]]$run_time
#> [1] 0.08
#> 
#> $scripts[[1]]$last_status
#> $scripts[[1]]$last_status$log
#> $scripts[[1]]$last_status$log[[1]]
#> [1] "\033G3;no staging files found"
#> 
#> $scripts[[1]]$last_status$log[[2]]
#> [1] "\033g\033G3;⠙ processing \033[1mepic\033[22m (\033[3mdata/epic/ingest.R\033[23m)\r\033g"
#> 
#> 
#> $scripts[[1]]$last_status$success
#> [1] TRUE
#> 
#> 
#> 
#> 
#> $checked
#> [1] "2025-07-01 15:09:03"
#> 
#> $check_results
#> $check_results$`data/epic/standard/children.csv.xz`
#> $check_results$`data/epic/standard/children.csv.xz`$data
#> [1] "time_missing"
#> 
#> 
#> $check_results$`data/epic/standard/county_no_time.csv.xz`
#> $check_results$`data/epic/standard/county_no_time.csv.xz`$data
#> [1] "time_missing"
#> 
#> 
#> $check_results$`data/epic/standard/no_geo.csv.xz`
#> $check_results$`data/epic/standard/no_geo.csv.xz`$data
#> [1] "geography_missing"
#> 
#> 
#> $check_results$`data/epic/standard/state_no_time.csv.xz`
#> $check_results$`data/epic/standard/state_no_time.csv.xz`$data
#> [1] "time_missing"
#> 
#> 
#> $check_results$`data/epic/standard/weekly.csv.xz`
#> list()
#> 
#> 
#> $standard_state
#> $standard_state$`data/epic/measure_info.json`
#> [1] "091570f4344efd0f8cf3dad361d86d21"
#> 
#> $standard_state$`data/epic/standard/children.csv.xz`
#> [1] "15eb004a9a0b516263b6cdb74903f28b"
#> 
#> $standard_state$`data/epic/standard/county_no_time.csv.xz`
#> [1] "b52c0900ece40113dc34d44d74f2a7c2"
#> 
#> $standard_state$`data/epic/standard/no_geo.csv.xz`
#> [1] "43194bae68995e1de8c675cc2de90921"
#> 
#> $standard_state$`data/epic/standard/state_no_time.csv.xz`
#> [1] "8a6a463098c30a20ed52b18fe857fa19"
#> 
#> $standard_state$`data/epic/standard/weekly.csv.xz`
#> [1] "e770e8a3795eea9a934b91db0266b936"
#> 
#> 
```
