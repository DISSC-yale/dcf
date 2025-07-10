dcf_read_settings <- function(project_dir = ".") {
  settings_file <- paste0(project_dir, "/settings.json")
  if (!file.exists(settings_file)) {
    cli::cli_abort(
      "{.arg project_dir} ({project_dir}) does not appear to be a Data Collection Framework project"
    )
  }
  jsonlite::read_json(settings_file)
}
