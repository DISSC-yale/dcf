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

  # initial ingest with issues
  writeLines(
    c(
      '# write raw',
      'data <- data.frame(loc = c("a", NA), year = c(2020, NA), value = c(1, NA))',
      'write.csv(data, "raw/data.csv", row.names = FALSE)',
      '',
      '# standardize',
      'data <- read.csv("raw/data.csv")',
      'colnames(data) <- c("geography", "time", "measure_name")',
      'write.csv(data, "standard/data.csv", row.names = FALSE)'
    ),
    project_files[[1L]]
  )
  timings <- dcf_process(source_name, root_dir)$timings
  expect_false(is.null(timings[[source_name]]))
  issues <- dcf_check_sources(source_name, root_dir)
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
  writeLines(
    c(
      '# write raw',
      'data <- data.frame(loc = c("a", NA), year = c(2020, NA), value = c(1, NA))',
      'write.csv(data, xzfile("raw/data.csv.xz"), row.names = FALSE)',
      '',
      '# standardize',
      'data <- read.csv("raw/data.csv.xz")',
      'colnames(data) <- c("geography", "time", "measure_name")',
      'write.csv(data[!is.na(data$time), ], xzfile("standard/data.csv.xz"), row.names = FALSE)'
    ),
    project_files[[1L]]
  )
  dcf_process(source_name, root_dir)
  dcf_measure_info(
    project_files[[3L]],
    measure_name = list(
      full_name = "measure_name"
    ),
    verbose = FALSE,
    open_after = FALSE
  )
  system2("git", "init")
  system2("git", 'config user.email "temp@example.com"')
  system2("git", 'config user.name "temp user"')
  system2("git", "add -A")
  system2("git", 'commit -m "initial commit"')
  report <- dcf_build(root_dir)
  package <- jsonlite::read_json(paste0(
    source_dir,
    "/standard/datapackage.json"
  ))
  expect_false(is.null(package$resources[[1L]]$versions$hash))
  expect_true(length(report$issues[[source_name]][[1L]]) == 0L)

  #
  # bundle project
  #

  bundle_name <- "bundle"
  bundle_dir <- paste(root_dir, data_dir, bundle_name, sep = "/")
  dcf_add_bundle(
    bundle_name,
    root_dir,
    source_files = paste0(source_name, "/standard/data.csv.xz"),
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
  dcf_process(bundle_name, root_dir)

  expect_true(file.exists(paste0(bundle_dir, "/dist/bundle.json.gz")))

  dcf_update_lock(root_dir)
  expect_true(file.exists(paste0(root_dir, "/renv.lock")))
})
