----------------------------------------------------------------------------
\i ./base/000_stop_semapore_during_run.sql
------------------------------------------------------
\i ./init/001_main_user_schema_sequence.sql
------------------------------------------------------
\i ./base/020_db_config_tools.sql
\i ./base/030_db_parameter.sql
\i ./base/031_cre_view_parameter_cds2db_out.sql
\i ./base/032_cre_view_parameter_dataproc_out.sql
\i ./base/033_cre_view_parameter_frontend_out.sql
\i ./base/035_db_log_table_structure.sql
\i ./base/100_cre_table_raw_cds2db_in.sql
\i ./base/120_cre_table_raw_db_log.sql
\i ./base/140_cre_table_typ_cds2db_in.sql
\i ./base/150_get_last_processing_nr_typed.sql
\i ./base/160_cre_table_typ_log.sql
\i ./base/180_cre_view_raw_type_diff_log.sql
\i ./base/190_cre_view_typ_dataproc_all.sql
\i ./base/190_cre_view_typ_dataproc_last_import.sql
\i ./base/200_take_over_check_date.sql
\i ./base/210_cre_view_typ_cds2db_all.sql
\i ./base/220_cre_view_raw_cds2db_last_import.sql
\i ./base/230_cre_view_raw_cds2db_last_version.sql
\i ./base/230_cre_view_raw_dataproc_last_version.sql
\i ./base/230_cre_view_typ_cds2db_last_version.sql
\i ./base/230_cre_view_typ_dataproc_last_version.sql
\i ./base/250_adding_historical_raw_records.sql
\i ./base/300_cds_in_to_db_log.sql
\i ./base/310_cds_in_to_db_log.sql
\i ./base/330_cre_table_dataproc_submodules_dataproc_in.sql
\i ./base/331_cre_table_dataproc_submodules_log.sql
\i ./base/332_db_submodules_dp_in_to_db_log.sql
\i ./base/334_cre_view_dataproc_submodules_last_import.sql
\i ./base/335_cre_view_dataproc_submodules_all.sql
\i ./base/340_cre_table_dataproc_core_dataproc_in.sql
\i ./base/341_cre_table_dataproc_core_log.sql
\i ./base/342_db_core_dp_in_to_db_log.sql
\i ./base/344_cre_view_dataproc_core_last_import.sql
\i ./base/345_cre_view_dataproc_core_all.sql
\i ./base/400_cre_table_typ_dataproc_in.sql
\i ./base/420_cre_table_frontend_log.sql
\i ./base/430_cre_table_frontend_log.sql
\i ./base/440_cre_table_frontend_in.sql
\i ./base/450_cre_table_frontend_in_trig.sql
\i ./base/460_cre_view_fe_dataproc_last_import.sql
\i ./base/461_cre_view_fe_dataproc_all.sql
\i ./base/462_cre_view_fe_dataproc_last_version.sql
\i ./base/470_cre_view_fe_frontend_last_import.sql
\i ./base/471_cre_view_fe_frontend_all.sql
\i ./base/472_cre_view_fe_frontend_last_version.sql
\i ./base/520_cre_view_fe_out.sql
\i ./base/600_dp_in_to_db_log.sql
\i ./base/620_fe_in_to_db_log.sql
\i ./base/950_cro_job.sql
\i ./base/recalculations/700_calculated_ref_create.sql
------------------------------------------------------
\i ./base/999_start_semapore_after_run.sql
----------------------------------------------------------------------------
