#' Prepare known INTERPOLAR station assignments for cohort description
#'
#' Loads distinct station, patient and Encounter assignments from `v_pids_per_ward`
#' in the database selected by the shared manual-project workflow. These assignments
#' are linked to the latest Encounter data by patient and Encounter ID. All related
#' case contacts are retained separately for subsequent analysis.
#'
#' @return Invisibly, a list with `known_ip_contacts` (station assignments with
#'   Encounter details and an `encounter_found` flag) and `encounters` (all loaded
#'   case contacts). Unmatched assignments remain in `known_ip_contacts`.
#'
#' @export
prepareCohortDescription <- function() {
  pids_per_ward <- etlutils::getPidsPerWardData(
    lock_id = "Cohort Description: load known station assignments",
    table_name = "v_pids_per_ward",
    column_names = c("input_datetime", "pids_per_ward_id")
  )
  available_columns <- etlutils::dbGetTableColumnTypes("v_encounter_last_version", readonly = TRUE)$column_name
  encounters <- etlutils::fhirdataGetAllEncounters(
    encounter_ids = unique(pids_per_ward$encounter_id),
    lock_id_extension = "Cohort Description",
    column_names = c(
      "enc_id", "enc_patient_ref", "enc_main_encounter_calculated_ref",
      "enc_period_start", "enc_period_end", "enc_type_system", "enc_type_code", "enc_class_code",
      intersect("enc_age_at_admission", available_columns)
    )
  )
  known_ip_contacts <- linkCohortStationContacts(pids_per_ward, encounters)
  message(
    "Cohort Description initialized: ", nrow(pids_per_ward),
    " distinct station/patient/Encounter assignments loaded and linked to Encounter data."
  )
  invisible(list(known_ip_contacts = known_ip_contacts, encounters = encounters))
}

#' Create complete expanded cohort descriptions for the configured site
#'
#' Uses the standard manual-submodule configuration, shared resource loaders and
#' output directory. All station/phase/FAS files contain aggregate results only.
#' @param source Named database source, regular or broad_consent.
#' @return Invisibly, an aggregate manifest of generated workbooks.
#' @export
createCohortDescription <- function(source = "regular") {
  if (!source %in% c("regular", "broad_consent")) stop("Unknown cohort data source.")
  started <- proc.time()[["elapsed"]]
  directory <- file.path(etlutils::getModuleDirNames(NULL)$global_dir, "reports", "cohort_description", source)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  # Write an initial status so a hard-killed run is never mistaken for a completed one.
  write_metrics <- function(status) {
    data.table::fwrite(data.table::data.table(
      source = source, status = status,
      elapsed_seconds = if (status == "running") NA_real_ else proc.time()[["elapsed"]] - started,
      max_rss_kib = if (status == "running") NA_real_ else etlutils::getProcessPeakMemoryKiB(),
      memory_scope = "R process since start"
    ), file.path(directory, "cohort_run_metrics.csv"), na = "NA")
  }
  write_metrics("running")
  status <- "failed"
  on.exit(write_metrics(status), add = TRUE)
  timezone <- etlutils::GLOBAL_TIMEZONE
  columns <- c("ward_name", "phase_a_start", "phase_b_start", "phase_b_end", "ward_type", "department")
  wards <- data.table::as.data.table(setNames(lapply(columns, function(column)
    unname(etlutils::extractVariablesListValues("PHASES_WARD", column))), columns))
  for (column in c("phase_a_start", "phase_b_start", "phase_b_end")) {
    data.table::set(wards, j = column, value = etlutils::parseTimestamp(wards[[column]], timezone))
  }
  # Validate dates before loading clinical data.
  buildCohortPeriods(wards, source, timezone)
  prepared <- runCohortStep("Link known INTERPOLAR contacts", prepareCohortDescription())
  diagnostic_dir <- file.path(
    etlutils::getModuleDirNames(NULL)$local_dir, "diagnostics", "cohort_description", source
  )
  prepared$known_ip_contacts <- retainLinkedCohortContacts(prepared$known_ip_contacts, diagnostic_dir)
  if (source == "broad_consent") {
    prepared$diagnostic_dir <- diagnostic_dir
    prepared$known_ip_contacts <- retainCohortContactsWithHospitalCase(
      prepared$known_ip_contacts, prepared$encounters, diagnostic_dir
    )
  }
  data <- loadCohortAnalysisData(prepared, timezone)
  manifest <- runCohortStep("Export expanded workbooks", exportCohortDescription(
    data$cases, wards, timezone,
    etlutils::getVarByNameOrDefaultIfMissing("SITE_CODE"), directory,
    source = source
  ))
  data.table::fwrite(
    data$quality[, .(check, count = maskCohortCounts(count))],
    file.path(directory, "cohort_quality.csv")
  )
  if (!file.copy(cohortAssetPath("report_readme.md"), file.path(dirname(directory), "README.md"), overwrite = TRUE)) {
    stop("Could not write the cohort report README.")
  }
  message("Cohort Description completed: ", nrow(manifest), " expanded workbooks in ", directory)
  status <- "completed"
  invisible(manifest)
}
