skip_if_not(grepl("R_LIBS", getwd(), fixed = TRUE), "not downloading data")


test_that("variable listing works", {
  variables <- dcf_variables("dissc-yale/pophive_demo")
  expect_true(nrow(variables) != 0L)
})
