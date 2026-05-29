# Recalculate MRPs for a given time range and add new results to the database.
mrpRecalculation <- function(start_date, end_date = NULL) {

  start_date <- etlutils::as.POSIXctWithTimezone(start_date)
  end_date <- if (is.null(end_date)) {
    etlutils::as.POSIXctWithTimezone(Sys.Date())
  } else {
    etlutils::as.POSIXctWithTimezone(end_date)
  }

  # Normalize values that are part of the logical MRP identity so that
  # comparisons are stable across character, NA, and timestamp columns.
  normalizeMRPKeyColumn <- function(value) {
    if (inherits(value, "POSIXct")) {
      value <- format(value, "%Y-%m-%d %H:%M:%S", tz = GLOBAL_TIMEZONE)
    } else {
      value <- as.character(value)
    }
    value[is.na(value)] <- "#NULL#"
    trimws(value)
  }

  # Build one comparable key from the clinically relevant MRP columns.
  addMRPKey <- function(dt, key_cols) {
    dt[, .mrp_recalculation_key := do.call(
      paste,
      c(lapply(.SD, normalizeMRPKeyColumn), sep = "|||")
    ), .SDcols = key_cols]
  }

  # Keep only genuinely new retrospective MRPs. The time-range selection may
  # revisit encounters that already contain retrospective MRP evaluations.
  filterExistingMRPs <- function(mrp_tables) {
    # Recalculation should only add rows for medication analyses that have at
    # least one newly discovered MRP. Matching dp_mrp_calculations rows are
    # reduced afterwards to the surviving retrospective MRP ids.
    ret_table <- mrp_tables$retrolektive_mrpbewertung_fe
    dp_table <- mrp_tables$dp_mrp_calculations

    ret_table <- ret_table[!is.na(ret_id)]
    dp_table <- dp_table[!is.na(ret_id)]

    if (!nrow(ret_table)) {
      return(list(
        retrolektive_mrpbewertung_fe = ret_table,
        dp_mrp_calculations = dp_table[0]
      ))
    }

    key_cols <- c(
      "record_id",
      "ret_meda_id",
      "ret_meda_dat_referenz",
      "ret_kurzbeschr",
      "ret_atc1",
      "ret_ip_klasse_01",
      "ret_ip_klasse_disease",
      "ret_atc2"
    )

    # A recalculation run is allowed to revisit encounters that already have
    # retrospective MRPs. The additive behavior is enforced here by removing
    # only rows that are identical on the domain-specific MRP key.
    meda_ids <- unique(na.omit(ret_table$ret_meda_id))
    existing_ret_table <- data.table::data.table()
    if (length(meda_ids)) {
      query <- paste0(
        "SELECT ", paste(key_cols, collapse = ", "), "\n",
        "FROM v_retrolektive_mrpbewertung_fe\n",
        "WHERE ret_meda_id IN ", etlutils::fhirdbGetQueryList(meda_ids), "\n"
      )
      existing_ret_table <- etlutils::dbGetReadOnlyQuery(
        query,
        lock_id = "MRP_Recalculation_existing_retrolektive_mrpbewertung"
      )
    }

    addMRPKey(ret_table, key_cols)

    if (nrow(existing_ret_table)) {
      addMRPKey(existing_ret_table, key_cols)
      ret_table <- ret_table[!.mrp_recalculation_key %in% existing_ret_table$.mrp_recalculation_key]
    }

    new_ret_ids <- unique(ret_table$ret_id)
    ret_table[, .mrp_recalculation_key := NULL]
    dp_table <- dp_table[ret_id %in% new_ret_ids]

    list(
      retrolektive_mrpbewertung_fe = ret_table,
      dp_mrp_calculations = dp_table
    )
  }

  # REDCap repeat instances are assigned per patient record. After filtering
  # out already existing MRPs, the remaining new rows must be renumbered so
  # they continue the existing repeat-instance sequence without collisions.
  renumberNewMRPs <- function(mrp_tables) {
    ret_table <- mrp_tables$retrolektive_mrpbewertung_fe
    dp_table <- mrp_tables$dp_mrp_calculations

    if (!nrow(ret_table)) {
      return(mrp_tables)
    }

    record_ids <- unique(na.omit(ret_table$record_id))
    existing_repeat_instances <- data.table::data.table()
    if (length(record_ids)) {
      query <- paste0(
        "SELECT record_id, redcap_repeat_instance\n",
        "FROM v_retrolektive_mrpbewertung_fe_last_version\n",
        "WHERE record_id IN ", etlutils::fhirdbGetQueryList(record_ids), "\n"
      )
      existing_repeat_instances <- etlutils::dbGetReadOnlyQuery(
        query,
        lock_id = "MRP_Recalculation_existing_repeat_instances"
      )
    }

    ret_table[, temp_old_ret_id := ret_id]
    ret_table[, temp_old_redcap_repeat_instance := redcap_repeat_instance]

    # Rebuild repeat instances after deduplication so that REDCap receives a
    # contiguous sequence of new repeat rows per patient record.
    repeat_instance_map <- ret_table[
      ,
      {
        existing_group <- existing_repeat_instances[record_id == .BY$record_id]
        # REDCap repeat instances must be unique per record and instrument.
        # New recalculated MRPs therefore continue counting from the highest
        # already exported instance of the same record.
        next_repeat_instance <- if (nrow(existing_group)) {
          max(as.integer(existing_group$redcap_repeat_instance), na.rm = TRUE) + 1L
        } else {
          1L
        }

        current_rows <- .SD[order(redcap_repeat_instance, ret_id)]
        current_rows[, new_redcap_repeat_instance := seq.int(
          from = next_repeat_instance,
          length.out = .N
        )]

        current_rows[, .(
          temp_old_ret_id,
          temp_old_redcap_repeat_instance,
          new_redcap_repeat_instance
        )]
      },
      by = record_id
    ]

    ret_table[
      repeat_instance_map,
      on = .(record_id, temp_old_ret_id, temp_old_redcap_repeat_instance),
      redcap_repeat_instance := i.new_redcap_repeat_instance
    ]

    dp_table[
      repeat_instance_map,
      on = .(ret_id = temp_old_ret_id, ret_redcap_repeat_instance = temp_old_redcap_repeat_instance),
      ret_redcap_repeat_instance := i.new_redcap_repeat_instance
    ]

    ret_table[, c("temp_old_ret_id", "temp_old_redcap_repeat_instance") := NULL]

    list(
      retrolektive_mrpbewertung_fe = ret_table,
      dp_mrp_calculations = dp_table
    )
  }

  etlutils::runLevel2("Calculate MRPs for time range", {
    # calculateMRPs() still returns both existing and newly rediscovered MRPs
    # for the selected encounters. The additive behavior is applied afterwards.
    mrp_tables <- calculateMRPs(start_date, end_date)
    mrp_tables <- filterExistingMRPs(mrp_tables)
    mrp_tables <- renumberNewMRPs(mrp_tables)
  })

  etlutils::runLevel2("Write new MRP results to database", {
    new_mrp_count <- nrow(mrp_tables$retrolektive_mrpbewertung_fe)
    if (new_mrp_count) {
      etlutils::dbWriteTables(
        tables = mrp_tables,
        lock_id = "Write additive MRP recalculation to database",
        stop_if_table_not_empty = FALSE
      )
      cat("Added ", new_mrp_count, " new MRP evaluation(s).\n", sep = "")
    } else {
      # A clean no-op is expected when all recalculated MRPs are already present.
      cat("No new MRP evaluations found for the selected time range.\n")
    }
  })

  etlutils::runLevel2("Export database content to REDCap", {
    requireNamespace("db2frontend")
    db2frontend::startDB2Frontend(validate_config = FALSE)
  })
}
