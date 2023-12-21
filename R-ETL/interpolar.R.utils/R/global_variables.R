# global variables for fhir-requests
utils::globalVariables(c("BUNDLES_AT_ONCE", "ENC_REQ_PER", "ENC_REQ_TYPE", "FHIR_ENDPOINT", "MAX_CORES", "MAX_BUNDLES",
                         "DELAY_REQ", "FHIR_USERNAME", "FHIR_PASSWORD", "COUNT", "FHIR_TOKEN", "FHIR_TOKEN_REFRESH_PASSWORD",
                         "FHIR_TOKEN_REFRESH_URL", "FHIR_TOKEN_REFRESH_USER", "NL_ENCODE", "MAX_LEN", "RES_LEN",
                         "REQUEST_ENCOUNTER", "URL_PORT_SPEC", "SORT"))
# global variables for ressource description
utils::globalVariables(c("PERIOD_END", "PERIOD_START", "RESOURCES_TO_DOWNLOAD", "TABLE_DESCRIPTION"))
# global variables for directory
utils::globalVariables(c("PROJECT_NAME", "SUB_PROJECTS_DIRS", "PROJECT_TIME_STAMP"))
# global variables for logging
utils::globalVariables(c("polar_clock", "VERBOSE", "DEBUG"))
# global variables for verbose level
utils::globalVariables(c("VL_20_OUTER_SCRIPTS", "VL_30_INNER_SCRIPTS", "VL_40_INNER_SCRIPTS_INFOS", "VL_50_TABLES",
                         "VL_60_ALL_TABLES", "VL_60_DOWNLOAD", "VL_90_FHIR_RESPONSE"))
