-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-03-17 23:22:37
-- Rights definition file size        : 15699 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2025-03-18 13:56:10
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  180_cre_view_raw_type_diff_log.sql
-- TEMPLATE:  template_cre_view.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _raw_diff
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  _raw
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

--Create SQL View not Typed Datasets in Schema cds2db_out
CREATE OR REPLACE VIEW cds2db_out.v_encounter_raw_diff AS (
   SELECT DISTINCT * FROM db_log.encounter_raw WHERE encounter_raw_id NOT IN (SELECT encounter_raw_id FROM db_log.encounter) ORDER BY encounter_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_patient_raw_diff AS (
   SELECT DISTINCT * FROM db_log.patient_raw WHERE patient_raw_id NOT IN (SELECT patient_raw_id FROM db_log.patient) ORDER BY patient_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_condition_raw_diff AS (
   SELECT DISTINCT * FROM db_log.condition_raw WHERE condition_raw_id NOT IN (SELECT condition_raw_id FROM db_log.condition) ORDER BY condition_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medication_raw_diff AS (
   SELECT DISTINCT * FROM db_log.medication_raw WHERE medication_raw_id NOT IN (SELECT medication_raw_id FROM db_log.medication) ORDER BY medication_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest_raw_diff AS (
   SELECT DISTINCT * FROM db_log.medicationrequest_raw WHERE medicationrequest_raw_id NOT IN (SELECT medicationrequest_raw_id FROM db_log.medicationrequest) ORDER BY medicationrequest_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration_raw_diff AS (
   SELECT DISTINCT * FROM db_log.medicationadministration_raw WHERE medicationadministration_raw_id NOT IN (SELECT medicationadministration_raw_id FROM db_log.medicationadministration) ORDER BY medicationadministration_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement_raw_diff AS (
   SELECT DISTINCT * FROM db_log.medicationstatement_raw WHERE medicationstatement_raw_id NOT IN (SELECT medicationstatement_raw_id FROM db_log.medicationstatement) ORDER BY medicationstatement_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_observation_raw_diff AS (
   SELECT DISTINCT * FROM db_log.observation_raw WHERE observation_raw_id NOT IN (SELECT observation_raw_id FROM db_log.observation) ORDER BY observation_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport_raw_diff AS (
   SELECT DISTINCT * FROM db_log.diagnosticreport_raw WHERE diagnosticreport_raw_id NOT IN (SELECT diagnosticreport_raw_id FROM db_log.diagnosticreport) ORDER BY diagnosticreport_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest_raw_diff AS (
   SELECT DISTINCT * FROM db_log.servicerequest_raw WHERE servicerequest_raw_id NOT IN (SELECT servicerequest_raw_id FROM db_log.servicerequest) ORDER BY servicerequest_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_procedure_raw_diff AS (
   SELECT DISTINCT * FROM db_log.procedure_raw WHERE procedure_raw_id NOT IN (SELECT procedure_raw_id FROM db_log.procedure) ORDER BY procedure_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_consent_raw_diff AS (
   SELECT DISTINCT * FROM db_log.consent_raw WHERE consent_raw_id NOT IN (SELECT consent_raw_id FROM db_log.consent) ORDER BY consent_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_location_raw_diff AS (
   SELECT DISTINCT * FROM db_log.location_raw WHERE location_raw_id NOT IN (SELECT location_raw_id FROM db_log.location) ORDER BY location_raw_id
);
CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward_raw_diff AS (
   SELECT DISTINCT * FROM db_log.pids_per_ward_raw WHERE pids_per_ward_raw_id NOT IN (SELECT pids_per_ward_raw_id FROM db_log.pids_per_ward) ORDER BY pids_per_ward_raw_id
);


--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_encounter_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_patient_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_condition_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medication_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_observation_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_procedure_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_consent_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_location_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_location_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


