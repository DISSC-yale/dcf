# Initialize a Data Collection Project

Establishes a new data collection framework project.

## Usage

``` r
dcf_init(
  name,
  base_dir = ".",
  data_dir = "data",
  github_account = "",
  branch = "main",
  repo_name = name,
  use_git = TRUE,
  open_after = FALSE
)
```

## Arguments

- name:

  Name of the source. Defaults to the current directory name.

- base_dir:

  Path to the parent of the project directory (where the `name`
  directory should be created). If `name` is not specified, will treat
  the current directory as `name`, and `".."` as `base_dir`.

- data_dir:

  Name of the directory to store projects in, relative to `base_dir`.

- github_account:

  Name of the GitHub account that will host the repository.

- branch:

  Name of the repository's branch.

- repo_name:

  Name of the repository.

- use_git:

  Logical; if `TRUE`, will initialize a git repository.

- open_after:

  Logical; if `TRUE`, will open the project in a new RStudio instance.

## Value

Nothing; creates default files and directories.

## Data Collection Project

A data collection project starts with a `settings.json` file, which
specifies where source and bundle projects live (a `data` subdirectory
by default).

The bulk of the project will then be in the source and bundle projects,
as created by the
[`dcf_add_source`](https://DISSC-yale.github.io/dcf/reference/dcf_add_source.md)
and
[`dcf_add_bundle`](https://DISSC-yale.github.io/dcf/reference/dcf_add_bundle.md).

Once these sub-projects are in place, they can be operated over by the
[`dcf_build`](https://DISSC-yale.github.io/dcf/reference/dcf_build.md),
which processes each sub-project using
[`dcf_process`](https://DISSC-yale.github.io/dcf/reference/dcf_process.md),
and checks them with
[`dcf_check`](https://DISSC-yale.github.io/dcf/reference/dcf_check.md),
resulting in a report.

## Examples

``` r
base_dir <- tempdir()
dcf_init("project_name", base_dir)
list.files(paste0(base_dir, "/project_name"))
#> [1] "README.md"     "project.Rproj" "scripts"       "settings.json"
```
