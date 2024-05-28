--Create View für Typet Tables für Dataprocessor in Schema db2dataprocessor_out

CREATE OR REPLACE VIEW db2dataprocessor_out.v_encounter_all_data as (SELECT * from db_log.encounter);
GRANT SELECT ON  db2dataprocessor_out.v_encounter_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_patient_all_data as (SELECT * from db_log.patient);
GRANT SELECT ON  db2dataprocessor_out.v_patient_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_condition_all_data as (SELECT * from db_log.condition);
GRANT SELECT ON  db2dataprocessor_out.v_condition_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medication_all_data as (SELECT * from db_log.medication);
GRANT SELECT ON  db2dataprocessor_out.v_medication_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationrequest_all_data as (SELECT * from db_log.medicationrequest);
GRANT SELECT ON  db2dataprocessor_out.v_medicationrequest_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationadministration_all_data as (SELECT * from db_log.medicationadministration);
GRANT SELECT ON  db2dataprocessor_out.v_medicationadministration_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationstatement_all_data as (SELECT * from db_log.medicationstatement);
GRANT SELECT ON  db2dataprocessor_out.v_medicationstatement_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_observation_all_data as (SELECT * from db_log.observation);
GRANT SELECT ON  db2dataprocessor_out.v_observation_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_diagnosticreport_all_data as (SELECT * from db_log.diagnosticreport);
GRANT SELECT ON  db2dataprocessor_out.v_diagnosticreport_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_servicerequest_all_data as (SELECT * from db_log.servicerequest);
GRANT SELECT ON  db2dataprocessor_out.v_servicerequest_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_procedure_all_data as (SELECT * from db_log.procedure);
GRANT SELECT ON  db2dataprocessor_out.v_procedure_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_consent_all_data as (SELECT * from db_log.consent);
GRANT SELECT ON  db2dataprocessor_out.v_consent_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_location_all_data as (SELECT * from db_log.location);
GRANT SELECT ON  db2dataprocessor_out.v_location_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

CREATE OR REPLACE VIEW db2dataprocessor_out.v_pids_per_ward_all_data as (SELECT * from db_log.pids_per_ward);
GRANT SELECT ON  db2dataprocessor_out.v_pids_per_ward_all_data TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


































