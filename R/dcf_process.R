#' Run Data Project Processes
#'
#' Operates over data source and bundle projects, optionally running the source
#' ingest scripts, then collecting metadata.
#'
#' @param name Name of a source project to process. Will
#' @param project_dir Path to the project directory. If not specified, and being called
#' from a source project, this will be assumed to be two steps back from the working directory.
#' @param ingest Logical; if \code{FALSE}, will re-process standardized data without running
#' ingestion scripts. Only applies to source projects.
#' @param is_auto Logical; if \code{TRUE}, will skip process scripts marked as manual.
#' @param force Logical; if \code{TRUE}, will ignore process frequencies
#' (will run scripts even if recently run).
#' @param clear_state Logical; if \code{TRUE}, will clear stored states before processing.
#' @returns A list with processing results:
#' \itemize{
#'   \item \code{timings}: How many seconds the scripts took to run.
#'   \item \code{logs}: The captured output of the scripts.
#' }
#' Each entry has an entry for each project.
#'
#' A `datapackage.json` file is also created / update in each source's `standard` directory.
#' @examples
#' \dontrun{
#'   # run from a directory containing a `data` directory containing the source
#'   dcf_process("source_name")
#'
#'   # run without executing the ingestion script
#'   dcf_process("source_name", ingest = FALSE)
#' }
#' @export

dcf_process <- function(
  name = NULL,
  project_dir = ".",
  ingest = TRUE,
  is_auto = FALSE,
  force = FALSE,
  clear_state = FALSE
) {
  settings_file <- paste0(project_dir, "/settings.json")
  from_project <- file.exists(settings_file)
  if (from_project) {
    source_dir <- paste0(
      project_dir,
      "/",
      jsonlite::read_json(settings_file)$data_dir
    )
  } else {
    project_dir <- "../.."
    source_dir <- ".."
    name <- basename(getwd())
  }

  sources <- if (is.null(name)) {
    list.files(
      source_dir,
      "process\\.json",
      recursive = TRUE,
      full.names = TRUE
    )
  } else {
    process_files <- paste0(source_dir, "/", name, "/process.json")
    if (any(!file.exists(process_files))) {
      cli::cli_abort(
        "missing process file{?/s}: {.emph {process_files[!file.exists(process_files)]}}"
      )
    }
    process_files
  }
  decide_to_run <- function(process_script) {
    if (is_auto && process_script$manual) {
      return(FALSE)
    }
    if (
      force || process_script$last_run == "" || process_script$frequency == 0L
    ) {
      return(TRUE)
    }
    if (
      difftime(Sys.time(), as.POSIXct(process_script$last_run), units = "day") >
        process_script$frequency
    ) {
      return(TRUE)
    }
    FALSE
  }
  collect_env <- new.env()
  collect_env$timings <- list()
  collect_env$logs <- list()
  process_source <- function(process_file) {
    process_def <- dcf_process_record(process_file)
    if (clear_state) {
      process_def$raw_state <- NULL
      process_def$standard_state <- NULL
      dcf_process_record(process_file, process_def)
    }
    name <- process_def$name
    dcf_add_source(name, project_dir, open_after = FALSE)
    for (si in seq_along(process_def$scripts)) {
      st <- proc.time()[[3]]
      process_script <- process_def$scripts[[si]]
      run_current <- ingest && decide_to_run(process_script)
      base_dir <- dirname(process_file)
      standard_dir <- paste0(base_dir, "/standard")
      script <- paste0(base_dir, "/", process_script$path)
      file_ref <- if (run_current) paste0(" ({.emph ", script, "})") else NULL
      cli::cli_progress_step(
        paste0("processing source {.strong ", name, "}", file_ref),
        spinner = TRUE
      )
      env <- new.env()
      env$dcf_process_continue <- TRUE
      status <- if (ingest) {
        tryCatch(
          list(
            log = utils::capture.output(
              source(script, env, chdir = TRUE),
              type = "message"
            ),
            success = TRUE
          ),
          error = function(e) list(log = e$message, success = FALSE)
        )
      } else {
        list(log = "", success = TRUE)
      }
      collect_env$logs[[name]] <- status$log
      if (run_current) {
        process_script$last_run <- Sys.time()
        process_script$run_time <- proc.time()[[3]] - st
        process_script$last_status <- status
        process_def$scripts[[si]] <- process_script
      }
      if (status$success) {
        collect_env$timings[[name]] <- process_script$run_time
      }
      if (!env$dcf_process_continue) break
    }
    process_def_current <- dcf_process_record(process_file)
    if (
      is.null(process_def_current$raw_state) ||
        !identical(process_def$raw_state, process_def_current$raw_state)
    ) {
      process_def_current$scripts <- process_def$scripts
      dcf_process_record(process_file, process_def_current)
    }
    data_files <- list.files(standard_dir, "\\.(?:csv|parquet|json)")
    data_files <- data_files[!grepl("datapackage", data_files, fixed = TRUE)]
    if (length(data_files)) {
      measure_info_file <- paste0(base_dir, "/measure_info.json")
      standard_state <- as.list(tools::md5sum(c(
        measure_info_file,
        paste0(standard_dir, "/", data_files)
      )))
      if (!identical(process_def_current$standard_state, standard_state)) {
        measure_info <- dcf_measure_info(
          measure_info_file,
          include_empty = FALSE,
          render = TRUE,
          write = FALSE,
          open_after = FALSE,
          verbose = FALSE
        )
        measure_sources <- list()
        for (measure_id in names(measure_info)) {
          measure_info[[measure_id]]$id <- measure_id
          info <- measure_info[[measure_id]]
          for (s in info$sources) {
            if (
              !is.null(s$location) &&
                !(s$location %in% names(sources))
            ) {
              measure_sources[[s$location]] <- s
            }
          }
        }
        if (!file.exists(paste0(standard_dir, "/datapackage.json"))) {
          dcf_datapackage_init(name, dir = standard_dir, quiet = TRUE)
        }
        dcf_datapackage_add(
          data_files,
          meta = list(
            source = unname(measure_sources),
            base_dir = base_dir,
            ids = "geography",
            time = "time",
            variables = measure_info
          ),
          dir = standard_dir,
          pretty = TRUE,
          summarize_ids = TRUE,
          verbose = FALSE
        )
        process_def_current$standard_state <- standard_state
        dcf_process_record(process_file, process_def_current)
      }
      cli::cli_progress_done(result = if (status$success) "done" else "failed")
    } else {
      cli::cli_progress_done(result = "failed")
      cli::cli_bullets(
        c(" " = "no standard data files found in {.path {process_file}}")
      )
    }
  }
  process_bundle <- function(process_file) {
    process_def <- dcf_process_record(process_file)
    if (clear_state) {
      process_def$source_state <- NULL
      process_def$dist_state <- NULL
      dcf_process_record(process_file, process_def)
    }
    name <- process_def$name
    dcf_add_bundle(name, project_dir, open_after = FALSE)
    for (si in seq_along(process_def$scripts)) {
      st <- proc.time()[[3]]
      process_script <- process_def$scripts[[si]]
      base_dir <- dirname(process_file)
      script <- paste0(base_dir, "/", process_script$path)
      run_current <- TRUE
      if (length(process_def$source_files)) {
        standard_files <- paste0(source_dir, "/", process_def$source_files)
        standard_state <- as.list(tools::md5sum(paste0(
          source_dir,
          "/",
          process_def$source_files
        )))
        run_current <- !identical(standard_state, process_def$source_state)
      }
      if (run_current) {
        cli::cli_progress_step(
          paste0(
            "processing bundle {.strong ",
            name,
            "} ({.emph ",
            script,
            "})"
          ),
          spinner = TRUE
        )
        env <- new.env()
        env$dcf_process_continue <- TRUE
        status <- tryCatch(
          list(
            log = utils::capture.output(
              source(script, env, chdir = TRUE),
              type = "message"
            ),
            success = TRUE
          ),
          error = function(e) list(log = e$message, success = FALSE)
        )
        collect_env$logs[[name]] <- status$log
        if (run_current) {
          process_script$last_run <- Sys.time()
          process_script$run_time <- proc.time()[[3]] - st
          process_script$last_status <- status
          process_def$scripts[[si]] <- process_script
        }
        if (status$success) {
          collect_env$timings[[name]] <- process_script$run_time
        }
        if (!env$dcf_process_continue) break
      }
    }
    process_def_current <- dcf_process_record(process_file)
    dist_dir <- paste0(base_dir, "/dist")
    dist_files <- grep(
      "datapackage",
      list.files(dist_dir),
      fixed = TRUE,
      invert = TRUE,
      value = TRUE
    )
    if (length(dist_files)) {
      dist_state <- as.list(tools::md5sum(paste0(
        base_dir,
        "/dist/",
        dist_files
      )))
      if (!identical(process_def_current$dist_state, dist_state)) {
        process_def_current$scripts <- process_def$scripts
        process_def_current$dist_state <- dist_state
        process_def_current$standard_state <- standard_state
        dcf_process_record(process_file, process_def_current)

        # merge with standard measure infos
        source_measure_info <- Reduce(
          c,
          lapply(
            paste0(
              source_dir,
              "/",
              sub("/.*$", "", process_def$source_files),
              "/standard/datapackage.json"
            ),
            function(f) jsonlite::read_json(f)$measure_info
          )
        )
        measure_info <- dcf_measure_info(
          paste0(base_dir, "/measure_info.json"),
          include_empty = FALSE,
          render = TRUE,
          write = FALSE,
          open_after = FALSE,
          verbose = FALSE
        )
        for (measure_id in names(measure_info)) {
          info <- measure_info[[measure_id]]
          info$id <- measure_id
          source_id <- if (!is.null(info$source_id)) info$source_id else
            measure_id
          source_info <- source_measure_info[[source_id]]
          if (!is.null(source_info)) {
            for (entry_name in names(source_info)) {
              if (
                is.null(info[[entry_name]]) ||
                  (is.character(info[[entry_name]]) && info[[entry_name]] == "")
              ) {
                info[[entry_name]] <- source_info[[entry_name]]
              } else if (is.list(info[[entry_name]])) {
                info[[entry_name]] <- unique(c(
                  info[[entry_name]],
                  source_info[[entry_name]]
                ))
              }
            }
          }
          measure_info[[measure_id]] <- info
        }
        measure_sources <- list()
        for (info in measure_info) {
          for (s in info$sources) {
            if (
              !is.null(s$location) &&
                !(s$location %in% names(sources))
            ) {
              measure_sources[[s$location]] <- s
            }
          }
        }
        if (!file.exists(paste0(dist_dir, "/datapackage.json"))) {
          dcf_datapackage_init(name, dir = dist_dir, quiet = TRUE)
        }
        dcf_datapackage_add(
          dist_files,
          meta = list(
            source = unname(measure_sources),
            base_dir = base_dir,
            ids = "geography",
            time = "time",
            variables = measure_info
          ),
          dir = dist_dir,
          pretty = TRUE,
          summarize_ids = TRUE,
          verbose = FALSE
        )
      }
      cli::cli_progress_done(result = if (status$success) "done" else "failed")
    } else {
      cli::cli_progress_done(result = "failed")
      cli::cli_bullets(
        c(" " = "no standard data files found in {.path {process_file}}")
      )
    }
  }
  for (process_file in sources[order(
    vapply(
      sources,
      function(f) {
        type <- jsonlite::read_json(f)$type
        is.null(type) || type == "bundle"
      },
      TRUE
    )
  )]) {
    process_def <- dcf_process_record(process_file)
    if (is.null(process_def$type) || process_def$type == "source") {
      process_source(process_file)
    } else {
      process_bundle(process_file)
    }
  }
  invisible(list(timings = collect_env$timings, logs = collect_env$logs))
}
