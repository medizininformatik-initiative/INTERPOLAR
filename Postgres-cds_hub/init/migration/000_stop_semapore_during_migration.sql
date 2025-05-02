DO
$$
BEGIN
    -- Set semapore if exit --------------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'db_config'
          AND table_name = 'db_process_control'
          AND column_name = 'pc_name'
    ) THEN
        -- Erste Bedingung: pc_name existiert, also weiter prüfen
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'db_config'
              AND table_name = 'db_process_control'
              AND column_name = 'pc_value'
        ) THEN
            -- Zweite Bedingung: pc_value existiert, dann Update durchführen
            UPDATE db_config.db_process_control 
            SET pc_value='Interrupted_migration', last_change_timestamp=CURRENT_TIMESTAMP 
            WHERE pc_name='semaphor_cron_job_data_transfer';
        END IF; -- Ende der inneren IF-Bedingung
    END IF; -- Ende der äußeren IF-Bedingung
END
$$;

