#' Download Medicare Disparities Data
#'
#' Download data from the Centers for Medicare & Medicaid Services (CMS)
#' \href{https://data.cms.gov/tools/mapping-medicare-disparities-by-population}{Mapping Medicare Disparities by Population} (MMD) tool.
#'
#' @param measure Name or letter code of the measure to download.
#' @param population The population code; either \code{f} (Medicare Fee For Service) or
#' \code{m} (Medicare Advantage).
#' @param year Year(s) to download (e.g., \code{2015:2020}). If not specified, all available
#' years will be included.
#' @param geography Geography code(s) to include, between \code{n} (national), \code{s} (state),
#' and \code{c} (county). If not specified, all available geographies will be included.
#' @param adjust,condition,sex,age,race,dual_elig,medicare_elig One or more codes indicating
#' the variable levels to include (see \code{\link{dcf_standardize_cmsmmd}}).
#' If \code{"."}, values will be across all levels, whereas if \code{NULL}, all available levels
#' will be included (aggregated and disaggregated). See the Making Requests section.
#' @param refresh_codebook Logical; if \code{TRUE}, will re-download the codebook even if it
#' exists in the temporary location (which is cleared each R session).
#' @param codebook_only Logical; if \code{TRUE}, will return the codebook without downloading data.
#' @param row_limit Maximum number of rows to return in each request. The API limit appears to be 100,000.
#' @param out_file Path to the CSV or Parquet file to write data to.
#' @param state The codebook state (MD5 hash) recorded during a previous download;
#' if provided, will only download if the new state does not match.
#' @param parquet Logical; if \code{TRUE}, will convert the downloaded CSV file to Parquet.
#' @param verbose Logical; if \code{FALSE}, will not display status messages.
#' @section Making Requests:
#' The API operates over several large files, partitioned by measure, year,
#' adjust, and dual and medicaid eligibility. These are identified with the codebook
#' (\code{dcf_download_cmsmmd(codebook_only = TRUE)}).
#'
#' The files are larger than the API's limit, so requests for each file have to be broken up
#' by the other variables within them (sex, age, race, and condition).
#'
#' For best performance, make requests as big as possible while staying under 100,000 rows
#' each (e.g., by setting \code{sex}, \code{age}, or \code{race} to \code{NULL}).
#' @returns \code{dcf_download_cmsmmd}: A list:
#' \itemize{
#'   \item \strong{\code{codebook}}: The codebook.
#'   \item \strong{\code{codebook_state}}: MD5 hash of the codebook.
#'   \item \strong{\code{data}}: The downloaded data.
#' }
#' @examples
#' # find the codes associated with menu values
#' variable_codes <- dcf_standardize_cmsmmd()
#' variable_codes[c(
#'   "sex", "age", "race",
#'   "adjust", "dual_elig", "medicare_elig"
#' )]
#'
#' # look at the codebook which defines source files
#' codebook <- dcf_download_cmsmmd(codebook_only = TRUE)
#' codebook
#'
#' \dontrun{
#'   # download data
#'   downloaded <- dcf_download_cmsmmd(
#'     "preventive care",
#'     population = "f",
#'     race = ".",
#'     sex = ".",
#'     age = NULL,
#'     condition = c(83, 85, 86, 88, 89, 95, 101, 102, 104, 105:107),
#'     adjust = 1
#'   )
#'
#'   # convert codes to levels
#'   data_standard <- dcf_standardize_cmsmmd(downloaded$data)
#' }
#' @export

dcf_download_cmsmmd <- function(
  measure,
  population = NULL,
  year = NULL,
  geography = NULL,
  adjust = NULL,
  condition = NULL,
  sex = c(1:2, "."),
  age = c(0:4, "."),
  race = c(1:6, "."),
  dual_elig = ".",
  medicare_elig = ".",
  refresh_codebook = FALSE,
  codebook_only = FALSE,
  row_limit = 9999999,
  out_file = NULL,
  state = NULL,
  parquet = FALSE,
  verbose = TRUE
) {
  # load codebook
  codebook_file <- paste0(tempdir(), "/codebook_crosswalk.csv")
  if (refresh_codebook || !file.exists(codebook_file)) {
    if (verbose) cli::cli_progress_step("retrieving codebook")
    codebook_req <- curl::curl_fetch_disk(
      "https://data.cms.gov/mmd-population/assets/codebook_crosswalk.csv",
      codebook_file
    )
    if (codebook_req$status_code != 200) {
      unlink(codebook_file)
      cli::cli_abort("failed to retrieve codebook: {codebook_req$status_code}")
    }
    if (verbose) cli::cli_progress_done()
  }
  new_state <- tools::md5sum(codebook_file)
  if (!is.null(state)) {
    if (state == new_state) {
      if (verbose) {
        cli::cli_alert_info("codebook has not changed since last download")
      }
      return(invisible(NULL))
    }
  }
  codebook <- vroom::vroom(
    codebook_file,
    col_types = list(
      elig = "c",
      race_code = "c",
      sex_code = "c",
      adjust = "c",
      dual = "c"
    ),
    na = " "
  )
  codebook$description <- tolower(codebook$description)

  if (codebook_only) return(codebook)

  # identify source(s)
  if (missing(measure)) {
    cli::cli_abort("specify a measure: {.value {unique(codebook$description)}}")
  }

  measure_descriptions <- unique(codebook$description)
  if (nchar(measure) == 1L) {
    codebook <- codebook[codebook$measure == tolower(measure), ]
  } else {
    codebook <- codebook[grepl(measure, codebook$description), ]
  }
  if (!nrow(codebook)) {
    cli::cli_abort(
      paste(
        'measure "{measure}" does not match the available measures:',
        "{.value {measure_descriptions}}"
      )
    )
  }

  if (is.null(population)) population <- codebook$population[[1L]]
  codebook <- codebook[
    filter_codebook(codebook$population, population, "population"),
  ]

  if (!is.null(year)) {
    if (is.numeric(year)) year <- as.character(year)
    if (any(nchar(year) > 2L)) {
      year <- substring(
        year,
        nchar(year) -
          as.integer(as.character(cut(
            as.numeric(year),
            c(
              -Inf,
              if (population == "m") 2014L else 2019L,
              Inf
            ),
            c(0L, 1L)
          )))
      )
    }
    codebook <- codebook[
      filter_codebook(codebook$year, year, "year"),
    ]
  }
  if (missing(dual_elig)) dual_elig <- codebook$dual[[1L]]
  if (!is.null(dual_elig)) {
    codebook <- codebook[
      filter_codebook(codebook$dual, dual_elig, "dual_elig"),
    ]
  }
  if (missing(medicare_elig)) medicare_elig <- codebook$elig[[1L]]
  if (!is.null(medicare_elig)) {
    codebook <- codebook[
      filter_codebook(codebook$elig, medicare_elig, "medicare_elig"),
    ]
  }

  # make requests
  param_sets <- expand.grid(
    Filter(
      length,
      list(
        fltr = adjust,
        agecat = age,
        sexcat = sex,
        racecat = race,
        condition = condition,
        "_source" = unique(codebook$url)
      )
    ),
    stringsAsFactors = FALSE
  )
  param_sets[param_sets == "." | param_sets == "all"] <- ".|IS NULL"
  data_url <- paste0(
    "https://data.cms.gov/data-api/v1/mmd-tool/?_size=",
    row_limit,
    "&"
  )
  n_requests <- nrow(param_sets)
  all_data <- list()
  if (verbose) cli::cli_h1("making requests to {data_url}")
  for (i in seq_len(n_requests)) {
    params <- as.list(param_sets[i, ])
    param_string <- paste0(names(params), "=", params, collapse = "&")
    req <- curl::curl_fetch_memory(utils::URLencode(paste0(
      data_url,
      param_string
    )))
    if (req$status_code != 200) {
      cli::cli_abort(
        "a request failed: ({req$status_code}) {rawToChar(req$content)}"
      )
    }
    all_data[[i]] <- jsonlite::fromJSON(rawToChar(req$content))
    if (verbose)
      cli::cli_progress_step(
        paste0(
          i,
          " of ",
          n_requests,
          " (",
          nrow(all_data[[i]]),
          " rows): ",
          param_string
        ),
        spinner = TRUE
      )
  }
  if (verbose) cli::cli_progress_done()

  all_data <- do.call(rbind, all_data)
  if (!is.null(out_file)) {
    dir.create(dirname(out_file), showWarnings = FALSE, recursive = TRUE)
    if (parquet || grepl(".parquet", out_file, fixed = TRUE)) {
      if (verbose) cli::cli_progress_step("writing to Parquet")
      arrow::write_parquet(
        all_data,
        compression = "gzip",
        sub(".csv", ".parquet", out_file, fixed = TRUE)
      )
    } else {
      if (verbose) cli::cli_progress_step("writing to CSV")
      vroom::vroom_write(all_data, out_file, ",")
    }
  }
  invisible(list(
    codebook_state = new_state,
    codebook = codebook,
    data = all_data
  ))
}

filter_codebook <- function(x, values, column) {
  su <- x %in% values
  if (!any(su)) {
    cli::cli_abort(
      paste(
        '{.arg {column}} does not contain specified values.',
        "Available values: {.value {unique(x)}}"
      )
    )
  }
  su
}

#' @rdname dcf_download_cmsmmd
#' @param raw_data The raw data as downloaded with \code{dcf_download_cmsmmd} to be standardized.
#' @returns \code{dcf_standardize_cmsmmd}: If \code{raw_data} is \code{NULL}, a list
#' with an entry for each API parameter, containing named vectors with level codes as names
#' mapping to level values (as they appear in the tool's menus).
#' Otherwise, a version of \code{raw_data} with coded values converted to labels.
#' @export

dcf_standardize_cmsmmd <- function(raw_data = NULL) {
  # extracted from https://data.cms.gov/mmd-population/js/menus.js
  menu <- jsonlite::read_json(
    system.file(
      "support_data/cms_mmd_levels.json.gz",
      package = "dcf"
    )
  )
  levels <- lapply(
    menu,
    function(e) {
      options <- Filter(
        length,
        lapply(e$options, function(o) {
          if (length(o$val)) {
            o$val <- as.character(o$val)
            o
          }
        })
      )
      c(
        structure(
          vapply(options, "[[", "", "disp"),
          names = vapply(options, "[[", "", "val")
        )
      )
    }
  )
  names(levels) <- vapply(menu, "[[", "", "id")
  levels$geography["n"] <- "National"
  levels$fltr <- levels$adjust
  levels$sex <- levels$sexcat <- levels$sex_code
  levels$race <- levels$racecat <- levels$race_code
  levels$age <- levels$agecat <- levels$age_group
  levels$eligcat <- levels$medicare_elig <- levels$eligibility
  levels$dual_elig <- levels$dual
  if (is.null(raw_data)) return(levels)
  for (col in colnames(raw_data)) {
    col_levels <- levels[[col]]
    if (!is.null(col_levels)) {
      values <- as.character(raw_data[[col]])
      values[values == ""] <- "."
      raw_data[[col]] <- c(col_levels, "." = "All")[values]
    }
  }
  raw_data
}
