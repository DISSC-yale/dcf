#' Interact with a Process File
#'
#' Read or update the current process file.
#'
#' See the \href{https://dissc-yale.github.io/dcf/articles/standards.html#scripts}{script standards}
#' for examples of using this within a sub-project script.
#'
#' @param path Path to the process JSON file.
#' @param updated An update version of the process definition. If specified, will
#' write this as the new process file, rather than reading any existing file.
#' @returns The process definition of the source project.
#' @examples
#' epic_process_file <- "../../../pophive/pophive_demo/data/epic/process.json"
#' if (file.exists(epic_process_file)) {
#'   dcf_process_record(epic_process_file)
#' }
#' @export

dcf_process_record <- function(path = "process.json", updated = NULL) {
  if (is.null(updated)) {
    if (!file.exists(path)) {
      cli::cli_abort("process file {path} does not exist")
    }
    spec <- jsonlite::read_json(path)
    if (is.null(spec$name)) spec$name <- basename(dirname(path))
    if (is.null(spec$type)) spec$type <- "source"
    spec
  } else {
    if (is.null(updated$type)) updated$type <- "source"
    jsonlite::write_json(updated, path, auto_unbox = TRUE, pretty = TRUE)
    updated
  }
}
