#' Run a Project's Build Process
#'
#' Build a Data Collection Framework project,
#' which involves processing and checking all data projects.
#'
#' @param project_dir Path to the Data Collection Framework project to be built.
#' @returns A version of the project report, which is also written to
#' \code{project_dir/docs/report.json.gz}.
#' @examples
#' project_file <- "../../../pophive"
#' if (file.exists(project_file)) {
#'   report <- dcf_build(project_file)
#' }
#' @export

dcf_build <- function(project_dir = ".") {
  settings <- dcf_read_settings(project_dir)
  data_dir <- paste0(project_dir, "/", settings$data_dir)
  process_state <- tools::md5sum(list.files(
    data_dir,
    "process\\.json",
    recursive = TRUE,
    full.names = TRUE
  ))
  process <- dcf_process(project_dir = project_dir, is_auto = TRUE)
  issues <- dcf_check_sources(project_dir = project_dir)
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
    names(datapackages) <- list.dirs(
      data_dir,
      recursive = FALSE,
      full.names = FALSE
    )
    report <- list(
      date = Sys.time(),
      repo = paste0(settings$github_account, "/", settings$name),
      source_times = process$timings,
      logs = process$logs,
      issues = issues,
      metadata = lapply(datapackages, jsonlite::read_json)
    )
    jsonlite::write_json(
      report,
      gzfile(report_file),
      auto_unbox = TRUE,
      dataframe = "columns"
    )
    invisible(report)
  } else {
    invisible(jsonlite::read_json(report_file))
  }
}
