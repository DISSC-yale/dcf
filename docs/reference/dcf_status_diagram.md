# Make a Status Diagram

Make a Data Collection Project status diagram.

## Usage

``` r
dcf_status_diagram(project_dir = ".", out_file = "status.md")
```

## Arguments

- project_dir:

  Path to the Data Collection Framework project to be built.

- out_file:

  File name of the file to write within `project_dir`.

## Value

A character vector of the status diagram, which is also written to the
`project_dir/status.md` file.

## Examples

``` r
if (FALSE) { # \dontrun{
  dcf_status_diagram("project_directory")
} # }
```
