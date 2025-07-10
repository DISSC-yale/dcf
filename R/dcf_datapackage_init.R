#' Create a datapackage.json template
#'
#' Initialize dataset documentation with a \code{datapackage.json} template, based on a
#' \href{https://specs.frictionlessdata.io/data-package}{Data Package} standard.
#'
#' @param name A unique name for the dataset; allowed characters are \code{[a-z._/-]}.
#' @param title A display name for the dataset; if not specified, will be a formatted version of \code{name}.
#' @param dir Directory in which to save the \code{datapackage.json} file.
#' @param ... passes arguments to \code{\link{dcf_datapackage_add}}.
#' @param write Logical; if \code{FALSE}, the package object will not be written to a file.
#' @param overwrite Logical; if \code{TRUE} and \code{write} is \code{TRUE}, an existing
#' \code{datapackage.json} file will be overwritten.
#' @param quiet Logical; if \code{TRUE}, will not print messages or navigate to files.
#' @examples
#' \dontrun{
#' # make a template datapackage.json file in the current working directory
#' dcf_datapackage_init("mtcars", "Motor Trend Car Road Tests")
#' }
#' @return An invisible list with the content written to the \code{datapackage.json} file.
#' @seealso Add basic information about a dataset with \code{\link{dcf_datapackage_add}}.
#' @export

dcf_datapackage_init <- function(
  name,
  title = name,
  dir = ".",
  ...,
  write = TRUE,
  overwrite = FALSE,
  quiet = !interactive()
) {
  if (missing(name)) {
    cli::cli_abort("{.arg name} must be specified")
  }
  package <- list(
    name = name,
    title = if (title == name) {
      gsub("\\b(\\w)", "\\U\\1", gsub("[._/-]", " ", name), perl = TRUE)
    } else {
      title
    },
    licence = list(
      url = "http://opendatacommons.org/licenses/pddl",
      name = "Open Data Commons Public Domain",
      version = "1.0",
      id = "odc-pddl"
    ),
    resources = list()
  )
  package_path <- normalizePath(paste0(dir, "/datapackage.json"), "/", FALSE)
  if (write && !overwrite && file.exists(package_path)) {
    cli::cli_abort(c(
      "datapackage ({.path {package_path}}) already exists",
      i = "add {.code overwrite = TRUE} to overwrite it"
    ))
  }
  if (length(list(...))) {
    package$resources <- dcf_datapackage_add(..., dir = dir, write = FALSE)
  }
  if (write) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
    }
    jsonlite::write_json(
      package,
      package_path,
      auto_unbox = TRUE,
      digits = 6,
      pretty = TRUE
    )
    if (!quiet) {
      cli::cli_bullets(c(
        v = "created metadata template for {name}:",
        "*" = paste0("{.path ", package_path, "}")
      ))
      rstudioapi::navigateToFile(package_path)
    }
  }
  invisible(package)
}
