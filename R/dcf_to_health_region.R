#' Map States to Health Regions
#'
#' Maps state FIPS state numeric codes to Human Health Service regions.
#'
#' @param geoids Character vector of GEOIDs.
#' @param prefix A prefix to add to region IDs.
#' @returns A vector of Health Region names the same length as \code{geoids}.
#' @examples
#' dcf_to_health_region(c("01", "01001", "02", "02001"))
#' @export

dcf_to_health_region <- function(geoids, prefix = "Region ") {
  regions <- c(
    "01" = 4,
    "02" = 10,
    "04" = 9,
    "05" = 6,
    "06" = 9,
    "08" = 8,
    "09" = 1,
    "10" = 3,
    "11" = 3,
    "12" = 4,
    "13" = 4,
    "15" = 9,
    "16" = 10,
    "17" = 5,
    "18" = 5,
    "19" = 7,
    "20" = 7,
    "21" = 4,
    "22" = 6,
    "23" = 1,
    "24" = 3,
    "25" = 1,
    "26" = 5,
    "27" = 5,
    "28" = 4,
    "29" = 7,
    "30" = 8,
    "31" = 7,
    "32" = 9,
    "33" = 1,
    "34" = 2,
    "35" = 6,
    "36" = 2,
    "37" = 4,
    "38" = 8,
    "39" = 5,
    "40" = 6,
    "41" = 10,
    "42" = 3,
    "44" = 1,
    "45" = 4,
    "46" = 8,
    "47" = 4,
    "48" = 6,
    "49" = 8,
    "50" = 1,
    "51" = 3,
    "53" = 10,
    "54" = 3,
    "55" = 5,
    "56" = 8,
    "72" = 2,
    "66" = 6,
    "74" = 2
  )
  regions[] <- paste0(prefix, regions)
  unname(regions[substring(geoids, 1L, 2L)])
}
