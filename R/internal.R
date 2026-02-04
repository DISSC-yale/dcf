dcf_read_settings <- function(project_dir = ".", strict = FALSE) {
  settings_file <- paste0(project_dir, "/settings.json")
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
  jsonlite::read_json(settings_file)
}
dcf_init_git <- function(dir) {
  if (!dir.exists(paste0(dir, ".git"))) {
    wd <- getwd()
    on.exit(setwd(wd))
    setwd(dir)
    system2("git", "init")
    setwd(wd)
  }
}
