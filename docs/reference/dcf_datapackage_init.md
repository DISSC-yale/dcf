# Create a datapackage.json template

Initialize dataset documentation with a `datapackage.json` template,
based on a [Data
Package](https://specs.frictionlessdata.io/data-package) standard.

## Usage

``` r
dcf_datapackage_init(
  name,
  title = name,
  dir = ".",
  ...,
  write = TRUE,
  overwrite = FALSE,
  quiet = !interactive()
)
```

## Arguments

- name:

  A unique name for the dataset; allowed characters are `[a-z._/-]`.

- title:

  A display name for the dataset; if not specified, will be a formatted
  version of `name`.

- dir:

  Directory in which to save the `datapackage.json` file.

- ...:

  passes arguments to
  [`dcf_datapackage_add`](https://DISSC-yale.github.io/dcf/reference/dcf_datapackage_add.md).

- write:

  Logical; if `FALSE`, the package object will not be written to a file.

- overwrite:

  Logical; if `TRUE` and `write` is `TRUE`, an existing
  `datapackage.json` file will be overwritten.

- quiet:

  Logical; if `TRUE`, will not print messages or navigate to files.

## Value

An invisible list with the content written to the `datapackage.json`
file.

## See also

Add basic information about a dataset with
[`dcf_datapackage_add`](https://DISSC-yale.github.io/dcf/reference/dcf_datapackage_add.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# make a template datapackage.json file in the current working directory
dcf_datapackage_init("mtcars", "Motor Trend Car Road Tests")
} # }
```
