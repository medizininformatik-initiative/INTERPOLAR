etlutils::runLevel2("Fallvignette Process Evaluation", {
  runFallvignetteProcessEvaluation(
    output_dir = file.path(MODULE_DIRS$global_dir, "reports"),
    id_mapping_output_dir = file.path(
      MODULE_DIRS$local_dir,
      "data"
    ),
    site_code = SITE_CODE
  )
})
