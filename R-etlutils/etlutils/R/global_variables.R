# global variables for fhir-requests
utils::globalVariables(c("BUNDLES_AT_ONCE", "ENC_REQ_PER", "ENC_REQ_TYPE", "FHIR_SERVER_ENDPOINT", "MAX_CORES", "MAX_ENCOUNTER_BUNDLES",
                         "DELAY_REQ", "FHIR_SERVER_USER", "FHIR_SERVER_PASS", "COUNT_PER_BUNDLE", "FHIR_TOKEN", "FHIR_TOKEN_REFRESH_PASSWORD",
                         "FHIR_TOKEN_REFRESH_URL", "FHIR_TOKEN_REFRESH_USER", "NEXT_LINK_ENCODE", "MAX_LEN", "RES_LEN",
                         "REQUEST_ENCOUNTER", "URL_PORT_SPEC", "SORT", "IDS_AT_ONCE", "OBS_BY_FILTER",
                         "ENCOUNTER_IDENTIFIER_PATH", "ENCOUNTER_IDENTIFIER_VALUE_PATTERN"))
# global variables for ressource description
utils::globalVariables(c("PERIOD_END", "PERIOD_START", "RESOURCES_TO_DOWNLOAD", "TABLE_DESCRIPTION"))
# global variables for directory
utils::globalVariables(c("PROJECT_NAME", "SUB_PROJECTS_DIRS", "PROJECT_TIME_STAMP"))
# global variables for logging
utils::globalVariables(c("VERBOSE", "DEBUG", "VERSIONS"))
