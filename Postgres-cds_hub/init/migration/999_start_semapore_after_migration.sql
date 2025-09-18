DO
$$
BEGIN
-- If the release version changes and migration have done, documentation of the release version
   IF EXISTS (
      SELECT 1 
      FROM (SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'release_version') a
          ,(SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'last_valid_release_version') b
          ,(SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'current_migration_flag') c
      WHERE a.parameter_value!=b.parameter_value AND c.parameter_value='1'
   ) THEN
      UPDATE db_config.db_parameter SET parameter_value = (SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'release_version_last_migration_start')
      WHERE parameter_name = 'release_version';

      UPDATE db_config.db_parameter SET parameter_value = (SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'release_version_last_migration_start')
      WHERE parameter_name = 'last_valid_release_version';

      UPDATE db_config.db_parameter SET parameter_value = (SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'release_version_date')
      WHERE parameter_name = 'last_valid_release_version_date';

      UPDATE db_config.db_parameter SET parameter_value = 
      (SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'release_version_date')||'-'||(SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'release_version')||' | '||parameter_value
      WHERE parameter_name = 'last_valid_release_version_log';

      UPDATE db_config.db_parameter SET parameter_value = (SELECT parameter_value FROM db_config.db_parameter WHERE parameter_name = 'release_version_nr_last_migration_start')
      WHERE parameter_name = 'release_version_nr';

      UPDATE db_config.db_parameter SET parameter_value=-1 WHERE parameter_name='current_migration_flag';
   END IF;


-- Set semapore if exit --------------------------------------------------------------------------
   IF EXISTS (
      SELECT 1 
      FROM information_schema.columns
      WHERE table_schema = 'db_config' 
        AND table_name = 'db_process_control' 
        AND column_name = 'pc_name'
   ) THEN
   IF EXISTS (
         SELECT 1 
         FROM information_schema.columns
         WHERE table_schema = 'db_config' 
           AND table_name = 'db_process_control' 
           AND column_name = 'pc_value'
      ) THEN
         UPDATE db_config.db_process_control SET pc_value='WaitForCronJob', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name='semaphor_cron_job_data_transfer' and pc_value!='WaitForCronJob';
      END IF;
   END IF;
   UPDATE db_config.db_parameter SET parameter_value=to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS') WHERE parameter_name='last_migration_date';
END
$$;
