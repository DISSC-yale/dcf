#' Retrieve A Data File
#'
#' Load a data file from a source data project, or list versions of the file.
#'
#' @param path Path to the file.
#' @param date Date of the version to load; A \code{Date}, or \code{character} in the format
#'   \code{YYYY-MM-DD}. Will match to the nearest version.
#' @param commit_hash SHA signature of the committed version;
#'   can be the first 6 or so characters. Ignored if \code{date} is provided.
#' @param versions Logical; if \code{TRUE}, will return a list of available version,
#'   rather than a
#' @returns If \code{versions} is \code{TRUE}, a \code{data.frame} with columns for
#'   the \code{hash}, \code{author}, \code{date}, and \code{message} of each commit.
#'   Otherwise, the path to a temporary file, if one was extracted.
#'
#' @examples
#' path <- "../../../pophive/data/wastewater/raw/flua.csv.xz"
#' if (file.exists(path)) {
#'   # list versions
#'   versions <- dcf_get_file(path, versions = TRUE)
#'   print(versions[, c("date", "hash")])
#'
#'   # extract a version to a temporary file
#'   temp_path <- dcf_get_file(path, "2025-05")
#'   basename(temp_path)
#' }
#'
#' @export

dcf_get_file <- function(
  path,
  date = NULL,
  commit_hash = NULL,
  versions = FALSE
) {
  if (missing(path)) {
    cli::cli_abort("specify a path")
  }
  if (!file.exists(path)) {
    cli::cli_abort("path does not exist")
  }
  vs <- data.frame(
    hash = character(),
    author = character(),
    date = character(),
    message = character()
  )
  if (versions || !is.null(date)) {
    commits <- sys::exec_internal("git", c("log", path))
    if (commits$status == 0L) {
      commits <- do.call(
        rbind,
        Filter(
          function(e) length(e) == 4L,
          strsplit(
            strsplit(rawToChar(commits$stdout), "commit ", fixed = TRUE)[[1L]],
            "\\n+(?:[^:]+:)?\\s*"
          )
        )
      )
      colnames(commits) <- colnames(vs)
      vs <- as.data.frame(commits)
    } else {
      cli::cli_abort("failed to git log: {rawToChar(commits$stderr)}")
    }
  }
  if (versions) {
    return(vs)
  }
  if (!is.null(date)) {
    if (nrow(vs) == 0L) {
      return(path)
    }
    if (is.character(date)) {
      date <- as.POSIXct(
        date,
        tryFormats = c(
          "%Y-%m-%d %H:%M:%S",
          "%Y-%m-%d %H:%M",
          "%Y-%m-%d",
          "%Y-%m",
          "%Y"
        ),
        tz = "UTC"
      )
    }
    commit_hash <- vs$hash[which.min(abs(
      as.POSIXct(vs$date, "%a %b %d %H:%M:%S %Y", tz = "UTC") - date
    ))]
  }
  if (is.null(commit_hash)) {
    return(path)
  }
  name_parts <- strsplit(basename(path), ".", fixed = TRUE)[[1L]]
  out_path <- paste0(
    tempdir(),
    "/",
    name_parts[[1L]],
    "-",
    substring(commit_hash, 1L, 6L),
    ".",
    paste(name_parts[-1L], collapse = ".")
  )
  if (file.exists(out_path)) {
    return(out_path)
  }
  status <- sys::exec_wait(
    "git",
    c("show", paste0(commit_hash, ":", path)),
    std_out = out_path
  )
  if (status != 0L) {
    cli::cli_abort("failed to git show: {rawToChar(status$stderr)}")
  }
  out_path
}
