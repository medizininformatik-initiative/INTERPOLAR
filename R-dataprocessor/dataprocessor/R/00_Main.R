#'
#' Starts the retrieval for this project. This is the main start function start the Data Processor job
#'
#' @export
dataprocessor <- function() {
  ###
  # Read the module configuration toml file.
  ###
  path2config_toml <- './R-dataprocessor/dataprocessor_config.toml'
  etlutils::initConstants(path2config_toml,
                          c(MAX_DAYS_CHECKED_FOR_MRPS_IN_FUTURE = 30,
                            MEDICATION_REQUEST_RESOURCE = "MedicationRequest",
                            MEDICATION_REQUEST_RESOURCE_ENCOUNTER_REFERENCE_COLUMN_NAME = "medreq_encounter_id",
                            MEDICATION_REQUEST_RESOURCE_MEDICATION_REFERENCE_COLUMN_NAME = "medreq_medicationreference_id",
                            MEDICATION_REQUEST_RESOURCE_TIMESTAMP_COLUMN_NAME = "medreq_doseinstruc_timing_event",
                            MEDICATION_REQUEST_RESOURCE_PERIOD_START_COLUMN_NAME = "medreq_doseinstruc_timing_repeat_boundsperiod_start",
                            MEDICATION_REQUEST_RESOURCE_PERIOD_END_COLUMN_NAME = "medreq_doseinstruc_timing_repeat_boundsperiod_end"
                          ))

  ###
  # Read the DB configuration toml file
  ###
  etlutils::initConstants(PATH_TO_DB_CONFIG_TOML)

  ###
  # Set the project name to 'dataprocessor'
  PROJECT_NAME <<- 'dataprocessor'
  ###

  etlutils::create_dirs(PROJECT_NAME)

  ###
  # Create globally used process_clock
  ###
  etlutils::createClock()

  ###
  # log all console outputs and save them at the end
  ###
  etlutils::start_logging('retrieval-total')

  etlutils::START__()

  etlutils::run_out('Run Dataprocessor', {

    etlutils::runProcess(etlutils::run_in('Create Frontend Tables for Patient and Encounter', {
      createFrontendTables()
    }))

    # steps to do:
    # correcting laboratory codes, units and values
    # ...
    # MRP calculation

    # # Calculate Drug Disease MPRS
    # etlutils::runProcess(etlutils::run_in('Calculate Drug Disease MRPs', {
    #   calculateDrugDiseaseMRPs()
    # }))

  })

  etlutils::finalize()
}
