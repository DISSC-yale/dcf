# Read Epic Cosmos Data

Read in metadata and data from an Epic Cosmos file.

## Usage

``` r
pophive_read_epic(path, path_root = ".")
```

## Arguments

- path:

  Path to the file.

- path_root:

  Directory containing `path`, if it is not full.

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
pophive_read_epic(basename(path), dirname(path))
#> $metadata
#> $metadata$file
#> [1] "file2d5836bb16e6.csv"
#> 
#> $metadata$md5
#> [1] "7abcea997e7630c84a12284d5abc2b97"
#> 
#> $metadata$date_processed
#> [1] "2025-06-20 14:45:29 EDT"
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
#>    year measure_1 value_name
#>   <int> <chr>          <int>
#> 1  2020 m1                 1
#> 2  2020 m2                 2
#> 3  2021 m1                 3
#> 4  2021 m2                 4
#> 
```
