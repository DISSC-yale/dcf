# Read Epic Cosmos Data

Read in metadata and data from an Epic Cosmos file.

## Usage

``` r
dcf_read_epic(path, path_root = ".", standard_names = NULL)
```

## Arguments

- path:

  Path to the file.

- path_root:

  Directory containing `path`, if it is not full.

- standard_names:

  A character vector with standard dataset names as names, and fixed
  patterns to search for in the metadata as values (in lowercase; e.g.,
  `c(condition = "condition name")`). These take precedence over the
  existing set of standard names, so make sure the pattern is
  sufficiently specific to the target dataset.

## Value

A list with `data.frame` entries for `metadata` and `data`.

## Examples

``` r
# write an example file
path <- tempfile(fileext = ".csv")
raw_lines <- c(
  "metadata field,metadata value,",
  ",,",
  ",Measures,Value Name",
  "Year,Measure 1,",
  "2020,m1,1",
  ",m2,2",
  "2021,m1,3",
  ",m2,4"
)
writeLines(raw_lines, path)

# read it in
dcf_read_epic(basename(path), dirname(path))
#> $metadata
#> $metadata$file
#> [1] "file85443989754c.csv"
#> 
#> $metadata$md5
#> [1] "7abcea997e7630c84a12284d5abc2b97"
#> 
#> $metadata$date_processed
#> [1] "2026-02-10 15:45:44 EST"
#> 
#> $metadata$standard_name
#> [1] ""
#> 
#> $metadata$`metadata field`
#> [1] "metadata value"
#> 
#> 
#> $data
#> # A tibble: 4 × 3
#>   year  measure_1 value_name
#>   <chr> <chr>     <chr>     
#> 1 2020  m1        1         
#> 2 2020  m2        2         
#> 3 2021  m1        3         
#> 4 2021  m2        4         
#> 
```
