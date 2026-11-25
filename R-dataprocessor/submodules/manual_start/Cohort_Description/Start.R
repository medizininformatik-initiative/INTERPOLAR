etlutils::runLevel2("Cohort Description", {
  if (
    !exists("manual_database_source") ||
    !manual_database_source %in% c("regular", "broad_consent")
  ) {
    stop("Configure the named sources regular and broad_consent in database.toml.")
  }
  if (
    !manual_database_partial &&
    !setequal(manual_database_sources, c("regular", "broad_consent"))
  ) {
    stop("A full cohort run requires both regular and broad_consent sources.")
  }
  createCohortDescription(source = manual_database_source)
})
