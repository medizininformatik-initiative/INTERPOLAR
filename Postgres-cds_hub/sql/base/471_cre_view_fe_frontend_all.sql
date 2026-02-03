-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-02 16:02:10
-- Rights definition file size        : 16818 Byte
--
-- Create SQL Tables in Schema "db2frontend_out"
-- Create time: 2026-02-02 16:20:29
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  base/471_cre_view_fe_frontend_all.sql
-- TEMPLATE:  template_cre_view_all.sql
-- OWNER_USER:  db2frontend_user
-- OWNER_SCHEMA:  db2frontend_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _fe
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2frontend_user
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
--Create View for typed tables for schema db2dataprocessor_out

------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_patient_fe'
        ) THEN
            DROP VIEW db2frontend_out.v_patient_fe; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_patient_fe AS (SELECT * from db_log.patient_fe);

        GRANT SELECT ON db2frontend_out.v_patient_fe TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_fall_fe'
        ) THEN
            DROP VIEW db2frontend_out.v_fall_fe; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_fall_fe AS (SELECT * from db_log.fall_fe);

        GRANT SELECT ON db2frontend_out.v_fall_fe TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_medikationsanalyse_fe'
        ) THEN
            DROP VIEW db2frontend_out.v_medikationsanalyse_fe; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_medikationsanalyse_fe AS (SELECT * from db_log.medikationsanalyse_fe);

        GRANT SELECT ON db2frontend_out.v_medikationsanalyse_fe TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_mrpdokumentation_validierung_fe'
        ) THEN
            DROP VIEW db2frontend_out.v_mrpdokumentation_validierung_fe; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_mrpdokumentation_validierung_fe AS (SELECT * from db_log.mrpdokumentation_validierung_fe);

        GRANT SELECT ON db2frontend_out.v_mrpdokumentation_validierung_fe TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_retrolektive_mrpbewertung_fe'
        ) THEN
            DROP VIEW db2frontend_out.v_retrolektive_mrpbewertung_fe; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_retrolektive_mrpbewertung_fe AS (SELECT * from db_log.retrolektive_mrpbewertung_fe);

        GRANT SELECT ON db2frontend_out.v_retrolektive_mrpbewertung_fe TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_risikofaktor_fe'
        ) THEN
            DROP VIEW db2frontend_out.v_risikofaktor_fe; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_risikofaktor_fe AS (SELECT * from db_log.risikofaktor_fe);

        GRANT SELECT ON db2frontend_out.v_risikofaktor_fe TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


------------------------------------------------------------------------------------------------------------------
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_trigger_fe'
        ) THEN
            DROP VIEW db2frontend_out.v_trigger_fe; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_trigger_fe AS (SELECT * from db_log.trigger_fe);

        GRANT SELECT ON db2frontend_out.v_trigger_fe TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

