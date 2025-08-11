#' Download Census Population Data
#'
#' Download American Community Survey population data from the U.S. Census Bureau.
#'
#' @param year Data year.
#' @param out_dir Directory to download the file to.
#' @param state_only Logical; if \code{TRUE}, will only load state data.
#'   Will still download county data.
#' @param age_groups A list mapping lower-level age groups to high-level ones
#' (e.g., \code{list(`<10 Years` = c("Under 5 years", "5 to 9 years"))}).
#' Or the name of a standard mapping (\code{"7"} or \code{"9"}).
#' If \code{FALSE}, will return the lowest-level age groups.
#' @param overwrite Logical; if \code{TRUE}, will re-download and overwrite existing data.
#' @param verbose Logical; if \code{FALSE}, will not display status messages.
#' @returns A \code{data.frame} including \code{GEOID} and \code{region_name}
#'   for states and counties, along with their population, in total and within
#'   age brackets.
#' @examples
#' if (file.exists("../../../pophive/census_population_2021.csv.xz")) {
#'   dcf_load_census(2021, "../../../pophive")[1:10, ]
#' }
#' @export

dcf_load_census <- function(
  year = 2021,
  out_dir = NULL,
  state_only = FALSE,
  age_groups = "9",
  overwrite = FALSE,
  verbose = TRUE
) {
  out_file <- paste0(out_dir, "/census_population_", year, ".csv.xz")
  write_out <- !is.null(out_dir)
  age_group_sets <- list(
    "7" = list(
      `<10 Years` = c("Under 5 years", "5 to 9 years"),
      `10-14 Years` = "10 to 14 years",
      `15-19 Years` = c("15 to 17 years", "18 and 19 years"),
      `20-39 Years` = c(
        "20 years",
        "21 years",
        "22 to 24 years",
        "25 to 29 years",
        "30 to 34 years",
        "35 to 39 years"
      ),
      `40-64 Years` = c(
        "40 to 44 years",
        "45 to 49 years",
        "50 to 54 years",
        "55 to 59 years",
        "60 and 61 years",
        "62 to 64 years"
      ),
      `65+ Years` = c(
        "65 and 66 years",
        "67 to 69 years",
        "70 to 74 years",
        "75 to 79 years",
        "80 to 84 years",
        "85 years and over"
      )
    ),
    "9" = list(
      `<10 Years` = c("Under 5 years", "5 to 9 years"),
      `10-18 Years` = c("10 to 14 years", "15 to 17 years"),
      `18-24 Years` = c(
        "18 and 19 years",
        "20 years",
        "21 years",
        "22 to 24 years"
      ),
      `25-34 Years` = c("25 to 29 years", "30 to 34 years"),
      `35-44 Years` = c("35 to 39 years", "40 to 44 years"),
      `45-54 Years` = c("45 to 49 years", "50 to 54 years"),
      `55-64 Years` = c(
        "55 to 59 years",
        "60 and 61 years",
        "62 to 64 years"
      ),
      `65+ Years` = c(
        "65 and 66 years",
        "67 to 69 years",
        "70 to 74 years",
        "75 to 79 years",
        "80 to 84 years",
        "85 years and over"
      )
    )
  )
  age_levels <- unlist(age_group_sets[[1L]])
  if (!overwrite && write_out && file.exists(out_file)) {
    if (verbose) {
      cli::cli_progress_step("reading in existing file")
    }
    pop <- as.data.frame(vroom::vroom(
      out_file,
      delim = ",",
      col_types = list(GEOID = "c", region_name = "c"),
      n_max = if (state_only) 52L else Inf
    ))
  } else {
    # GEOID to region name mapping
    id_url <- "https://www2.census.gov/geo/docs/reference/codes2020/national_"
    if (verbose) {
      cli::cli_progress_step("downloading state IDs map")
    }
    state_ids <- vroom::vroom(
      paste0(id_url, "state2020.txt"),
      delim = "|",
      col_types = list(
        STATE = "c",
        STATEFP = "c",
        STATENS = "c",
        STATE_NAME = "c"
      )
    )
    if (verbose) {
      cli::cli_progress_step("downloading county IDs map")
    }
    county_ids <- vroom::vroom(
      paste0(id_url, "county2020.txt"),
      delim = "|",
      col_types = list(
        STATE = "c",
        STATEFP = "c",
        COUNTYFP = "c",
        COUNTYNS = "c",
        COUNTYNAME = "c",
        CLASSFP = "c",
        FUNCSTAT = "c"
      )
    )
    region_name = structure(
      sub(
        " County",
        "",
        c(
          state_ids$STATE_NAME,
          paste0(county_ids$COUNTYNAME, ", ", county_ids$STATE)
        ),
        fixed = TRUE
      ),
      names = c(
        state_ids$STATEFP,
        paste0(county_ids$STATEFP, county_ids$COUNTYFP)
      )
    )

    # population data

    ## age group labels from IDs
    if (verbose) {
      cli::cli_progress_step("downloading ACS variable lables")
    }
    labels <- vroom::vroom(
      paste0(
        "https://www2.census.gov/programs-surveys/acs/summary_file/",
        min(2021L, year),
        "/sequence-based-SF/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.txt"
      ),
      delim = ",",
      col_types = list(
        `File ID` = "c",
        `Table ID` = "c",
        `Sequence Number` = "c",
        `Line Number` = "d",
        `Start Position` = "i",
        `Total Cells in Table` = "c",
        `Total Cells in Sequence` = "i",
        `Table Title` = "c",
        `Subject Area` = "c"
      )
    )
    variable_labels <- structure(
      labels$`Table Title`,
      names = paste0(
        labels$`Table ID`,
        "_E",
        formatC(labels$`Line Number`, width = 3L, flag = 0L)
      )
    )

    ## age group counts
    url <- paste0(
      "https://www2.census.gov/programs-surveys/acs/summary_file/",
      year,
      "/table-based-SF/data/5YRData/acsdt5y",
      year,
      "-b01001.dat"
    )
    if (verbose) {
      cli::cli_progress_step("downloading population data")
    }
    data <- vroom::vroom(url, delim = "|", col_types = list(GEO_ID = "c"))
    data <- data[
      grep("0[45]00000US", data$GEO_ID),
      grep("E", colnames(data), fixed = TRUE)
    ]
    colnames(data)[-1L] <- variable_labels[colnames(data)[-1L]]
    if (verbose) {
      cli::cli_progress_step("agregating across sex and fine age groups")
    }
    pop <- cbind(
      data.frame(
        GEOID = substring(data$GEO_ID, 10L),
        region_name = "",
        Total = data[["Total:"]]
      ),
      do.call(
        cbind,
        lapply(
          structure(age_levels, names = age_levels),
          function(l) rowSums(data[, colnames(data) == l])
        )
      )
    )
    pop$region_name = region_name[pop$GEOID]
    states <- pop[1L:52L, ]
    health_regions <- as.data.frame(do.call(
      rbind,
      lapply(
        split(
          states[, -(1L:2L)],
          dcf_to_health_region(states$GEOID, "hhs_")
        ),
        colSums
      )
    ))
    health_regions$GEOID <- rownames(health_regions)
    health_regions$region_name <- sub(
      "hhs_",
      "Health Region ",
      rownames(health_regions),
      fixed = TRUE
    )
    pop <- rbind(pop, health_regions[, colnames(pop)])

    if (write_out) {
      if (verbose) {
        cli::cli_progress_step("writing output")
      }
      dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
      vroom::vroom_write(pop, out_file, ",")
    }
  }
  if (is.numeric(age_groups)) age_groups <- as.character(age_groups)
  if (is.character(age_groups) && (age_groups %in% names(age_group_sets)))
    age_groups <- age_group_sets[[as.character(age_groups)]]
  if (is.list(age_groups)) {
    pop <- cbind(
      pop[, !(colnames(pop) %in% age_levels)],
      do.call(
        cbind,
        lapply(
          age_groups,
          function(l) rowSums(pop[, colnames(pop) %in% l, drop = FALSE])
        )
      )
    )
  }
  invisible(if (state_only) pop[1L:52L, ] else pop)
}
