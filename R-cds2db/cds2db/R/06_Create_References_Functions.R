ENCOUNTER_TYPES <- c("einrichtungskontakt", "abteilungskontakt", "versorgungsstellenkontakt")

getEncounterReferenceColumnName <- function(resource_name) {
  return(etlutils::fhirdbGetColumns(resource_name, "_encounter_ref"))
}

getEncounterCalculatedReferenceColumnName <- function(resource_name) {
  return(etlutils::fhirdbGetColumns(resource_name, "_encounter_calculated_ref"))
}

getEncounterColNamesForReferenceCalculation <- function() {
  enc_resource_name <- "encounter"
  enc_col_names_for_ref_calculation <- c(
    etlutils::fhirdbGetIDColumn(enc_resource_name),
    type_code_col_name = etlutils::fhirdbGetColumns(enc_resource_name, "_type_code"), # we need this column only with a name as reference for the where clause
    etlutils::fhirdbGetColumns(enc_resource_name, c(
      "_patient_ref",
      "_period_start",
      "_period_end",
      "_identifier_system",
      "_identifier_value",
      "_class_code",
      "_partof_ref",
      "_partof_calculated_ref",
      "_main_encounter_calculated_ref"#,
      #"_diagnosis_condition_ref",
      #"_diagnosis_condition_calculated_ref"
    ))
  )
  return(enc_col_names_for_ref_calculation)
}

createReferencesForEncounters <- function(encounters, common_encounter_fhir_identifier_system) {

  #
  # Find the best fitting parent encounter by timestamp and prefer inpatient encounters
  #
  findParentEncounter <- function(child_row, candidate_parent_encounters) {

    child_start <- child_row$enc_period_start
    child_end <- child_row$enc_period_end
    # filter candidates that enclose the child encounter
    # Keep candidates that start no later than the child start.
    # Compare end times only if BOTH ends are present; otherwise ignore end.
    candidate_parent_encounters <- candidate_parent_encounters[
      enc_period_start <= child_start &
        (is.na(child_end) | is.na(enc_period_end) | enc_period_end >= child_end)
    ]
    if (nrow(candidate_parent_encounters) > 1) {

      getParentCandidates <- function(candidate_parent_encounters, enc_class) {
        new_candidate_parent_encounters <- candidate_parent_encounters[enc_class_code == enc_class]
        if (nrow(new_candidate_parent_encounters) >= 1) {
          return(new_candidate_parent_encounters)
        }
        return(NULL)
      }
      new_candidate_parent_encounters <- getParentCandidates(candidate_parent_encounters, "IMP")
      if (is.null(new_candidate_parent_encounters)) {
        new_candidate_parent_encounters <- getParentCandidates(candidate_parent_encounters, "SS")
      }
      if (is.null(new_candidate_parent_encounters)) {
        new_candidate_parent_encounters <- getParentCandidates(candidate_parent_encounters, "AMB")
      }
      if(!is.null(new_candidate_parent_encounters)) {
        candidate_parent_encounters <- new_candidate_parent_encounters
      }
    }

    if (nrow(candidate_parent_encounters) > 1) {
      time_diff <- abs(as.numeric(difftime(
        candidate_parent_encounters$enc_period_start,
        child_start,
        units = "secs"
      )))
      idx <- which.min(time_diff)
      best_fit_parent <- candidate_parent_encounters[idx]
    } else if (nrow(candidate_parent_encounters) == 1) {
      best_fit_parent <- candidate_parent_encounters
    } else {
      best_fit_parent <- NULL
    }
    return(best_fit_parent)
  }

  # add the both calculated columns
  if (!("enc_partof_calculated_ref" %in% names(encounters))) {
    encounters[, enc_partof_calculated_ref := NA_character_]
    encounters[, enc_main_encounter_calculated_ref := NA_character_]
    #encounters[, enc_diagnosis_condition_calculated_ref := NA_character_] # currently not used
  }

  # split Encounters by type code
  encounters_by_type <- list(einrichtungskontakt = encounters[enc_type_code == ENCOUNTER_TYPES[[1]]],
                             abteilungskontakt = encounters[enc_type_code == ENCOUNTER_TYPES[[2]]],
                             versorgungsstellenkontakt = encounters[enc_type_code == ENCOUNTER_TYPES[[3]]])

  # cat warning message if there are no encounters of at least one type
  for (type_index in 1:3) {
    if (!nrow(encounters_by_type[[type_index]])) {
      msg <- paste0("No '", ENCOUNTER_TYPES[[type_index]], "' Encounters found!")
      etlutils::catWarningMessage(msg)
    }
  }

  if (!any(encounters[, is.na(enc_main_encounter_calculated_ref)])) {
    return(encounters)
  }

  etlutils::runLevel2("Fill the enc_partof_calculated_ref column level by level (direct copy)", {

    etlutils::runLevel2("... from existing part_of references", {
      for (i in 2:3) { # for each level except the first (einrichtungskontakt)
        encounters_of_lvl <- encounters_by_type[[i]]
        parent_encounters_of_lvl <- encounters_by_type[[i - 1]]
        if (nrow(parent_encounters_of_lvl)) {
          for (enc_index in seq_len(nrow(encounters_of_lvl))) {
            partof_ref <- encounters_of_lvl$enc_partof_ref[enc_index]
            if (!is.na(partof_ref)) { # direct copy
              encounters_of_lvl[enc_index, enc_partof_calculated_ref := partof_ref]
            }
            # print all 10000 rows progress
            if (enc_index %% 10000 == 0) {
              cat(paste0("Processed ", enc_index, " of ", nrow(encounters_of_lvl), " encounters of type '", ENCOUNTER_TYPES[[i]], "'\n"))
            }
          }
        }
        encounters_by_type[[i]] <- encounters_of_lvl
      }
    })

    etlutils::runLevel2("... from common_encounter_fhir_identifier_system", {
      if (etlutils::isSimpleNotEmptyString(common_encounter_fhir_identifier_system)) {
        for (enc_lvl in 2:3) { # for each level except the first (einrichtungskontakt)
          encounters_of_lvl <- encounters_by_type[[enc_lvl]]
          parent_encounters_of_lvl <- encounters_by_type[[enc_lvl - 1]]
          if (nrow(parent_encounters_of_lvl)) {
            for (enc_index in seq_len(nrow(encounters_of_lvl))) {
              if (is.na(encounters_of_lvl$enc_partof_calculated_ref[enc_index])) {
                identifier_system <- encounters_of_lvl$enc_identifier_system[enc_index]
                if (identifier_system %in% common_encounter_fhir_identifier_system) {
                  patient_ref <- encounters_of_lvl$enc_patient_ref[enc_index]
                  identifier_value <- encounters_of_lvl$enc_identifier_value[enc_index]
                  parent_candidate_ids <- parent_encounters_of_lvl[enc_patient_ref %in% patient_ref & enc_identifier_value %in% identifier_value, enc_id]
                  parent_candidate_id <- unique(parent_candidate_ids)
                  if (length(parent_candidate_id) == 1) {
                    parent_encounter_ref <- etlutils::fhirdataGetEncounterReference(parent_candidate_id)
                    encounters_of_lvl[enc_index, enc_partof_calculated_ref := parent_encounter_ref]
                  }
                }
              }
              # print all 10000 rows progress
              if (enc_index %% 10000 == 0) {
                cat(paste0("Processed ", enc_index, " of ", nrow(encounters_of_lvl), " encounters of type '", ENCOUNTER_TYPES[[enc_lvl]], "'\n"))
              }
            }
          }
          encounters_by_type[[enc_lvl]] <- encounters_of_lvl
        }
      }
    })

    etlutils::runLevel2("... from timestamps", {
      for (i in 2:3) { # for each level except the first (einrichtungskontakt)
        encounters_of_lvl <- encounters_by_type[[i]]
        parent_encounters_of_lvl <- encounters_by_type[[i - 1]]
        if (nrow(parent_encounters_of_lvl)) {
          for (enc_index in seq_len(nrow(encounters_of_lvl))) {
            if (is.na(encounters_of_lvl$enc_partof_calculated_ref[enc_index])) {
              patient_ref <- encounters_of_lvl$enc_patient_ref[enc_index]
              candidate_parent_encounters <- parent_encounters_of_lvl[enc_patient_ref == patient_ref]
              if (nrow(candidate_parent_encounters)) {

                parent_encounter <- findParentEncounter(
                  child_row = encounters_of_lvl[enc_index],
                  candidate_parent_encounters = candidate_parent_encounters
                )
                if (!is.null(parent_encounter)) {
                  encounters_of_lvl[enc_index, enc_partof_calculated_ref := paste0("Encounter/", parent_encounter$enc_id)]
                }
              }
            }
            # print all 10000 rows progress
            if (enc_index %% 10000 == 0) {
              cat(paste0("Processed ", enc_index, " of ", nrow(encounters_of_lvl), " encounters of type '", ENCOUNTER_TYPES[[i]], "'\n"))
            }
          }
        }
        encounters_by_type[[i]] <- encounters_of_lvl
      }
    })
  })

  # update the encounters table in the list
  encounters <- data.table::rbindlist(encounters_by_type)
  # fill all abteilungskontakt and versorgungstellenkontakt Encounters NA partof refs with "invalid"
  encounters[is.na(enc_partof_calculated_ref) & (enc_type_code %in% ENCOUNTER_TYPES[2:3]),
             enc_partof_calculated_ref := "invalid"]

  # Start: create enc_main_encounter_calculated_ref

  # Unique enc_ids (FHIR-cracked table can have duplicates per enc_id)
  ids <- unique(encounters$enc_id)
  # Memoization to avoid repeated walks
  resolve_cache <- new.env(parent = emptyenv())

  # Resolve top-most encounter (max depth = 3), return "Encounter/<id>" or "invalid"
  resolveMainRef <- function(id) {
    # Return cached if present
    if (exists(id, envir = resolve_cache, inherits = FALSE)) {
      return(get(id, envir = resolve_cache, inherits = FALSE))
    }
    walk_id <- id
    main_id <- NA_character_

    for (hop in 1:3) {
      current_row <- encounters[enc_id == walk_id]
      if (nrow(current_row) == 0L) {  # unknown id
        main_id <- NA_character_
        break
      }
      current_row <- current_row[1]  # take any row for this enc_id
      partof_ref <- current_row$enc_partof_calculated_ref
      # Reached top-level (no parent)
      if (is.na(partof_ref)) {
        main_id <- walk_id
        break
      }
      # Go to parent; abort on "invalid" or empty
      parent_id <- etlutils::fhirdataExtractIDs(partof_ref)
      if (identical(parent_id, "invalid") || length(parent_id) == 0L || is.na(parent_id)) {
        main_id <- NA_character_
        break
      }
      walk_id <- parent_id
    }
    main_ref <- if (is.na(main_id)) "invalid" else etlutils::fhirdataGetEncounterReference(main_id)
    assign(id, main_ref, envir = resolve_cache)
    return(main_ref)
  }

  # Build mapping enc_id -> main_ref and join back
  main_map <- data.table::data.table(
    enc_id = ids,
    enc_main_encounter_calculated_ref = vapply(ids, resolveMainRef, FUN.VALUE = character(1))
  )
  encounters[
    main_map,
    on = .(enc_id),
    enc_main_encounter_calculated_ref := i.enc_main_encounter_calculated_ref
  ]

  # Determine missing enc_main_encounter_calculated_ref via temporal overlap with einrichtungskontakt
  # encounters for the same patients, if hierarchy information missing
  assignMissingMainEncounterRefs <- function(encounters, child_type, enc_level_1) {
    # all Encounters of type with invalid main_ref
    enc_children <- encounters[
      enc_main_encounter_calculated_ref == "invalid" &
        enc_type_code == child_type
    ]

    if (nrow(enc_children)) {
      for (enc_index in seq_len(nrow(enc_children))) {
        child_row <- enc_children[enc_index]
        parent_encounter <- findParentEncounter(
          child_row = child_row,
          candidate_parent_encounters =
            enc_level_1[enc_patient_ref == child_row$enc_patient_ref]
        )
        if (!is.null(parent_encounter)) {
          encounters[
            enc_id == child_row$enc_id,
            enc_main_encounter_calculated_ref :=
              etlutils::fhirdataGetEncounterReference(parent_encounter$enc_id)
          ]
        }
      }
    }
    return(encounters)
  }

  # all Einrichtungskontakte (type 1)
  enc_level_1 <- encounters[
    enc_type_code == ENCOUNTER_TYPES[1],
    .(enc_id, enc_patient_ref, enc_period_start, enc_period_end, enc_class_code)
  ]

  # add missing main encounter refs for abteilungskontakt and versorgungsstellenkontakt Encounters based on temporal overlap
  for (type in ENCOUNTER_TYPES[c(2, 3)]) {
    assignMissingMainEncounterRefs(encounters, type, enc_level_1)
  }

  # End: create enc_main_encounter_calculated_ref

  return(encounters)
}

createReferencesForResource <- function(encounters, resource_name, resource_table, start_column_names) {
  etlutils::runLevel2Line(paste0("Create Encounter References for ", resource_name), {

    calculated_ref_col_name <- getEncounterCalculatedReferenceColumnName(resource_name)
    # Once the data has been retrieved from the database, we only need to calculate the cal_ref
    # columns for the resources that have never contained a value, so all others can be removed.
    if (calculated_ref_col_name %in% names(resource_table)) {
      resource_table <- resource_table[is.na(get(calculated_ref_col_name))]
    }
    if (!is.null(resource_table) && nrow(resource_table) > 0) {
      ref_col_name <- getEncounterReferenceColumnName(resource_name)
      # add the calculated reference column if not exists
      # If the data comes from the DB, then this column already exists and may contain values that
      # must not be overwritten. If the data comes from the FHIR server, then the column does not
      # yet exist and must be initialized.
      if (!(calculated_ref_col_name %in% names(resource_table))) {
        resource_table[, (calculated_ref_col_name) := NA_character_]
      }
      # If there are no NAs in the calculated reference column, we are done
      if (!any(resource_table[, is.na(get(calculated_ref_col_name))])) {
        return(resource_table)
      }

      # Check if the current resource type is present in the temp_calculated_items table. If so, we
      # can skip the calculation, because it was already done before for this resource.
      query <- paste0("SELECT 1 FROM v_temp_calculated_items WHERE cal_resource = '", resource_name, "' LIMIT 1;")
      resource_in_temp <- etlutils::dbGetReadOnlyQuery(query, lock_id = "createReferencesForResource()")
      if (nrow(resource_in_temp)) {
        return(resource_table)
      }

      for (row_index in seq_len(nrow(resource_table))) {
        resource_encounter_ref <- resource_table[row_index, get(ref_col_name)]
        # first try to get the reference from the existing encounter reference column (if it exists)
        if (!is.na(resource_encounter_ref)) {
          resource_encounter_id <- etlutils::fhirdataExtractIDs(resource_encounter_ref)
          encounter_resource <- encounters[enc_id == resource_encounter_id]
          if (nrow(encounter_resource)) {
            encounter_row <- encounter_resource[
              !is.na(enc_main_encounter_calculated_ref) &
                trimws(enc_main_encounter_calculated_ref) != "invalid"
            ][seq_len(min(.N, 1))]

            if (nrow(encounter_row)) {
              encounter_ref <- encounter_row$enc_main_encounter_calculated_ref
              resource_table <- resource_table[row_index, (calculated_ref_col_name) := encounter_ref]
            }
          }
        }

        # the encounter of the calculated reference must be an einrichtungskontakt -> trace back via partOf
        if (is.na(resource_table[row_index, get(calculated_ref_col_name)])) {
          resource_encounter_ref <- resource_table[row_index, get(ref_col_name)]
          # first try to get the reference from the existing encounter reference column (if it exists)
          if (!is.na(resource_encounter_ref)) {
            resource_encounter_id <- etlutils::fhirdataExtractIDs(resource_encounter_ref)
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
              if (identical(parent_encounter_id, "invalid")) {
                parent_encounter_id <- NA_character_
                break
              }
              encounter_resource <- encounters[enc_id == parent_encounter_id]
            }
            if (!is.na(parent_encounter_id)) {
              encounter_ref <- etlutils::fhirdataGetEncounterReference(parent_encounter_id)
              resource_table[row_index, (calculated_ref_col_name) := encounter_ref]
            }
          }
        }

        # get the reference from the timestamps
        if (is.na(resource_table[row_index, get(calculated_ref_col_name)])) {
          patient_ref_col_name <- etlutils::fhirdbGetColumns(resource_name, "_patient_ref")
          patient_ref <- resource_table[row_index, get(patient_ref_col_name)]
          candidate_encounters <- encounters[enc_patient_ref == patient_ref & enc_type_code == ENCOUNTER_TYPES[[1]]]
          if (nrow(candidate_encounters)) {
            # find the best fitting encounter by timestamp
            for (start_column_name in start_column_names) {
              resource_start_time <- resource_table[row_index, get(start_column_name)]
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
                  idx <- which.min(time_diff)
                  best_fit_encounter <- candidate_encounters_filtered[idx]
                  resource_table[row_index, (calculated_ref_col_name) := paste0("Encounter/", best_fit_encounter$enc_id)]
                  break  # Exit the for loop over start_column_names
                }
              }
            }
          }
        }
        # if the reference is still NA -> mark it as invalid
        if (is.na(resource_table[row_index, get(calculated_ref_col_name)])) {
          resource_table[row_index, (calculated_ref_col_name) := "invalid"]
        }
      }
    }
  })
  return(resource_table)
}

#
# Write calculated reference columns back to the full encounter table
#
joinCalculatedRefColumsToEncounter <- function(fullEncTable, encTableWithCalculatedRefs) {
  # get calculated ref columns by grep("_calculated_ref", ...)
  calculated_col_names <- grep("_calculated_ref$", names(encTableWithCalculatedRefs), value = TRUE)
  enc_id_col_name <- etlutils::fhirdbGetIDColumn("encounter")

  fullEncTable[
    encTableWithCalculatedRefs,
    on = enc_id_col_name,
    (calculated_col_names) := mget(paste0("i.", calculated_col_names))
  ]

  return(fullEncTable)
}
