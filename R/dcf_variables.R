#' View Project Variables
#'
#' Get a list of measures (a codebook) that are included in a data collection project.
#'
#' @param project Path to a local project, or the GitHub account and repository name
#' (\code{"{account_name}/{repo_name}"}) of a remote project.
#' Or a report as returned from \code{\link{dcf_report}}.
#' @param exclude A character vector of variable names to exclude from the list (usually ID columns).
#' @param ... Additional arguments passed to \code{\link{dcf_report}}.
#' @returns A tibble containing variables:
#' \tabular{ll}{
#'   \code{name} \tab Name of the variable, as it appears in the data file. \cr
#'   \code{type} \tab The value's storage type. \cr
#'   \code{n} \tab Number of non-missing observations within the file. \cr
#'   \code{duplicates} \tab Number of duplicated values within the file. \cr
#'   \code{missing} \tab Number of missing values within the file. \cr
#'   \code{project_type} \tab The project type, between \code{source} and \code{bundle}. \cr
#'   \code{data_format} \tab The orientation of the data, between \code{wide} and \code{tall}. \cr
#'   \code{file} \tab The file containing the variable; a path relative to the project root. \cr
#'   \code{short_name} \tab Short name, if included in measure info. \cr
#'   \code{long_name} \tab Long name, if included in measure info. \cr
#'   \code{short_decription} \tab Short description, if included in measure info. \cr
#'   \code{long_description} \tab Long description, if included in measure info. \cr
#'   \code{measure_type} \tab Higher-level description of type than storage type
#'     (e.g., \code{count} versus \code{integer}), if included in measure info. \cr
#'   \code{unit} \tab How a single value should be interpreted
#'     (e.g., \code{per 100k people} for a rate per 100k people), if included in measure info. \cr
#'   \code{time_resolution} \tab The measure's collection frequency, if included in measure info. \cr
#'   \code{category} \tab The measure's category, if included in measure info. \cr
#'   \code{subcategory} \tab The measure's subcategory, if included in measure info. \cr
#' }
#' @family data user interface functions
#' @examples
#' dcf_variables("dissc-yale/pophive_demo")
#' @export

dcf_variables <- function(
  project = ".",
  exclude = c("geography", "time", "age"),
  ...
) {
  report <- if (is.list(project)) project else dcf_report(project, ...)
  data_dir <- report$settings$data_dir
  dplyr::as_tibble(do.call(
    rbind,
    lapply(names(report$metadata), function(project_output) {
      datapackage <- report$metadata[[project_output]]
      measure_info <- datapackage$measure_info
      do.call(
        rbind,
        lapply(datapackage$resources, function(resource) {
          file <- paste(data_dir, project_output, resource$filename, sep = "/")
          project_type <- if (grepl("/dist/", file, fixed = TRUE)) "bundle" else
            "source"
          n_rows <- resource$row_count
          data_format <- if (is.null(resource$data_format)) "wide" else
            resource$data_format
          do.call(
            rbind,
            Filter(
              length,
              if (data_format == "tall") {
                lapply(resource$schema$fields, function(field) {
                  if ("levels" %in% names(field$info)) {
                    do.call(
                      rbind,
                      lapply(
                        field$info$levels,
                        function(level) {
                          n <- field$table[[level$id]]
                          level_row(
                            level,
                            if (is.null(n)) 0L else n,
                            file,
                            project_type
                          )
                        }
                      )
                    )
                  }
                })
              } else {
                lapply(resource$schema$fields, function(field) {
                  if (length(exclude) && field$name %in% exclude) return(NULL)
                  info <- field$info
                  if ("info" %in% names(info)) info <- info$info
                  if (is.null(info) && !is.null(measure_info)) {
                    info <- measure_info[[field$name]]
                  }
                  cbind(
                    data.frame(
                      name = field$name,
                      type = field$type,
                      n = n_rows - field$missing,
                      duplicates = field$duplicates,
                      missing = field$missing,
                      project_type = project_type,
                      data_format = "wide",
                      file = file
                    ),
                    unpack_info(info)
                  )
                })
              }
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
    measure_type = NA_character_,
    unit = NA_character_,
    time_resolution = NA_character_,
    category = NA_character_,
    subcategory = NA_character_
  )
  info_names <- names(info)
  if ("name" %in% info_names && !("short_name" %in% info_names)) {
    info$short_name <- info$name
  }
  if ("description" %in% info_names && !("short_description" %in% info_names)) {
    info$short_description <- info$description
  }
  info_names <- names(info)
  for (name in colnames(unpacked)) {
    if (name %in% info_names) {
      unpacked[[name]] <- info[[name]]
    }
  }
  unpacked
}

level_row <- function(level, n, file, project_type) {
  cbind(
    data.frame(
      name = level$id,
      type = level$type,
      n = n,
      duplicates = NA,
      missing = NA,
      project_type = project_type,
      data_format = "tall",
      file = file
    ),
    unpack_info(level$info)
  )
}
