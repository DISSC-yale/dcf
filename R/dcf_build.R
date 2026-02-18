#' Run a Project's Build Process
#'
#' Build a Data Collection Framework project,
#' which involves processing and checking all data projects.
#'
#' @param project_dir Path to the Data Collection Framework project to be built.
#' @param is_auto Logical; if \code{FALSE}, will run \code{\link{dcf_process}} as if it were run
#' manually.
#' @param ... Passes arguments to \code{\link{dcf_process}}.
#' @param make_diagram Logical; if \code{FALSE}, will not make a \code{status.md} diagram.
#' @param make_file_log Logical; if \code{FALSE}, will not make a \code{file_log.json} output.
#' @returns A version of the project report, which is also written to
#' \code{project_dir/docs/report.json.gz}.
#' @examples
#' project_file <- "../../../pophive/pophive_demo"
#' if (file.exists(project_file)) {
#'   report <- dcf_build(project_file)
#' }
#' @export

dcf_build <- function(
  project_dir = ".",
  is_auto = TRUE,
  ...,
  make_diagram = TRUE,
  make_file_log = TRUE
) {
  settings <- dcf_read_settings(project_dir)
  is_standalone <- isTRUE(settings$standalone)
  data_dir <- if (is_standalone) {
    dirname(project_dir)
  } else {
    paste0(project_dir, "/", settings$data_dir)
  }

  processes <- list.files(
    data_dir,
    "process\\.json",
    recursive = TRUE,
    full.names = TRUE
  )
  process_state <- tools::md5sum(processes)
  process <- dcf_process(project_dir = project_dir, is_auto = TRUE, ...)
  issues <- dcf_check(project_dir = project_dir)
  report_file <- paste0(project_dir, "/report.json.gz")
  if (
    !identical(
      process_state,
      tools::md5sum(list.files(
        data_dir,
        "process\\.json",
        recursive = TRUE,
        full.names = TRUE
      ))
    )
  ) {
    datapackages <- list.files(
      data_dir,
      "datapackage\\.json",
      recursive = TRUE,
      full.names = TRUE
    )
    names(datapackages) <- sub(
      "^/",
      "",
      sub(
        data_dir,
        "",
        sub("/datapackage.json", "", datapackages, fixed = TRUE),
        fixed = TRUE
      )
    )
    names(processes) <- sub(
      "^/",
      "",
      sub(
        data_dir,
        "",
        sub("/process.json", "", processes, fixed = TRUE),
        fixed = TRUE
      )
    )
    report <- list(
      date = Sys.time(),
      settings = settings,
      source_times = process$timings,
      logs = process$logs,
      issues = issues,
      metadata = lapply(datapackages, jsonlite::read_json),
      processes = lapply(processes, jsonlite::read_json)
    )
    with_levels <- list()
    measures <- list()
    for (p in seq_along(report$metadata)) {
      for (r in seq_along(report$metadata[[p]]$resources)) {
        for (f in seq_along(
          report$metadata[[p]]$resources[[r]]$schema$fields
        )) {
          info <- report$metadata[[p]]$resources[[r]]$schema$fields[[f]]$info
          if (!is.null(info)) {
            measures[[info$id]] <- list(
              project = report$metadata[[p]]$name,
              file = report$metadata[[p]]$resources[[r]]$filename,
              info = info
            )
            if (!is.null(info$levels)) {
              with_levels <- c(with_levels, list(c(p, r, f)))
            }
          }
        }
      }
    }
    for (cords in with_levels) {
      levels <- report$metadata[[cords[[1L]]]]$resources[[cords[[
        2L
      ]]]]$schema$fields[[cords[[3L]]]]$info$levels
      source_info <- list()
      for (level_id in names(levels)) {
        level <- levels[[level_id]]
        source_id <- if (!is.list(level) || is.null(level$source_id))
          level_id else level$source_id
        source_info[[source_id]] <- measures[[source_id]]
      }
      report$metadata[[cords[[1L]]]]$resources[[cords[[
        2L
      ]]]]$schema$fields[[cords[[3L]]]]$info$source_info <- source_info
    }
    jsonlite::write_json(
      report,
      gzfile(report_file),
      auto_unbox = TRUE,
      dataframe = "columns"
    )
  } else {
    report <- jsonlite::read_json(report_file)
  }
  if (make_file_log) {
    file_log <- list()
    for (file_dir in names(report$metadata)) {
      if (grepl("/dist", file_dir, fixed = TRUE)) {
        p <- report$metadata[[file_dir]]
        for (p_file in p$resources) {
          file_log[[paste0(
            settings$data_dir,
            "/",
            file_dir,
            "/",
            p_file$filename
          )]] <- list(
            updated = if (length(p_file$vintage)) p_file$vintage else
              p_file$last_modified,
            md5 = p_file$md5
          )
        }
      }
    }
    jsonlite::write_json(
      file_log,
      paste0(project_dir, "/file_log.json"),
      auto_unbox = TRUE
    )
  }
  if (make_diagram) {
    dcf_status_diagram(project_dir)
  }
  invisible(report)
}
