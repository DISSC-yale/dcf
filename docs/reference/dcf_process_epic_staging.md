# Process Epic Stating Files

Process Epic stating files, lightly standardizing them and moving them
to raw.

## Usage

``` r
dcf_process_epic_staging(
  staging_dir = "raw/staging",
  out_dir = "raw",
  verbose = TRUE,
  cleanup = TRUE,
  ...
)
```

## Arguments

- staging_dir:

  Directory containing the staging files.

- out_dir:

  Directory to write new raw files to.

- verbose:

  Logical; if `FALSE`, will not show status messages.

- cleanup:

  Logical; if `FALSE`, will not remove staging files after being
  processed.

- ...:

  Passes additional arguments to
  [`dcf_read_epic`](https://DISSC-yale.github.io/dcf/reference/dcf_read_epic.md).

## Value

`NULL` if no staging files are found. Otherwise, a list with entries for
`data` and `metadata`. Each of these are lists with entries for each
recognized standard name, with potentially combined outputs similar to
[`dcf_read_epic`](https://DISSC-yale.github.io/dcf/reference/dcf_read_epic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  # run from a source project
  dcf_process_epic_staging()
} # }
```
