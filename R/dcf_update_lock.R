#' Update renv.lock
#'
#' Updates the \code{renv.lock} file with dependencies found in project scripts.
#'
#' @param project_dir Directory of the Data Collection project.
#' @param refresh Logical; if \code{FALSE}, will update an existing
#' \code{renv.lock} file, rather than recreating it.
#' @returns Nothing; writes an \code{renv.lock} file.
#' @examples
#' \dontrun{
#'   dcf_update_lock()
#' }
#' @export

dcf_update_lock <- function(
  project_dir = ".",
  refresh = TRUE
) {
  settings <- dcf_read_settings(project_dir)
  extra <- unique(
    renv::dependencies(list.files(
      paste0(project_dir, "/", settings$data_dir),
      "\\.[Rr]$",
      recursive = TRUE,
      full.names = TRUE
    ))$Package
  )
  not_installed <- !(extra %in% rownames(utils::installed.packages()))
  if (any(not_installed)) utils::install.packages(extra[not_installed])
  if (refresh) unlink(paste0(project_dir, "/renv.lock"))
  renv::snapshot(packages = extra, lockfile = paste0(project_dir, "/renv.lock"))
}
