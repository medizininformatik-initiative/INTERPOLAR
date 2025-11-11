-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-07-01 13:49:10
-- Rights definition file size        : 16391 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2025-11-11 12:32:55
-- TABLE_DESCRIPTION:  ./R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx[table_description]
-- SCRIPTNAME:  335_cre_view_dataproc_submodules_all.sql
-- TEMPLATE:  template_cre_view_all.sql
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
DROP VIEW db2dataprocessor_out.v_dp_mrp_calculations; -- first drop the view
CREATE OR REPLACE VIEW db2dataprocessor_out.v_dp_mrp_calculations AS (SELECT * from db_log.dp_mrp_calculations);

GRANT SELECT ON db2dataprocessor_out.v_dp_mrp_calculations TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

