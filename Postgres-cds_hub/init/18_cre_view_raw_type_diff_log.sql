--Create SQL View not Typed Datasets in Schema cds2db_out
CREATE OR REPLACE VIEW cds2db_out.v_encounter AS (
   SELECT DISTINCT * FROM db_log.encounter_raw WHERE encounter_raw_id NOT IN (SELECT encounter_raw_id FROM db_log.encounter) ORDER BY encounter_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_patient AS (
   SELECT DISTINCT * FROM db_log.patient_raw WHERE patient_raw_id NOT IN (SELECT patient_raw_id FROM db_log.patient) ORDER BY patient_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_condition AS (
   SELECT DISTINCT * FROM db_log.condition_raw WHERE condition_raw_id NOT IN (SELECT condition_raw_id FROM db_log.condition) ORDER BY condition_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medication AS (
   SELECT DISTINCT * FROM db_log.medication_raw WHERE medication_raw_id NOT IN (SELECT medication_raw_id FROM db_log.medication) ORDER BY medication_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest AS (
   SELECT DISTINCT * FROM db_log.medicationrequest_raw WHERE medicationrequest_raw_id NOT IN (SELECT medicationrequest_raw_id FROM db_log.medicationrequest) ORDER BY medicationrequest_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration AS (
   SELECT DISTINCT * FROM db_log.medicationadministration_raw WHERE medicationadministration_raw_id NOT IN (SELECT medicationadministration_raw_id FROM db_log.medicationadministration) ORDER BY medicationadministration_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement AS (
   SELECT DISTINCT * FROM db_log.medicationstatement_raw WHERE medicationstatement_raw_id NOT IN (SELECT medicationstatement_raw_id FROM db_log.medicationstatement) ORDER BY medicationstatement_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_observation AS (
   SELECT DISTINCT * FROM db_log.observation_raw WHERE observation_raw_id NOT IN (SELECT observation_raw_id FROM db_log.observation) ORDER BY observation_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport AS (
   SELECT DISTINCT * FROM db_log.diagnosticreport_raw WHERE diagnosticreport_raw_id NOT IN (SELECT diagnosticreport_raw_id FROM db_log.diagnosticreport) ORDER BY diagnosticreport_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest AS (
   SELECT DISTINCT * FROM db_log.servicerequest_raw WHERE servicerequest_raw_id NOT IN (SELECT servicerequest_raw_id FROM db_log.servicerequest) ORDER BY servicerequest_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_procedure AS (
   SELECT DISTINCT * FROM db_log.procedure_raw WHERE procedure_raw_id NOT IN (SELECT procedure_raw_id FROM db_log.procedure) ORDER BY procedure_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_consent AS (
   SELECT DISTINCT * FROM db_log.consent_raw WHERE consent_raw_id NOT IN (SELECT consent_raw_id FROM db_log.consent) ORDER BY consent_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_location AS (
   SELECT DISTINCT * FROM db_log.location_raw WHERE location_raw_id NOT IN (SELECT location_raw_id FROM db_log.location) ORDER BY location_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward AS (
   SELECT DISTINCT * FROM db_log.pids_per_ward_raw WHERE pids_per_ward_raw_id NOT IN (SELECT pids_per_ward_raw_id FROM db_log.pids_per_ward) ORDER BY pids_per_ward_raw_id
);


--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_encounter TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_patient TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_condition TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medication TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationrequest TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationadministration TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationstatement TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_observation TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_servicerequest TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_procedure TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_consent TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_location TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_location TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


