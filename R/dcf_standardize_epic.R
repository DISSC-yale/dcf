#' Standardize Epic Data
#'
#' Standardize a raw Epic data table.
#'
#' @param raw_data Raw Epic data, such as returned from \link{dcf_read_epic}.
#' @returns A standardized form of \code{data}.
#' @section Standardization:
#' \itemize{
#'   \item Collapse location columns (\code{state} or \code{county}) to a single
#'     \code{geography} column, and region names to IDs.
#'   \item Collapse time columns (\code{year}, \code{month}, or \code{week}) to a single
#'     \code{time} column, and clean up value formatting.
#'   \item Drop rows with no values across value columns.
#' }
#' @examples
#' \dontrun{
#'   raw_data <- dcf_read_epic("data/epic/raw/flu.csv.xz")
#'   standard_data <- dcf_process_epic_raw(raw_data)
#' }
#'
#' @export

dcf_standardize_epic <- function(raw_data) {
  region_names <- epic_id_maps$regions
  names(region_names) <- gsub(
    " (?:CITY AND BOROUGH|BOROUGH|PARISH|MUNICIPALITY|MUNICIPIO)|[.']",
    "",
    toupper(names(region_names))
  )
  cols <- colnames(raw_data)
  time_col <- which(cols == "year")
  if (length(time_col)) {
    colnames(raw_data)[time_col] <- "time"
    raw_data$time <- as.integer(substring(
      raw_data$time,
      nchar(raw_data$time) - 4L
    ))
  }
  month_col <- which(cols == "month")
  if (length(month_col)) {
    raw_data$time <- paste0(
      raw_data$time,
      "-",
      epic_id_maps$months[raw_data$month]
    )
  }
  week_col <- which(cols == "week")
  if (length(week_col)) {
    raw_data$time <- paste0(
      raw_data$time,
      "-",
      vapply(
        strsplit(raw_data$week, "[^A-Za-z0-9]"),
        function(p) {
          paste0(
            epic_id_maps$months[[p[[1L]]]],
            "-",
            formatC(as.integer(p[[2L]]), width = 2L, flag = "0")
          )
        },
        ""
      )
    )
  }
  geo_col <- grep("^(?:state|county)", cols)
  if (length(geo_col)) {
    colnames(raw_data)[geo_col] <- "geography"
    raw_data$geography <- toupper(raw_data$geography)
    missing_geo <- !(raw_data$geography %in% names(region_names))
    if (any(missing_geo)) {
      geo <- sub(
        "LA ",
        "LA",
        sub("^SAINT", "ST", raw_data$geography[missing_geo]),
        fixed = TRUE
      )
      if (any(grepl(", VA", geo, fixed = TRUE))) {
        geo[geo == "SALEM, VA"] <- "SALEM CITY, VA"
        geo[geo == "RADFORD, VA"] <- "RADFORD CITY, VA"
        geo[geo == "DONA ANA, NM"] <- "DO\u00d1A ANA, NM"
        geo[geo == "MATANUSKA SUSITNA, AK"] <- "MATANUSKA-SUSITNA, AK"
      }
      raw_data$geography[missing_geo] <- geo
    }
    missing_regions <- raw_data$geography[
      !(raw_data$geography %in% names(region_names))
    ]
    if (length(missing_regions)) {
      cli::cli_warn(
        'unrecognized regions: {paste(unique(missing_regions), collapse = "; ")}'
      )
    }
    raw_data$geography <- region_names[raw_data$geography]
    raw_data <- raw_data[!is.na(raw_data$geography), ]
  }
  raw_data <- raw_data[,
    !(colnames(raw_data) %in% c("state", "county", "year", "month", "week"))
  ]
  raw_data[
    rowSums(
      !is.na(raw_data[,
        !(colnames(raw_data) %in% c("geography", "time", "age"))
      ])
    ) !=
      0L,
  ]
}
