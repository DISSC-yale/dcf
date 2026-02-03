#' Adds documentation of a dataset to a datapackage
#'
#' Add information about variables in a dataset to a \code{datapackage.json} metadata file.
#'
#' @param filename A character vector of paths to plain-text tabular data files, relative to \code{dir}.
#' @param meta Information about each data file. A list with a list entry for each entry in
#' \code{filename}; see details. If a single list is provided for multiple data files, it will apply to all.
#' @param packagename Package to add the metadata to; path to the \code{.json} file relative to
#' \code{dir}, or a list with the read-in version.
#' @param dir Directory in which to look for \code{filename}, and write \code{packagename}.
#' @param write Logical; if \code{FALSE}, returns the \code{paths} metadata without reading or rewriting
#' \code{packagename}.
#' @param refresh Logical; if \code{FALSE}, will retain any existing dataset information.
#' @param sha A number specifying the Secure Hash Algorithm function,
#' if \code{openssl} is available (checked with \code{Sys.which('openssl')}).
#' @param pretty Logical; if \code{TRUE}, will pretty-print the datapackage.
#' @param summarize_ids Logical; if \code{TRUE}, will include ID columns in schema field summaries.
#' @param open_after Logical; if \code{TRUE}, opens the written datapackage after saving.
#' @param verbose Logical; if \code{FALSE}, will not show status messages.
#' @details
#' \code{meta} should be a list with unnamed entries for entry in \code{filename},
#' and each entry can include a named entry for any of these:
#' \describe{
#'   \item{source}{
#'   A list or list of lists with entries for at least \code{name}, and ideally for \code{url}.
#'   }
#'   \item{ids}{
#'   A list or list of lists with entries for at least \code{variable} (the name of a variable in the dataset).
#'   Might also include \code{map} with a list or path to a JSON file resulting in a list with an
#'   entry for each ID, and additional information about that entity, to be read in a its features.
#'   All files will be loaded to help with aggregation, but local files will be included in the datapackage,
#'   whereas hosted files will be loaded client-side.
#'   }
#'   \item{time}{
#'   A string giving the name of a variable in the dataset representing a repeated observation of the same entity.
#'   }
#'   \item{variables}{
#'   A list with named entries providing more information about the variables in the dataset.
#'   See \code{\link{dcf_measure_info}}.
#'   }
#'   \item{vintage}{
#'   A string specifying the time and/or location at which the data were produced.
#'   }
#' }
#' @examples
#' \dontrun{
#' # write example data
#' write.csv(mtcars, "mtcars.csv")
#'
#' # add it to an existing datapackage.json file in the current working directory
#' dcf_datapackage_add("mtcars.csv")
#' }
#' @return An invisible version of the updated datapackage, which is also written to
#' \code{datapackage.json} if \code{write = TRUE}.
#' @seealso Initialize the \code{datapackage.json} file with \code{\link{dcf_datapackage_init}}.
#' @export

dcf_datapackage_add <- function(
  filename,
  meta = list(),
  packagename = "datapackage.json",
  dir = ".",
  write = TRUE,
  refresh = TRUE,
  sha = "512",
  pretty = FALSE,
  summarize_ids = FALSE,
  open_after = FALSE,
  verbose = interactive()
) {
  if (missing(filename)) {
    cli::cli_abort("{.arg filename} must be specified")
  }
  setnames <- names(filename)
  if (file.exists(filename[[1]])) {
    if (dir == ".") {
      dir <- dirname(filename[[1]])
    }
    filename <- basename(filename)
  }
  if (any(!file.exists(paste0(dir, "/", filename)))) {
    filename <- filename[!file.exists(filename)]
    cli::cli_abort("{?a file/files} did not exist: {filename}")
  }
  package <- if (
    is.character(packagename) && file.exists(paste0(dir, "/", packagename))
  ) {
    paste0(dir, "/", packagename)
  } else {
    packagename
  }
  if (write) {
    if (is.character(package)) {
      package <- paste0(dir, "/", packagename)
      package <- if (file.exists(package)) {
        packagename <- package
        jsonlite::read_json(package)
      } else {
        dcf_datapackage_init(
          if (!is.null(setnames)) setnames[[1]] else filename[[1]],
          dir = dir
        )
      }
    }
    if (!is.list(package)) {
      cli::cli_abort(c(
        "{.arg package} does not appear to be in the right format",
        i = "this should be (or be read in from JSON as) a list with a {.code resource} entry"
      ))
    }
  }
  if (!is.list(package)) {
    package <- list()
  }
  single_meta <- FALSE
  metas <- if (!is.null(names(meta))) {
    meta_names <- if (is.null(setnames)) filename else setnames
    if (all(meta_names %in% names(meta))) {
      meta[meta_names]
    } else {
      single_meta <- TRUE
      if (length(meta$variables) == 1 && is.character(meta$variables)) {
        if (!file.exists(meta$variables)) {
          meta$variables <- paste0(dir, "/", meta$variables)
        }
        if (file.exists(meta$variables)) {
          meta$variables <- jsonlite::read_json(meta$variables)
        }
      }
      meta$variables <- replace_equations(meta$variables)
      meta
    }
  } else {
    meta[seq_along(filename)]
  }
  if (!single_meta) {
    metas <- lapply(metas, function(m) {
      m$variables <- replace_equations(m$variables)
      m
    })
  }
  collect_metadata <- function(file) {
    f <- paste0(dir, "/", filename[[file]])
    m <- if (single_meta) meta else metas[[file]]
    format <- if (grepl(".parquet", f, fixed = TRUE)) {
      "parquet"
    } else if (grepl(".json", f, fixed = TRUE)) {
      "json"
    } else if (grepl(".csv", f, fixed = TRUE)) {
      "csv"
    } else if (grepl(".rds", f, fixed = TRUE)) {
      "rds"
    } else {
      "tsv"
    }
    if (is.na(format)) {
      format <- "rds"
    }
    info <- file.info(f)
    metas <- list()
    unpack_meta <- function(n) {
      if (!length(m[[n]])) {
        list()
      } else if (is.list(m[[n]][[1]])) {
        m[[n]]
      } else {
        list(m[[n]])
      }
    }
    vintage <- unlist(unpack_meta("vintage"))
    ids <- unpack_meta("ids")
    idvars <- NULL
    for (i in seq_along(ids)) {
      if (is.list(ids[[i]])) {
        if (
          length(ids[[i]]$map) == 1 &&
            is.character(ids[[i]]$map) &&
            file.exists(ids[[i]]$map)
        ) {
          ids[[i]]$map_content <- paste(
            readLines(ids[[i]]$map, warn = FALSE),
            collapse = ""
          )
        }
      } else {
        ids[[i]] <- list(variable = ids[[i]])
      }
      if (!ids[[i]]$variable %in% idvars) idvars <- c(idvars, ids[[i]]$variable)
    }
    data <- if (format == "rds") {
      tryCatch(readRDS(f), error = function(e) NULL)
    } else if (format == "parquet") {
      tryCatch(arrow::read_parquet(f), error = function(e) NULL)
    } else if (format == "json") {
      tryCatch(
        as.data.frame(jsonlite::read_json(f, simplifyVector = TRUE)),
        error = function(e) NULL
      )
    } else {
      attempt_read(f, c("geography", "time", idvars))
    }
    if (is.null(data)) {
      cli::cli_warn(c(
        paste0("failed to read in the data file ({.file {f}})"),
        i = "check that it is in a compatible format"
      ))
      return(NULL)
    }
    if (!all(rownames(data) == seq_len(nrow(data)))) {
      data <- cbind(`_row` = rownames(data), data)
    }
    timevar <- unlist(unpack_meta("time"))
    times <- if (is.null(timevar)) rep(1, nrow(data)) else data[[timevar]]
    times_unique <- unique(times)
    if (!single_meta) {
      varinf <- unpack_meta("variables")
      if (length(varinf) == 1 && is.character(varinf[[1]])) {
        if (!file.exists(varinf[[1]])) {
          varinf[[1]] <- paste0(dir, "/", varinf[[1]])
        }
        if (file.exists(varinf[[1]])) {
          if (varinf[[1]] %in% names(metas)) {
            varinf <- metas[[varinf[[1]]]]
          } else {
            varinf <- metas[[varinf[[1]]]] <- dcf_measure_info(
              varinf[[1]],
              write = FALSE,
              render = TRUE
            )
          }
          varinf <- varinf[varinf != ""]
        }
      }
      varinf_full <- names(varinf)
      varinf_suf <- sub("^[^:]+:", "", varinf_full)
    }
    created <- as.character(info$mtime)
    res <- list(
      bytes = as.integer(info$size),
      encoding = stringi::stri_enc_detect(f)[[1]][1, 1],
      md5 = tools::md5sum(f)[[1]],
      format = format,
      name = if (!is.null(setnames)) {
        setnames[file]
      } else if (!is.null(m$name)) {
        m$name
      } else {
        sub("\\.[^.]*$", "", basename(filename[[file]]))
      },
      filename = filename[[file]],
      versions = get_versions(f),
      source = unpack_meta("source"),
      ids = ids,
      id_length = if (length(idvars)) {
        id_lengths <- nchar(data[[idvars[1]]])
        id_lengths <- id_lengths[!is.na(id_lengths)]
        if (all(id_lengths == id_lengths[1])) id_lengths[1] else 0
      } else {
        0
      },
      time = timevar,
      profile = "data-resource",
      created = as.character(info$mtime),
      last_modified = as.character(info$ctime),
      vintage = if (length(vintage)) vintage else NULL,
      row_count = nrow(data),
      entity_count = if (length(idvars)) {
        length(unique(data[[idvars[1]]]))
      } else {
        nrow(data)
      },
      schema = list(
        fields = lapply(
          if (summarize_ids) {
            colnames(data)
          } else {
            colnames(data)[!colnames(data) %in% idvars]
          },
          function(cn) {
            v <- data[[cn]]
            invalid <- !is.finite(v)
            r <- list(name = cn, duplicates = sum(duplicated(v)))
            if (!single_meta) {
              if (cn %in% varinf_full) {
                r$info <- varinf[[cn]]
              } else if (cn %in% varinf_suf) {
                r$info <- varinf[[which(varinf_suf == cn)]]
              }
              r$info <- r$info[r$info != ""]
            }
            su <- !is.na(v)
            if (any(su)) {
              r$time_range <- which(times_unique %in% range(times[su])) - 1
              r$time_range <- if (length(r$time_range)) {
                r$time_range[c(1, length(r$time_range))]
              } else {
                c(-1, -1)
              }
            } else {
              r$time_range <- c(-1, -1)
            }
            if (!is.character(v) && all(invalid)) {
              r$type <- "unknown"
              r$missing <- length(v)
            } else if (is.numeric(v)) {
              r$type <- if (all(invalid | as.integer(v) == v)) {
                "integer"
              } else {
                "float"
              }
              r$missing <- sum(invalid)
              r$mean <- round(mean(v, na.rm = TRUE), 6)
              r$sd <- round(stats::sd(v, na.rm = TRUE), 6)
              r$min <- round(min(v, na.rm = TRUE), 6)
              r$max <- round(max(v, na.rm = TRUE), 6)
            } else {
              r$type <- "string"
              v <- as.factor(as.character(v))
              r$missing <- sum(is.na(v) | is.nan(v) | grepl("^[\\s.-]$", v))
              r$table <- structure(as.list(tabulate(v)), names = levels(v))
            }
            r
          }
        )
      )
    )
    if (!single_meta && "_references" %in% names(varinf)) {
      res[["_references"]] <- varinf[["_references"]]
    }
    if (Sys.which("openssl") != "") {
      res[[paste0("sha", sha)]] <- calculate_sha(f, sha)
    }
    res
  }
  metadata <- Filter(length, lapply(seq_along(filename), collect_metadata))
  if (single_meta) {
    package$measure_info <- lapply(meta$variables, function(e) e[e != ""])
  }
  names <- vapply(metadata, "[[", "", "filename")
  for (resource in package$resources) {
    if (length(resource$versions)) {
      su <- which(names %in% resource$filename)
      if (length(su)) {
        if (length(metadata[[su]]$versions)) {
          metadata[[su]]$versions <- rbind(
            metadata[[su]]$versions,
            if (is.data.frame(resource$versions)) {
              resource$versions
            } else {
              as.data.frame(do.call(cbind, resource$versions))
            }
          )
          metadata[[su]]$versions <- metadata[[su]]$versions[
            !duplicated(metadata[[su]]$versions),
          ]
        }
      }
    }
  }
  if (refresh) {
    package$resources <- metadata
  } else {
    package$resources <- c(
      metadata,
      package$resources[
        !(vapply(package$resources, "[[", "", "filename") %in% names)
      ]
    )
  }
  if (write) {
    packagename <- if (is.character(packagename)) {
      packagename
    } else {
      "datapackage.json"
    }
    jsonlite::write_json(
      package,
      if (file.exists(packagename)) {
        packagename
      } else {
        paste0(dir, "/", packagename)
      },
      auto_unbox = TRUE,
      digits = 6,
      dataframe = "columns",
      pretty = pretty
    )
    if (verbose) {
      cli::cli_bullets(c(
        v = paste(
          if (refresh) "updated resource in" else "added resource to",
          "datapackage.json:"
        ),
        "*" = paste0("{.path ", packagename, "}")
      ))
      if (open_after) rstudioapi::navigateToFile(packagename)
    }
  }
  invisible(package)
}

get_versions <- function(file) {
  log <- suppressWarnings(system2(
    "git",
    c("log", file),
    stdout = TRUE
  ))
  if (is.null(attr(log, "status"))) {
    log_entries <- strsplit(paste(log, collapse = "|"), "commit ")[[
      1
    ]]
    log_entries <- do.call(
      rbind,
      Filter(
        function(x) length(x) == 4L,
        strsplit(
          log_entries[log_entries != ""],
          "\\|+(?:[^:]+:)?\\s*"
        )
      )
    )
    if (length(log_entries)) {
      colnames(log_entries) <- c(
        "hash",
        "author",
        "date",
        "message"
      )
      as.data.frame(log_entries)
    }
  }
}

attempt_read <- function(file, id_cols) {
  tryCatch(
    {
      sep <- if (grepl(".csv", file, fixed = TRUE)) "," else "\t"
      cols <- scan(file, "", nlines = 1, sep = sep, quiet = TRUE)
      types <- rep("?", length(cols))
      types[cols %in% id_cols] <- "c"
      arrow::read_delim_arrow(
        gzfile(file),
        sep,
        col_names = cols,
        col_types = paste(types, collapse = ""),
        skip = 1,
        convert_options = arrow::csv_convert_options(check_utf8 = FALSE)
      )
    },
    error = function(e) NULL
  )
}

calculate_sha <- function(file, level) {
  if (Sys.which("openssl") != "") {
    tryCatch(
      strsplit(
        system2(
          "openssl",
          c("dgst", paste0("-sha", level), shQuote(file)),
          TRUE
        ),
        " ",
        fixed = TRUE
      )[[1]][2],
      error = function(e) ""
    )
  } else {
    ""
  }
}
