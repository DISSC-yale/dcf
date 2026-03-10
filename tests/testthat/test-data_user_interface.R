skip_if_not(grepl("R_LIBS", getwd(), fixed = TRUE), "not downloading data")


test_that("variable listing works", {
  repo <- "dissc-yale/pophive_demo"
  variables <- dcf_variables(repo)
  expect_true(nrow(variables) != 0L)

  select_vars <- c("n_flu", "nrevss")
  data <- dcf_data(select_vars, repo, project_type = "source")
  expect_true(all(select_vars %in% colnames(data$data)))

  data <- variables |>
    dplyr::filter(name %in% select_vars, project_type == "source") |>
    dcf_data(project = repo)
  expect_true(all(select_vars %in% colnames(data$data)))
})
