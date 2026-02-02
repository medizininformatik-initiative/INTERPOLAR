mrpCheck <- function(start_date, end_date) {

  etlutils::runLevel2("MRP Calculation", {
    start_date <- etlutils::as.POSIXctWithTimezone(start_date)
    end_date <- etlutils::as.POSIXctWithTimezone(end_date)
    mrp_table_lists_all <- calculateMRPs(start_date, end_date, return_used_resources = "record_ids")
  })

  etlutils::runLevel2("Create local MRP result table", {
    needed_cols <- c("ret_id", "record_id", "ret_kurzbeschr", "ret_meda_dat1")
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
                         old = old_col_names,
                         new = c("FHIR Patient ID",
                                 "REDCap Record ID",
                                 "FHIR Encounter ID",
                                 "FHIR Encounter Start",
                                 "FHIR Encounter End",
                                 "MRP Typ",
                                 "REDCap Medikationsanalyse ID",
                                 "Station",
                                 "Datum Medikationsanalyse",
                                 "MRP Beschreibung"))


    # add export period at the end of the table in the first column
    result <- etlutils::addRowsWithColumn(result, c("", paste("Start:", format(start_date, "%Y-%m-%d %H:%M:%S")), paste("End:", format(end_date, "%Y-%m-%d %H:%M:%S"))), column = "MRP Typ")
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

    # remove encounter start and end date columns in global output file
    result[, c("FHIR Encounter Start", "FHIR Encounter End") := NULL]

  })

  etlutils::runLevel2("Save calculated MRPs as local Excel file", {
    etlutils::writeExcelFileGlobal(list("MRP Check" = result), "MRP_Check_Result_global")
  })

}
