test_that("standalone source works", {
  base_dir <- paste0(tempdir(), "/dcf_standalone")
  dcf_add_source("standalone_source", base_dir, open_after = FALSE)
  project_dir <- paste0(base_dir, "/standalone_source")

  project_files <- paste0(
    project_dir,
    "/",
    c("ingest.R", "process.json", "measure_info.json")
  )
  writeLines(
    'write.csv(data.frame(id = c(1, 2), value = c(5, 10)), "standard/data.csv", row.names = FALSE)',
    project_files[[1L]]
  )

  report <- dcf_build(project_dir)

  expect_identical(report$settings$name, "standalone_source")
  expect_identical(
    list(
      source_times = "standalone_source",
      logs = "standalone_source",
      issues = "standalone_source",
      metadata = "standalone_source/standard",
      processes = "standalone_source"
    ),
    lapply(
      report[c("source_times", "logs", "issues", "metadata", "processes")],
      names
    )
  )
})
