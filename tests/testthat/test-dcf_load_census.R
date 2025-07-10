skip_if_not(
  grepl("R_LIBS", getwd(), fixed = TRUE),
  "not downloading census data"
)

test_that("download works", {
  root_dir <- paste0(tempdir(), "/census")
  data <- dcf_load_census(out_dir = root_dir)
  expect_true(all(c("01", "01001", "hhs_1") %in% data$GEOID))
  expect_message(dcf_load_census(out_dir = root_dir), "existing")
})
