codeSummaryFixture <- function() {
  resources <- c(
    "Observation", "Condition", "Procedure", "Medication", "MedicationRequest",
    "MedicationAdministration", "MedicationStatement", "Patient", "Encounter", "Location"
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
      MedicationStatement = "medstat",
      Patient = "pat",
      Encounter = "enc",
      Location = "loc"
    )
    paths <- c("id", "subject/reference", "encounter/calculated_ref")
    fields <- c("id", "patient_ref", "encounter_calculated_ref")
    if (resource == "Encounter") {
      paths[[3]] <- "main/encounter/calculated/ref"
      fields[[3]] <- "main_encounter_calculated_ref"
    }
    if (resource %in% c("Medication", "Patient")) {
      paths <- "id"
      fields <- "id"
    }
    if (startsWith(resource, "Medication") && resource != "Medication") {
      paths <- c(paths, "medicationReference/reference", paste0("medicationCodeableConcept/coding/", c("system", "version", "code")))
      fields <- c(fields, "medicationreference_ref", "direct_system", "direct_version", "direct_code")
      if (resource != "MedicationRequest") paths[[3]] <- "context/calculated_ref"
    } else {
      coding_path <- switch(
        resource,
        Patient = "identifier/type/coding/",
        Encounter = "class/",
        "code/coding/"
      )
      paths <- c(paths, paste0(coding_path, c("system", "version", "code")))
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
      paths <- c(paths, paste0("method/coding/", c("system", "version", "code")))
      fields <- c(fields, "method_system", "method_version", "method_code")
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

# Reuse the normal fixture and exporter for a visible, entirely synthetic SNOMED
# example. Six or more resources keep detail rows above the suppression threshold.
codeSummarySnomedFixture <- function() {
  fixture <- codeSummaryFixture()
  fixture$extra_sql <- c(
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,obs_code_system,obs_code_version,obs_code_code,obs_value,obs_unit,obs_unit_system,obs_low,obs_high,obs_range_type,obs_method_system,obs_method_code) SELECT 'snomed-o'||n,'Patient/s'||n,'Encounter/s'||((n-1)%3+1),'http://snomed.info/sct','demo-v1','386661006',36+n/10.0,'Cel','http://unitsofmeasure.org','36','38','normal','http://snomed.info/sct','414564002' FROM generate_series(1,6) n;",
    "INSERT INTO observation (obs_id,obs_patient_ref,obs_encounter_calculated_ref,obs_code_system,obs_code_version,obs_code_code,obs_value,obs_unit,obs_unit_system) SELECT 'snomed-o-other'||n,'Patient/s'||n,CASE WHEN n=6 THEN NULL ELSE 'Encounter/s1' END,'http://snomed.info/sct','demo-v1','49727002',n/2.0,'1','http://unitsofmeasure.org' FROM generate_series(1,6) n;",
    "INSERT INTO observation (obs_id,obs_code_system,obs_code_code,obs_value,obs_unit) SELECT 'snomed-o-rare'||n,'http://snomed.info/sct','267036007',n,'1' FROM generate_series(1,2) n;",
    "INSERT INTO observation SELECT * FROM observation WHERE obs_id LIKE 'snomed-%';",
    "INSERT INTO condition (con_id,con_patient_ref,con_encounter_calculated_ref,con_code_system,con_code_version,con_code_code) SELECT 'snomed-c'||n,'Patient/s'||n,'Encounter/s'||((n-1)%3+1),'http://snomed.info/sct','demo-v1','386661006' FROM generate_series(1,6) n;",
    "INSERT INTO condition (con_id,con_code_system,con_code_code) SELECT 'snomed-c-rare'||n,'http://snomed.info/sct','49727002' FROM generate_series(1,4) n;",
    "INSERT INTO procedure (proc_id,proc_patient_ref,proc_encounter_calculated_ref,proc_code_system,proc_code_version,proc_code_code) SELECT 'snomed-p'||n,'Patient/s'||n,'Encounter/s'||((n-1)%3+1),'http://snomed.info/sct','demo-v1','80146002' FROM generate_series(1,6) n;",
    "INSERT INTO procedure (proc_id,proc_code_system,proc_code_version,proc_code_code) SELECT 'snomed-p-other'||n,'http://snomed.info/sct','demo-v1','71388002' FROM generate_series(1,5) n;",
    "INSERT INTO medication (med_id,med_code_system,med_code_version,med_code_code,med_ingredient_system,med_ingredient_version,med_ingredient_code) SELECT 'snomed-med'||n,'http://snomed.info/sct','demo-v1','372687004','http://snomed.info/sct','demo-v1','387458008' FROM generate_series(1,6) n;",
    "INSERT INTO medication (med_id,med_code_system,med_code_version,med_code_code) SELECT 'snomed-med-rare'||n,'http://snomed.info/sct','demo-v1','372507007' FROM generate_series(1,4) n;",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_medicationreference_ref,medreq_direct_system,medreq_direct_version,medreq_direct_code) SELECT 'snomed-r'||n,'Patient/s'||n,'Encounter/s'||((n-1)%3+1),'Medication/snomed-med'||n,'http://snomed.info/sct','demo-v1','372687004' FROM generate_series(1,6) n;",
    "INSERT INTO medicationrequest (medreq_id,medreq_patient_ref,medreq_encounter_calculated_ref,medreq_direct_system,medreq_direct_version,medreq_direct_code) SELECT 'snomed-r-direct'||n,'Patient/s'||n,'Encounter/s1','http://snomed.info/sct','demo-v1','372687004' FROM generate_series(1,5) n;",
    "INSERT INTO medicationadministration (medadm_id,medadm_patient_ref,medadm_encounter_calculated_ref,medadm_medicationreference_ref) SELECT 'snomed-a'||n,'Patient/s'||n,'Encounter/s'||((n-1)%3+1),'Medication/snomed-med'||n FROM generate_series(1,6) n;",
    "INSERT INTO medicationadministration (medadm_id,medadm_patient_ref,medadm_direct_system,medadm_direct_version,medadm_direct_code) SELECT 'snomed-a-direct'||n,'Patient/s'||n,'http://snomed.info/sct','demo-v1','387207008' FROM generate_series(1,5) n;",
    "INSERT INTO medicationstatement (medstat_id,medstat_patient_ref,medstat_encounter_calculated_ref,medstat_direct_system,medstat_direct_version,medstat_direct_code) SELECT 'snomed-s-direct'||n,'Patient/s'||n,'Encounter/s1','http://snomed.info/sct','demo-v1','372729009' FROM generate_series(1,5) n;",
    "INSERT INTO medicationrequest SELECT * FROM medicationrequest WHERE medreq_id LIKE 'snomed-%';",
    "INSERT INTO medicationadministration SELECT * FROM medicationadministration WHERE medadm_id LIKE 'snomed-%';",
    "INSERT INTO medicationstatement SELECT * FROM medicationstatement WHERE medstat_id LIKE 'snomed-%';"
  )
  fixture
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
  data.table::fread(text = paste0(paste(output, collapse = "\n"), "\n"), na.strings = "")
}
