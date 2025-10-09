#' Process Epic Stating Files
#'
#' Process Epic stating files, lightly standardizing them and moving them to raw.
#'
#' @param staging_dir Directory containing the staging files.
#' @param out_dir Directory to write new raw files to.
#' @param verbose Logical; if \code{FALSE}, will not show status messages.
#' @param cleanup Logical; if \code{FALSE}, will not remove staging files after being processed.
#' @returns \code{NULL} if no staging files are found.
#'   Otherwise, a list with entries for \code{data} and \code{metadata}.
#'   Each of these are lists with entries for each recognized standard name,
#'   with potentially combined outputs similar to \code{\link{dcf_read_epic}}
#'
#' @examples
#' \dontrun{
#'   # run from a source project
#'   dcf_process_epic_staging()
#' }
#'
#' @export

dcf_process_epic_staging <- function(
  staging_dir = "raw/staging",
  out_dir = "raw",
  verbose = TRUE,
  cleanup = TRUE
) {
  files <- sort(list.files(
    staging_dir,
    "csv",
    full.names = TRUE,
    recursive = TRUE
  ))
  files <- files[!grepl("census", files)]
  if (!length(files)) {
    if (verbose) {
      cli::cli_progress_message("no staging files found")
    }
    return(NULL)
  }
  id_cols <- c("state", "county", "age", "year", "month", "week")
  metadata <- list()
  data <- list()
  for (file in files) {
    if (verbose) {
      cli::cli_progress_step("processing file {.file {file}}", spinner = TRUE)
    }
    epic <- tryCatch(dcf_read_epic(file), error = function(e) NULL)
    if (is.null(epic)) {
      if (verbose) {
        cli::cli_progress_done(result = "failed")
      }
      next
    }
    if (epic$metadata$standard_name == "") {
      if (verbose) {
        cli::cli_warn("failed to identify standard type for {.file {file}}")
        cli::cli_progress_done(result = "failed")
      }
      next
    }
    name <- epic$metadata$standard_name
    metadata[[name]] <- c(list(epic$metadata), metadata[[name]])
    file_id_cols <- id_cols[id_cols %in% colnames(epic$data)]
    epic$data <- epic$data[
      rowMeans(is.na(epic$data[,
        !(colnames(epic$data) %in% file_id_cols),
        drop = FALSE
      ])) !=
        1,
    ]
    n_col <- grep("^n_", colnames(epic$data))
    if (length(n_col)) {
      colnames(epic$data)[[n_col]] <- paste0("n_", epic$metadata$standard_name)
    }
    if (!is.null(data[[name]])) {
      cols <- colnames(data[[name]])
      cols <- cols[!(cols %in% colnames(epic$data))]
      if (length(cols)) {
        epic$data[, cols] <- NA
      }
      epic$data <- epic$data[, colnames(data[[name]])]
      file_id_cols <- id_cols[id_cols %in% colnames(data[[name]])]
      data[[name]] <- data[[name]][
        !(do.call(paste, data[[name]][, file_id_cols]) %in%
          do.call(paste, epic$data[, file_id_cols])),
      ]
    }
    data[[name]] <- rbind(epic$data, data[[name]])
    if (verbose) cli::cli_progress_done()
  }
  for (name in names(metadata)) {
    if (verbose) {
      cli::cli_progress_step(
        "writing standard raw output for {.field {name}}",
        spinner = TRUE
      )
    }
    paths <- paste0(out_dir, "/", name, ".", c("json", "csv.xz"))
    jsonlite::write_json(
      metadata[[name]],
      paths[[1L]],
      auto_unbox = TRUE,
      pretty = TRUE
    )
    vroom::vroom_write(data[[name]], paths[[2L]])
    if (cleanup) {
      unlink(vapply(metadata[[name]], "[[", "", "file"))
    }
    if (verbose) cli::cli_process_done()
  }
  return(list(metadata = metadata, data = data))
}
