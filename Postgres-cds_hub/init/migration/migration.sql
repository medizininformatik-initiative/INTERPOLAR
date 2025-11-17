-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-06-20 11:15:33
-- Rights definition file size        : 16391 Byte
--
-- Create SQL Tables in Schema "NA"
-- Create time: 2025-06-23 11:01:05
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  migration/migration.sql
-- TEMPLATE:  template_migration.sql
-- OWNER_USER:  
-- OWNER_SCHEMA:  
-- TAGS:  
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  
-- RIGHTS:  
-- GRANT_TARGET_USER:  
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

----------------------------------------------------------------------------
\i migration/000_stop_semapore_during_migration.sql
------------------------------------------------------
\i ./001_main_user_schema_sequence.sql
\i ./020_db_config_tools.sql
\i ./030_db_parameter.sql
\i ./035_db_log_table_structure.sql
\i ./100_cre_table_raw_cds2db_in.sql
\i ./120_cre_table_raw_db_log.sql
\i ./140_cre_table_typ_cds2db_in.sql
\i ./150_get_last_processing_nr_typed.sql
\i ./160_cre_table_typ_log.sql
\i ./180_cre_view_raw_type_diff_log.sql
\i ./190_cre_view_typ_dataproc_all.sql
\i ./190_cre_view_typ_dataproc_last_import.sql
\i ./200_take_over_check_date.sql
\i ./210_cre_view_typ_cds2db_all.sql
\i ./220_cre_view_raw_cds2db_last_import.sql
\i ./230_cre_view_raw_cds2db_last_version.sql
\i ./230_cre_view_raw_dataproc_last_version.sql
\i ./230_cre_view_typ_cds2db_last_version.sql
\i ./230_cre_view_typ_dataproc_last_version.sql
\i ./250_adding_historical_raw_records.sql
\i ./300_cds_in_to_db_log.sql
\i ./310_cds_in_to_db_log.sql
\i ./330_cre_table_dataproc_submodules_dataproc_in.sql
\i ./331_cre_table_dataproc_submodules_log.sql
\i ./332_db_submodules_dp_in_to_db_log.sql
\i ./334_cre_view_dataproc_submodules_last_import.sql
\i ./335_cre_view_dataproc_submodules_all.sql
\i ./340_cre_table_dataproc_core_dataproc_in.sql
\i ./341_cre_table_dataproc_core_log.sql
\i ./342_db_core_dp_in_to_db_log.sql
\i ./344_cre_view_dataproc_core_last_import.sql
\i ./345_cre_view_dataproc_core_all.sql
\i ./400_cre_table_typ_dataproc_in.sql
\i ./420_cre_table_frontend_log.sql
\i ./430_cre_table_frontend_log.sql
\i ./440_cre_table_frontend_in.sql
\i ./450_cre_table_frontend_in_trig.sql
\i ./460_cre_view_fe_dataproc_last_import.sql
\i ./470_cre_view_fe_dataproc_all.sql
\i ./520_cre_view_fe_out.sql
\i ./600_dp_in_to_db_log.sql
\i ./620_fe_in_to_db_log.sql
\i ./950_cro_job.sql
\i ./recalculations/700_calculated_ref_create.sql -- in these release funtion for old date calculated_items 
------------------------------------------------------
\i migration/999_start_semapore_after_migration.sql
----------------------------------------------------------------------------

