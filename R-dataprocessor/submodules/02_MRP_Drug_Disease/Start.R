etlutils::runLevel2("Calculate Drug-Disease MRPs", {
  etlutils::runLevel3("Load and expand Drug-Disease Definition", {
    drug_disease_mrp_tables <- getExpandedContent("Drug_Disease", MRP_PAIR_LISTS_PATHS)
  })
  calculateDrugDiseaseMRPs(drug_disease_mrp_tables)
})
