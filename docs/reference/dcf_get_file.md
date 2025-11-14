# Retrieve A Data File

Load a data file from a source data project, or list versions of the
file.

## Usage

``` r
dcf_get_file(path, date = NULL, commit_hash = NULL, versions = FALSE)
```

## Arguments

- path:

  Path to the file.

- date:

  Date of the version to load; A `Date`, or `character` in the format
  `YYYY-MM-DD`. Will match to the nearest version.

- commit_hash:

  SHA signature of the committed version; can be the first 6 or so
  characters. Ignored if `date` is provided.

- versions:

  Logical; if `TRUE`, will return a list of available version, rather
  than a

## Value

If `versions` is `TRUE`, a `data.frame` with columns for the `hash`,
`author`, `date`, and `message` of each commit. Otherwise, the path to a
temporary file, if one was extracted.

## Examples

``` r
path <- "../../../pophive/data/wastewater/raw/flua.csv.xz"
if (file.exists(path)) {
  # list versions
  versions <- dcf_get_file(path, versions = TRUE)
  print(versions[, c("date", "hash")])

  # extract a version to a temporary file
  temp_path <- dcf_get_file(path, "2025-05")
  basename(temp_path)
}
```
