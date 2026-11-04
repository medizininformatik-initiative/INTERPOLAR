codeSummaryFixture <- function() {
  resources <- c(
    "Observation", "Condition", "Procedure", "Medication", "MedicationRequest",
    "MedicationAdministration", "MedicationStatement"
  )
  descriptions <- lapply(resources, function(resource) {
    prefix <- switch(
      resource,
      Observation = "obs",
      Condition = "con",
      Procedure = "proc",
      Medication = "med",
      MedicationRequest = "medreq",
      MedicationAdministration = "medadm",
      MedicationStatement = "medstat"
    )
    paths <- c("id", "subject/reference", "encounter/calculated_ref")
    fields <- c("id", "patient_ref", "encounter_calculated_ref")
    if (resource == "Medication") {
      paths <- "id"
      fields <- "id"
    }
    if (startsWith(resource, "Medication") && resource != "Medication") {
      paths <- c(paths, "medicationReference/reference")
      fields <- c(fields, "medicationreference_ref")
      if (resource != "MedicationRequest") paths[[3]] <- "context/calculated_ref"
    } else {
      paths <- c(paths, paste0("code/coding/", c("system", "version", "code")))
      fields <- c(fields, "code_system", "code_version", "code_code")
    }
    if (resource == "Medication") {
      paths <- c(paths, paste0("ingredient/itemCodeableConcept/coding/", c("system", "version", "code")))
      fields <- c(fields, "ingredient_system", "ingredient_version", "ingredient_code")
    }
    if (resource == "Observation") {
      paths <- c(
        paths, "valueQuantity/value", "valueQuantity/code", "valueQuantity/system",
        "referenceRange/low/value", "referenceRange/high/value",
        "referenceRange/type/coding/code", "referenceRange/type/coding/system"
      )
      fields <- c(fields, "value", "unit", "unit_system", "low", "high", "range_type", "range_system")
    }
    data.table::data.table(
      RESOURCE = resource, FHIR_EXPRESSION = paths,
      COLUMN_NAME = paste(prefix, fields, sep = "_")
    )
  })
  description <- data.table::rbindlist(descriptions)
  metadata <- description[, .(
    TABLE_FAMILY = "FHIR", TABLE_NAME = tolower(RESOURCE), VIEW_SCHEMA = "pg_temp",
    VIEW_NAME = tolower(RESOURCE), COLUMN_NAME
  )]
  config <- getConfig(envir = new.env(parent = emptyenv()), command_arguments = character())
  list(description = description, metadata = metadata, config = config)
}

codeSummaryFixtureSql <- function(fixture) {
  tables <- split(fixture$metadata, fixture$metadata$TABLE_NAME)
  definitions <- vapply(tables, function(table) {
    columns <- vapply(table$COLUMN_NAME, function(column) {
      paste(quoteIdentifier(column), if (column == "obs_value") "double precision" else "text")
    }, character(1))
    paste0(
      "CREATE TEMP TABLE ", quoteIdentifier(table$TABLE_NAME[[1]]), " (",
      paste(columns, collapse = ", "), ");"
    )
  }, character(1))
  paste(c(
    definitions,
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,obs_code_system,obs_code_version,obs_code_code,obs_value,obs_unit,obs_unit_system,obs_low,obs_high,obs_range_type,obs_range_system)",
    "SELECT 'o'||n,'Patient/p1', CASE WHEN n=6 THEN 'invalid' ELSE 'Encounter/e1' END,'http://loinc.org','v1','common',n,'mg/dL','http://unitsofmeasure.org','1','10','normal','http://terminology.hl7.org/CodeSystem/referencerange-meaning' FROM generate_series(1,6) n;",
    "INSERT INTO observation SELECT * FROM observation;",
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,obs_code_system,obs_code_code,obs_value,obs_unit) VALUES ('rare1','Patient/p1','Encounter/e1','http://loinc.org','r1',100,'g/L'),('rare2','Patient/p1','Encounter/e1','http://loinc.org','r2',200,'g/L');",
    "INSERT INTO medication (med_id,med_code_system,med_code_code) SELECT 'm'||n,'http://fhir.de/CodeSystem/bfarm/atc','A01' FROM generate_series(1,5) n;",
    "INSERT INTO medication (med_id,med_code_system,med_code_code) SELECT 'who'||n,'http://www.whocc.no/atc','A01' FROM generate_series(1,5) n;",
    "INSERT INTO medication (med_id,med_code_system,med_code_code) VALUES ('example','http://fhir.de/CodeSystem/bfarm/atc','B01'),('no-code',NULL,NULL);",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref) VALUES ('q1','Patient/p1','Encounter/e1','Medication/example'),('q2','Patient/p1','Encounter/e1','Medication/example'),('q3','Patient/p1',NULL,NULL),('q4','Patient/p1',NULL,'Medication/missing'),('q5','Patient/p1',NULL,'Medication/no-code');",
    "INSERT INTO medicationrequest SELECT * FROM medicationrequest;",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref) VALUES ('qwho','Patient/who','Encounter/who','Medication/who1');",
    "INSERT INTO medicationadministration (medadm_id,medadm_patient_ref,medadm_encounter_calculated_ref,medadm_medicationreference_ref) SELECT 'a'||n,'Patient/p1','Encounter/e1','Medication/example' FROM generate_series(1,3) n;"
  ), collapse = "\n")
}

runCodeSummaryFixtureQuery <- function(fixture, query) {
  container <- Sys.getenv("DQA_TEST_POSTGRES_CONTAINER")
  testthat::skip_if(!nzchar(container), "Set DQA_TEST_POSTGRES_CONTAINER for isolated PostgreSQL integration tests")
  sql_file <- tempfile(fileext = ".sql")
  error_file <- tempfile()
  on.exit(unlink(c(sql_file, error_file)), add = TRUE)
  writeLines(paste0(
    codeSummaryFixtureSql(fixture), "\n", paste(fixture$extra_sql, collapse = "\n"),
    "\nCOPY (", query, ") TO STDOUT WITH CSV HEADER;"
  ), sql_file)
  output <- system2("docker", c(
    "exec", "-i", shQuote(container), "psql", "-X", "-q", "-v", "ON_ERROR_STOP=1",
    "-U", "postgres", "-d", "postgres"
  ), stdin = sql_file, stdout = TRUE, stderr = error_file)
  if (!is.null(attr(output, "status"))) stop(paste(readLines(error_file), collapse = "\n"))
  data.table::fread(paste(output, collapse = "\n"), na.strings = "")
}
