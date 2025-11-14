# Standardize Epic Data

Standardize a raw Epic data table.

## Usage

``` r
pophive_standardize_epic(raw_data)
```

## Arguments

- raw_data:

  Raw Epic data, such as returned from
  [pophive_read_epic](https://DISSC-yale.github.io/dcf/reference/pophive_read_epic.md).

## Value

A standardized form of `data`.

## Standardization

- Collapse location columns (`state` or `county`) to a single
  `geography` column, and region names to IDs.

- Collapse time columns (`year`, `month`, or `week`) to a single `time`
  column, and clean up value formatting.

- Drop rows with no values across value columns.

## Examples

``` r
if (FALSE) { # \dontrun{
  raw_data <- pophive_read_epic("data/epic/raw/flu.csv.xz")
  standard_data <- pophive_process_epic_raw(raw_data)
} # }
```
