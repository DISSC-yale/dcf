path <- paste0(tempdir(), "/measure_info.json")

test_that("makes an initial file", {
  initial <- dcf_measure_info(
    path,
    "measure name" = list(
      id = "measure name",
      short_description = "A measure.",
      statement = "This entity has {value} measure units."
    )
  )
  expect_identical(initial, jsonlite::read_json(path))
})

test_that("existing files is added to", {
  addition <- dcf_measure_info(
    path,
    "measure two" = list(
      id = "measure two",
      short_description = "Another measure.",
      statement = "This entity has {value} measure units.",
      citations = "ref1"
    ),
    references = list(ref1 = list(author = list(given = "name")))
  )
  expect_identical(
    names(addition),
    c("measure name", "measure two", "_references")
  )
})

test_that("missing references are flagged", {
  expect_warning(
    dcf_measure_info(
      path,
      "measure three" = list(
        id = "measure three",
        short_description = "Another measure.",
        statement = "This entity has {value} measure units.",
        citations = c("ref2", "ref3")
      ),
      include_empty = FALSE
    ),
    "no matching reference entry"
  )
})

test_that("strict works", {
  expect_warning(
    addition <- dcf_measure_info(
      path,
      "measure three" = list(
        custom_entry = "",
        citations = "ref1"
      ),
      strict = TRUE,
      include_empty = FALSE
    ),
    "unrecognized entry"
  )
  expect_identical(
    names(addition$`measure three`),
    c("citations", "id", "short_description", "statement")
  )
})

test_that("dynamic entries work", {
  rendered <- dcf_measure_info(
    path,
    "measure {category} {variant}" = list(
      id = "measure {category} {variant}",
      short_description = "Another measure ({category}; {variant}).",
      statement = "This entity has {value} {category} {variant}.",
      categories = c("a", "b"),
      variants = list(
        u1 = list(default = "U1", description = "You One"),
        u2 = list(id = "u_two", source = list(name = "source 1"))
      )
    ),
    render = TRUE
  )
  expect_identical(
    names(rendered),
    c(
      "measure name",
      "measure two",
      "measure three",
      "measure a U1",
      "measure b U1",
      "measure a u2",
      "measure b u2",
      "_references"
    )
  )
  expect_identical(rendered[["measure a U1"]]$description, NULL)
  expect_identical(
    rendered[["measure a U1"]]$short_description,
    "Another measure (a; You One)."
  )
  expect_identical(rendered[["measure a u2"]]$id, "measure a u_two")
  expect_identical(rendered[["measure a u2"]]$source, list(name = "source 1"))
})
