-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-04-04 03:35:29
-- Rights definition file size        : 15808 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2025-04-04 08:42:20
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  210_cre_view_typ_cds2db_all.sql
-- TEMPLATE:  template_cre_view_all.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  
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
------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_encounter AS (SELECT * from db_log.encounter);

GRANT SELECT ON cds2db_out.v_encounter TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_patient AS (SELECT * from db_log.patient);

GRANT SELECT ON cds2db_out.v_patient TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_condition AS (SELECT * from db_log.condition);

GRANT SELECT ON cds2db_out.v_condition TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medication AS (SELECT * from db_log.medication);

GRANT SELECT ON cds2db_out.v_medication TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest AS (SELECT * from db_log.medicationrequest);

GRANT SELECT ON cds2db_out.v_medicationrequest TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration AS (SELECT * from db_log.medicationadministration);

GRANT SELECT ON cds2db_out.v_medicationadministration TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement AS (SELECT * from db_log.medicationstatement);

GRANT SELECT ON cds2db_out.v_medicationstatement TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_observation AS (SELECT * from db_log.observation);

GRANT SELECT ON cds2db_out.v_observation TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport AS (SELECT * from db_log.diagnosticreport);

GRANT SELECT ON cds2db_out.v_diagnosticreport TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest AS (SELECT * from db_log.servicerequest);

GRANT SELECT ON cds2db_out.v_servicerequest TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_procedure AS (SELECT * from db_log.procedure);

GRANT SELECT ON cds2db_out.v_procedure TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_consent AS (SELECT * from db_log.consent);

GRANT SELECT ON cds2db_out.v_consent TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_location AS (SELECT * from db_log.location);

GRANT SELECT ON cds2db_out.v_location TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward AS (SELECT * from db_log.pids_per_ward);

GRANT SELECT ON cds2db_out.v_pids_per_ward TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


