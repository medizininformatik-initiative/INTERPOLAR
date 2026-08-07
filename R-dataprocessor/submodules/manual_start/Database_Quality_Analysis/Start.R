etlutils::runLevel2("Database Quality Analysis", {
  etlutils::dbSetModuleContextFromEnvironment(
    module_name = "dataprocessor",
    db_schema_base_name = "dataprocessor",
    target_prefix = "DB_ANALYSIS"
  )
  createReport()
})
