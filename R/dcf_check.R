#' Check Data Projects
#'
#' Check the data files and measure info of subprojects.
#'
#' @param names Name or names of projects.
#' @param project_dir Path to the Data Collection Framework project.
#' @param verbose Logical; if \code{FALSE}, will not print status messages.
#' @returns A list with an entry for each source, containing a character vector
#'   including any issue codes:
#' \itemize{
#'   \item \code{not_compressed}: The file does not appear to be compressed.
#'   \item \code{cant_read}: Failed to read the file in.
#'   \item \code{geography_nas}: The file's \code{geography} column contains NAs.
#'   \item \code{time_nas}: The file's \code{time} column contains NAs.
#'   \item \code{missing_info: {column_name}}: The file's indicated column does not have
#'     a matching entry in \code{measure_info.json}.
#' }
#' @examples
#' \dontrun{
#'   dcf_check("gtrends")
#' }
#' @export

dcf_check <- function(
  names = NULL,
  project_dir = ".",
  verbose = TRUE
) {
  if (missing(project_dir) && length(names) == 1L && dir.exists(project_dir)) {
    project_dir <- names
    names <- NULL
  }
  if (is.null(names)) {
    project_dir <- normalizePath(project_dir, "/", FALSE)
    if (file.exists(paste0(project_dir, "/", "process.json"))) {
      names <- basename(project_dir)
      project_dir <- dirname(project_dir)
    } else if (!file.exists(paste0(project_dir, "/", "settings.json"))) {
      names <- basename(project_dir)
      project_dir <- dirname(dirname(project_dir))
    }
  }

  settings <- dcf_read_settings(project_dir)
  base_dir <- paste0(project_dir, "/", settings$data_dir)
  if (is.null(names)) {
    names <- list.dirs(base_dir, recursive = FALSE, full.names = FALSE)
    names <- names[file.exists(paste0(base_dir, "/", names, "/process.json"))]
  }
  issues <- list()
  for (name in names) {
    source_dir <- paste0(base_dir, "/", name, "/")
    if (!dir.exists(source_dir)) {
      cli::cli_abort("specify the name of an existing data project")
    }
    process_file <- paste0(source_dir, "process.json")
    if (!file.exists(process_file)) {
      cli::cli_abort("{name} does not appear to be a data project")
    }
    process <- dcf_process_record(process_file)
    is_bundle <- !is.null(process$type) && process$type == "bundle"
    info_file <- paste0(source_dir, "measure_info.json")
    info <- tryCatch(
      dcf_measure_info(
        info_file,
        render = TRUE,
        write = FALSE,
        verbose = FALSE,
        open_after = FALSE
      ),
      error = function(e) NULL
    )
    measure_ids <- unique(c(
      names(info),
      unlist(lapply(info, "[[", "source_id"))
    ))
    if (is.null(info)) {
      cli::cli_abort("{.file {info_file}} is malformed")
    }
    if (verbose) {
      cli::cli_bullets(c("", "Checking project {.strong {name}}"))
    }
    data_files <- list.files(
      paste0(source_dir, if (is_bundle) "dist" else "standard"),
      "\\.(?:csv|parquet|json)",
      full.names = TRUE
    )
    data_files <- data_files[!grepl("datapackage", data_files, fixed = TRUE)]
    source_issues <- list()
    for (file in list.files(
      paste0(source_dir, "raw"),
      "csv$",
      full.names = TRUE
    )) {
      source_issues[[file]] <- list(data = "not_compressed")
    }
    if (length(data_files)) {
      for (file in data_files) {
        file_id <- paste0(
          basename(source_dir),
          "/",
          sub(source_dir, "", file, fixed = TRUE)
        )
        issue_messages <- NULL
        if (verbose) {
          cli::cli_progress_step("checking file {.file {file}}", spinner = TRUE)
        }
        data_issues <- NULL
        measure_issues <- NULL
        data <- tryCatch(
          if (grepl(".parquet", file, fixed = TRUE)) {
            dplyr::collect(arrow::read_parquet(file))
          } else if (grepl(".json", file, fixed = TRUE)) {
            as.data.frame(jsonlite::read_json(file, simplifyVector = TRUE))
          } else {
            attempt_read(file, c("geography", "time"))
          },
          error = function(e) NULL
        )
        if (is.null(data)) {
          data_issues <- c(data_issues, "cant_read")
        } else {
          if (grepl("csv$", file)) {
            data_issues <- c(data_issues, "not_compressed")
            if (verbose) {
              issue_messages <- c(
                issue_messages,
                "file is not compressed"
              )
            }
          }
          if (("geography" %in% colnames(data)) && anyNA(data$geography)) {
            data_issues <- c(data_issues, "geography_nas")
            if (verbose) {
              issue_messages <- c(
                issue_messages,
                "{.emph geography} column contains NAs"
              )
            }
          }
          if (("time" %in% colnames(data)) && anyNA(data$time)) {
            data_issues <- c(data_issues, "time_nas")
            if (verbose) {
              issue_messages <- c(
                issue_messages,
                "{.emph time} column contains NAs"
              )
            }
          }
          for (col in colnames(data)) {
            col_id <- paste0(file_id, "|", col)
            if (
              !(col %in% c("geography", "time")) &&
                (!(col %in% measure_ids) && !(col_id %in% measure_ids))
            ) {
              measure_issues <- c(measure_issues, paste("missing_info:", col))
              if (verbose) {
                issue_messages <- c(
                  issue_messages,
                  paste0(
                    "{.emph ",
                    col,
                    "} column does not have an entry in measure_info"
                  )
                )
              }
            }
          }
        }
        file_issues <- list()
        if (length(data_issues)) {
          file_issues$data <- data_issues
        }
        if (length(measure_issues)) {
          file_issues$measures <- measure_issues
        }
        source_issues[[file]] <- file_issues
        if (verbose) {
          if (length(issue_messages)) {
            cli::cli_progress_done(result = "failed")
            cli::cli_bullets(structure(
              issue_messages,
              names = rep(" ", length(issue_messages))
            ))
          } else {
            cli::cli_progress_done()
          }
        }
      }
    } else {
      if (verbose) cli::cli_alert_info("no standard data files found to check")
    }
    if (!identical(process$check_results, source_issues)) {
      process$checked <- Sys.time()
      process$check_results <- source_issues
      dcf_process_record(process_file, process)
    }
    issues[[name]] <- source_issues
  }

  invisible(issues)
}
