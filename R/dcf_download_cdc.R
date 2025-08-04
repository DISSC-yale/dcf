#' Download Data from the CDC
#'
#' Download data and metadata from the Centers for Disease Control and Prevention (CDC).
#'
#' @param id ID of the resource (e.g., \code{ijqb-a7ye}).
#' @param out_dir Directory in which to save the metadata and data files.
#' @param state The state ID of a previous download; if provided, will only download if the
#' new state does not match.
#' @param parquet Logical; if \code{TRUE}, will convert the downloaded CSV file to Parquet.
#' @param verbose Logical; if \code{FALSE}, will not display status messages.
#' @returns The state ID of the downloaded files;
#' downloads files (\code{<id>.json} and \code{<id>.csv.xz}) to \code{out_dir}
#' @section \code{data.cdc.gov} URLs:
#'
#' For each resource ID, there are 3 relevant CDC URLs:
#' \itemize{
#'   \item \strong{\code{resource/<id>}}: This redirects to the resource's main page,
#'     with displayed metadata and a data preview
#'     (e.g., \href{https://data.cdc.gov/resource/ijqb-a7ye}{data.cdc.gov/resource/ijqb-a7ye}).
#'   \item \strong{\code{api/views/<id>}}: This is a direct link to the underlying
#'     JSON metadata (e.g., \href{https://data.cdc.gov/api/views/ijqb-a7ye}{data.cdc.gov/api/views/ijqb-a7ye}).
#'   \item \strong{\code{api/views/<id>/rows.csv}}: This is a direct link to the full
#'     CSV dataset (e.g., \href{https://data.cdc.gov/api/views/ijqb-a7ye/rows.csv}{data.cdc.gov/api/views/ijqb-a7ye/rows.csv}).
#' }
#'
#' @examples
#' \dontrun{
#'   dcf_download_cdc("ijqb-a7ye")
#' }
#' @export

dcf_download_cdc <- function(
  id,
  out_dir = "raw",
  state = NULL,
  parquet = FALSE,
  verbose = TRUE
) {
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  if (verbose) {
    resource_url <- paste0("https://data.cdc.gov/resource/", id)
    cli::cli_h1(
      "downloading resource {.url {resource_url}}"
    )
  }
  url <- paste0("https://data.cdc.gov/api/views/", id)
  initial_timeout <- options(timeout = 99999L)$timeout
  on.exit(options(timeout = initial_timeout))
  if (verbose) {
    cli::cli_progress_step("metadata: {.url {url}}")
  }
  metadata_file <- paste0(tempdir(), "/", id, ".json")
  status <- utils::download.file(url, metadata_file, quiet = TRUE)
  if (status != 0L) {
    cli::cli_abort("failed to download metadata")
  }
  metadata <- jsonlite::read_json(metadata_file)
  new_state <- if (is.null(metadata$rowsUpdatedAt)) {
    as.list(tools::md5sum(metadata_file))
  } else {
    metadata$rowsUpdatedAt
  }
  if (!identical(new_state, state)) {
    file.rename(metadata_file, paste0(out_dir, "/", id, ".json"))
    data_url <- paste0(url, "/rows.csv")
    out_path <- paste0(out_dir, "/", id, ".csv")
    if (verbose) {
      cli::cli_progress_step("data: {.url {data_url}}")
    }
    status <- utils::download.file(data_url, out_path, quiet = TRUE)
    if (status != 0L) {
      cli::cli_abort("failed to download data")
    }
    if (parquet) {
      if (verbose) {
        cli::cli_progress_step("writing to Parquet")
      }
      data <- arrow::read_csv_arrow(out_path)
      arrow::write_parquet(
        data,
        compression = "gzip",
        sub(".csv", ".parquet", out_path, fixed = TRUE)
      )
      unlink(out_path)
    } else {
      if (verbose) {
        cli::cli_progress_step("compressing data")
      }
      unlink(paste0(out_path, ".xz"))
      status <- system2("xz", c("-f", out_path))
      if (status != 0L) {
        cli::cli_abort("failed to compress data")
      }
    }
    if (verbose) {
      cli::cli_progress_done()
    }
    invisible(new_state)
  } else {
    unlink(metadata_file)
    invisible(state)
  }
}
