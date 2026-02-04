#' Adds a Source Project
#'
#' Establishes a new data source project, used to collect and prepare data from a new source.
#'
#' @param name Name of the source.
#' @param project_dir Path to the Data Collection Framework project.
#' @param open_after Logical; if \code{FALSE}, will not open the project.
#' @param use_git Logical; if \code{TRUE}, will initialize a git repository.
#' @param use_workflow Logical; if \code{TRUE}, will add a GitHub Actions workflow.
#' @returns Nothing; creates default files and directories.
#' @section Project:
#'
#' Within a source project, there are two files to edits:
#' \itemize{
#'   \item \strong{\code{ingest.R}}: This is the primary script, which is automatically rerun.
#'     It should store raw data and resources in \code{raw/} where possible,
#'     then use what's in \code{raw/} to produce standard-format files in \code{standard/}.
#'     This file is sourced from its location during processing, so any system paths
#'     must be relative to itself.
#'   \item \strong{\code{measure_info.json}}: This is where you can record information
#'     about the variables included in the standardized data files.
#'     See \code{\link{dcf_measure_info}}.
#' }
#'
#' @examples
#' project_dir <- paste0(tempdir(), "/temp_project")
#' dcf_init("temp_project", dirname(project_dir))
#' dcf_add_source("source_name", project_dir)
#' list.files(paste0(project_dir, "/data/source_name"))
#'
#' @export

dcf_add_source <- function(
  name,
  project_dir = ".",
  open_after = interactive(),
  use_git = TRUE,
  use_workflow = FALSE
) {
  if (is.null(name)) {
    cli::cli_abort("provide a name")
  }
  name <- gsub("[^A-Za-z0-9]+", "_", name)
  is_standalone <- !file.exists(paste0(project_dir, "/settings.json"))
  data_dir <- dcf_read_settings(project_dir)$data_dir
  base_dir <- paste0(project_dir, "/", data_dir)
  base_path <- paste0(base_dir, "/", name, "/")
  dir.create(paste0(base_path, "raw"), showWarnings = FALSE, recursive = TRUE)
  dir.create(paste0(base_path, "standard"), showWarnings = FALSE)
  paths <- paste0(
    base_path,
    c(
      "measure_info.json",
      "ingest.R",
      "project.Rproj",
      "standard/datapackage.json",
      "process.json",
      "README.md",
      ".gitignore",
      ".github/workflows/process.yaml"
    )
  )
  if (!file.exists(paths[[1L]])) {
    dcf_measure_info(
      paths[[1L]],
      example_variable = list(),
      verbose = FALSE,
      open_after = FALSE
    )
  }
  if (!file.exists(paths[[2L]])) {
    writeLines(
      paste0(
        c(
          "#",
          "# Download",
          "#",
          "",
          "# add files to the `raw` directory",
          "",
          "#",
          "# Reformat",
          "#",
          "",
          "# read from the `raw` directory, and write to the `standard` directory",
          ""
        ),
        collapse = "\n"
      ),
      paths[[2L]]
    )
  }
  if (!file.exists(paths[[3L]])) {
    writeLines("Version: 1.0\n", paths[[3L]])
  }
  if (!file.exists(paths[[4L]])) {
    dcf_datapackage_init(
      name,
      dir = paste0(base_path, "standard"),
      quiet = TRUE
    )
  }

  if (!file.exists(paths[[5L]])) {
    dcf_process_record(
      paths[[5L]],
      list(
        name = name,
        type = "source",
        scripts = list(
          list(
            path = "ingest.R",
            manual = FALSE,
            frequency = 0L,
            last_run = "",
            run_time = "",
            last_status = list(log = "", success = TRUE)
          )
        ),
        checked = "",
        check_results = list(),
        standalone = is_standalone
      )
    )
  }
  if (!file.exists(paths[[6L]])) {
    writeLines(
      paste0(
        c(
          paste("#", name),
          "",
          "This is a dcf data source project, initialized with `dcf::dcf_add_source`.",
          "",
          "You can use the `dcf` package to check the project:",
          "",
          "```R",
          "dcf_check()",
          "```",
          "",
          "And process it:",
          "",
          "```R",
          "dcf_process()",
          "```"
        ),
        collapse = "\n"
      ),
      paths[[6L]]
    )
  }
  if (is_standalone) {
    if (use_git) {
      dcf_init_git(base_path)
      if (!file.exists(paths[[7L]])) {
        writeLines(
          paste(
            c(
              "*.Rproj",
              ".Rproj.user",
              "*.Rprofile",
              "*.Rhistory",
              "*.Rdata",
              ".DS_Store",
              "renv"
            ),
            collapse = "\n"
          ),
          paths[[7L]]
        )
      }
    }
    if (use_workflow && !file.exists(paths[[8L]])) {
      dir.create(dirname(paths[[8L]]), recursive = TRUE, showWarnings = FALSE)
      file.copy(
        system.file("workflows/build.yaml", package = "dcf"),
        paths[[8L]]
      )
    }
  }
  if (open_after) rstudioapi::openProject(paths[[3L]], newSession = TRUE)
}
