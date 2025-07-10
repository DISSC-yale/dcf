# check and rebuild package
spelling::spell_check_package()
devtools::document()
pkgdown::build_site(lazy = TRUE)

devtools::check()
covr::report(covr::package_coverage(quiet = FALSE), "docs/coverage.html")

# update sysdata.rda
population <- dcf::dcf_load_census(2021, "resources")
epic_id_maps <- list(
  regions = structure(population$GEOID, names = population$region_name),
  months = structure(
    formatC(seq_len(12), width = 2L, flag = "0"),
    names = month.abb
  )
)
save(epic_id_maps, file = "r/sysdata.rda", compress = "xz")
