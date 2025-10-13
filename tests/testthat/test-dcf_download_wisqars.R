skip_if_not(grepl("R_LIBS", getwd(), fixed = TRUE), "not downloading data")

test_that("download works", {
  file <- tempfile()
  params <- dcf_download_wisqars(file)
  expect_true(file.exists(file))
  data <- vroom::vroom(file)
  expect_true(nrow(data) > 0)

  file <- tempfile()
  params <- dcf_download_wisqars(file, fatal_outcome = FALSE)
  data <- vroom::vroom(file)
  expect_true(nrow(data) > 0)
})
