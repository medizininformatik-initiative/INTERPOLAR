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
-- Noch Testen das keine Jobs laufen uns Semaphore auf Ready to connect steht
         UPDATE db_config.db_process_control SET pc_value='Interrupted_micration', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name='semaphor_cron_job_data_transfer'
      END IF;
   END IF;
END
$$;
