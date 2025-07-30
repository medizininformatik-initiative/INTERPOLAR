if (hasPhaseBWards()) {
  etlutils::runLevel2("MRP Calculation", {
    mrp_table_lists_all <- calculateMRPs()
  })

  etlutils::runLevel2("Write Retrolective MRP calculation to database", {
    etlutils::dbWriteTables(
      tables = mrp_table_lists_all,
      lock_id = "Write Retrolective MRP calculation to database",
      stop_if_table_not_empty = FALSE)
  })

} else {
  etlutils::runLevel2("MRP Calculation", {
    etlutils::catWarningMessage("No Phase B wards found. MRP calculation will not be performed.\n")
  })
}
