#' Initialize a Data Collection Project
#'
#' Establishes a new data collection framework project.
#'
#' @param name Name of the source. Defaults to the current directory name.
#' @param base_dir Path to the parent of the project directory (where the \code{name}
#' directory should be created). If \code{name} is not specified, will treat the current
#' directory as \code{name}, and \code{".."} as \code{base_dir}.
#' @param data_dir Name of the directory to store projects in, relative to \code{base_dir}.
#' @param github_account Name of the GitHub account that will host the repository.
#' @param branch Name of the repository's branch.
#' @param repo_name Name of the repository.
#' @param use_git Logical; if \code{TRUE}, will initialize a git repository.
#' @param open_after Logical; if \code{TRUE}, will open the project in a new RStudio instance.
#' @returns Nothing; creates default files and directories.
#' @section Data Collection Project:
#'
#' A data collection project starts with a \code{settings.json} file, which
#' specifies where source and bundle projects live (a \code{data} subdirectory by default).
#'
#' The bulk of the project will then be in the source and bundle projects, as created
#' by the \code{\link{dcf_add_source}} and \code{\link{dcf_add_bundle}}.
#'
#' Once these sub-projects are in place, they can be operated over by the
#' \code{\link{dcf_build}}, which processes each sub-project using
#' \code{\link{dcf_process}}, and checks them with \code{\link{dcf_check}},
#' resulting in a report.
#'
#' @examples
#' base_dir <- tempdir()
#' dcf_init("project_name", base_dir)
#' list.files(paste0(base_dir, "/project_name"))
#'
#' @export

dcf_init <- function(
  name,
  base_dir = ".",
  data_dir = "data",
  github_account = "",
  branch = "main",
  repo_name = name,
  use_git = TRUE,
  open_after = FALSE
) {
  if (missing(name)) {
    base_dir <- normalizePath(base_dir, "/", FALSE)
    name <- basename(base_dir)
  } else {
    name <- gsub("[^A-Za-z0-9]+", "_", name)
  }
  base_path <- paste0(base_dir, "/", name, "/")
  dir.create(base_path, showWarnings = FALSE, recursive = TRUE)
  paths <- paste0(
    base_path,
    c(
      "project.Rproj",
      "settings.json",
      "README.md",
      "scripts/build.R",
      ".github/workflows/build.yaml",
      ".gitignore"
    )
  )
  if (
    !file.exists(paths[[1L]]) && !length(list.files(base_path, "\\.Rproj$"))
  ) {
    writeLines("Version: 1.0\n", paths[[1L]])
  }
  if (!file.exists(paths[[2L]])) {
    jsonlite::write_json(
      list(
        name = name,
        data_dir = data_dir,
        github_account = github_account,
        branch = "main",
        repo_name = repo_name
      ),
      paths[[2L]],
      auto_unbox = TRUE,
      pretty = TRUE
    )
  }
  if (!file.exists(paths[[3L]])) {
    writeLines(
      paste0(
        c(
          paste("#", name),
          "",
          "This is a Data Collection Framework project, initialized with `dcf::dcf_init`.",
          "",
          "You can us the `dcf` package to check the source projects:",
          "",
          "```R",
          paste0('dcf::dcf_check_source()'),
          "```",
          "",
          "And process them:",
          "",
          "```R",
          paste0('dcf::dcf_process()'),
          "```"
        ),
        collapse = "\n"
      ),
      paths[[3L]]
    )
  }
  if (!file.exists(paths[[4L]])) {
    dir.create(dirname(paths[[4L]]), showWarnings = FALSE)
    writeLines(
      paste(c("library(dcf)", "dcf_build()"), collapse = "\n"),
      paths[[4L]]
    )
  }
  if (!file.exists(paths[[5L]])) {
    dir.create(dirname(paths[[5L]]), recursive = TRUE, showWarnings = FALSE)
    file.copy(system.file("workflows/build.yaml", package = "dcf"), paths[[5L]])
  }
  if (use_git) {
    dcf_init_git(base_path)
    if (!file.exists(paths[[6L]])) {
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
        paths[[6L]]
      )
    }
  }
  if (open_after) rstudioapi::openProject(paths[[1L]], newSession = TRUE)
}
