--Create View for typed tables for schema db2dataprocessor_out

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_encounter_all AS (SELECT * from db_log.encounter);
GRANT SELECT ON db2dataprocessor_out.v_encounter_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_patient_all AS (SELECT * from db_log.patient);
GRANT SELECT ON db2dataprocessor_out.v_patient_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_condition_all AS (SELECT * from db_log.condition);
GRANT SELECT ON db2dataprocessor_out.v_condition_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medication_all AS (SELECT * from db_log.medication);
GRANT SELECT ON db2dataprocessor_out.v_medication_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationrequest_all AS (SELECT * from db_log.medicationrequest);
GRANT SELECT ON db2dataprocessor_out.v_medicationrequest_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationadministration_all AS (SELECT * from db_log.medicationadministration);
GRANT SELECT ON db2dataprocessor_out.v_medicationadministration_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationstatement_all AS (SELECT * from db_log.medicationstatement);
GRANT SELECT ON db2dataprocessor_out.v_medicationstatement_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_observation_all AS (SELECT * from db_log.observation);
GRANT SELECT ON db2dataprocessor_out.v_observation_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_diagnosticreport_all AS (SELECT * from db_log.diagnosticreport);
GRANT SELECT ON db2dataprocessor_out.v_diagnosticreport_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_servicerequest_all AS (SELECT * from db_log.servicerequest);
GRANT SELECT ON db2dataprocessor_out.v_servicerequest_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_procedure_all AS (SELECT * from db_log.procedure);
GRANT SELECT ON db2dataprocessor_out.v_procedure_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_consent_all AS (SELECT * from db_log.consent);
GRANT SELECT ON db2dataprocessor_out.v_consent_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_location_all AS (SELECT * from db_log.location);
GRANT SELECT ON db2dataprocessor_out.v_location_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_pids_per_ward_all AS (SELECT * from db_log.pids_per_ward);
GRANT SELECT ON db2dataprocessor_out.v_pids_per_ward_all TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

