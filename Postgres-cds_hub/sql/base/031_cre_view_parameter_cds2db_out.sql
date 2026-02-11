-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-02 10:00:19
-- Rights definition file size        : 16573 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2026-02-02 10:09:17
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/031_cre_view_parameter_cds2db_out.sql
-- TEMPLATE:  template_cre_view_parameter.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
-- TABLE_PREFIX:  fix
-- TABLE_POSTFIX:  
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################


------------------------------------------------------------------------------------------------------------------
-- view in schema cds2db_out to have access to db-parameters - table is fix
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_db_parameter'
        ) THEN
            DROP VIEW cds2db_out.v_db_parameter; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_db_parameter AS (SELECT * FROM db_config.db_parameter ORDER BY parameter_name);

        GRANT SELECT ON cds2db_out.v_db_parameter TO cds2db_user;
        GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;
----------------------------
    END IF; -- do migration
END
$innerview$;


