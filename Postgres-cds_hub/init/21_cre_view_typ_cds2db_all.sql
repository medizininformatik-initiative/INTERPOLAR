-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-08-21 09:59:34
-- Rights definition file size        : 15036 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2024-08-28 11:51:18
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  21_cre_view_typ_cds2db_all.sql
-- TEMPLATE:  template_cre_view2.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _all
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  cds2db_user
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
CREATE OR REPLACE VIEW cds2db_out.v_encounter_all AS (SELECT * from db_log.encounter);
GRANT SELECT ON cds2db_out.v_encounter_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_patient_all AS (SELECT * from db_log.patient);
GRANT SELECT ON cds2db_out.v_patient_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_condition_all AS (SELECT * from db_log.condition);
GRANT SELECT ON cds2db_out.v_condition_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medication_all AS (SELECT * from db_log.medication);
GRANT SELECT ON cds2db_out.v_medication_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest_all AS (SELECT * from db_log.medicationrequest);
GRANT SELECT ON cds2db_out.v_medicationrequest_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration_all AS (SELECT * from db_log.medicationadministration);
GRANT SELECT ON cds2db_out.v_medicationadministration_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement_all AS (SELECT * from db_log.medicationstatement);
GRANT SELECT ON cds2db_out.v_medicationstatement_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_observation_all AS (SELECT * from db_log.observation);
GRANT SELECT ON cds2db_out.v_observation_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport_all AS (SELECT * from db_log.diagnosticreport);
GRANT SELECT ON cds2db_out.v_diagnosticreport_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest_all AS (SELECT * from db_log.servicerequest);
GRANT SELECT ON cds2db_out.v_servicerequest_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_procedure_all AS (SELECT * from db_log.procedure);
GRANT SELECT ON cds2db_out.v_procedure_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_consent_all AS (SELECT * from db_log.consent);
GRANT SELECT ON cds2db_out.v_consent_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_location_all AS (SELECT * from db_log.location);
GRANT SELECT ON cds2db_out.v_location_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward_all AS (SELECT * from db_log.pids_per_ward);
GRANT SELECT ON cds2db_out.v_pids_per_ward_all TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

