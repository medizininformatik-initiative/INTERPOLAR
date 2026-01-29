-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-01-28 05:28:51
-- Rights definition file size        : 16569 Byte
--
-- Create SQL Tables in Schema "db2frontend_out"
-- Create time: 2026-01-28 05:41:37
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  033_cre_view_parameter_dataproc_out.sql
-- TEMPLATE:  template_cre_view_parameter.sql
-- OWNER_USER:  db2frontend_user
-- OWNER_SCHEMA:  db2frontend_out
-- TAGS:  
-- TABLE_PREFIX:  fix
-- TABLE_POSTFIX:  
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2frontend_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################


------------------------------------------------------------------------------------------------------------------
-- view in schema db2frontend_out to have access to db-parameters - table is fix
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2frontend_out' AND table_name = 'v_db_parameter'
        ) THEN
            DROP VIEW db2frontend_out.v_db_parameter; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_db_parameter AS (SELECT * FROM db_config.db_parameter ORDER BY parameter_name);

        GRANT SELECT ON db2frontend_out.v_db_parameter TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


