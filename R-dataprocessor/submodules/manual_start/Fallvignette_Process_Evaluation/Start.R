etlutils::runLevel2("Fallvignette Process Evaluation", {
  runFallvignetteProcessEvaluation(
    mapping_file_name = FALLVIGNETTE_MAPPING_FILE_NAME,
    path_to_db_config_toml = PATH_TO_DB_CONFIG_TOML,
    output_dir = file.path(MODULE_DIRS$global_dir, "reports"),
    output_file_name = FALLVIGNETTE_OUTPUT_FILE_NAME,
    id_mapping_output_dir = file.path(
      MODULE_DIRS$local_dir,
      "data"
    ),
    id_mapping_file_name = FALLVIGNETTE_ID_MAPPING_FILE_NAME,
    site_code = SITE_CODE
  )
})
