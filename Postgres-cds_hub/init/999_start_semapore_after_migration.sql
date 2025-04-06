DO
$$
BEGIN
-- Set semapore if exit --------------------------------------------------------------------------
   IF EXISTS (
      SELECT 1 
      FROM pg_catalog.pg_columns 
      WHERE table_schema = 'db_config' 
        AND table_name = 'db_process_control' 
        AND column_name = 'pc_name'
   ) THEN
   IF EXISTS (
         SELECT 1 
         FROM pg_catalog.pg_columns 
         WHERE table_schema = 'db_config' 
           AND table_name = 'db_process_control' 
           AND column_name = 'pc_value'
      ) THEN
         UPDATE db_config.db_process_control SET pc_value='WaitForCronJob', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name='semaphor_cron_job_data_transfer' and pc_value!='WaitForCronJob';
      END IF;
   END IF;
END
$$;
