test_that("init works", {
  dir <- paste0(tempdir(TRUE), "/test_data")
  dir.create(dir)
  on.exit(unlink(dir, TRUE, TRUE))
  path <- paste0(dir, "/mtcars.csv")
  write.csv(
    cbind(mtcars, group = sample(c("a", "b"), nrow(mtcars), TRUE)),
    path,
    row.names = FALSE
  )
  expect_equal(
    dcf_datapackage_init("mtcars", filename = path, write = FALSE)$resources,
    dcf_datapackage_add(path, write = FALSE)
  )
})

dir <- tempdir(TRUE)
on.exit(unlink(dir, TRUE, TRUE))
write.csv(
  cbind(mtcars, group = sample(c("a", "b"), nrow(mtcars), TRUE)),
  paste0(dir, "/mtcars.csv"),
  row.names = FALSE
)
dcf_datapackage_init("mtcars", "Motor Trend Car Road Tests", dir, quiet = TRUE)

test_that("adds to an existing package", {
  metadata <- dcf_datapackage_add("mtcars.csv", dir = dir)
  read <- jsonlite::read_json(paste0(dir, "/datapackage.json"))$resources
  read[[1]]$schema$fields <- lapply(read[[1]]$schema$fields, function(f) {
    f$time_range <- as.numeric(f$time_range)
    f
  })
  metadata$resources[[1]]$time <- Filter(length, list(a = NULL))
  metadata$resources[[1]]$versions <- Filter(length, list(a = NULL))
  expect_equal(metadata$resources, read)
})

test_that("equations are replaced", {
  metadata <- dcf_datapackage_add(
    "mtcars.csv",
    list(
      variables = list(
        e1 = list(description = " $a_{i} = b^\\frac{c}{d}$ "),
        e2 = list(description = "$a_{i} = b^\\frac{c}{d}$"),
        e3 = list(description = "\\[a_{i} = b^\\frac{c}{d}\\]"),
        e4 = list(description = "\\(a_{i} = b^\\frac{c}{d}\\)"),
        e5 = list(
          description = "\\begin{math}a_{i} = b^\\frac{c}{d}\\end{math}"
        ),
        t1 = list(description = "between $100 and $200")
      )
    ),
    dir = dir
  )
  expect_true(all(grepl(
    "<math",
    vapply(metadata$measure_info[1:5], "[[", "", "description"),
    fixed = TRUE
  )))
  expect_true(
    !grepl("<math", metadata$measure_info$t1$description, fixed = TRUE)
  )
})
