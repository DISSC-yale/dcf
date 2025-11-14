# Adds a source project structure

Adds a source project structure

## Usage

``` r
pophive_update_manifest(path, url = NULL, description = NULL)
```

## Arguments

- path:

  Path of the file to record the state of.

- url:

  URL where the file was originally downloaded from.

- description:

  High-level description of the file, to add to the metadata entry.

## Value

List with file metadata, which is also added to a `manifest.json` file:

- url:

  URL of the file.

- description:

  Provided description.

- time:

  Time downloaded; YYYY-MM-DD HH:MM:SS TZ

- bytes:

  Size of the file in bytes.

- md5:

  MD5 hash of the file.

## Examples

``` r
if (dir.exists("../data")) {
  # download the file
  url <- paste0(
    "https://raw.githubusercontent.com/DISSC-yale/gtrends_collection/",
    "refs/heads/main/data/term%3D%252Fg%252F11j30ybfx6/part-0.parquet"
  )
  path <- tempfile(fileext = ".parquet")
  download.file(url, path, mode = "wb")

  # add/update metadata in manifest.json
  pophive_update_manifest(
    path, url,
    description = paste(
      "Google Trends data for the /g/11j30ybfx6",
      "(Respiratory syncytial virus vaccine) topic."
    )
  )
}
```
