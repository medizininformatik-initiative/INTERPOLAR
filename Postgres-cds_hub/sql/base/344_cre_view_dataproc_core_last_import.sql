-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-02 10:00:19
-- Rights definition file size        : 16573 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2026-02-02 10:28:34
-- TABLE_DESCRIPTION:  ./R-dataprocessor/dataprocessor/inst/extdata/Dataprocessor_Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/344_cre_view_dataproc_core_last_import.sql
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
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_input_data_files_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_input_data_files_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_input_data_files_last_import AS (
            SELECT * FROM db_log.input_data_files
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.input_data_files)
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
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_input_data_files_processed_content_last_import'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_input_data_files_processed_content_last_import; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_input_data_files_processed_content_last_import AS (
            SELECT * FROM db_log.input_data_files_processed_content
            WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM db_log.input_data_files_processed_content)
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

--SQL Role for Views in Schema db2dataprocessor_out
GRANT SELECT ON TABLE db2dataprocessor_out.v_input_data_files_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_input_data_files_processed_content_last_import TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

