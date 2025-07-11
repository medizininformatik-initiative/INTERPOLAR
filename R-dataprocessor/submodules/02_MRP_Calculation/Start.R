etlutils::runLevel2("MRP Calculation", {

  mrp_contents <- list()
  mrp_table_lists_all <- list()

  # Step 1: Load and expand MRP Definitions
  etlutils::runLevel3("Load and expand MRP Definitions", {
    for (mrp_type in names(MRP_CALCULATION_TYPE)) {

      if (!(mrp_type %in% c("Drug_Disease", "Drug_Drug"))) next

      etlutils::runLevel3(paste0("Load and expand ", mrp_type, " Definition"), {
        mrp_content <- getExpandedContent(mrp_type, file.path(MRP_PAIR_PATH, paste0("MRP_", mrp_type)))
        if (!is.null(mrp_content)) {
          mrp_contents[[mrp_type]] <- mrp_content
        }
      })
    }
  })

  # Step 2: Calculate MRPs
  etlutils::runLevel3("Calculate MRPs", {
    for (mrp_type in names(mrp_contents)) {
      etlutils::runLevel3(paste0("Calculate ", mrp_type, " MRPs"), {

        mrp_type_cleaned <- gsub("_", "", mrp_type)
        function_name <- paste0("calculate", mrp_type_cleaned, "MRPs")
        calculation_fn <- get(function_name, mode = "function")

        result <- calculation_fn(
          mrp_contents[[mrp_type]]$processed_content,
          mrp_contents[[mrp_type]]$processed_content_hash
        )

        for (name in names(result)) {
          mrp_table_lists_all[[name]] <- data.table::rbindlist(
            list(mrp_table_lists_all[[name]], result[[name]]),
            fill = TRUE
          )
        }
      })
    }
  })

  etlutils::runLevel3("Write Retrolective MRP calculation to database", {
    etlutils::dbWriteTables(
      tables = mrp_table_lists_all,
      lock_id = "Write Retrolective MRP calculation to database",
      stop_if_table_not_empty = FALSE)
  })
})
