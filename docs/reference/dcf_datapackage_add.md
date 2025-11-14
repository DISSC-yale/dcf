# Adds documentation of a dataset to a datapackage

Add information about variables in a dataset to a `datapackage.json`
metadata file.

## Usage

``` r
dcf_datapackage_add(
  filename,
  meta = list(),
  packagename = "datapackage.json",
  dir = ".",
  write = TRUE,
  refresh = TRUE,
  sha = "512",
  pretty = FALSE,
  summarize_ids = FALSE,
  open_after = FALSE,
  verbose = interactive()
)
```

## Arguments

- filename:

  A character vector of paths to plain-text tabular data files, relative
  to `dir`.

- meta:

  Information about each data file. A list with a list entry for each
  entry in `filename`; see details. If a single list is provided for
  multiple data files, it will apply to all.

- packagename:

  Package to add the metadata to; path to the `.json` file relative to
  `dir`, or a list with the read-in version.

- dir:

  Directory in which to look for `filename`, and write `packagename`.

- write:

  Logical; if `FALSE`, returns the `paths` metadata without reading or
  rewriting `packagename`.

- refresh:

  Logical; if `FALSE`, will retain any existing dataset information.

- sha:

  A number specifying the Secure Hash Algorithm function, if `openssl`
  is available (checked with `Sys.which('openssl')`).

- pretty:

  Logical; if `TRUE`, will pretty-print the datapackage.

- summarize_ids:

  Logical; if `TRUE`, will include ID columns in schema field summaries.

- open_after:

  Logical; if `TRUE`, opens the written datapackage after saving.

- verbose:

  Logical; if `FALSE`, will not show status messages.

## Value

An invisible version of the updated datapackage, which is also written
to `datapackage.json` if `write = TRUE`.

## Details

`meta` should be a list with unnamed entries for entry in `filename`,
and each entry can include a named entry for any of these:

- source:

  A list or list of lists with entries for at least `name`, and ideally
  for `url`.

- ids:

  A list or list of lists with entries for at least `variable` (the name
  of a variable in the dataset). Might also include `map` with a list or
  path to a JSON file resulting in a list with an entry for each ID, and
  additional information about that entity, to be read in a its
  features. All files will be loaded to help with aggregation, but local
  files will be included in the datapackage, whereas hosted files will
  be loaded client-side.

- time:

  A string giving the name of a variable in the dataset representing a
  repeated observation of the same entity.

- variables:

  A list with named entries providing more information about the
  variables in the dataset. See
  [`dcf_measure_info`](https://DISSC-yale.github.io/dcf/reference/dcf_measure_info.md).

- vintage:

  A string specifying the time and/or location at which the data were
  produced.

## See also

Initialize the `datapackage.json` file with
[`dcf_datapackage_init`](https://DISSC-yale.github.io/dcf/reference/dcf_datapackage_init.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# write example data
write.csv(mtcars, "mtcars.csv")

# add it to an existing datapackage.json file in the current working directory
dcf_datapackage_add("mtcars.csv")
} # }
```
