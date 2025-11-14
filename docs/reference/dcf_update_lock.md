# Update renv.lock

Updates the `renv.lock` file with dependencies found in project scripts.

## Usage

``` r
dcf_update_lock(project_dir = ".", refresh = TRUE)
```

## Arguments

- project_dir:

  Directory of the Data Collection project.

- refresh:

  Logical; if `FALSE`, will update an existing `renv.lock` file, rather
  than recreating it.

## Value

Nothing; writes an `renv.lock` file.

## Examples

``` r
if (FALSE) { # \dontrun{
  dcf_update_lock()
} # }
```
