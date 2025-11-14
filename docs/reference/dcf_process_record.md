# Interact with a Source Process File

Read or update the current source process file.

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

## Examples

``` r
epic_process_file <- "../../data/epic/process.json"
if (file.exists(epic_process_file)) {
  dcf_process_record(path = epic_process_file)
}
```
