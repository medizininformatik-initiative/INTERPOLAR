-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-04-18 00:56:43
-- Rights definition file size        : 15800 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2025-04-18 01:01:32
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  220_cre_view_raw_cds2db_last_import.sql
-- TEMPLATE:  template_cre_view_last_import.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _raw_last_import
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  _raw
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

--Create View for frontend tables for schema cds2db_out

CREATE OR REPLACE VIEW cds2db_out.v_encounter_raw_last_import AS (
SELECT * FROM db_log.encounter_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.encounter_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_patient_raw_last_import AS (
SELECT * FROM db_log.patient_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.patient_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_condition_raw_last_import AS (
SELECT * FROM db_log.condition_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.condition_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_medication_raw_last_import AS (
SELECT * FROM db_log.medication_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.medication_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest_raw_last_import AS (
SELECT * FROM db_log.medicationrequest_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.medicationrequest_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration_raw_last_import AS (
SELECT * FROM db_log.medicationadministration_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.medicationadministration_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement_raw_last_import AS (
SELECT * FROM db_log.medicationstatement_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.medicationstatement_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_observation_raw_last_import AS (
SELECT * FROM db_log.observation_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.observation_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport_raw_last_import AS (
SELECT * FROM db_log.diagnosticreport_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.diagnosticreport_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_servicerequest_raw_last_import AS (
SELECT * FROM db_log.servicerequest_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.servicerequest_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_procedure_raw_last_import AS (
SELECT * FROM db_log.procedure_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.procedure_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_consent_raw_last_import AS (
SELECT * FROM db_log.consent_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.consent_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_location_raw_last_import AS (
SELECT * FROM db_log.location_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.location_raw)
);

CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward_raw_last_import AS (
SELECT * FROM db_log.pids_per_ward_raw
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.pids_per_ward_raw)
);

--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_location_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward_raw_last_import TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


