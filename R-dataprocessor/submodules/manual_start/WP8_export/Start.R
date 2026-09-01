etlutils::runLevel2("WP8-Export (Fallvignetten)", {
  runFallvignetteProcessEvaluation(
    output_dir = file.path(MODULE_DIRS$global_dir, "reports"),
    id_mapping_output_dir = file.path(
      MODULE_DIRS$local_dir,
      "data"
    ),
    site_code = SITE_CODE
  )
})
