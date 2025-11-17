mustCreateReferencesForOldData <- function() {
  # checke über SQl, ob in der Encounter-Tabelle mindestens ein nicht-NA-Eintrag in der enc_partof_calculated_ref Spalte existiert
}

createReferences <- function(resource_tables, common_encounter_fhir_identifier_system = NULL) {

  start_time_column_names <- list(
    observation = "obs_effectivedatetime",
    procedure = c("proc_performedperiod_start", "proc_performeddatetime"),
    medicationadministration = c("medadm_effectiveperiod_start", "medadm_effectivedatetime"),
    medicationstatement = c("medstat_effectiveperiod_start", "medstat_effectivedatetime"),
    medicationrequest = "medreq_authoredon",
    condition = "con_recordeddate",
    diagnosticreport = c("diagrep_effectivedatetime", "diagrep_issued"),
    servicerequest = "servreq_authoredon"
  )

  encounter_type <- c("einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt")

  # if the resources are null that indicates that we must create all references for old data
  if (is.null(resource_tables)) {

    getAllLastViewResources <- function(resource_name, column_names) {
      # get all resources from DB via the v_encounter_last_version view
      resource_name <- tolower(resource_name)
      column_names <- paste0(column_names, collapse = ", ")
      query <- paste0(
        "SELECT DISTINCT ", column_names, " FROM v_", resource_name, "_last_version;\n",
      )
      etlutils::dbGetReadOnlyQuery(query, lock_id = paste0("getAllLastViewResources(", resource_name, ")"))
    }

    getAllLastViewNonEncounterResources <- function(resource_name) {
      column_names <- c(
        etlutils::fhirdbGetIDColumn(resource_name),
        getEncounterReferenceColumnName(resource_name),
        getEncounterCalculatedReferenceColumnName(resource_name),
        start_time_column_names[[resource_name]]
      )
      return(getAllLastViewResources(resource_name, column_names))
    }

    getAllLastViewEncounterResources <- function() {
      # get all Encounters from DB via the v_encounter_last view
      enc_resource_name <- "encounter"
      column_names <- c(
        etlutils::fhirdbGetIDColumn(enc_resource_name),
        etlutils::fhirdbGetColumns(enc_resource_name, c(
          "_period_start",
          "_period_end",
          "_partof_ref",
          "_partof_calculated_ref",
          "_main_encounter_calculated_ref"#,
          #"_diagnosis_condition_calculated_ref"
        )
      )
      return(getAllLastViewResources(enc_resource_name, column_names))
    }

    writeTableWithReferencesToDB <- function(resource_name, resource_table, calculated_col_names = NULL) {
      id_col_name <- etlutils::fhirdbGetIDColumn(resource_name)

      if (is.null(calculated_col_names)) {
        calculated_col_names <- start_time_col_names[[resource_name]]
      }
      # Initialize empty data.table
      db_table <- data.table::data.table()

      # Preallocate the total number of rows
      total_rows <- nrow(resource_table) * length(calculated_col_names)
      data.table::set(db_table, j = id_column_name, value = rep(NA_character_, total_rows))

      # Populate the remaining columns
      for (calculated_col_index in seq_along(calculated_col_names)) {
        calculated_col_name <- calculated_col_names[calculated_col_index]

        for (row_index in seq_len(nrow(resource_table))) {
          full_row_index <- row_index + ((calculated_col_index - 1) * nrow(resource_table))

          # Fill values for this row
          data.table::set(db_table, i = full_row_index, j = "cal_schema", value = "db_log")
          data.table::set(db_table, i = full_row_index, j = "cal_resource", value = resource_name)
          data.table::set(db_table, i = full_row_index, j = "cal_fhir_column", value = id_col_name)
          data.table::set(db_table, i = full_row_index, j = "cal_fhir_id", value = resource_table[[row_index, id_col_name]])
          data.table::set(db_table, i = full_row_index, j = "cal_calculated_column_name", value = calculated_col_name)
          data.table::set(db_table, i = full_row_index, j = "cal_calculated_value", value = resource_table[[row_index, calculated_col_name]])
        }
      }

      etlutils::dbWriteTable()

    }

    all_encounters <- getAllLastViewEncounterResources()
    all_encounters <- createReferencesForEncounters(all_encounters)

    # iterate over all other resource tables and get them with their last view and create their calculated_ref columns
    for (resource_name in names(start_time_column_names)) {
      start_column_names <- start_time_column_names[[resource_name]]
      resource_table <- getAllLastViewResources(resource_name)
      resource_table <- createReferencesForResource(all_encounters, resource_name, resource_table, start_column_names)
      # write resource with the new references table back to DB
      writeTableWithReferencesToDB(resource_name, resource_table)
    }
    # write encounters with the new reference columns to database as last (because
    # the whole process will be repeated, if the encounters are not written correctly)
    writeTableWithReferencesToDB(
      resource_name = "encounter",
      resource_table = all_encounters,
      calculated_col_names = etlutils::fhirdbGetColumns("encounter", c(
        "_partof_calculated_ref",
        "_main_encounter_calculated_ref"
      ))
    )

  # we must create the references only for new download resources
  } else {
    # 1.) Fill the calculated reference columns for Encounters
    resource_tables$encounter <- createReferencesForEncounters(resource_tables$encounter)
    # 2.) Fill the ..._encounter_calculated_ref of all Encounter referencing resources using
    #     the enc_partof_calculated_ref or timestamps
    for (resource_name in names(start_time_column_names)) {
      start_column_names <- start_time_column_names[[resource_name]]
      # update the resource table in the list
      resource_tables[[resource_name]] <- createReferencesForResource(resource_tables$encounter, resource_name, resource_tables[[resource_name]], start_column_names)
    }
  }
}

  # 3.) Fill the diagnosis ref in Encounters from Conditions (enc_diagnosis_condition_calculated_ref)
  # TODO
  # Vorgehen: Man muss für jede Diagnose einzeln prüfen, ob sie bereits als Referenz im Encounter vorkommt.
  # Jeder Encounter kann beliebig viele Zeilen besitzen (für jeden Listenwert eine).
  # Wenn der Encounter gar keine Diagnose hatte, dann sind bei allen seinen Zeilen in der Encounter-Tabelle die Werte leer.
  # Man muss immer alle Zeilen duplizieren, die durch andere Listenwerte als Diagnosenlisten entstanden sind und diese
  # mit der neuen Referenz auffüllen. (bzw. genausoviele Zeilen neu erzeugen, wie andere Einzel-Diagnosenreferenzen gleichzeitig).
  # Man kann auch alle Diagnosenspalten löschen und dann auf dem table unique ausführen. So viele Zeilen, wie dann
  # übrig bleiben, muss man pro neuer Diagnosenreferenz erzeugen.
  #
  return(resource_tables)
}
