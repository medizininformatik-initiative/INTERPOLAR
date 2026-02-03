-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-02 16:02:10
-- Rights definition file size        : 16818 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2026-02-02 16:20:29
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  base/462_cre_view_fe_dataproc_last_version.sql
-- TEMPLATE:  template_cre_view_last_version.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _last_version
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
--Create SQL View for latest Version of the FHIR-Data for schema db2dataprocessor_out


--SQL Role for Views in Schema db2dataprocessor_out
GRANT SELECT ON TABLE db2dataprocessor_out.v_patient_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_fall_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medikationsanalyse_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_mrpdokumentation_validierung_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_retrolektive_mrpbewertung_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_risikofaktor_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_trigger_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

