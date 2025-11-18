mustCreateReferencesForOldData <- function() {
  # Check via SQL if there is at least one non-NULL/non-empty value in enc_partof_calculated_ref
  query <- paste0(
    "SELECT 1 AS has_ref\n",
    "FROM v_encounter_last_version\n",
    "WHERE enc_main_encounter_calculated_ref IS NOT NULL\n",
    "LIMIT 1;\n"
  )
  res <- etlutils::dbGetReadOnlyQuery(query, lock_id = "mustCreateReferencesForOldData()")
  # If no rows returned, references must be created
  return(nrow(res) == 0L)
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

  # if the resources are null that indicates that we must create all references for old data
  if (is.null(resource_tables)) {

    getAllLastViewResources <- function(resource_name, column_names) {
      # get all resources from DB via the v_encounter_last_version view
      resource_name <- tolower(resource_name)
      column_names <- paste0(column_names, collapse = ", ")
      query <- paste0(
        "SELECT DISTINCT ", column_names, " FROM v_", resource_name, "_last_version;\n"
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
      # get all Encounters from DB via the v_encounter_last_version view
      enc_resource_name <- "encounter"
      column_names <- c(
        etlutils::fhirdbGetIDColumn(enc_resource_name),
        etlutils::fhirdbGetColumns(enc_resource_name, c(
          "_type_code",
          "_period_start",
          "_period_end",
          "_partof_ref",
          "_partof_calculated_ref",
          "_main_encounter_calculated_ref"#,
          #"_diagnosis_condition_calculated_ref"
        ))
      )
      return(getAllLastViewResources(enc_resource_name, column_names))
    }

    writeTableWithReferencesToDB <- function(resource_name, resource_table, calculated_col_names, lock_id) {
      id_col_name <- etlutils::fhirdbGetIDColumn(resource_name)

      # Initialize empty data.table
      temp_calculated_items <- data.table::data.table()

      # Preallocate the total number of rows
      total_rows <- nrow(resource_table) * length(calculated_col_names)
      data.table::set(temp_calculated_items, j = "cal_fhir_column", value = rep(NA_character_, total_rows))

      # Populate the remaining columns
      for (calculated_col_index in seq_along(calculated_col_names)) {
        calculated_col_name <- calculated_col_names[calculated_col_index]
        for (row_index in seq_len(nrow(resource_table))) {
          full_row_index <- row_index + ((calculated_col_index - 1) * nrow(resource_table))
          # Fill values for this row
          data.table::set(temp_calculated_items, i = full_row_index, j = "cal_schema", value = "db_log")
          data.table::set(temp_calculated_items, i = full_row_index, j = "cal_resource", value = resource_name)
          data.table::set(temp_calculated_items, i = full_row_index, j = "cal_fhir_column", value = id_col_name)
          data.table::set(temp_calculated_items, i = full_row_index, j = "cal_fhir_id", value = resource_table[row_index, get(id_col_name)])
          data.table::set(temp_calculated_items, i = full_row_index, j = "cal_calculated_column_name", value = calculated_col_name)
          data.table::set(temp_calculated_items, i = full_row_index, j = "cal_calculated_value", value = resource_table[row_index, get(calculated_col_name)])
        }
      }
      etlutils::dbWriteTable(temp_calculated_items, lock_id = lock_id)
      etlutils::dbGetQuery("SELECT db.temp_700_calculated_olddata_items();", lock_id = paste0("Take over calculated references in Database core for ", resource_name))
    }

    all_encounters <- getAllLastViewEncounterResources()
    all_encounters <- createReferencesForEncounters(all_encounters, common_encounter_fhir_identifier_system)

    # iterate over all other resource tables and get them with their last view and create their calculated_ref columns
    for (resource_name in names(start_time_column_names)) {
      start_column_names <- start_time_column_names[[resource_name]]
      resource_table <- getAllLastViewNonEncounterResources(resource_name)
      resource_table <- createReferencesForResource(all_encounters, resource_name, resource_table, start_column_names)
      # write resource with the new references table back to DB
      writeTableWithReferencesToDB(
        resource_name,
        resource_table,
        calculated_col_names = etlutils::fhirdbGetColumns(resource_name, "_encounter_calculated_ref"),
        lock_id = paste("Write recalculated references for old", resource_name, "data")
      )
    }
    # write encounters with the new reference columns to database as last (because
    # the whole process will be repeated, if the encounters are not written correctly)
    writeTableWithReferencesToDB(
      resource_name = "encounter",
      resource_table = all_encounters,
      calculated_col_names = etlutils::fhirdbGetColumns("encounter", c(
        "_partof_calculated_ref",
        "_main_encounter_calculated_ref"
      )),
      lock_id = "Write recalculated references for old encounter data"
    )

    # we must create the references only for new download resources
  } else {
    # 1.) Fill the calculated reference columns for Encounters
    resource_tables$encounter <- createReferencesForEncounters(resource_tables$encounter, common_encounter_fhir_identifier_system)
    # 2.) Fill the ..._encounter_calculated_ref of all Encounter referencing resources using
    #     the enc_partof_calculated_ref or timestamps
    for (resource_name in names(start_time_column_names)) {
      start_column_names <- start_time_column_names[[resource_name]]
      # update the resource table in the list
      resource_tables[[resource_name]] <- createReferencesForResource(resource_tables$encounter, resource_name, resource_tables[[resource_name]], start_column_names)
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
