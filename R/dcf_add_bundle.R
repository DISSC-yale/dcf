#' Adds a Bundle Project
#'
#' Establishes a new data bundle project, used to prepare outputs from standardized datasets.
#'
#' @param name Name of the bundle
#' @param project_dir Path to the Data Collection Framework project.
#' @param source_files Character vector of paths to standard files form source projects.
#' @param open_after Logical; if \code{FALSE}, will not open the project.
#' @returns Nothing; creates default files and directories.
#' @section Project:
#'
#' Within a bundle project, there are two files to edits:
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
#' dcf_add_bundle("bundle_name", project_dir)
#' list.files(paste0(project_dir, "/data/bundle_name"))
#'
#' @export

dcf_add_bundle <- function(
  name,
  project_dir = ".",
  source_files = NULL,
  open_after = interactive()
) {
  if (missing(name)) {
    cli::cli_abort("specify a name")
  }
  name <- gsub("[^A-Za-z0-9]+", "_", name)
  settings <- dcf_read_settings(project_dir)
  base_dir <- paste(c(project_dir, settings$data_dir, name), collapse = "/")
  dir.create(paste0(base_dir, "/dist"), showWarnings = FALSE, recursive = TRUE)
  paths <- paste0(
    base_dir,
    "/",
    c(
      "README.md",
      "project.Rproj",
      "process.json",
      "measure_info.json",
      "build.R"
    )
  )
  if (!file.exists(paths[[1L]])) {
    writeLines(
      paste0(
        c(
          paste("#", name),
          "",
          "This is a Data Collection Framework data bundle project, initialized with `dcf::dcf_add_bundle`.",
          "",
          "You can us the `dcf` package to rebuild the bundle:",
          "",
          "```R",
          paste0('dcf::dcf_process("', name, '", "..")'),
          "```"
        ),
        collapse = "\n"
      ),
      paths[[1L]]
    )
  }
  if (!file.exists(paths[[2L]])) {
    writeLines("Version: 1.0\n", paths[[2L]])
  }
  if (!file.exists(paths[[3L]])) {
    jsonlite::write_json(
      list(
        name = name,
        type = "bundle",
        scripts = list(
          list(
            path = "build.R",
            last_run = "",
            run_time = "",
            last_status = list(log = "", success = TRUE)
          )
        ),
        source_files = source_files
      ),
      paths[[3L]],
      auto_unbox = TRUE,
      pretty = TRUE
    )
  }
  if (!file.exists(paths[[4L]])) {
    writeLines("{}\n", paths[[4L]])
  }
  if (!file.exists(paths[[5L]])) {
    writeLines(
      paste0(
        c(
          "# read data from data source projects",
          "# and write to this project's `dist` directory",
          ""
        ),
        collapse = "\n"
      ),
      paths[[5L]]
    )
  }
  if (open_after) rstudioapi::openProject(paths[[2L]], newSession = TRUE)
}
