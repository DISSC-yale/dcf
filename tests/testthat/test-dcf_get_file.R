skip_if(Sys.which("git") == "", "git is not available")

test_that("lists and extracts", {
  base_dir <- paste0(tempdir(), "/temp_git")
  dir.create(base_dir, showWarnings = FALSE)
  wd <- setwd(base_dir)
  on.exit(setwd(wd))

  # initialize the repo
  system2("git", "init")
  system2("git", 'config user.email "temp@example.com"')
  system2("git", 'config user.name "temp user"')

  # make initial version of data
  path <- "data.csv"
  write.csv(data.frame(value = 1), path, row.names = FALSE)
  system2("git", "add data.csv")
  system2("git", 'commit -m "initial commit"')
  Sys.sleep(1)

  # overwrite with a new version
  write.csv(data.frame(value = 2), path, row.names = FALSE)
  system2("git", "add data.csv")
  system2("git", 'commit -m "update data"')

  versions <- dcf_get_file(path, versions = TRUE)
  expect_identical(versions$message, c("update data", "initial commit"))

  v1 <- read.csv(dcf_get_file(path, "1999"))
  expect_true(v1$value == 1)

  v2 <- read.csv(dcf_get_file(
    path,
    commit_hash = substring(versions$hash[[1]], 1L, 6L)
  ))
  expect_true(v2$value == 2)
})
