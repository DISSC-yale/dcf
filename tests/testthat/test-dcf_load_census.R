skip_if_not(
  grepl("R_LIBS", getwd(), fixed = TRUE),
  "not downloading census data"
)

test_that("download works", {
  root_dir <- paste0(tempdir(), "/census")
  data <- dcf_load_census(out_dir = root_dir, age_groups = FALSE)
  expect_true("Under 5 years" %in% colnames(data))
  expect_true(all(c("01", "01001", "hhs_1") %in% data$GEOID))
  expect_message(data <- dcf_load_census(out_dir = root_dir), "existing")
  expect_true("<10 Years" %in% colnames(data))
})
