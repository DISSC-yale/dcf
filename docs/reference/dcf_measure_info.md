# Make a measurement metadata file

Make a `measure_info.json` file, or add measure entries to an existing
one.

## Usage

``` r
dcf_measure_info(
  path,
  ...,
  info = list(),
  references = list(),
  sources = list(),
  strict = FALSE,
  include_empty = TRUE,
  overwrite_entry = FALSE,
  render = NULL,
  overwrite = FALSE,
  write = TRUE,
  verbose = TRUE,
  open_after = interactive()
)
```

## Arguments

- path:

  Path to the `measure_info.json` file, existing or to be created.

- ...:

  Lists containing individual measure items. See the Measure Entries
  section.

- info:

  A list containing measurement information to be added.

- references:

  A list containing citation entries. See the Reference Entries section.

- sources:

  A list containing source entries. See the Sources Entries section.

- strict:

  Logical; if `TRUE`, will only allow recognized entries and values.

- include_empty:

  Logical; if `FALSE`, will omit entries that have not been provided.

- overwrite_entry:

  Logical; if `TRUE`, will replace rather than add to an existing entry.

- render:

  Path to save a version of `path` to, with dynamic entries expanded.
  See the Dynamic Entries section.

- overwrite:

  Logical; if `TRUE`, will overwrite rather than add to an existing
  `path`.

- write:

  Logical; if `FALSE`, will not write the build or rendered measure
  info.

- verbose:

  Logical; if `FALSE`, will not display status messages.

- open_after:

  Logical; if `FALSE`, will not open the measure file after
  writing/updating.

## Value

An invisible list containing measurement metadata (the rendered version
if made).

## Measure Entries

Measure entries are named by the unique variable name with any of these
entries (if `strict`):

- **`id`**: Unique identifier of the measure; same as the entry name.
  This is meant to correspond to the column name containing the measure
  in data files. It should be minimal in length while still being unique
  across all files within the project. It should only contain the
  characters `a-z`, `0-9`, or `_`.

- **`short_name`**: Shortest possible display name.

- **`long_name`**: Longer display name.

- **`category`**: Arbitrary category for the measure.

- **`short_description`**: Shortest possible description.

- **`long_description`**: Complete description. Either description can
  include TeX-style equations, enclosed in escaped square brackets
  (e.g., `"The equation \\[a_{i} = b^\\frac{c}{d}\\] was used."`; or
  `$...$`, `\\(...\\)`, or `\\begin{math}...\\end{math}`). The final
  enclosing symbol must be followed by a space or the end of the string.
  These are pre-render to MathML with
  [`katex_mathml`](https://docs.ropensci.org/katex/reference/katex.html).

- **`statement`**: String with dynamic references to entity features
  (e.g., `"measure value = {value}"`). References can include:

  - `value`: Value of a currently displaying variable at a current time.

  - `region_name`: Alias of `features.name`.

  - `features.<entry>`: An entity feature, coming from
    `entity_info.json` or GeoJSON properties. All entities have at least
    `name` and `id` entries (e.g., `"{features.id}"`).

  - `variables.<entry>`: A variable feature such as `name` which is the
    same as `id` (e.g., `"{variables.name}"`).

  - `data.<variable>`: The value of another variable at a current time
    (e.g., `"{data.variable_a}"`).

- **`measure_type`**: Type of the measure's value. Recognized types are
  displayed in a special way:

  - `year` or `integer` show as entered (usually as whole numbers).
    Other numeric types are rounded to show a set number of digits.

  - `percent` shows as `{value}%`.

  - `minutes` shows as `{value} minutes`.

  - `dollar` shows as `${value}`.

  - `internet speed` shows as `{value} Mbps`.

- **`unit`**: Prefix or suffix associated with the measure's type, such
  as `%` for `percent`, or `Mbps` for `rate`.

- **`time_resolution`**: Temporal resolution of the variable, such as
  `year` or `week`.

- **`restrictions`**: A license or description of restrictions that may
  apply to the measure.

- **`sources`**: A list or list of list containing source information,
  including any of these entries:

  - `id`: An ID found in the `_sources` entry, to inherit entries from.

  - `name`: Name of the source (such as an organization name).

  - `url`: General URL of the source (such as an organization's
    website).

  - `location`: More specific description of the source (such as a the
    name of a particular data product).

  - `location_url`: More direct URL to the resource (such as a page
    listing data products).

- **`citations`**: A vector of reference ids (the names of `reference`
  entries; e.g., `c("ref1", "ref3")`).

- **`categories`**: A named list of categories, with any of the other
  measure entries, or a `default` entry giving a default category name.
  See the Dynamic Entries section.

- **`variants`**: A named list of variants, with any of the other
  measure entries, or a `default` entry giving a default variant name.
  See the Dynamic Entries section.

## Bundle Entries

Measures in bundle projects can inherit the information provided in
source bundles. This will happen when either the measure has the same
name as an existing measure (in which case, the info can be empty:
`"existing_measure": {}`), or when a special `source_id` entry maps to
an existing measure
(`"new_measure": {"source_id": "existing_measure"}`).

If bundle files are in tall format, such that measures are stacked, when
can be documented by (1) using a special `levels` entry to map levels of
a variable that identifies the measure, then (2) using a special
`measure_column` entry for variable containing values, to point to that
identifier variable:

1.  `"measure": {"levels": {"existing_measure": {}, "new_measure": {"source_id": "existing_measure"}}}`

2.  `"value": {"measure_column": "measure"}`

## Duplicate Names

It is strongly preferable that every distinct measure has a name that is
unique across all files within a collection project.

If names must be duplicated between files, they can be prefixed with the
path to the file containing them, relative to the data directory (or
standalone parent), separated by a bar (`|`; e.g.,
`subproject_name/dist/data.csv.gz|measure_name`).

## Dynamic Entries

You may have several closely related variables in a dataset, which share
sections of metadata, or have formulaic differences. In cases like this,
the `categories` and/or `variants` entries can be used along with
dynamic notation to construct multiple entries from a single template.

Though functionally the same, `categories` might include broken-out
subsets of some total (such as race groups, as categories of a total
population), whereas `variants` may be different transformations of the
same variable (such as raw counts versus percentages).

In dynamic entries, `{category}` or `{variant}` refers to entries in the
`categories` or `variants` lists. By default, these are replaced with
the name of each entries in those lists (e.g., `"variable_{category}"`
where `categories = "a"` would become `"variable_a"`). A `default` entry
would change this behavior (e.g., with
`categories = list(a = list(default = "b")` that would become
`"variable_b"`). Adding `.name` would force the original behavior (e.g.,
`"variable_{category.name}"` would be `"variable_a"`). A name of
`"blank"` is treated as an empty string.

When notation appears in a measure info entry, they will first default
to a matching name in the `categories` or `variants` list; for example,
`short_name` in `list(short_name = "variable {category}")` with
`categories = list(a = list(short_name = "(category a)"))` would become
`"variable (category a)"`. To force this behavior, the entry name can be
included in the notation (e.g., `"{category.short_name}"` would be
`"variable (category a)"` in any entry).

Only string entries are processed dynamically – any list-like entries
(such as `source`, `citations`, or `layer`) appearing in `categories` or
`variants` entries will fully replace the base entry.

Dynamic entries can be kept dynamic when passed to a data site, but can
be rendered for other uses, where the rendered version will have each
dynamic entry replaced with all unique combinations of `categories` and
`variants` entries, assuming both are used in the dynamic entry's name
(e.g., `"variable_{category}_{variant}"`). See Examples.

## Reference Entries

Reference entries can be included in a `_references` entry, and should
have names corresponding to those included in any of the measures'
`citation` entries. These can include any of these entries:

- **`id`**: The reference id, same as the entry name.

- **`author`**: A list or list of lists specifying one or more authors.
  These can include entries for `given` and `family` names.

- **`year`**: Year of the publication.

- **`title`**: Title of the publication.

- **`journal`**: Journal in which the publication appears.

- **`volume`**: Volume number of the journal.

- **`page`**: Page number of the journal.

- **`doi`**: Digital Object Identifier, from which a link is made
  (`https://doi.org/{doi}`).

- **`version`**: Version number of software.

- **`url`**: Link to the publication, alternative to a DOI.

## Source Entries

Source entries can be included in a `_sources` entry, and should have
names corresponding to those included in any of the measures' `sources`
entry. These can include any of these entries:

- **`name`**: Name of the source.

- **`url`**: Link to the source's site.

- **`description`**: A description of the source.

- **`notes`**: A list of additional notes about the source.

- **`organization`**: Name of a higher-level organization that the
  source is a part of.

- **`organization_url`**: Link to the organization's site.

- **`category`**: A top-level category classification.

- **`subcategory`**: A lower-level category classification.

## Examples

``` r
path <- tempfile()

# make an initial file
dcf_measure_info(path, "measure_name" = list(
  id = "measure_name",
  short_description = "A measure.",
  statement = "This entity has {value} measure units."
), verbose = FALSE)

# add another measure to that
measure_info <- dcf_measure_info(path, "measure_two" = list(
  id = "measure_two",
  short_description = "Another measure.",
  statement = "This entity has {value} measure units."
), verbose = FALSE)
names(measure_info)
#> [1] "measure_name" "measure_two" 

# add a dynamic measure, and make a rendered version
measure_info_rendered <- dcf_measure_info(
  path,
  "measure_{category}_{variant.name}" = list(
    id = "measure_{category}_{variant.name}",
    short_description = "Another measure ({category}; {variant}).",
    statement = "This entity has {value} {category} {variant}s.",
    categories = c("a", "b"),
    variants = list(u1 = list(default = "U1"), u2 = list(default = "U2"))
  ),
  render = TRUE, verbose = FALSE
)
names(measure_info_rendered)
#> [1] "measure_name" "measure_two"  "measure_a_u1" "measure_b_u1" "measure_a_u2"
#> [6] "measure_b_u2"
measure_info_rendered[["measure_a_u1"]]$statement
#> [1] "This entity has {value} a U1s."
```
