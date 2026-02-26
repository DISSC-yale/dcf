#' Make a Status Diagram
#'
#' Make a Data Collection Project status diagram.
#'
#' @param project_dir Path to the Data Collection Framework project to be built.
#' @param out_file File name of the file to write within \code{project_dir}.
#' @returns A character vector of the status diagram, which is also written to
#' the \code{project_dir/status.md} file.
#' @examples
#' \dontrun{
#'   dcf_status_diagram("project_directory")
#' }
#' @export

dcf_status_diagram <- function(project_dir = ".", out_file = "status.md") {
  report_file <- paste0(project_dir, "/report.json.gz")
  if (!file.exists(report_file)) {
    cli::cli_abort("no report file found")
  }
  report <- jsonlite::read_json(report_file)
  data_dir <- if (is.null(report$settings$data_dir)) {
    "data"
  } else {
    report$settings$data_dir
  }
  branch <- if (is.null(report$settings$branch)) {
    "main"
  } else {
    report$settings$branch
  }
  repo <- if (identical(report$settings$github_account, "")) {
    NULL
  } else {
    paste0(report$settings$github_account, "/", report$settings$repo_name)
  }
  indent <- "    "
  d <- c(
    'classDef pass stroke:#66bb6a',
    'classDef warn stroke:#ffa726',
    'classDef fail stroke:#f44336'
  )
  sources <- NULL
  source_ids <- list()
  file_ids <- NULL
  relationships <- NULL
  projects <- NULL
  node_id <- 0L
  for (name in names(sort(vapply(
    report$processes,
    function(p) !is.null(p$type) && p$type == "bundle",
    TRUE
  )))) {
    timing <- report$source_times[[name]]
    issues <- report$issues[[name]]
    if (length(issues)) {
      names(issues) <- sub(
        paste0(data_dir, "/"),
        "",
        sub(
          paste0(project_dir, "/"),
          "",
          sub("^\\.*/", "", names(issues)),
          fixed = TRUE
        ),
        fixed = TRUE
      )
    }
    metas <- report$metadata[grep(
      paste0("^", name, "/"),
      names(report$metadata)
    )]
    measures <- if (length(metas)) metas[[1L]]$measure_info else list()
    process <- report$processes[[name]]
    contents <- NULL
    if (!is.null(process$type) && identical(process$type, "bundle")) {
      dist_files <- grep(
        "measure_info|datapackage",
        names(process$dist_state),
        value = TRUE,
        invert = TRUE
      )
      for (filename in sub(
        paste0("^[./]*", data_dir, "/", name, "/(?:dist|standard)/"),
        "",
        dist_files
      )) {
        node_id <- node_id + 1L
        contents <- c(
          contents,
          paste0(
            "n",
            node_id,
            '["`',
            if (is.null(repo)) {
              filename
            } else {
              make_link(
                paste0(
                  "https://github.com/",
                  repo,
                  "/blob/",
                  branch,
                  "/",
                  data_dir,
                  "/",
                  name,
                  "/dist/",
                  filename
                ),
                filename
              )
            },
            '`"]'
          )
        )
      }
      file_nodes <- file_ids[
        if (!is.null(names(process$source_files))) {
          names(process$source_files)
        } else {
          unlist(process$source_files)
        }
      ]
      file_nodes <- file_nodes[!is.na(file_nodes)]
      if (length(file_nodes)) {
        relationships <- c(
          relationships,
          paste0("n", file_nodes, " --> ", name)
        )
      }
    } else {
      measure_sources <- measures[["_sources"]]
      if (is.null(measure_sources)) {
        measure_sources <- measures[["_source"]]
      }
      for (project_meta in metas) {
        for (r in project_meta$resources) {
          node_id <- node_id + 1L
          file_path <- paste0(
            name,
            "/standard/",
            r$filename
          )
          file_ids[paste0(name, "/standard/", r$filename)] <- node_id
          file_issues <- issues[[file_path]]
          for (field in r$schema$fields) {
            field_source <- measures[[field$name]]$sources
            if (!is.null(names(field_source))) {
              field_source <- list(field_source)
            }
            for (s in field_source) {
              if (is.character(s)) {
                s <- list(id = s)
              }
              if (!is.null(s$id)) {
                s <- if (is.null(measure_sources[[s$id]])) {
                  c(s, list(name = s$id))
                } else {
                  c(s, measure_sources[[s$id]])
                }
              }
              if (is.null(source_ids[[s$name]])) {
                source_id <- paste0("s", length(source_ids))
                source_ids[[s$name]] <- source_id
                sources[[source_id]] <- list(
                  id = source_id,
                  general = make_link(s$url, s$name),
                  specific = NULL
                )
                parent_id <- source_id
              } else {
                parent_id <- source_ids[[s$name]]
              }
              if (is.null(s$location_url)) {
                source_id <- source_ids[[s$name]]
              } else {
                if (is.null(source_ids[[s$location_url]])) {
                  source_id <- paste0("s", length(source_ids))
                  source_ids[[s$location_url]] <- source_id
                  relationships <- unique(c(
                    relationships,
                    paste0(
                      parent_id,
                      "---",
                      source_id,
                      '["',
                      make_link(s$location_url, s$location),
                      '"]'
                    )
                  ))
                  sources[[parent_id]]$specific <- c(
                    sources[[parent_id]]$specific,
                    source_id
                  )
                } else {
                  source_id <- source_ids[[s$location_url]]
                }
              }
              relationships <- unique(c(
                relationships,
                paste0(source_id, " --> n", node_id)
              ))
            }
          }
          failed <- is.null(report$source_times[[name]])
          contents <- c(
            contents,
            paste0(
              "n",
              node_id,
              '["`',
              if (is.null(repo)) {
                r$filename
              } else {
                make_link(
                  paste0(
                    "https://github.com/",
                    repo,
                    "/blob/",
                    branch,
                    "/",
                    data_dir,
                    "/",
                    name,
                    "/standard/",
                    r$filename
                  ),
                  r$filename
                )
              },
              if (length(file_issues)) {
                paste0("<br/><br/>", make_list(unlist(file_issues)))
              },
              if (failed) {
                paste0(
                  if (length(file_issues)) "<br />" else "<br /><br />",
                  "Script Failed:<br />",
                  gsub(
                    '[`"]',
                    "'",
                    paste(report$logs[[name]], collapse = "<br />")
                  )
                )
              },
              paste0(
                '`"]:::',
                if (failed) {
                  "fail"
                } else if (length(file_issues)) {
                  "warn"
                } else {
                  "pass"
                }
              )
            )
          )
        }
      }
    }
    projects <- c(
      projects,
      c(
        paste0(
          "subgraph ",
          name,
          '["`',
          if (is.null(repo)) {
            name
          } else {
            make_link(
              paste0(
                "https://github.com/",
                repo,
                "/tree/",
                branch,
                "/",
                data_dir,
                "/",
                name
              ),
              name
            )
          },
          '`"]'
        ),
        paste0(indent, c("direction LR", contents)),
        "end"
      )
    )
  }
  out <- c(
    "```mermaid",
    "flowchart LR",
    paste0(
      indent,
      c(
        d,
        vapply(
          sources,
          function(s) paste(c(s$id, '(("', s$general, '"))'), collapse = ""),
          ""
        ),
        projects,
        relationships
      )
    ),
    "```"
  )
  if (is.character(out_file) && out_file != "") {
    writeLines(out, paste0(project_dir, "/", out_file))
  }
  invisible(out)
}

make_link <- function(url, name = NULL) {
  paste0(
    '<strong><a href="',
    url,
    '" target="_blank" rel="noreferrer">',
    if (is.null(name)) sub("https?://(?:www\\.)?", "", url) else name,
    "</a></strong>"
  )
}

make_list <- function(items) {
  paste0(
    "<ul>",
    paste(
      vapply(
        items,
        function(i) paste0("<li><code>", i, "</code></li>"),
        ""
      ),
      collapse = ""
    ),
    "</ul>"
  )
}
