etlutils::runLevel2("MRP Calculation", {

  etlutils::runLevel3("Load and expand MRP Definitions", {
    mrp_contents <- list()
    for (mrp_calculation_type in names(MRP_CALCULATION_TYPE)) {

      #TODO: erweitern für alle anderen MRP-Arten und die folgende IF-Bedingung entfernen
      if (mrp_calculation_type == "Drug_Disease")

      etlutils::runLevel3(paste0("Load and expand", MRP_CALCULATION_TYPE[[mrp_calculation_type]], " Definition"), {
        mrp_content <- getExpandedContent(mrp_calculation_type, paste0(MRP_PAIR_PATH, "/MRP_", mrp_calculation_type))
        if (!is.null(mrp_content)) {
          mrp_contents[[mrp_calculation_type]] <- mrp_content
        }
      })
    }
  })

  #TODO: bei weiteren MRP-Arten dann die dp_mrp_calculation-Tabelle immer rbinden und alle anderen Tabellen zur Gesamtliste hinzufügen

  etlutils::runLevel3("Calculate MRPs", {
    for (iiiii in seq_along(mrp_contents)) {
      etlutils::runLevel3(paste0("Calculate ", names(mrp_contents)[iiiii], " MRPs"), {
        mrp_table_lists <- calculateDrugDiseaseMRPs(mrp_content$processed_content,
                                                    mrp_content$processed_content_hash)
      })
    }
  })

  etlutils::runLevel3("Write Retrolective MRP calculation to database", {
    etlutils::dbWriteTables(
      tables = mrp_table_lists,
      lock_id = "Write Retrolective MRP calculation to database",
      stop_if_table_not_empty = TRUE)
  })
})
