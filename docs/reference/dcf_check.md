# Check Data Projects

Check the data files and measure info of subprojects.

## Usage

``` r
dcf_check(names = NULL, project_dir = ".", verbose = TRUE)
```

## Arguments

- names:

  Name or names of projects.

- project_dir:

  Path to the Data Collection Framework project.

- verbose:

  Logical; if `FALSE`, will not print status messages.

## Value

A list with an entry for each source, containing a character vector
including any issue codes:

- `not_compressed`: The file does not appear to be compressed.

- `cant_read`: Failed to read the file in.

- `geography_nas`: The file's `geography` column contains NAs.

- `geography_dropped`: The file's `geography` column has levels dropped
  from previous versions.

- `time_nas`: The file's `time` column contains NAs.

- `missing_info: {column_name}`: The file's indicated column does not
  have a matching entry in `measure_info.json`.

- `dropped_measure: {column_name}`: The file's indicated column is not
  present when it was previously.

- `type_changed: {column_name}`: The file's indicated column's type
  changed from the previous version.

## Examples

``` r
if (FALSE) { # \dontrun{
  dcf_check("gtrends")
} # }
```
