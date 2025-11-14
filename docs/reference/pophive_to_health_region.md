# Map States to Health Regions

Maps state FIPS state numeric codes to Human Health Service regions.

## Usage

``` r
pophive_to_health_region(geoids, prefix = "Region ")
```

## Arguments

- geoids:

  Character vector of GEOIDs.

- prefix:

  A prefix to add to region IDs.

## Value

A vector of Health Region names the same length as `geoids`.

## Examples

``` r
pophive_to_health_region(c("01", "01001", "02", "02001"))
#> [1] "Region 4"  "Region 4"  "Region 10" "Region 10"
```
