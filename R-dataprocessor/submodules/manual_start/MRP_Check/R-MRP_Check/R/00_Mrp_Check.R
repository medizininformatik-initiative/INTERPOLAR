mrpCheck <- function(start_date, end_date) {
  anonymizeTimestampsByPatient <- function(
    dt,
    patient_id_col = "FHIR Patient ID",
    text_col = "MRP Beschreibung",
    min_future_days = 365,
    max_future_days = 365 * 10
  ) {
    # Identify rows
    patient_rows <- which(!is.na(dt[[patient_id_col]]))
    na_rows <- which(is.na(dt[[patient_id_col]]))

    # Identify POSIXct columns
    time_cols <- names(dt)[vapply(dt, inherits, logical(1), what = "POSIXct")]

    timestamp_pattern <- "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}"

    # ------------------------------------------------------------------
    # Generate shifts
    # ------------------------------------------------------------------
    if (length(patient_rows) > 0L) {
      shifts <- dt[
        patient_rows,
        .(shift_seconds = sample.int(
          max_future_days * 86400 - min_future_days * 86400 + 1L,
          1L
        ) + min_future_days * 86400),
        by = patient_id_col
      ]
      dt[shifts, shift_seconds := i.shift_seconds, on = patient_id_col]
    }

    if (length(na_rows) > 0L) {
      na_shift_seconds <-
        sample.int(
          max_future_days * 86400 - min_future_days * 86400 + 1L,
          1L
        ) + min_future_days * 86400
    }

    # ------------------------------------------------------------------
    # Shift POSIXct columns (patients only)
    # ------------------------------------------------------------------
    for (col in time_cols) {
      for (i in patient_rows) {
        val <- dt[[col]][i]
        if (is.na(val)) next
        data.table::set(
          dt,
          i = i,
          j = col,
          value = val + dt$shift_seconds[i]
        )
      }
    }

    # ------------------------------------------------------------------
    # Shift timestamps inside text (patients + NA rows)
    # ------------------------------------------------------------------
    for (i in c(patient_rows, na_rows)) {
      txt <- dt[[text_col]][i]
      if (is.na(txt)) next

      matches <- gregexpr(timestamp_pattern, txt, perl = TRUE)[[1]]
      if (length(matches) == 1L && matches[1] == -1L) next

      match_len <- attr(matches, "match.length")

      shift_val <- if (!is.na(dt[[patient_id_col]][i])) {
        dt$shift_seconds[i]
      } else {
        na_shift_seconds
      }

      for (k in rev(seq_along(matches))) {
        old_ts <- substr(
          txt,
          matches[k],
          matches[k] + match_len[k] - 1L
        )

        new_ts <- format(
          as.POSIXct(old_ts, tz = "UTC") + shift_val,
          "%Y-%m-%d %H:%M:%S"
        )

        substr(
          txt,
          matches[k],
          matches[k] + match_len[k] - 1L
        ) <- new_ts
      }

      data.table::set(dt, i = i, j = text_col, value = txt)
    }

    # Cleanup
    if ("shift_seconds" %in% names(dt)) {
      dt[, shift_seconds := NULL]
    }

    invisible(dt)
  }

  etlutils::runLevel2("MRP Calculation", {
    start_date <- etlutils::as.POSIXctWithTimezone(start_date)
    end_date <- etlutils::as.POSIXctWithTimezone(end_date)
    mrp_table_lists_all <- calculateMRPs(start_date, end_date, return_used_resources = "record_ids")
  })

  etlutils::runLevel2("Create local MRP result table", {
    needed_cols <- c("ret_id", "record_id", "ret_kurzbeschr", "ret_meda_dat_referenz")
    etlutils::retainColumns(mrp_table_lists_all$retrolektive_mrpbewertung_fe, needed_cols)
    mrp_table_lists_all$retrolektive_mrpbewertung_fe <- unique(mrp_table_lists_all$retrolektive_mrpbewertung_fe)

    needed_cols <- c("ret_id", "enc_id", "mrp_calculation_type", "meda_id", "ward_name")
    etlutils::retainColumns(mrp_table_lists_all$dp_mrp_calculations, needed_cols)
    mrp_table_lists_all$dp_mrp_calculations <- unique(mrp_table_lists_all$dp_mrp_calculations)

    result <- mrp_table_lists_all$dp_mrp_calculations[mrp_table_lists_all$retrolektive_mrpbewertung_fe, on = "ret_id"]
    result <- unique(result[, ret_id := NULL])

    result[, record_id := as.character(record_id)]
    if (nrow(result)) {
      # merges the pat_id column as first column to the result table
      result <- mrp_table_lists_all$record_ids[result, on = "record_id"]
    } else {
      # if the result is empty -> ensure all needed columns are present in the correct order
      result[, pat_id := character()]
      data.table::setcolorder(result, c("pat_id", setdiff(names(result), "pat_id")))
    }

    main_encounters <- mrp_table_lists_all$main_encounters

    # Remove duplicates in main_encounters
    main_encounters_unique <- main_encounters[, .SD[1], by = enc_id]

    # Merge only enc_period_start and enc_period_end into result
    result <- merge(
      result,
      main_encounters_unique[, .(enc_id, enc_period_start, enc_period_end)],
      by = "enc_id",
      all.x = TRUE
    )

    old_col_names <- c(
      "pat_id",
      "record_id",
      "enc_id",
      "enc_period_start",
      "enc_period_end",
      "mrp_calculation_type",
      "meda_id",
      "ward_name",
      "ret_meda_dat_referenz",
      "ret_kurzbeschr"
    )

    # Reorder columns
    data.table::setcolorder(result, old_col_names)

    result <- unique(result)
  })

  etlutils::runLevel2("Rename columns in calculated MRP Excel file", {
    data.table::setnames(result,
                         old = c("pat_id",
                                 "record_id",
                                 "enc_id",
                                 "mrp_calculation_type",
                                 "meda_id",
                                 "ward_name",
                                 "ret_meda_dat_referenz",
                                 "ret_kurzbeschr"),
                         new = c("FHIR Patient ID",
                                 "REDCap Record ID",
                                 "FHIR Encounter ID",
                                 "MRP Typ",
                                 "REDCap Medikationsanalyse ID",
                                 "Station",
                                 "Datum Medikationsanalyse",
                                 "MRP Beschreibung"))


    # Add export period at the end of the table in the first column
    result <- etlutils::addRowsWithColumn(result, c("", paste("Start:", format(start_date, "%Y-%m-%d %H:%M:%S")), paste("End:", format(end_date, "%Y-%m-%d %H:%M:%S"))), column = "MRP Beschreibung")
  })

  etlutils::runLevel2("Save calculated MRPs as local Excel file", {
    etlutils::writeExcelFileLocal(list("MRP Check" = result), "MRP_Check_Result_local")
  })

  etlutils::runLevel2("Create global MRP result table", {
    id_cols <- grep(" ID$", names(result), value = TRUE)

    for (col in id_cols) {
      # Create grouping only for non-NA values, keep NA as NA
      result[, (col) := {
        tmp <- rep(NA_integer_, .N)  # initialize with NA
        non_na_idx <- !is.na(get(col))
        tmp[non_na_idx] <- match(get(col)[non_na_idx], unique(get(col)[non_na_idx]))
        tmp
      }]
    }

    # Remove encounter start and end date columns in global output file
    result[, c("FHIR Encounter End") := NULL]

    # Anonymize all dates
    result <- anonymizeTimestampsByPatient(result)
  })

  etlutils::runLevel2("Save calculated MRPs as local Excel file", {
    etlutils::writeExcelFileGlobal(list("MRP Check" = result), "MRP_Check_Result_global")
  })

}
