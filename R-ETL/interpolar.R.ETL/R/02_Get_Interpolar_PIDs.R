#' Extracts the Interploar relevant patient IDs from download Encounter resources.
#'
#' @return the Interploar relevant patient IDs
#'
#' @export
getInterpolarPatientIDs <- function() {

  interpolar.R.utils::run_in(toupper('get_encounters'), {
    PERIOD_START <<- "2019-01-02"
    PERIOD_END <<- "2019-06-02"
    encounters <- interpolar.R.utils::get_encounters()
  })

  # #build FHIR-Server-Requests
  # request <- fhircrackr::fhir_url(url = FHIR_SERVER_ENDPOINT, resource = "Encounter")
  # #download and crack bundles
  # bundles <- fhircrackr::fhir_search(request, max_bundles = 5)
  # table_enc <- fhircrackr::fhir_crack(bundles = bundles, design = TABLE_DESCRIPTION$Encounter, verbose = 10)

}
