#' Retrieve Project Report
#'
#' Retrieve the report file from a local or remote project.
#'
#' @param project Path to a local project, or the GitHub account and repository name
#' (\code{"{account_name}/{repo_name}"}) of a remote project.
#' @param branch Name of the remote repository branch.
#' @param commit Commit hash; overrides \code{branch}.
#' @param provider Base URL of the remote repository provider.
#' @param cache Directory to store retrieved report in (at \code{{cache}/{project}/report.json.gz}).
#' @param refresh Logical; if \code{TRUE}, will always retrieve a fresh copy of the report,
#' even if a copy exists in \code{cache}.
#' @returns A data collection project report:
#' \tabular{ll}{
#'   \code{date} \tab Timestamp when the report was created. \cr
#'   \code{settings} \tab The project's settings file. \cr
#'   \code{source_times} \tab
#'     A list with entries for each subproject, containing the number of milliseconds
#'     it took to run the project's scripts. \cr
#'   \code{issues} \tab
#'     A list with entries for each subproject, containing issues flagged by
#'     \code{\link{dcf_check}}, within a list with \code{data} and/or \code{measure} entries,
#'     containing character vectors of issue labels. \cr
#'   \code{logs} \tab
#'     A list with entries for each subproject, containing the logged output of their scripts. \cr
#'   \code{metadata} \tab
#'     A list with entries for each subproject, containing the datapackage of their output,
#'     as created by \code{\link{dcf_measure_info}}. \cr
#'   \code{processes} \tab
#'     A list with entries for each subproject, containing their process definitions
#'     (see \code{\link{dcf_add_source}} and/or \code{\link{dcf_add_bundle}}). \cr
#' }
#' @examples
#' report <- dcf_report("dissc-yale/pophive_demo")
#' report$date
#' jsonlite::toJSON(report$settings, auto_unbox = TRUE, pretty = TRUE)
#' @export

dcf_report <- function(
  project = "dissc-yale/pophive_demo",
  branch = "main",
  commit = NULL,
  provider = "https://github.com",
  cache = tempdir(),
  refresh = FALSE
) {
  if (dir.exists(project)) {
    report_file <- paste0(project, "/report.json.gz")
    if (!file.exists(report_file)) {
      cli::cli_abort("report does not exist at {report_file}")
    }
  } else {
    report_file <- paste0(cache, "/", project, "/report.json.gz")
    if (refresh || !file.exists(report_file)) {
      dir.create(dirname(report_file), FALSE, TRUE)
      report_url <- paste0(
        provider,
        "/",
        project,
        "/raw/",
        if (is.null(commit)) paste0("refs/heads/", branch) else commit,
        "/report.json.gz"
      )
      req <- curl::curl_fetch_disk(report_url, report_file)
      if (req$status_code != 200L) {
        unlink(report_file)
        cli::cli_abort(
          "failed to retrieve report at {report_url}: {req$status_code}, {req$content}"
        )
      }
    }
  }
  invisible(jsonlite::read_json(report_file))
}
