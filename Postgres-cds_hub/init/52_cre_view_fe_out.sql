-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-08-21 09:59:34
-- Rights definition file size        : 15036 Byte
--
-- Create SQL Tables in Schema "db2frontend_out"
-- Create time: 2024-08-28 11:51:27
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  52_cre_view_fe_out.sql
-- TEMPLATE:  template_cre_view3.sql
-- OWNER_USER:  db2frontend_user
-- OWNER_SCHEMA:  db2frontend_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2frontend_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  _fe
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

--Create View for frontend tables for schema db2frontend_out

CREATE OR REPLACE VIEW db2frontend_out.v_patient AS (
SELECT * FROM db_log.patient_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.patient_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_fall AS (
SELECT * FROM db_log.fall_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.fall_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_medikationsanalyse AS (
SELECT * FROM db_log.medikationsanalyse_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.medikationsanalyse_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_mrpdokumentation_validierung AS (
SELECT * FROM db_log.mrpdokumentation_validierung_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.mrpdokumentation_validierung_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_risikofaktor AS (
SELECT * FROM db_log.risikofaktor_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.risikofaktor_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_trigger AS (
SELECT * FROM db_log.trigger_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.trigger_fe)
);

--SQL Role for Views in Schema db2frontend_out
GRANT SELECT ON TABLE db2frontend_out.v_patient TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_patient TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_fall TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_fall TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_medikationsanalyse TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_medikationsanalyse TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_mrpdokumentation_validierung TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_mrpdokumentation_validierung TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_risikofaktor TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_risikofaktor TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_trigger TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_trigger TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;


