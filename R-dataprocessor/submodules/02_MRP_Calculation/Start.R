etlutils::runLevel2("MRP Calculation", {

  etlutils::runLevel3("Load and expand Drug-Disease Definition", {
    drug_disease_mrp_tables <- getExpandedContent(MRP_CALCULATION_TYPE$Drug_Disease, MRP_PAIR_LISTS_PATHS)
  })

  etlutils::runLevel3("Calculate Drug-Disease MRPs", {
    mrp_table_lists <- calculateDrugDiseaseMRPs(drug_disease_mrp_tables)
  })

  etlutils::runLevel3("Write Retrolective MRP calculation to database", {
    etlutils::dbWriteTables(
      tables = mrp_table_lists,
      lock_id = "Write Retrolective MRP calculation to database",
      stop_if_table_not_empty = TRUE)
  })
})
