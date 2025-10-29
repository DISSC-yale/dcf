skip_if_not(grepl("R_LIBS", getwd(), fixed = TRUE), "not downloading data")


test_that("download and standardization works", {
  codebook <- dcf_download_cmsmmd(codebook_only = TRUE)
  expect_true(nrow(codebook) != 0)

  file <- tempfile(fileext = ".parquet")
  res <- dcf_download_cmsmmd(
    "discharge",
    year = c(2012, 2022),
    sex = 1,
    race = 1,
    age = 1,
    row_limit = 10,
    out_file = file
  )

  standard <- dcf_standardize_cmsmmd(res$data)
  expect_true(!anyNA(standard))
  expect_true(standard$sexcat[[1]] == "Male")

  expect_message(
    dcf_download_cmsmmd(
      "discharge",
      year = c(2012, 2022),
      sex = 1,
      race = 1,
      age = 1,
      row_limit = 10,
      out_file = file,
      state = res$codebook_state
    ),
    "not changed"
  )
})
