dcf_attempt_read_json <- function(path, ..., strict = TRUE) {
  contents <- tryCatch(jsonlite::read_json(path, ...), error = function(e) NULL)
  if (is.null(contents)) {
    (if (strict) cli::cli_abort else cli::cli_warn)(
      "failed to read {.file {path}}"
    )
  }
  contents
}
dcf_read_settings <- function(project_dir = ".", strict = FALSE) {
  settings_file <- file.path(project_dir, "settings.json")
  if (!file.exists(settings_file)) {
    if (strict) {
      cli::cli_abort(
        "{.arg project_dir} ({project_dir}) does not appear to be a Data Collection Framework project"
      )
    } else {
      return(list(
        name = basename(normalizePath(project_dir, "/", FALSE)),
        data_dir = ".",
        standalone = TRUE
      ))
    }
  }
  dcf_attempt_read_json(settings_file)
}
dcf_init_git <- function(dir) {
  if (!dir.exists(file.path(dir, ".git"))) {
    wd <- getwd()
    on.exit(setwd(wd))
    setwd(dir)
    system2("git", "init")
    setwd(wd)
  }
}

dcf_git_versions <- function(file, dir = ".") {
  wd <- setwd(dir)
  on.exit(setwd(wd))
  log <- suppressWarnings(system2(
    "git",
    c("log", '--format="%H|||%an <%ae>|||%ad|||%s"', shQuote(file)),
    stdout = TRUE
  ))
  setwd(wd)
  if (is.null(attr(log, "status"))) {
    log_entries <- do.call(
      rbind,
      Filter(
        function(x) length(x) == 4L,
        strsplit(log, "|||", fixed = TRUE)
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
