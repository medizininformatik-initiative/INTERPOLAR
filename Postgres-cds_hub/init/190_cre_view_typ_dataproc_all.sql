-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-03-17 23:22:37
-- Rights definition file size        : 15699 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2025-03-18 13:56:10
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  190_cre_view_typ_dataproc_all.sql
-- TEMPLATE:  template_cre_view2.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  
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
------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_encounter AS (SELECT * from db_log.encounter);

GRANT SELECT ON db2dataprocessor_out.v_encounter TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_patient AS (SELECT * from db_log.patient);

GRANT SELECT ON db2dataprocessor_out.v_patient TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_condition AS (SELECT * from db_log.condition);

GRANT SELECT ON db2dataprocessor_out.v_condition TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medication AS (SELECT * from db_log.medication);

GRANT SELECT ON db2dataprocessor_out.v_medication TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationrequest AS (SELECT * from db_log.medicationrequest);

GRANT SELECT ON db2dataprocessor_out.v_medicationrequest TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationadministration AS (SELECT * from db_log.medicationadministration);

GRANT SELECT ON db2dataprocessor_out.v_medicationadministration TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationstatement AS (SELECT * from db_log.medicationstatement);

GRANT SELECT ON db2dataprocessor_out.v_medicationstatement TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_observation AS (SELECT * from db_log.observation);

GRANT SELECT ON db2dataprocessor_out.v_observation TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_diagnosticreport AS (SELECT * from db_log.diagnosticreport);

GRANT SELECT ON db2dataprocessor_out.v_diagnosticreport TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_servicerequest AS (SELECT * from db_log.servicerequest);

GRANT SELECT ON db2dataprocessor_out.v_servicerequest TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_procedure AS (SELECT * from db_log.procedure);

GRANT SELECT ON db2dataprocessor_out.v_procedure TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_consent AS (SELECT * from db_log.consent);

GRANT SELECT ON db2dataprocessor_out.v_consent TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_location AS (SELECT * from db_log.location);

GRANT SELECT ON db2dataprocessor_out.v_location TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW db2dataprocessor_out.v_pids_per_ward AS (SELECT * from db_log.pids_per_ward);

GRANT SELECT ON db2dataprocessor_out.v_pids_per_ward TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


