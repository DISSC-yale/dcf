#' Download CDC WISQARS Reports
#'
#' Download reports data from the CDC's
#' \href{https://wisqars.cdc.gov/reports}{Web-based Injury Statistics Query and Reporting System}.
#'
#' @param file File to save the report to (\code{csv} or \code{parquet}).
#' @param year_start Earliest year to include.
#' @param year_end Latest year to include.
#' @param geography State or region code.
#' @param intent Intent ID or name:
#' \tabular{lll}{
#'   \code{0} \tab \code{all} \tab All \cr
#'   \code{1} \tab \code{unintentional} \tab Unintentional \cr
#'   \code{2} \tab \code{suicide} \tab Suicide \cr
#'   \code{3} \tab \code{homicide} \tab Homicide \cr
#'   \code{4} \tab \code{homicide_legal} \tab Homicide and Legal Intervention \cr
#'   \code{5} \tab \code{undetermined} \tab Undetermined \cr
#'   \code{6} \tab \code{legal} \tab Legal Intervention \cr
#'   \code{8} \tab \code{violence} \tab Violence-related \cr
#' }
#' @param disposition Patient disposition given nonfatal: one or multiple of \code{all} (0),
#' \code{treated} (1; treated and released), \code{transfered} (2), \code{hospitalized} (3), or
#' \code{observed} (4; observed/left AMA/unknown).
#' @param mechanism Mechanism code; default to \code{20810} (all injury).
#' Other codes appear in the URL in the \code{m} parameter when submitting the filter.
#' @param group_ages Logical; if \code{FALSE}, will not group ages into 5-year bins.
#' @param age_min Youngest age to include.
#' @param age_max Oldest age to include.
#' @param sex Sex groups to include: one or multiple of \code{all} (0), \code{male} (1),
#' \code{female} (2), or \code{unknown} (3)..
#' @param race Race groups to include: one or multiple of \code{all} (0), \code{white} (1),
#' \code{black} (2), \code{aa} (3; American Indian or Alaska Native), \code{asian} (4),
#' \code{pi} (5; Hawaiian Native or Pacific Islander), \code{more} (6; more than one race).
#' These levels apply if \code{race_reporting} is \code{single} (default) -- provide
#' these by index for other \code{race_reporting} levels.
#' @param race_reporting How to group race groups, between \code{none} (0), \code{bridge} (1),
#' \code{single} (2), or \code{aapi} (3).
#' @param ethnicity Which ethnic groups to include: one or multiple of \code{all} (0),
#' \code{non_hispanic} (1), \code{hispanic} (2), or \code{unknown} (3).
#' @param YPLL Age to use when calculating Years of Potential Life Lost.
#' @param metro Region type filter: \code{TRUE} for only metropolitan / urban, or \code{FALSE}
#' for only non-metropolitan / rural. Will include all region types if \code{NULL} (default).
#' @param group_by One or more variables to group by. These are uppercased and sometimes
#' abbreviated or encoded; see the \code{r1} through \code{r4} URL parameters.
#' @param fatal_outcome Logical; if \code{FALSE}, will return non-fatal results.
#' @param brain_injury_only Logical; if \code{TRUE}, will return only traumatic brain injury results.
#' @param include_total Logical; if \code{FALSE}, will not include totals.
#' @param verbose Logical; if \code{FALSE}, will not display status messages.
#' @returns A list containing the parameters of the request. The returned data are written to \code{file}.
#' @examples
#' file <- "../../../wisqars.csv.xz"
#' if (file.exists(file)) {
#'   dcf_download_wisqars(file, verbose = FALSE)
#'   vroom::vroom(file)
#' }
#' @export

dcf_download_wisqars <- function(
  file,
  fatal_outcome = TRUE,
  brain_injury_only = FALSE,
  year_start = 2018,
  year_end = year_start,
  geography = "00",
  intent = "all",
  disposition = "all",
  mechanism = if (fatal_outcome) 20810 else 3000,
  group_ages = NULL,
  age_min = 0,
  age_max = 199,
  sex = "all",
  race = "all",
  race_reporting = "single",
  ethnicity = "all",
  YPLL = 65,
  metro = NULL,
  group_by = NULL,
  include_total = FALSE,
  verbose = TRUE
) {
  intents <- list(
    all = 0,
    unintentional = 1,
    violence = 8,
    homicide_legal = 4,
    homicide = 3,
    legal = 6,
    suicide = 2,
    undetermined = 5
  )
  dispositions <- list(
    all = 0,
    treated = 1,
    transfered = 2,
    hospitalized = 3,
    observed = 4
  )
  sexes <- list(
    all = 0,
    male = 1,
    female = 2,
    unknown = 3
  )
  races <- list(
    all = 0,
    white = 1,
    black = 2,
    aa = 3,
    asian = 4,
    pi = 5,
    more = 6
  )
  race_reportings <- list(
    none = 0,
    bridge = 1,
    single = 2,
    aapi = 3
  )
  ethnicities <- list(
    all = 0,
    non_hispanic = 1,
    hispanic = 2,
    unknown = 3
  )
  if (missing(group_ages) && (!missing(age_min) || !missing(age_max))) {
    group_ages <- FALSE
  }
  params <- list(
    TotalLine = if (include_total) "YES" else "NO",
    intent = if (is.character(intent)) intents[[tolower(intent)]] else 0L,
    mech = mechanism,
    sex = paste(
      vapply(sex, function(l) if (is.character(l)) sexes[[l]] else l, 0),
      collapse = ","
    ),
    race = paste(
      vapply(race, function(l) if (is.character(l)) sexes[[l]] else l, 0),
      collapse = ","
    ),
    race_yr = if (is.character(race_reporting))
      race_reportings[[race_reporting]] else race_reporting,
    year1 = year_start,
    year2 = year_end,
    agebuttn = if (is.null(group_ages)) "ALL" else if (group_ages) "5Yr" else
      "custom",
    fiveyr1 = age_min,
    fiveyr2 = age_max,
    c_age1 = age_min,
    c_age2 = age_max,
    groupby1 = "NONE",
    groupby2 = "NONE",
    groupby3 = "NONE",
    groupby4 = "NONE",
    groupby5 = "NONE",
    groupby6 = "NONE"
  )
  if (fatal_outcome) {
    params$state <- geography
    params$ethnicty <- paste(
      vapply(
        ethnicity,
        function(l) if (is.character(l)) ethnicities[[l]] else l,
        0
      ),
      collapse = ","
    )
    params$ypllage <- YPLL
    params$urbrul <- if (is.null(metro)) 0 else if (metro) 1 else 2
    params$tbi <- if (brain_injury_only) 1L else 0L
  } else {
    params$groupby1 <- "NONE1"
    params$groupby2 <- "NONE2"
    params$groupby3 <- "NONE3"
    params$groupby4 <- "NONE4"
    params$groupby5 <- "NONE5"
    params$groupby6 <- "NONE6"
    params$outcome <- "NFI"
    params$racethn <- 0
    params$disp <- paste(
      vapply(
        disposition,
        function(l) if (is.character(l)) dispositions[[l]] else l,
        0
      ),
      collapse = ","
    )
  }
  for (group in seq_along(group_by)) {
    params[[paste0("groupby", group)]] <- toupper(group_by[[group]])
  }
  params <- lapply(params, as.character)
  if (fatal_outcome) {
    params$app_id <- 1002
    params$component_id <- 1000
  }

  if (verbose) {
    url <- paste0(
      "https://wisqars.cdc.gov/reports/?o=",
      if (fatal_outcome) "MORT" else "NFI"
    )
    if (!fatal_outcome) {
      url <- paste0(url, "&g=00&me=")
    }
    url_param_map <- list(
      year1 = "y1",
      year2 = "y2",
      tbi = "t",
      disp = "d",
      state = "g",
      ethnicty = "e",
      intent = "i",
      mech = "m",
      sex = "s",
      race = "r",
      agebuttn = "a",
      urbrul = "me",
      race_yr = "ry",
      ypllage = "yp",
      fiveyr1 = "g1",
      fiveyr2 = "g2",
      c_age1 = "a1",
      c_age2 = "a2",
      groupby1 = "r1",
      groupby2 = "r2",
      groupby3 = "r3",
      groupby4 = "r4",
      groupby5 = "r5",
      groupby6 = "r6"
    )
    for (k in names(params)) {
      url_key <- url_param_map[[k]]
      if (!is.null(url_key)) {
        for (value in params[[k]]) url <- paste0(url, "&", url_key, "=", value)
      }
    }
    cli::cli_alert_info("requesting report {.url {url}}")
  }

  handler <- curl::new_handle()
  curl::handle_setheaders(handler, "Content-Type" = "application/json")
  curl::handle_setopt(
    handler,
    copypostfields = jsonlite::toJSON(
      list(parameters = params),
      auto_unbox = TRUE
    )
  )
  req <- curl::curl_fetch_memory(
    paste0(
      "https://wisqars.cdc.gov/api/cost-",
      if (fatal_outcome) "fatal" else "nonfatal"
    ),
    handle = handler
  )
  if (req$status_code == 200) {
    dir.create(dirname(file), FALSE, TRUE)
    data <- jsonlite::fromJSON(rawToChar(req$content))
    if (!length(data)) {
      cli::cli_warn("no rows in data, so no file written")
    } else {
      if (grepl("parquet", file)) {
        arrow::write_parquet(data, file, compression = "gzip")
      } else {
        vroom::vroom_write(data, file, ",")
      }
    }
  } else {
    cli::cli_abort("request failed: {req$status_code}")
  }
  invisible(params)
}
