skip_if_not(grepl("R_LIBS", getwd(), fixed = TRUE), "not downloading data")

test_that("download works", {
  root_dir <- paste0(tempdir(), "/cdc_data")
  id <- "ijqb-a7ye"
  dcf_download_cdc(id, root_dir)
  expect_true(all(file.exists(paste0(
    root_dir,
    "/",
    id,
    c(".json", ".csv.xz")
  ))))
})
