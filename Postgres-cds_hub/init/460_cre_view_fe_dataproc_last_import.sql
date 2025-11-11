-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-07-01 13:49:10
-- Rights definition file size        : 16391 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2025-11-11 12:32:52
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  460_cre_view_fe_dataproc_last_import.sql
-- TEMPLATE:  template_cre_view_last_import.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _fe_last_import
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2dataprocessor_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  _fe
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create View for frontend tables for schema db2dataprocessor_out
DROP VIEW db2dataprocessor_out.v_patient_fe_last_import; -- first drop the view

CREATE OR REPLACE VIEW db2dataprocessor_out.v_patient_fe_last_import AS (
SELECT * FROM db_log.patient_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.patient_fe)
);
DROP VIEW db2dataprocessor_out.v_fall_fe_last_import; -- first drop the view

CREATE OR REPLACE VIEW db2dataprocessor_out.v_fall_fe_last_import AS (
SELECT * FROM db_log.fall_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.fall_fe)
);
DROP VIEW db2dataprocessor_out.v_medikationsanalyse_fe_last_import; -- first drop the view

CREATE OR REPLACE VIEW db2dataprocessor_out.v_medikationsanalyse_fe_last_import AS (
SELECT * FROM db_log.medikationsanalyse_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.medikationsanalyse_fe)
);
DROP VIEW db2dataprocessor_out.v_mrpdokumentation_validierung_fe_last_import; -- first drop the view

CREATE OR REPLACE VIEW db2dataprocessor_out.v_mrpdokumentation_validierung_fe_last_import AS (
SELECT * FROM db_log.mrpdokumentation_validierung_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.mrpdokumentation_validierung_fe)
);
DROP VIEW db2dataprocessor_out.v_retrolektive_mrpbewertung_fe_last_import; -- first drop the view

CREATE OR REPLACE VIEW db2dataprocessor_out.v_retrolektive_mrpbewertung_fe_last_import AS (
SELECT * FROM db_log.retrolektive_mrpbewertung_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.retrolektive_mrpbewertung_fe)
);
DROP VIEW db2dataprocessor_out.v_risikofaktor_fe_last_import; -- first drop the view

CREATE OR REPLACE VIEW db2dataprocessor_out.v_risikofaktor_fe_last_import AS (
SELECT * FROM db_log.risikofaktor_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.risikofaktor_fe)
);
DROP VIEW db2dataprocessor_out.v_trigger_fe_last_import; -- first drop the view

CREATE OR REPLACE VIEW db2dataprocessor_out.v_trigger_fe_last_import AS (
SELECT * FROM db_log.trigger_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.trigger_fe)
);

--SQL Role for Views in Schema db2dataprocessor_out
GRANT SELECT ON TABLE db2dataprocessor_out.v_patient_fe_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_fall_fe_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medikationsanalyse_fe_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_mrpdokumentation_validierung_fe_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_retrolektive_mrpbewertung_fe_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_risikofaktor_fe_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_trigger_fe_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

