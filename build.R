# check and rebuild package
spelling::spell_check_package()
devtools::document()
pkgdown::build_site(lazy = TRUE)

devtools::check()
covr::report(covr::package_coverage(quiet = FALSE), "docs/coverage.html")

# update sysdata.rda
population <- dcf::dcf_load_census(2021L, "resources")
population <- rbind(
  population,
  rbind(
    c(
      GEOID = "0",
      region_name = "Total",
      colSums(population[, -(1L:2L)])
    ),
    c(
      GEOID = "52",
      region_name = "Virgin Islands",
      Total = 87146L
    )[colnames(population)]
  )
)
epic_id_maps <- list(
  regions = structure(population$GEOID, names = population$region_name),
  months = structure(
    formatC(seq_len(12L), width = 2L, flag = "0"),
    names = month.abb
  )
)
save(epic_id_maps, file = "r/sysdata.rda", compress = "xz")
