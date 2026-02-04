#' Adds a Bundle Project
#'
#' Establishes a new data bundle project, used to prepare outputs from standardized datasets.
#'
#' @param name Name of the bundle
#' @param project_dir Path to the Data Collection Framework project.
#' @param source_files A list or character vector, with names as paths to standard files
#' form source projects (relative to the project's data directory), and distribution file
#' names as entries. This associates input with output files, allowing for calculation of
#' a source state, and metadata inheritance from source files.
#' @param open_after Logical; if \code{FALSE}, will not open the project.
#' @param use_git Logical; if \code{TRUE}, will initialize a git repository.
#' @param use_workflow Logical; if \code{TRUE}, will add a GitHub Actions workflow.
#' @returns Nothing; creates default files and directories.
#' @section Project:
#'
#' Within a bundle project, there are two files to edits:
#' \itemize{
#'   \item \strong{\code{build.R}}: This is the primary script, which is automatically rerun.
#'     It should read data from the \code{standard} directory of source projects,
#'     and write to it's own \code{dist} directory.
#'   \item \strong{\code{measure_info.json}}: This should list all non-ID variable names
#'     in the data files within \code{dist}. These will inherit the standard measure info
#'     if found in the source projects referred to in \code{source_files}.
#'     If the \code{dist} name is different, but should still inherit standard measure info,
#'     a \code{source_id} entry with the original measure ID will be used to identify the original
#'     measure info.
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
  open_after = interactive(),
  use_git = TRUE,
  use_workflow = FALSE
) {
  if (missing(name)) {
    cli::cli_abort("specify a name")
  }
  name <- gsub("[^A-Za-z0-9]+", "_", name)
  is_standalone <- !file.exists(paste0(project_dir, "/settings.json"))
  data_dir <- dcf_read_settings(project_dir)$data_dir
  base_dir <- paste0(project_dir, "/", data_dir)
  base_path <- paste0(base_dir, "/", name, "/")
  if (!is.null(source_files)) {
    su <- !file.exists(paste0(
      data_dir,
      "/",
      if (is.null(names(source_files))) source_files else names(source_files)
    ))
    if (any(su)) {
      cli::cli_abort(
        "source file{? doesn't/s don't} exist: {settings$data_dir[su]}"
      )
    }
  }
  dir.create(paste0(base_path, "/dist"), showWarnings = FALSE, recursive = TRUE)
  paths <- paste0(
    base_path,
    "/",
    c(
      "README.md",
      "project.Rproj",
      "process.json",
      "measure_info.json",
      "build.R",
      "README.md",
      ".gitignore",
      ".github/workflows/process.yaml"
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
        source_files = if (!is.null(names(source_files)))
          as.list(source_files) else source_files
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
  if (!file.exists(paths[[6L]])) {
    writeLines(
      paste0(
        c(
          paste("#", name),
          "",
          "This is a dcf data bundle project, initialized with `dcf::dcf_add_bundle`.",
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
  if (open_after) rstudioapi::openProject(paths[[2L]], newSession = TRUE)
}
