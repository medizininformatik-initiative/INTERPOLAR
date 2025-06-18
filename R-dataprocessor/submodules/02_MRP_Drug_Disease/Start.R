etlutils::runLevel2("MRP Calculation", {

  etlutils::runLevel3("Load and expand Drug-Disease Definition", {
    drug_disease_mrp_tables <- getExpandedContent("Drug_Disease", MRP_PAIR_LISTS_PATHS)
  })

  etlutils::runLevel3("Calculate Drug-Disease MRPs", {
    mrp_table_lists <- calculateDrugDiseaseMRPs(drug_disease_mrp_tables)
  })

})
