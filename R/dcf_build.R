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
#' project_file <- "../../../pophive"
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
  data_dir <- paste0(project_dir, "/", settings$data_dir)
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
    names(datapackages) <- dirname(sub(
      "^/",
      "",
      sub(data_dir, "", datapackages, fixed = TRUE)
    ))
    names(processes) <- dirname(sub(
      "^/",
      "",
      sub(data_dir, "", processes, fixed = TRUE)
    ))
    report <- list(
      date = Sys.time(),
      settings = settings,
      source_times = process$timings,
      logs = process$logs,
      issues = issues,
      metadata = lapply(datapackages, jsonlite::read_json),
      processes = lapply(processes, jsonlite::read_json)
    )
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
            updated = p_file$last_modified,
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
