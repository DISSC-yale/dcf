test_that("reading works", {
  raw_dir <- paste0(tempdir(), "/raw")
  stage_dir <- paste0(raw_dir, "/staging")
  dir.create(stage_dir, FALSE, TRUE)

  path <- paste0(stage_dir, "/RSV.csv")
  raw_lines <- c(
    "metadata field,metadata value,,,,",
    ",,,,,",
    ",,,,Measures,Value Name",
    "county,Year,week,Age,RSV,",
    '"SALEM, VA",2020,Jun 6,6 years or more,m1,1',
    '"SALEM, VA",,,Total: all,m2,2',
    '"SALEM, VA",2021,Jun 6,65 years or more,m1,3',
    '"SALEM, VA",,,No value,m2,4'
  )
  writeLines(raw_lines, path)
  writeLines(raw_lines, paste0(stage_dir, "/RSV2.csv"))

  read <- dcf_process_epic_staging(stage_dir, raw_dir)
  expect_identical(read$metadata$rsv[[1L]]$`metadata field`, "metadata value")
  expect_identical(
    as.character(unlist(read$data$rsv)),
    c(
      rep("SALEM, VA", 4L),
      "2020",
      "2020",
      "2021",
      "2021",
      rep("Jun 6", 4L),
      "6+ Years",
      "Total",
      "65+ Years",
      NA_character_,
      "m1",
      "m2",
      "m1",
      "m2",
      1L:4L
    )
  )

  standard <- dcf_standardize_epic(read$data$rsv)
  expect_identical(
    colnames(standard),
    c("geography", "time", "age", "rsv", "value_name")
  )
  expect_identical(
    as.character(standard[1L, ]),
    c("51775", "2020-06-06", "6+ Years", "m1", "1")
  )
})

test_that("reading ED Injuries works", {
  file <- tempfile()
  writeLines(
    c(
      'Session Title,"Opioid Overdoses in ED, State Month Age",,,,',
      ",,,,,",
      ',,,ED Diagnoses,"ICD-10 OPIOID OVERDOSE, Initial Encounter",None of the above',
      "Year,Month,State of Residence (U.S.),Age at Time of Visit,,",
      ",,,≥ 15 and < 25 Years,28,34805",
      ",,,≥ 25 and < 45 Years,63,73973",
      ",,,≥ 45 and < 65 Years,27,65709",
      ",,,65 Years or more,17,63019"
    ),
    file
  )
  parsed <- dcf_read_epic(file)
  expect_true(parsed$metadata$standard_name == "ed_opioid")
})
