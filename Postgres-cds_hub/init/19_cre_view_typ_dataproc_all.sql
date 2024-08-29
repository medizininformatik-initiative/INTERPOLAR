-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-08-21 09:59:34
-- Rights definition file size        : 15036 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2024-08-28 11:51:18
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  19_cre_view_typ_dataproc_all.sql
-- TEMPLATE:  template_cre_view2.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _all
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

