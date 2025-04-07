-- ###################### PARAMETER ############################
DO
$$
DECLARE
---------------------------------------------------------------------------------------
   -- >>>> WICHTIG Standort / Zeitabhängig <<<< -- Hier bitte Variablen setzen
   release_version VARCHAR := '2.10';               -- GitHup release version
   release_version_date VARCHAR := '2025-04-04';    -- GitHup release version date
   project_participants VARCHAR := 'IMISE Leipzig'; -- project participants to distinguish between different instances
   pause_after_process_execution VARCHAR := '10';   -- Pause after copy process execution in second [5-30 sec] - ready to connect
   data_import_hist_every_dataset VARCHAR := 'no';  -- Documentation of each individual data record (db_log.data_import_hist) in all the transfer functions [yes|no] - large resource requirements only for debugging
   max_process_time_set_ready VARCHAR := '120';     -- Maximum time that the semaphore may remain in use before it is released again in minutes [5-120]
   copy_fhir_metadata_from_raw_to_typed VARCHAR := 'N';-- Optionale Einstellung (Yes/No) ob die FHIR-Metadaten beim Kopiervorgang auch von RAW in die TYPED Tabellen übernommen werden soll.
---------------------------------------------------------------------------------------
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'release_version'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('release_version',release_version,'GitHup release version');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=release_version WHERE parameter_name='release_version';
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'release_version_date'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('release_version_date',release_version_date,'GitHup release version date');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=release_version_date WHERE parameter_name='release_version_date';
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'project_participants'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('project_participants',release_version_date,'project participants to distinguish between different instances');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=release_version_date WHERE parameter_name='project_participants';
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'database_initialization_time'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('database_initialization_time',to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS'),'Timestamp of database initialization');
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'last_migration_date'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('last_migration_date',to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS'),'last_migration_date');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS') WHERE parameter_name='last_migration_date';
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'pause_after_process_execution'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('pause_after_process_execution',pause_after_process_execution,'Pause after copy process execution in second [5-30 sec] - ready to connect');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=pause_after_process_execution WHERE parameter_name='pause_after_process_execution';
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'data_import_hist_every_dataset'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('data_import_hist_every_dataset',data_import_hist_every_dataset,'Documentation of each individual data record (db_log.data_import_hist) in all the transfer functions [yes|no] - large resource requirements only for debugging');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=data_import_hist_every_dataset WHERE parameter_name='data_import_hist_every_dataset';
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'max_process_time_set_ready'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('max_process_time_set_ready',max_process_time_set_ready,'Maximum time that the semaphore may remain in use before it is released again in minutes [5-120]');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=max_process_time_set_ready WHERE parameter_name='max_process_time_set_ready';
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_parameter WHERE pc_name = 'copy_fhir_metadata_from_raw_to_typed'
   ) THEN
      INSERT INTO db_config.db_parameter (parameter_name, parameter_value, parameter_description)
      VALUES ('copy_fhir_metadata_from_raw_to_typed',copy_fhir_metadata_from_raw_to_typed,'Optionale Einstellung (Yes/No) ob die FHIR-Metadaten beim Kopiervorgang auch von RAW in die TYPED Tabellen übernommen werden soll.');
   ELSE
      UPDATE db_config.db_parameter SET parameter_value=max_process_time_set_ready WHERE parameter_name='copy_fhir_metadata_from_raw_to_typed';
   END IF;
END
$$;
