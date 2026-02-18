# Standards

Aside from the stricter standards that are established and checked by
the package, there are many soft standards to try to align with as part
of building up a source project.

## Naming

There are a few general guidelines for naming files:

1.  Only use portable characters: Best to stick to `a-z0-9_-`, but
    certainly never use `:`.
2.  Keep names short: There is a total path length limit on Windows, so
    avoid long files names especially when deeply nested within
    directories. Avoid duplicating information in the path (e.g.,
    instead of `category/category_data.csv` use `category/data.csv`).
3.  Avoid new files: When a file represents the same thing (e.g., result
    of a download from a given source), it should keep the same name, as
    opposed to having dates or version numbers appended to the name. New
    versions of files should overwrite previous versions, potentially
    after being merged, deepening on the data source. Versions of files
    are retained in the git tree, rather than in separate files.

And there are similar considerations when naming variables:

1.  Best to stick to a limited set of characters (`a-z0-9_`).
2.  Keep lengths minimal, while still being identifiable – you should be
    able to tell what the variable means from the name, but complete
    information should be stored in the measure info entry. For
    instance, only include subset or value-related information if there
    are multiple variants (e.g., `value_count` and `value_percent`).
3.  Make names unique across source projects. This means including
    enough relevant source information. The source may implicitly
    include information about the value, so this should be kept out of
    the name, and only made explicit in the measure info.

## Compression

Almost any data files that can be compressed should be compressed.

The main reason not to compress a file is if it is meant for viewing,
rather than being read in.

Gzip is the most portable type of compression, and files that are
gzip-compressed can be read in from a URL, rather than needing to be
downloaded and read in separately. This makes gzip good for the standard
output files.

LZMA (xz) generally results in smaller files, so it may be best for raw
files.

Parquet files default to snappy compression, but can also use gzip. Gzip
generally results in smaller files, but is slightly less readily usable
in browsers, so it may be best to use snappy if files are meant for the
web, and use gzip otherwise.

The `vroom` package, among others, automatically compresses when
writing, and decompresses when reading, based on the file name:

``` r
data <- vroom::vroom("data.csv.xz")
vroom::vroom_write(data, "data.csv.xz", ",")
```

The some standard functions (like `read.csv`) now automatically
decompress, but do not automatically compress, so a connection must be
used when writing:

``` r
data <- read.csv("data.csv.xz")
write.csv(data, xzfile("data.csv.xz"), row.names = FALSE)
```

If a function doesn’t automatically handle compression extensions, but
does accept a connection, you can use the `gzfile` function across
compression types to read:

``` r
data <- arrow::read_csv_arrow(gzfile("data.csv.xz"))
```

## Scripts

All automated scripts must run within a fresh remote machine. Packages
used within the script should be available, depending on the project’s
`renv.lock` file being up to date (potentially updated with
`dcf_update_lock`). But no absolute file paths, and no relative local
paths outside of the project should be used.

Scripts are run separately in their own environment, so no information
will be passed between them. If you need to pass information between
scripts, write it to a file both scripts can access (that is within the
project).

### Regulating Runs

#### Within Scripts

Within scripts, you might want to make complete re-running depend on the
state of the original data (e.g., the date that data were last update).
The state you have available will depend on the source, but once you
have a state value, you can store it in the project’s file to refer to
between runs.

The most general state would be the hash of the raw files, so an
`ingest.R` file might look like this:

``` r
# calcualte the raw state
raw_state <- as.list(tools::md5sum(list.files(
  "raw",
  recursive = TRUE,
  full.names = TRUE
)))

# read the project's process file
process <- dcf::dcf_process_record()

# process raw only if state has changed
if (!identical(process$raw_state, raw_state)) {

  # some code to read raw files and write standard files
  
  # write the new raw state to the project's process file
  process$raw_state <- raw_state
  dcf::dcf_process_record(updated = process)
}
```

This state value isn’t ideal since you would need to re-download files
to calculate it. Better to use some form of state ID provided from the
source (such as a file hash or update data).

#### Within Source Projects

In [source
projects](https://dissc-yale.github.io/dcf/reference/dcf_add_source.html),
the `process.json` has 2 fields that can be used to control when a
script is run:

- If `manual` is true, the script will be skipped when run from
  `dcf_built` – it will only run from `dcf_process`. This may be useful
  if the script depend on local resources or a manual process, so you
  only want it to run locally.
- If `frequency` is not 0, the script will only run every `frequency`
  days. This may be useful if your build process is run frequently, but
  you know a particular script will need to be run less frequently
  (e.g., if the data source only updates once a year).
