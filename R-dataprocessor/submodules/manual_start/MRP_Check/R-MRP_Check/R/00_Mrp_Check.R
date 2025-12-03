mrpCheck <- function() {
  etlutils::runLevel2("MRP Calculation", {
    mrp_table_lists_all <- calculateMRPs(Sys.Date() - 60)
  })

  etlutils::runLevel2("Save calculated MRPs as Excel files", {
    etlutils::writeExcelFileLocal(mrp_table_lists_all, "MRP_Check_Result")
  })

}
