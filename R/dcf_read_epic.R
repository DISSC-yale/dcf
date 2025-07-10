#' Read Epic Cosmos Data
#'
#' Read in metadata and data from an Epic Cosmos file.
#'
#' @param path Path to the file.
#' @param path_root Directory containing \code{path}, if it is not full.
#' @returns A list with \code{data.frame} entries for \code{metadata} and \code{data}.
#'
#' @examples
#' # write an example file
#' path <- tempfile(fileext = ".csv")
#' raw_lines <- c(
#'   "metadata field,metadata value,",
#'   ",,",
#'   ",Measures,Value Name",
#'   "Year,Measure 1,",
#'   "2020,m1,1",
#'   ",m2,2",
#'   "2021,m1,3",
#'   ",m2,4"
#' )
#' writeLines(raw_lines, path)
#'
#' # read it in
#' dcf_read_epic(basename(path), dirname(path))
#'
#' @export

dcf_read_epic <- function(path, path_root = ".") {
  full_path <- if (file.exists(path)) {
    path
  } else {
    sub("//", "/", paste0(path_root, "/", path), fixed = TRUE)
  }
  lines <- readLines(full_path, n = 25L, skipNul = FALSE)
  metadata_break <- grep("^[, ]*$", lines)
  if (!length(metadata_break)) {
    cli::cli_abort(
      "path does not appear to point to a file in the Epic format (no metadata separation)"
    )
  }
  meta_end <- min(metadata_break) - 1L
  data_start <- (if (length(metadata_break) == 1L) {
    metadata_break
  } else {
    max(metadata_break[
      metadata_break == c(-1L, metadata_break[-1L])
    ])
  }) +
    1L
  meta <- c(
    list(
      file = path,
      md5 = unname(tools::md5sum(full_path)),
      date_processed = Sys.time(),
      standard_name = ""
    ),
    as.list(unlist(lapply(
      strsplit(sub(",+$", "", lines[seq_len(meta_end)]), ",", fixed = TRUE),
      function(r) {
        l <- list(paste(r[-1L], collapse = ","))
        if (l[[1]] == "") {
          r <- strsplit(r, ": ", fixed = TRUE)[[1L]]
          l <- list(paste(r[-1L], collapse = ","))
        }
        names(l) <- r[[1L]]
        l[[1L]] <- gsub('^"|"$', "", l[[1L]])
        l
      }
    )))
  )
  standard_names <- c(
    vaccine_mmr = "MMR receipt",
    rsv_tests = "RSV tests",
    flu = "Influenza",
    self_harm = "self-harm",
    covid = "COVID",
    rsv = "RSV",
    obesity = "BMI",
    obesity = "obesity",
    all_encounters = "All ED Encounters"
  )
  meta_string <- paste(unlist(meta), collapse = " ")
  for (i in seq_along(standard_names)) {
    if (grepl(standard_names[[i]], meta_string, fixed = TRUE)) {
      meta$standard_name = names(standard_names)[[i]]
      break
    }
  }
  id_cols <- seq_len(
    length(strsplit(lines[data_start], "^,|Measures,")[[1L]]) - 1L
  )
  header <- c(
    strsplit(lines[data_start + 1L], ",", fixed = TRUE)[[1L]][id_cols],
    strsplit(lines[data_start], ",", fixed = TRUE)[[1L]][-id_cols]
  )
  data <- arrow::read_csv_arrow(
    full_path,
    col_names = header,
    col_types = paste(rep("c", length(header)), collapse = ""),
    na = c("", "-"),
    skip = data_start + 1L
  )
  percents <- grep("^(?:Percent|Base|RSV test)", header)
  if (length(percents)) {
    for (col in percents) {
      data[[col]] <- sub("%", "", data[[col]], fixed = TRUE)
    }
  }
  number <- grep("Number", header, fixed = TRUE)
  if (length(number)) {
    for (col in number) {
      data[[col]][data[[col]] == "10 or fewer"] <- 5L
    }
  }
  for (col in id_cols) {
    data[[col]] <- vctrs::vec_fill_missing(data[[col]], "down")
  }
  if (all(c("Measures", "Base Patient") %in% colnames(data))) {
    data <- Reduce(
      merge,
      lapply(split(data, data$Measures), function(d) {
        measure <- d$Measures[[1L]]
        d[[measure]] <- d[["Base Patient"]]
        d[, !(colnames(d) %in% c("Measures", "Base Patient"))]
      })
    )
  }
  colnames(data) <- standard_columns(colnames(data))
  if (meta$standard_name == "obesity") {
    meta$standard_name <- paste0(
      meta$standard_name,
      "_",
      if ("state" %in% colnames(data)) "state" else "county"
    )
  }
  if ("age" %in% colnames(data)) {
    std_age <- standard_age(data$age)
    missed_ages <- (data$age != "No value") & is.na(std_age)
    if (any(missed_ages)) {
      std_age[missed_ages] <- data$age[missed_ages]
      missed_levels <- unique(data$age[missed_ages])
      cli::cli_warn("missed age levels: {.field {missed_levels}}")
    }
    data$age <- std_age
  }
  list(metadata = meta, data = data)
}

standard_age <- function(age) {
  c(
    `less than 1 years` = "<1 Years",
    `1 and < 2 years` = "1-2 Years",
    `2 and < 3 years` = "2-3 Years",
    `3 and < 4 years` = "3-4 Years",
    `1 and < 5 years` = "1-4 Years",
    `1 year or more and less than 5 years` = "1-4 Years",
    `4 and < 5 years` = "4-5 Years",
    `less than 5 years` = "<5 Years",
    `5 and < 6 years` = "5-6 Years",
    `5 and < 18 years` = "5-17 Years",
    `5 years or more and less than 18 years (1)` = "5-17 Years",
    `6 and < 7 years` = "6-7 Years",
    `6 years or more` = "6+ Years",
    `7 and < 8 years` = "7-8 Years",
    `8 and < 9 years` = "8-9 Years",
    `9 years or more` = "9+ Years",
    `less than 10 years` = "<10 Years",
    `10 and < 15 years` = "10-14 Years",
    `15 and < 20 years` = "15-19 Years",
    `18 and < 40 years` = "18-39 Years",
    `18 and < 50 years` = "18-49 Years",
    `18 years or more and less than 50 years` = "18-49 Years",
    `20 and < 40 years` = "20-39 Years",
    `40 and < 65 years` = "40-64 Years",
    `50 and < 65 years` = "50-64 Years",
    `50 years or more and less than 64 years` = "50-64 Years",
    `65 years or more` = "65+ Years",
    `65 and < 110 years` = "65+ Years",
    `total` = "Total"
  )[
    sub("^[^a-z0-9]+|:.*$", "", tolower(age))
  ]
}

standard_columns <- function(cols) {
  cols <- gsub(" ", "_", sub("number of ", "n_", tolower(cols)), fixed = TRUE)
  cols[grep("^age", cols)] <- "age"
  cols[grep("^state", cols)] <- "state"
  cols[grep("^county", cols)] <- "county"
  cols[grep("bmi_30", cols)] <- "bmi_30_49.8"
  cols[grep("hemoglobin_a1c_7", cols)] <- "hemoglobin_a1c_7"
  cols[grep("mmr_receipt", cols)] <- "mmr_receipt"
  cols[grep("^rsv_tests", cols)] <- "rsv_tests"
  cols
}
