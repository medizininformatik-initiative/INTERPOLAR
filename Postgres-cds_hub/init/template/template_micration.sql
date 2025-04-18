----------------------------------------------------------------------------
---- Wichtig !! - !! Erst Parameter an lokale Gegebenheiten anpassen !! ----
----   Important!! - !! First adjust parameters to local conditions!!   ----
-- Bitte Skript - 030_db_parameter.sql - öffnen und anpassen --
-- Please open and adjust the script - 030_db_parameter.sql --
----------------------------------------------------------------------------

\i 000_stop_semapore_during_migration.sql
\i 001_main_user_schema_sequence.sql
\i 020_db_config_tools.sql
\i 030_db_parameter.sql
\i 035_db_log_table_structure.sql
\i 100_cre_table_raw_cds2db_in.sql
\i 120_cre_table_raw_db_log.sql
\i 140_cre_table_typ_cds2db_in.sql
\i 150_get_last_processing_nr_typed.sql
\i 160_cre_table_typ_log.sql
\i 180_cre_view_raw_type_diff_log.sql
\i 190_cre_view_typ_dataproc_all.sql
\i 190_cre_view_typ_dataproc_last_import.sql
\i 200_take_over_check_date.sql
\i 210_cre_view_typ_cds2db_all.sql
\i 220_cre_view_raw_cds2db_last_import.sql
\i 230_cre_view_raw_cds2db_last_version.sql
\i 230_cre_view_raw_dataproc_last_version.sql
\i 230_cre_view_typ_cds2db_last_version.sql
\i 230_cre_view_typ_dataproc_last_version.sql
\i 250_adding_historical_raw_records.sql
\i 300_cds_in_to_db_log.sql
\i 310_cds_in_to_db_log.sql
\i 400_cre_table_typ_dataproc_in.sql
\i 420_cre_table_frontend_log.sql
\i 430_cre_table_frontend_log.sql
\i 440_cre_table_frontend_in.sql
\i 450_cre_table_frontend_in_trig.sql
\i 460_cre_view_fe_dataproc_last_import.sql
\i 470_cre_view_fe_dataproc_all.sql
\i 520_cre_view_fe_out.sql
\i 600_dp_in_to_db_log.sql
\i 620_fe_in_to_db_log.sql
\i 950_cro_job.sql
--\i 980_dev_and_test.sql
\i 999_start_semapore_after_migration.sql