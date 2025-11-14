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

- `geography_missing`: File does not contain a `geography` column.

- `geography_nas`: The file's `geography` column contains NAs.

- `time_missing`: File does not contain a `time` column.

- `time_nas`: The file's `time` column contains NAs.

- `missing_info: {column_name}`: The file's indicated column does not
  have a matching entry in `measure_info.json`.

## Examples

``` r
if (FALSE) { # \dontrun{
  dcf_check("gtrends")
} # }
```
