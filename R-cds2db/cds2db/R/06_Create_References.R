createReferences <- function(resource_tables) {

  start_time_column_names <- list(
    Observation = "obs_effectivedatetime",
    Procedure = c("proc_performedperiod_start", "proc_performeddatetime"),
    MedicationAdministration = c("medadm_effectiveperiod_start", "medadm_effectivedatetime"),
    MedicationStatement = c("medstat_effectiveperiod_start", "medstat_effectivedatetime"),
    MedicationRequest = "medreq_authoredon",
    Condition = "con_recordeddate",
    DiagnosticReport = c("diagrep_effectivedatetime", "diagrep_issued"),
    ServiceRequest = "servreq_authoredon"
  )

  getResourcePrefix <- function(column_name) {
    return(sub("_.*", "", column_name))  # get the resource short prefix
  }

  getEncounterReferenceColumnName <- function(column_name) {
    resource_prefix <- getResourcePrefix(column_name)
    return(paste0(resource_prefix, "_encounter_ref"))
  }

  getEncounterCalculatedReferenceColumnName <- function(column_name) {
    resource_prefix <- getResourcePrefix(column_name)
    return(paste0(resource_prefix, "_encounter_calculated_ref"))
  }

  encounter_type <- c("einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt")
  encounters <- resource_tables$Encounter

  # add the both calculated columns
  encounters[, enc_partof_calculated_ref := NA_character_]
  encounters[, enc_diagnosis_condition_calculated_ref := NA_character_]

  # split Encounters by type code
  encounters_by_type <- list(einrichtungskontakt = encounters[enc_type_code == encounter_type[[1]]],
                             abteilungskontakt = encounters[enc_type_code == encounter_type[[2]]],
                             versorgungsstellenkontakt = encounters[enc_type_code == encounter_type[[3]]],
                             invalid = encounters[!(enc_type_code %in% encounter_type)])

  # cat a warning for every invalid Encounter
  if (nrow(encounters_by_type$invalid)) {
    message <- "The Encounters with the following FHIR ID have no or an invalid type/code attribute and will be ignored:\n"
    message <- paste0(message, paste0("  ", encounters_by_type$invalid$enc_id, collapse = "\n"))
    etlutils::catWarningMessage(message)
  }

  # cat warning message if there are no encounters of at least one type
  for (type_index in 1:3) {
    if (!nrow(encounters_by_type[[type_index]])) {
      message <- paste0("No '", encounter_type[[type_index]], "' Encounters found!")
      etlutils::catWarningMessage(message)
    }
  }

  # fill the enc_partof_calculated_ref column level by level
  for (i in 2:3) { # for each level except the first (einrichtungskontakt)
    encounters_of_lvl <- encounters_by_type[[i]]
    parent_encounters_of_lvl <- encounters_by_type[[i - 1]]
    if (nrow(parent_encounters_of_lvl)) {
      for (enc_index in seq_len(nrow(encounters_of_lvl))) {
        partof_ref <- encounters_of_lvl$enc_partof_ref[enc_index]
        if (!is.na(partof_ref)) { # direct copy
          encounters_of_lvl[enc_index, enc_partof_calculated_ref := partof_ref]
        } else { # get the reference from the timestamps
          patient_ref <- encounters_of_lvl$enc_patient_ref[enc_index]
          candidate_parent_encounters <- parent_encounters_of_lvl[parent_encounters_of_lvl$enc_patient_ref == patient_ref]
          if (nrow(candidate_parent_encounters)) {
            # find the best fitting parent encounter by timestamp
            child_start <- encounters_of_lvl$enc_period_start[enc_index]
            child_end <- encounters_of_lvl$enc_period_end[enc_index]
            # filter candidates that enclose the child encounter
            candidate_parent_encounters <- candidate_parent_encounters[
              enc_period_start <= child_start & (is.na(enc_period_end) | enc_period_end >= child_end)
            ]
            if (nrow(candidate_parent_encounters)) {
              time_diff <- abs(as.numeric(difftime(
                candidate_parent_encounters$enc_period_start,
                child_start,
                units = "secs"
              )))
              best_fit_parent <- candidate_parent_encounters[order(time_diff)][1]
              encounters_of_lvl[enc_index, enc_partof_calculated_ref := best_fit_parent$enc_id]
            }
          }
        }
      }
    }
  }

  # update the encounters table in the list
  encounters <- data.table::rbindlist(encounters_by_type)
  # fill all abteilungskontakt and versorgungstellenkontakt Encounters NA partof refs with "invalid"
  encounters[is.na(enc_partof_calculated_ref) & (enc_type_code %in% encounter_type[2:3]),
             enc_partof_calculated_ref := "invalid"]

  resource_tables$Encounter <- encounters

  # 2.) Fill the ..._encounter_calculated_ref using
  #     the enc_partof_calculated_ref or timestamps
  for (resource_name in names(start_time_column_names)) {
    start_column_names <- start_time_column_names[[resource_name]]
    # all columns should return the same result, so we choose the always existing first value
    ref_col_name <- getEncounterReferenceColumnName(start_column_names[1])
    calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(start_column_names[1])
    resource_table <- resource_tables[[resource_name]]
    if (!is.null(resource_table) && nrow(resource_table) > 0) {
      # add the calculated reference column
      resource_table[[calculated_ref_col_name]] <- NA_character_
      for (row_index in seq_len(nrow(resource_table))) {
        resource_encounter_ref <- resource_table[[ref_col_name]][row_index]
        if (!is.na(resource_encounter_ref)) {
          resource_encounter_id <- etlutils::fhirdataExtractIDs(resource_encounter_ref)
          # the encounter of the calculated reference must be an einrichtungskontakt -> trace back via partOf
          encounter_resource <- encounters[enc_id == resource_encounter_id]
          parent_encounter_id <- NA_character_
          while (nrow(encounter_resource)) {
            # we just take the very first because all should have the same values in the columns we are interested in
            encounter_resource <- encounter_resource[1]
            partof_ref <- encounter_resource$enc_partof_calculated_ref
            if (is.na(partof_ref)) {
              parent_encounter_id <- encounter_resource$enc_id
              break
            }
            parent_encounter_id <- etlutils::fhirdataExtractIDs(partof_ref)
            encounter_resource <- encounters[enc_id == parent_encounter_id]
          }
          if (!is.na(parent_encounter_id)) {
            encounter_ref <- etlutils::fhirdataGetEncounterReference(parent_encounter_id)
            resource_table[[calculated_ref_col_name]][row_index] <- encounter_ref
          }
        }
        # get the reference from the timestamps
        if (is.na(resource_table[[calculated_ref_col_name]][row_index])) {
          patient_ref_col_name <- paste0(getResourcePrefix(start_column_names[1]), "_patient_ref")
          patient_ref <- resource_table[[patient_ref_col_name]][row_index]
          candidate_encounters <- encounters[enc_patient_ref == patient_ref]
          if (nrow(candidate_encounters)) {
            # find the best fitting encounter by timestamp
            for (start_column_name in start_column_names) {
              resource_start_time <- resource_table[[start_column_name]][row_index]
              if (!is.na(resource_start_time)) {
                # filter candidates that enclose the resource timestamp
                candidate_encounters_filtered <- candidate_encounters[
                  enc_period_start <= resource_start_time & (is.na(enc_period_end) | enc_period_end >= resource_start_time)
                ]
                if (nrow(candidate_encounters_filtered)) {
                  # If multiple candidates remain, take the one with the closest start time (no side-effect column)
                  time_diff <- abs(as.numeric(difftime(
                    candidate_encounters_filtered$enc_period_start,
                    resource_start_time,
                    units = "secs"
                  )))
                  best_fit_encounter <- candidate_encounters_filtered[order(time_diff)][1]
                  # Assign by reference with dynamic column name
                  resource_table[row_index, (calculated_ref_col_name) := best_fit_encounter$enc_id]
                  break  # Exit the for loop over start_column_names
                }
              }
            }
          }
        }
        # if the reference is still NA -> mark it as invalid
        if (is.na(resource_table[[calculated_ref_col_name]][row_index])) {
          resource_table[row_index, (calculated_ref_col_name) := "invalid"]
        }
      }
      # update the resource table in the list
      resource_tables[[resource_name]] <- resource_table
    }

    # 3.) Fill the diagnosis ref in Encounters from Conditions
    # TODO
    # Vorgehen: Man muss für jede Diagnose einzeln prüfen, ob sie bereits als Referenz im Encounter vorkommt.
    # Jeder Encounter kann beliebig viele Zeilen besitzen (für jeden Listenwert eine).
    # Wenn der Encounter gar keine Diagnose hatte, dann sind bei allen seinen Zeilen in der Encounter-Tabelle die Werte leer.
    # Man muss immer alle Zeilen duplizieren, die durch andere Listenwerte als Diagnosenlisten entstanden sind und diese
    # mit der neuen Referenz auffüllen. (bzw. genausoviele Zeilen neu erzeugen, wie andere Einzel-Diagnosenreferenzen gleichzeitig).
    # Man kann auch alle Diagnosenspalten löschen und dann auf dem table unique ausführen. So viele Zeilen, wie dann
    # übrig bleiben, muss man pro neuer Diagnosenreferenz erzeugen.
    #
  }
  return(resource_tables)
}
