-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-05-05 10:51:51
-- Rights definition file size        : 15631 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2025-05-21 14:18:16
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  190_cre_view_typ_dataproc_last_import.sql
-- TEMPLATE:  template_cre_view_last_import.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _last_import
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2dataprocessor_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

--Create View for frontend tables for schema db2dataprocessor_out

CREATE OR REPLACE VIEW db2dataprocessor_out.v_encounter_last_import AS (
SELECT * FROM db_log.encounter
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.encounter)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_patient_last_import AS (
SELECT * FROM db_log.patient
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.patient)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_condition_last_import AS (
SELECT * FROM db_log.condition
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.condition)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medication_last_import AS (
SELECT * FROM db_log.medication
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.medication)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationrequest_last_import AS (
SELECT * FROM db_log.medicationrequest
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.medicationrequest)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationadministration_last_import AS (
SELECT * FROM db_log.medicationadministration
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.medicationadministration)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationstatement_last_import AS (
SELECT * FROM db_log.medicationstatement
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.medicationstatement)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_observation_last_import AS (
SELECT * FROM db_log.observation
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.observation)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_diagnosticreport_last_import AS (
SELECT * FROM db_log.diagnosticreport
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.diagnosticreport)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_servicerequest_last_import AS (
SELECT * FROM db_log.servicerequest
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.servicerequest)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_procedure_last_import AS (
SELECT * FROM db_log.procedure
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.procedure)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_consent_last_import AS (
SELECT * FROM db_log.consent
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.consent)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_location_last_import AS (
SELECT * FROM db_log.location
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.location)
);

CREATE OR REPLACE VIEW db2dataprocessor_out.v_pids_per_ward_last_import AS (
SELECT * FROM db_log.pids_per_ward
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.pids_per_ward)
);

--SQL Role for Views in Schema db2dataprocessor_out
GRANT SELECT ON TABLE db2dataprocessor_out.v_encounter_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_patient_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_condition_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medication_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationrequest_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationadministration_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationstatement_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_observation_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_diagnosticreport_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_servicerequest_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_procedure_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_consent_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_location_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_pids_per_ward_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


