----------------------------------------------------------------------------
---- Wichtig !! - !! Erst Parameter an lokale Gegebenheiten anpassen !! ----
----   Important!! - !! First adjust parameters to local conditions!!   ----
-- Bitte Skript - 030_db_parameter.sql - öffnen und anpassen --
-- Please open and adjust the script - 030_db_parameter.sql --
----------------------------------------------------------------------------

@000_stop_semapore_during_migration.sql
@001_main_user_schema_sequence.sql
@020_db_config_tools.sql
@030_db_parameter.sql
@035_db_log_table_structure.sql
@100_cre_table_raw_cds2db_in.sql
@120_cre_table_raw_db_log.sql
@140_cre_table_typ_cds2db_in.sql
@150_get_last_processing_nr_typed.sql
@160_cre_table_typ_log.sql
@180_cre_view_raw_type_diff_log.sql
@190_cre_view_typ_dataproc_all.sql
@190_cre_view_typ_dataproc_last_import.sql
@200_take_over_check_date.sql
@210_cre_view_typ_cds2db_all.sql
@220_cre_view_raw_cds2db_last_import.sql
@230_cre_view_raw_cds2db_last_version.sql
@230_cre_view_raw_dataproc_last_version.sql
@230_cre_view_typ_cds2db_last_version.sql
@230_cre_view_typ_dataproc_last_version.sql
@250_adding_historical_raw_records.sql
@300_cds_in_to_db_log.sql
@310_cds_in_to_db_log.sql
@400_cre_table_typ_dataproc_in.sql
@420_cre_table_frontend_log.sql
@430_cre_table_frontend_log.sql
@440_cre_table_frontend_in.sql
@450_cre_table_frontend_in_trig.sql
@460_cre_view_fe_dataproc_last_import.sql
@470_cre_view_fe_dataproc_all.sql
@520_cre_view_fe_out.sql
@600_dp_in_to_db_log.sql
@620_fe_in_to_db_log.sql
@950_cro_job.sql
--@980_dev_and_test.sql
@999_start_semapore_after_migration.sql