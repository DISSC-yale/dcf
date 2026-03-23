test_that("project build works", {
  root_dir <- paste0(tempdir(), "/dcf_test")
  data_dir <- "output"
  dcf_init(
    "dcf_test",
    dirname(root_dir),
    data_dir = data_dir,
    open_after = FALSE
  )
  wd <- setwd(root_dir)
  on.exit(setwd(wd))

  #
  # source project
  #

  source_name <- "test_source"
  source_dir <- paste(root_dir, data_dir, source_name, sep = "/")
  dcf_add_source(source_name, root_dir, open_after = FALSE)
  project_files <- paste0(
    source_dir,
    "/",
    c("ingest.R", "process.json", "measure_info.json")
  )
  expect_true(all(file.exists(project_files)))
  process <- dcf_process_record(project_files[[2L]])
  process$vintages <- list(data.csv.xz = "2020")
  dcf_process_record(project_files[[2L]], process)

  # initial ingest with issues
  writeLines(
    c(
      '# write raw',
      'data <- data.frame(',
      '  loc = c("a", NA), year = c(2020, NA), value = c(1, NA), cats = c("c", "b")',
      ')',
      'write.csv(data, "raw/data.csv", row.names = FALSE)',
      '',
      '# standardize',
      'data <- read.csv("raw/data.csv")',
      'colnames(data) <- c("geography", "time", "measure_name", "cats")',
      'write.csv(data, "standard/data.csv", row.names = FALSE)'
    ),
    project_files[[1L]]
  )
  timings <- dcf_process(source_name, root_dir)$timings
  expect_false(is.null(timings[[source_name]]))
  issues <- dcf_check(source_name, root_dir)
  expect_true(length(issues[[source_name]]) != 0)

  # updated with issues corrected
  unlink(
    paste0(
      source_dir,
      "/",
      c("raw", "standard"),
      "/data.csv"
    ),
    force = TRUE
  )
  script <- c(
    '# write raw',
    'data <- data.frame(',
    '  loc = c("a", NA), year = c(2020, NA), value = c(1, NA),',
    '  value2 = c(100, 101), cats = c("c", "b")',
    ')',
    'write.csv(data, xzfile("raw/data.csv.xz"), row.names = FALSE)',
    '',
    '# standardize',
    'data <- read.csv("raw/data.csv.xz")',
    'colnames(data) <- c("geography", "time", "measure1", "measure2", "cats")',
    'write.csv(data[!is.na(data$time), ], xzfile("standard/data.csv.xz"), row.names = FALSE)'
  )
  writeLines(script, project_files[[1L]])
  dcf_process(source_name, root_dir)
  package <- jsonlite::read_json(paste0(
    source_dir,
    "/standard/datapackage.json"
  ))
  expect_identical(
    package$change_report,
    list(
      data.csv.xz = list(state = "new file"),
      data.csv = list(state = "removed file")
    )
  )
  dcf_measure_info(
    project_files[[3L]],
    measure1 = list(
      sources = c("source_a", "source_b")
    ),
    measure2 = list(),
    cats = list(),
    sources = list(
      source_a = list(name = "Source A", url = "example.com/a"),
      source_b = list(name = "Source B", url = "example.com/b")
    ),
    verbose = FALSE,
    open_after = FALSE
  )
  script[4L] <- '  value2 = c(100.1, 101.1), cats = c("a", "b")'
  writeLines(script, project_files[[1L]])
  system2("git", "init")
  system2("git", 'config user.email "temp@example.com"')
  system2("git", 'config user.name "temp user"')
  system2("git", "add -A")
  system2("git", 'commit -m "initial commit"')
  report <- dcf_build(root_dir, clear_state = TRUE)
  package <- report$metadata[[1L]]
  expect_false(is.null(package$resources[[1L]]$versions$hash))
  expect_false(package$change_report$data.csv.xz$variables$measure2$same_type)
  expect_identical(
    package$change_report$data.csv.xz$variables$cats,
    list(
      status = "present",
      same_type = TRUE,
      added_levels = "a",
      dropped_levels = "c"
    )
  )
  expect_true(length(report$issues[[source_name]][[1L]]) == 1L)

  #
  # bundle project
  #

  bundle_name <- "bundle"
  bundle_dir <- paste(root_dir, data_dir, bundle_name, sep = "/")
  dcf_add_bundle(
    bundle_name,
    root_dir,
    source_files = structure(
      list(c("bundle.json.gz", "optional.csv.gz")),
      names = paste0(source_name, "/standard/data.csv.xz")
    ),
    open_after = FALSE
  )
  bundle_files <- paste0(
    bundle_dir,
    "/",
    c("build.R", "process.json", "measure_info.json")
  )
  expect_true(all(file.exists(bundle_files)))
  writeLines(
    c(
      paste0('data <- read.csv("../', source_name, '/standard/data.csv.xz")'),
      'jsonlite::write_json(data, gzfile("dist/bundle.json.gz"), dataframe = "columns")'
    ),
    bundle_files[[1L]]
  )
  dcf_measure_info(
    bundle_files[[3L]],
    measurea = list(source_id = "measure1"),
    measure2 = list(),
    cats = list(),
    open_after = FALSE
  )

  #
  # tall bundle
  #

  bundle_name <- "bundle_tall"
  bundle_dir <- paste(root_dir, data_dir, bundle_name, sep = "/")
  dcf_add_bundle(
    bundle_name,
    root_dir,
    source_files = structure(
      list(c("bundle.json.gz", "bundle_standard.json.gz")),
      names = paste0(source_name, "/standard/data.csv.xz")
    ),
    open_after = FALSE
  )
  bundle_files <- paste0(
    bundle_dir,
    "/",
    c("build.R", "process.json", "measure_info.json")
  )
  expect_true(all(file.exists(bundle_files)))
  writeLines(
    c(
      paste0('data <- read.csv("../', source_name, '/standard/data.csv.xz")'),
      "measures <- colnames(data)[!(colnames(data) %in% c('geography', 'time', 'cats'))]",
      "jsonlite::write_json(data.frame(",
      '  geography = data[["geography"]], time = data[["time"]],',
      "  measure = measures, value = as.numeric(data[1, measures]),",
      "  row.names = NULL",
      '), gzfile("dist/bundle.json.gz"), dataframe = "columns")',
      "jsonlite::write_json(data.frame(",
      '  geography = data[["geography"]], time = data[["time"]],',
      "  measure = 1:2, value = as.numeric(data[1, measures] / 100),",
      "  row.names = NULL",
      '), gzfile("dist/bundle_standard.json.gz"), dataframe = "columns")'
    ),
    bundle_files[[1L]]
  )
  dcf_measure_info(
    bundle_files[[3L]],
    `bundle_tall/dist/bundle.json.gz|measure` = list(
      levels = list(
        measure1 = NULL,
        measure2 = NULL
      )
    ),
    `bundle_tall/dist/bundle_standard.json.gz|measure` = list(
      levels = list(
        `1` = list(source_id = "measure1"),
        `2` = list(source_id = "measure2")
      )
    ),
    `{variant}value` = list(
      measure_column = "{variant}measure",
      variants = list(
        `bundle_tall/dist/bundle.json.gz|` = list(),
        `bundle_tall/dist/bundle_standard.json.gz|` = list()
      )
    ),
    open_after = FALSE
  )

  report <- dcf_build(root_dir, clear_state = TRUE)
  expect_identical(
    unname(vapply(unlist(report$issues, FALSE), length, 0L)),
    integer(4)
  )
  expect_identical(
    report$metadata$`test_source/standard`$resources[[1L]]$schema$fields[[
      3L
    ]]$info,
    report$metadata$`bundle_tall/dist`$resources[[1L]]$schema$fields[[
      3L
    ]]$info$source_info$measure1$info
  )
  expect_identical(
    jsonlite::read_json(paste0(root_dir, "/file_log.json"))[[1]]$updated,
    "2020"
  )

  dcf_status_diagram(root_dir)

  expect_true(file.exists(paste0(root_dir, "/status.md")))
  expect_true(file.exists(paste0(bundle_dir, "/dist/bundle.json.gz")))

  dcf_update_lock(root_dir)
  expect_true(file.exists(paste0(root_dir, "/renv.lock")))

  manual_report <- jsonlite::read_json(paste0(root_dir, "/report.json.gz"))
  manual_report$settings$report_url <- ""
  expect_identical(
    dcf_report(root_dir),
    manual_report
  )

  variables <- dcf_variables(root_dir)
  data <- dcf_data(variables$name[1L], root_dir, "wide")
  expect_true(data$data$geography == "a")

  data <- dcf_data(variables$name[1L], root_dir, "tall")
  expect_identical(data$data$geography, c("a", "a"))
})
