# global variables for fhir-requests
utils::globalVariables(c("FHIR_SERVER_ENDPOINT", "MAX_CORES", "MAX_ENCOUNTER_BUNDLES",
                         "FHIR_SERVER_USER", "FHIR_SERVER_PASS", "COUNT_PER_BUNDLE", "FHIR_TOKEN",
                         "FHIR_TOKEN_REFRESH_PASSWORD", "FHIR_TOKEN_REFRESH_URL",
                         "FHIR_TOKEN_REFRESH_USER", "MAX_CHARACTER_LENGTH_FOR_GET_REQUESTS",
                         "MAX_CHARACTER_LENGTH_FOR_GET_REQUESTS_RESERVE", "SORT", "IDS_AT_ONCE"))
# global variables for directory
utils::globalVariables(c("MODULE_NAME", "MODULE_DIRS", "MODULE_TIME_STAMP"))
# global variables for logging
utils::globalVariables(c("VERBOSE", "DEBUG"))
