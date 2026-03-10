#' Use Data from a Data Collection Project
#'
#' Load the standard or distribution data from a local or remote data collection project.
#'
#' @param variables A character vector of variable names to be loaded, or a selected
#' subset of a project data dictionary, as returned from \code{\link{dcf_variables}}.
#' @param project Path to a local project, or the GitHub account and repository name
#' (\code{"{account_name}/{repo_name}"}) of a remote project.
#' @param data_format The data format to select, between \code{tall} and \code{wide}.
#' Useful if there are duplicate measure names between files of different formats.
#' @param project_type Project type to select, between \code{bundle} and \code{source}.
#' @param ... Additional arguments passed to \code{\link{dcf_report}}.
#' @param unify Logical; if \code{FALSE}, will return \code{data} as a list with entries for each
#' file. Otherwise (by default), will attempt to combine the loaded data.
#' @param only_selected Logical; if \code{TRUE}, will drop columns that were not included in
#' \code{variables}, other than ID columns.
#' @param cache Path to a directory in which to store downloaded files. Within this directory,
#' the repository structure will be recreated within an account-named directory.
#' @param refresh Logical; if \code{TURE}, will download files even if they exist in the \code{cache}.
#' @param verbose Logical; if \code{FALSE}, will not show status messages.
#' @returns A list with entries for metadata (the datapackage resource entry for each file loaded)
#' and data (a tibble or list of tibbles of the unified or separately loaded files).
#' @family data user interface functions
#' @examples
#' # retrieve the full bundle file that includes the `epic_rsv` measure
#' bundle <- dcf_data(
#'   "epic_rsv",
#'   "dissc-yale/pophive_demo",
#'   data_format = "tall",
#'   verbose = FALSE
#' )
#' bundle$data
#'
#' if (require("ggplot2", quietly = TRUE)) {
#'   # extract short names from data
#'   labels <- vapply(
#'     bundle$metadata[[1L]]$schema$fields[[3L]]$info$levels,
#'     function(measure) measure$info$short_name,
#'     ""
#'   )
#'
#'   # show trends from different measures over time
#'   bundle$data |>
#'     dplyr::filter(
#'       time >= as.Date("2024-01-01"),
#'       measure != "epic_all_encounters"
#'     ) |>
#'     dplyr::mutate(measure = labels[measure]) |>
#'     ggplot(aes(x = time, y = value_scaled, color = measure)) +
#'     theme_dark() %+replace%
#'     theme(panel.background = element_rect(fill = FALSE, color = FALSE)) +
#'     geom_smooth(
#'       method = "gam",
#'       formula = y ~ s(x, bs = "cs", k = 50L)
#'     )
#' }
#' @export

dcf_data <- function(
  variables = NULL,
  project = ".",
  data_format = NULL,
  project_type = "bundle",
  ...,
  unify = TRUE,
  only_selected = FALSE,
  cache = tempdir(),
  refresh = FALSE,
  verbose = TRUE
) {
  report <- dcf_report(project, ..., refresh = refresh)
  if (is.null(variables) || is.character(variables)) {
    all_variables <- dcf_variables(report)
    selected <- all_variables[
      all_variables$project_type == project_type &
        grepl(
          paste0("^(?:", paste(variables, collapse = "|"), ")$"),
          all_variables$name
        ),
    ]
  } else {
    if (!all(c("name", "file") %in% colnames(variables))) {
      cli::cli_abort(
        "`variables` must include `name` and `file` columns if not a character vector"
      )
    }
    all_variables <- selected <- variables
    variables <- selected$name
  }
  if (!is.null(data_format)) {
    selected <- selected[selected$data_format == data_format, ]
  }
  if (nrow(selected) == 0L) {
    cli::cli_abort("no variables found")
  }
  not_found <- if (is.null(variables)) character() else
    variables[!(variables %in% selected$name)]
  if (length(not_found)) {
    cli::cli_abort("variable{?/s} not found: {not_found}")
  }
  data_dir <- report$settings$data_dir
  files <- unique(selected$file)
  project_outputs <- gsub("^[^/]+/|/[^/]+$", "", files)
  project_metadata <- report$metadata[
    names(report$metadata) %in% project_outputs
  ]
  file_metadata <- list()
  for (output in names(project_metadata)) {
    datapackage <- project_metadata[[output]]
    for (i in seq_along(datapackage$resources)) {
      resource_file <- paste(
        data_dir,
        output,
        datapackage$resources[[i]]$filename,
        sep = "/"
      )
      if (resource_file %in% files) {
        file_metadata[[resource_file]] <- datapackage$resources[[i]]
      }
    }
  }
  file_metadata <- file_metadata[files]

  # download files to cache if needed
  if (identical(report$settings$report_url, "")) {
    if (verbose) cli::cli_alert_info("loading files from local project")
    project_root <- paste0(project, "/")
  } else {
    project_root <- paste0(
      normalizePath(paste0(cache, "/", project), "/", FALSE),
      "/"
    )
    if (verbose)
      cli::cli_alert_info("downloading files to cache: {project_root}")
    base_url <- dirname(report$settings$report_url)
    for (file in files) {
      cached_file <- paste0(project_root, file)
      if (refresh || !file.exists(cached_file)) {
        file_url <- paste0(base_url, "/", file)
        dir.create(dirname(cached_file), FALSE, TRUE)
        req <- curl::curl_fetch_disk(file_url, cached_file)
        if (req$status_code != 200L) {
          unlink(cached_file)
          cli::cli_warn("failed to download {.url {file_url}}")
        }
      }
    }
    if (verbose) cli::cli_alert_info("loading files from cache project")
  }

  # load files
  n_files <- length(files)
  if (verbose)
    cli::cli_progress_bar("loading files", "download", total = n_files)
  data <- list()
  data_tall <- structure(logical(n_files), names = files)
  for (file in files) {
    data[[file]] <- attempt_read(paste0(project_root, file))
    data[[file]]$source_file <- file
    if (identical(file_metadata[[file]]$data_format, "tall")) {
      data_tall[[file]] <- TRUE
    }
    if (verbose) cli::cli_progress_update()
  }
  if (verbose) cli::cli_progress_done()

  if (unify) {
    if (length(data) > 1L) {
      all_cols <- unique(unlist(lapply(data, colnames)))
      if (!any(data_tall)) {
        id_cols <- c("geography", "time", "age")
        id_cols <- id_cols[id_cols %in% all_cols]
        if (only_selected)
          all_cols <- all_cols[all_cols %in% c(id_cols, selected$name)]
        data <- dplyr::as_tibble(Reduce(
          function(x, y) merge(x, y, id_cols, all = TRUE),
          lapply(
            data,
            function(d) {
              for (col in id_cols[!(id_cols %in% colnames(d))]) d[[col]] <- NA
              if (only_selected) d <- d[, all_cols[all_cols %in% colnames(d)]]
              d[, colnames(d) != "source_file"]
            }
          )
        ))
      } else if (all(data_tall)) {
        data <- do.call(
          dplyr::bind_rows,
          lapply(files, function(file) {
            d <- data[[file]]
            if (only_selected) {
              measure_col <- unlist(lapply(
                file_metadata[[file]]$schema$fields,
                function(field)
                  if ("levels" %in% names(field$info)) field$name else NULL
              ))
              d <- d[d[[measure_col]] %in% selected$name, ]
            }
            d[, all_cols]
          })
        )
      } else {
        cli::cli_warn(
          "datasets are in inconsistent formats, so will not be unified"
        )
      }
    } else {
      data <- data[[1L]]
    }
  }

  invisible(list(metadata = file_metadata, data = data))
}
