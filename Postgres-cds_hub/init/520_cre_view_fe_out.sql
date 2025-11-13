-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-07-01 13:49:10
-- Rights definition file size        : 16391 Byte
--
-- Create SQL Tables in Schema "db2frontend_out"
-- Create time: 2025-11-13 09:12:48
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  520_cre_view_fe_out.sql
-- TEMPLATE:  template_cre_view_last_import.sql
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

DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create View for frontend tables for schema db2frontend_out

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_patient'
        ) THEN
            DROP VIEW db2frontend_out.v_patient; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_patient AS (
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
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_fall'
        ) THEN
            DROP VIEW db2frontend_out.v_fall; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_fall AS (
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
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_medikationsanalyse'
        ) THEN
            DROP VIEW db2frontend_out.v_medikationsanalyse; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_medikationsanalyse AS (
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
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_mrpdokumentation_validierung'
        ) THEN
            DROP VIEW db2frontend_out.v_mrpdokumentation_validierung; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_mrpdokumentation_validierung AS (
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
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_retrolektive_mrpbewertung'
        ) THEN
            DROP VIEW db2frontend_out.v_retrolektive_mrpbewertung; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_retrolektive_mrpbewertung AS (
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
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_risikofaktor'
        ) THEN
            DROP VIEW db2frontend_out.v_risikofaktor; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_risikofaktor AS (
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
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_trigger'
        ) THEN
            DROP VIEW db2frontend_out.v_trigger; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_trigger AS (
            SELECT * FROM db_log.trigger_fe
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.trigger_fe)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

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

GRANT SELECT ON TABLE db2frontend_out.v_retrolektive_mrpbewertung TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_retrolektive_mrpbewertung TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_risikofaktor TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_risikofaktor TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_trigger TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_trigger TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

