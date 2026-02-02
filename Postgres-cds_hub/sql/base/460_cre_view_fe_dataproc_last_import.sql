-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-02 10:00:19
-- Rights definition file size        : 16573 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2026-02-02 10:28:27
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  base/460_cre_view_fe_dataproc_last_import.sql
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

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_patient_fe_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_patient_fe_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_patient_fe_last_import AS (
            SELECT * FROM db_log.patient_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.patient_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_fall_fe_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_fall_fe_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_fall_fe_last_import AS (
            SELECT * FROM db_log.fall_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.fall_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_medikationsanalyse_fe_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_medikationsanalyse_fe_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_medikationsanalyse_fe_last_import AS (
            SELECT * FROM db_log.medikationsanalyse_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.medikationsanalyse_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_mrpdokumentation_validierung_fe_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_mrpdokumentation_validierung_fe_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_mrpdokumentation_validierung_fe_last_import AS (
            SELECT * FROM db_log.mrpdokumentation_validierung_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.mrpdokumentation_validierung_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_retrolektive_mrpbewertung_fe_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_retrolektive_mrpbewertung_fe_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_retrolektive_mrpbewertung_fe_last_import AS (
            SELECT * FROM db_log.retrolektive_mrpbewertung_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.retrolektive_mrpbewertung_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_risikofaktor_fe_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_risikofaktor_fe_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_risikofaktor_fe_last_import AS (
            SELECT * FROM db_log.risikofaktor_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.risikofaktor_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_trigger_fe_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_trigger_fe_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_trigger_fe_last_import AS (
            SELECT * FROM db_log.trigger_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.trigger_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

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

