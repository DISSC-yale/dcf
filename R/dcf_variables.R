#' View Project Variables
#'
#' Get a list of measures (a codebook) that are included in a data collection project.
#'
#' @param project Path to a local project, or the GitHub account and repository name
#' (\code{"{account_name}/{repo_name}"}) of a remote project.
#' @param ... Additional arguments passed to \code{\link{dcf_report}}.
#' @returns A tibble containing variables:
#' \tabular{ll}{
#'   \code{name} \tab Name of the variable, as it appears in the data file. \cr
#'   \code{type} \tab The value's storage type. \cr
#'   \code{n} \tab Number of non-missing observations within the file. \cr
#'   \code{duplicates} \tab Number of duplicated values within the file. \cr
#'   \code{missing} \tab Number of missing values within the file. \cr
#'   \code{file} \tab The file containing the variable; a path relative to the project root. \cr
#'   \code{short_name} \tab Short name, if included in measure info. \cr
#'   \code{long_name} \tab Long name, if included in measure info. \cr
#'   \code{short_decription} \tab Short description, if included in measure info. \cr
#'   \code{long_description} \tab Long description, if included in measure info. \cr
#'   \code{unit} \tab Unit (what the value represents), if included in measure info. \cr
#'   \code{category} \tab The measure's category, if included in measure info. \cr
#' }
#' @examples
#' dcf_variables("dissc-yale/pophive_demo")
#' @export

dcf_variables <- function(project = ".", ...) {
  report <- dcf_report(project, ...)
  data_dir <- report$settings$data_dir
  dplyr::as_tibble(do.call(
    rbind,
    lapply(names(report$metadata), function(project_output) {
      datapackage <- report$metadata[[project_output]]
      do.call(
        rbind,
        lapply(datapackage$resources, function(resource) {
          file <- paste(data_dir, project_output, resource$filename, sep = "/")
          n_rows <- resource$row_count
          do.call(
            rbind,
            Filter(
              length,
              lapply(resource$schema$fields, function(field) {
                info <- field$info
                if ("info" %in% names(info)) info <- info$info
                no_info <- is.null(info)
                cbind(
                  data.frame(
                    name = field$name,
                    type = field$type,
                    n = n_rows - field$missing,
                    duplicates = field$duplicates,
                    missing = field$missing,
                    file = file
                  ),
                  unpack_info(info)
                )
              })
            )
          )
        })
      )
    })
  ))
}

unpack_info <- function(info) {
  unpacked <- data.frame(
    short_name = NA_character_,
    long_name = NA_character_,
    short_description = NA_character_,
    long_description = NA_character_,
    unit = NA_character_,
    category = NA_character_
  )
  info_names <- names(info)
  for (name in colnames(unpacked)) {
    if (name %in% info_names) {
      unpacked[[name]] <- info[[name]]
    }
  }
  unpacked
}
