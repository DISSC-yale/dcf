# Download Data from the CDC

Download data and metadata from the Centers for Disease Control and
Prevention (CDC).

## Usage

``` r
pophive_download_cdc(id, out_dir = "raw", state = NULL, verbose = TRUE)
```

## Arguments

- id:

  ID of the resource (e.g., `ijqb-a7ye`).

- out_dir:

  Directory in which to save the metadata and data files.

- state:

  The state ID of a previous download; if provided, will only download
  if the new state does not match.

- verbose:

  Logical; if `FALSE`, will not display status messages.

## Value

The state ID of the downloaded files; downloads files (`<id>.json` and
`<id>.csv.xz`) to `out_dir`

## `data.cdc.gov` URLs

For each resource ID, there are 3 relevant CDC URLs:

- **`resource/<id>`**: This redirects to the resource's main page, with
  displayed metadata and a data preview (e.g.,
  [data.cdc.gov/resource/ijqb-a7ye](https://data.cdc.gov/resource/ijqb-a7ye)).

- **`api/views/<id>`**: This is a direct link to the underlying JSON
  metadata (e.g.,
  [data.cdc.gov/api/views/ijqb-a7ye](https://data.cdc.gov/api/views/ijqb-a7ye)).

- **`api/views/<id>/rows.csv`**: This is a direct link to the full CSV
  dataset (e.g.,
  [data.cdc.gov/api/views/ijqb-a7ye/rows.csv](https://data.cdc.gov/api/views/ijqb-a7ye/rows.csv)).

## Examples

``` r
if (FALSE) { # \dontrun{
  pophive_download_cdc("ijqb-a7ye")
} # }
```
