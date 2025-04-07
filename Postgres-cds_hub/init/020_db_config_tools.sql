-- View "v_cron_jobs" in schema "db_config" - Übersicht der cron jobs
------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW db_config.v_cron_jobs AS
SELECT command, count(1) anzahl
,  (SELECT to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') FROM cron.job_run_details s WHERE command=m.command AND s.status='succeeded') last_succeeded_run
,  (SELECT to_char(min(s.end_time),'YYYY-MM-DD HH24:MI:SS') FROM cron.job_run_details s WHERE command=m.command AND s.status='succeeded') first_succeeded_run
,  (SELECT to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') FROM cron.job_run_details s WHERE command=m.command AND s.status!='succeeded') last_faild_run
FROM cron.job_run_details m group by command ORDER BY 3 desc;

GRANT SELECT ON db_config.v_cron_jobs TO db_user;

-- Cronjpob der immer um Mitternacht alle erfolgreichen cronjob-logs löscht, die älter als 2 Tage sind
------------------------------------------------------------------------------------------------
-- Cron-Job nur anlegen, wenn er noch nicht existiert
DO
$$
DECLARE
   erg VARCHAR;
BEGIN
   IF EXISTS (
      SELECT 1 FROM cron.job
      WHERE command = 'DELETE FROM cron.job_run_details WHERE status=''succeeded'' AND end_time < now() - interval ''2 days'''
      LIMIT 1
        ) THEN

      SELECT res FROM public.pg_background_result(public.pg_background_launch(
         'SELECT cron.schedule(''0 0 * * *'', 'DELETE FROM cron.job_run_details WHERE status=''succeeded'' AND end_time < now() - interval ''2 days''');'
    ) ) AS t(res TEXT) INTO erg;
   END IF;
END
$$;

-- Table "db_parameter" in schema "db_config" - Parameter für Ablauf in der Datenbank
------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_parameter (
  id SERIAL,
  parameter_name VARCHAR UNIQUE,
  parameter_value VARCHAR,
  parameter_description VARCHAR,
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

-- Index idx_db_config_db_parameter_name for Table "db_parameter" in schema "db_config"
------------------------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_config_db_parameter_name
ON db_config.db_parameter (   parameter_name );

GRANT INSERT ON db_config.db_parameter TO db_user;
GRANT SELECT ON db_config.db_parameter TO db_user;
GRANT UPDATE ON db_config.db_parameter TO db_user;

-- Table "db_process_control" in schema "db_config" - Tabele für Semaphore und Fortschrittskennzahlen
------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_process_control (
  id SERIAL,
  pc_name VARCHAR UNIQUE,
  pc_value VARCHAR,
  pc_description VARCHAR,
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

-- Index idx_db_config_db_db_process_control_name for Table "db_process_control" in schema "db_config"
------------------------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_config_db_db_process_control_name
ON db_config.db_process_control (   pc_name );

GRANT INSERT ON db_config.db_process_control TO db_user;
GRANT SELECT ON db_config.db_process_control TO db_user;
GRANT UPDATE ON db_config.db_process_control TO db_user;
GRANT SELECT ON db_config.db_process_control TO cds2db_user;
GRANT SELECT ON db_config.db_process_control TO db2frontend_user;
GRANT SELECT ON db_config.db_process_control TO db2dataprocessor_user;
GRANT SELECT ON db_config.db_process_control TO db_log_user;

-- initialiesieren der notwendigen values
------------------------------------------------------------------------------------------------
DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'semaphor_cron_job_data_transfer'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('semaphor_cron_job_data_transfer','WaitForCronJob','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / Interrupted');
   END IF;

   -- Normal Status are: WaitForCronJo--> Ongoing --> ReadyToConnect --> WaitForCronJob 
   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'timepoint_1_cron_job_data_transfer'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('timepoint_1_cron_job_data_transfer','none','start time that needs to be remembered (last time copy function started) Format: YYYY-MM-DD HH24:MI:SS.US');
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'timepoint_2_cron_job_data_transfer'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('timepoint_2_cron_job_data_transfer','none','start time that needs to be remembered (last time copy function / table started) Format: YYYY-MM-DD HH24:MI:SS.US');
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'timepoint_3_cron_job_data_transfer'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('timepoint_3_cron_job_data_transfer','none','start time that needs to be remembered Format: YYYY-MM-DD HH24:MI:SS.US');
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'waitpoint_cron_job_data_transfer'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('waitpoint_cron_job_data_transfer','none','start time that needs to be remembered Format: YYYY-MM-DD HH24:MI:SS.US');
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'current_executed_function'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('current_executed_function','','current executed function (db.data_transfer_status)');
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'current_total_number_of_records_in_the_function'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('current_total_number_of_records_in_the_function','','current total number of records in the function (db.data_transfer_status)');
   END IF;

   IF NOT EXISTS (
      SELECT 1 FROM db_config.db_process_control WHERE pc_name = 'currently_processed_number_of_data_records_in_the_function'
   ) THEN
      INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
      VALUES ('currently_processed_number_of_data_records_in_the_function','','currently processed number of data records in the function (db.data_transfer_status)');
   END IF;
END
$$;

-- Table "data_import_hist" in schema "db"
------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db.data_import_hist (
  id SERIAL,
  table_primary_key INT, -- Primary key in the documentet table
  last_processing_nr INT, -- Last processing number of the data in the table
  schema_name VARCHAR, -- Schema
  table_name VARCHAR, -- Table
  function_name VARCHAR, -- Name of function
  variable_name VARCHAR, -- Variable name of the different calculations
  dataset_count INT, -- count of datasets in this session
  copy_time_in_sec DOUBLE PRECISION, -- time to process in second
  last_check_datetime TIMESTAMP DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT NULL,  -- Processing status of the data record
  import_hist_cre_at TIMESTAMP DEFAULT current_timestamp -- Timestamp the HistRec wars create
);

-- Index idx_db_data_import_hist_last_processing_nr for Table "data_import_hist" in schema "db"
------------------------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_data_import_hist_last_processing_nr
ON db.data_import_hist (   last_processing_nr );

-- Index idx_db_data_import_hist_schema_name for Table "data_import_hist" in schema "db"
------------------------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_data_import_hist_schema_name
ON db.data_import_hist (   schema_name );

-- Index idx_db_data_import_hist_table_name for Table "data_import_hist" in schema "db"
------------------------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_data_import_hist_table_name
ON db.data_import_hist (   table_name );

-- Index idx_db_data_import_hist_function_name for Table "data_import_hist" in schema "db"
------------------------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_data_import_hist_function_name
ON db.data_import_hist (   function_name );

-- Index idx_db_data_import_hist_variable_name for Table "data_import_hist" in schema "db"
------------------------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_data_import_hist_variable_name
ON db.data_import_hist (   variable_name );

GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db_log TO cds2db_user;
GRANT USAGE ON SCHEMA db_log TO db2frontend_user;

GRANT INSERT, SELECT ON TABLE db.data_import_hist TO db_log_user;
GRANT INSERT, SELECT ON TABLE db.data_import_hist TO db_user;
GRANT INSERT, SELECT ON TABLE db.data_import_hist TO cds2db_user;
GRANT INSERT, SELECT ON TABLE db.data_import_hist TO db2dataprocessor_user;
GRANT INSERT, SELECT ON TABLE db.data_import_hist TO db2frontend_user;

-- View "data_count_report" in "db_config"
------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW db_config.v_data_count_report AS
SELECT a.*, b.dataset_count_new_ds, b.new_ds_per_sec
FROM
(SELECT to_char(import_hist_cre_at,'YYYY-MM-DD') day_sum, function_name
, CASE
    WHEN function_name = 'copy_raw_cds_in_to_db_log' THEN 'CDS2DB_IN (RAW) -> DB_LOG'
    WHEN function_name = 'copy_type_cds_in_to_db_log' THEN 'CDS2DB_IN (Typed) -> DB_LOG'
    WHEN function_name = 'copy_fe_dp_in_to_db_log' THEN 'DP (Typed) -> DB_LOG-Frontend'
    WHEN function_name = 'copy_fe_fe_in_to_db_log' THEN 'DB_LOG-Frontend -> DB_LOG'
    WHEN function_name = 'take_over_last_check_date' THEN 'DB_LOG (internal) - Synchronization of the last imported data sets'
    ELSE 'NichtDefinierteFunktion'
END dataflow
, sum(dataset_count) dataset_count_all_ds, round(sum(copy_time_in_sec)) copy_time_in_sec
, round(sum(dataset_count)/sum(copy_time_in_sec)) all_ds_per_sec FROM db.data_import_hist a
where variable_name='data_count_pro_all' group by function_name, to_char(import_hist_cre_at,'YYYY-MM-DD')
) a
left join (SELECT to_char(import_hist_cre_at,'YYYY-MM-DD') day_sum, function_name, sum(dataset_count) dataset_count_new_ds, round(sum(copy_time_in_sec)) copy_time_in_sec
, round(sum(dataset_count)/sum(copy_time_in_sec)) new_ds_per_sec FROM db.data_import_hist a
where variable_name='data_count_pro_new' group by function_name, to_char(import_hist_cre_at,'YYYY-MM-DD')
) b on (a.day_sum=b.day_sum AND a.function_name=b.function_name)
ORDER BY day_sum DESC, function_name
;

GRANT SELECT ON db_config.v_data_count_report TO db_user;

-- Table "db_error_log" in schema "db_config" - Dokumentation bei Auftretenden Fehlern in der Datenbank
------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_error_log (
  id SERIAL,
  err_schema VARCHAR, -- Schema in which the error occurred
  err_objekt VARCHAR, -- Table or function or other object WHEREthe error occurred
  err_user VARCHAR, -- User
  err_msg VARCHAR, -- Error message
  err_line VARCHAR, -- Optionally the code line/section
  err_variables VARCHAR, -- Optional variables for troubleshooting
  last_processing_nr INT, -- Optional last_processing_nr
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP   -- Time at which the error record is inserted
);

GRANT INSERT ON db_config.db_error_log TO db_user;
GRANT SELECT ON db_config.db_error_log TO db_user;
GRANT UPDATE ON db_config.db_error_log TO db_user;

-- View "v_db_error_log" in "db_config"
------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW db_config.v_db_error_log AS
SELECT input_datetime, id, err_schema, err_objekt, err_line, err_msg, err_variables, err_user, last_processing_nr FROM db_config.db_error_log
ORDER BY input_datetime desc, id desc;

GRANT SELECT ON db_config.v_db_error_log TO db_user;

-- Funktion zur Dokumentation von Fehlern
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.error_log(
  err_schema VARCHAR DEFAULT current_schema, -- Schema in which the error occurred
  err_objekt VARCHAR DEFAULT NULL, -- Table or function or other object WHEREthe error occurred
  err_user VARCHAR DEFAULT current_user, -- User
  err_msg VARCHAR DEFAULT 'n.a.', -- Error message
  err_line VARCHAR DEFAULT '', -- Optionally the code line/section
  err_variables VARCHAR DEFAULT '', -- Optional variables for troubleshooting
  last_processing_nr int DEFAULT NULL -- Optional last_processing_nr
)
RETURNS VOID
SECURITY DEFINER
AS $$
DECLARE
    erg TEXT;
BEGIN
    -- direct writing in a sub process
    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'INSERT INTO db_config.db_error_log (err_schema,err_objekt,err_user,err_msg,err_line,err_variables,last_processing_nr) VALUES ('''||err_schema||''', '''||err_objekt||''', '''||err_user||''', '''||err_msg||''', '''||err_line||''', '''||err_variables||''','||COALESCE(last_processing_nr,'NULL')||')'
    ) ) AS t(res TEXT) INTO erg;
EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            -- write error with commit of the main process
            INSERT INTO db_config.db_error_log (err_schema, err_objekt, err_user, err_msg, err_line, err_variables, last_processing_nr)
            VALUES (err_schema, err_objekt, err_user, err_msg, err_line, err_variables, last_processing_nr);
        EXCEPTION
            WHEN OTHERS THEN
                -- Dokumentieren das beim schreiben des Fehlers ein Fehler entstanden ist
                INSERT INTO db_config.db_error_log (err_schema, err_objekt, err_msg)
                VALUES ('Fehler bei Fehler schreiben', CAST('db.error_log' AS  VARCHAR), CAST(SQLSTATE||' - '||SQLERRM AS VARCHAR));
        END;
END;
$$ LANGUAGE plpgsql; --db.error_log

GRANT EXECUTE ON FUNCTION db.error_log(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,INT) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.error_log(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,INT) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.error_log(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,INT) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.error_log(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,INT) TO db_user;

-- Funktionen zur einheitlichen Darstellung als String
-- 1. immutable overloaded function for TEXT / VARCHAR / CHAR
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data TEXT)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT input_data;
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(TEXT) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TEXT) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TEXT) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TEXT) TO db_user;

-- 2. immutable overloaded function for SMALLINT / INTEGER / BIGINT
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data BIGINT)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT input_data;
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(BIGINT) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BIGINT) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BIGINT) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BIGINT) TO db_user;

-- 3. immutable overloaded function for REAL / FLOAT4 / DOUBLE PRECISION
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data DOUBLE PRECISION)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT input_data;
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(DOUBLE PRECISION) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(DOUBLE PRECISION) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(DOUBLE PRECISION) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(DOUBLE PRECISION) TO db_user;

-- 4. immutable overloaded function for NUMERIC / DECIMAL
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data NUMERIC)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT to_char(input_data, 'FM999999999999990.999999');
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(NUMERIC) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(NUMERIC) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(NUMERIC) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(NUMERIC) TO db_user;

-- 5. immutable overloaded function for DATE / TIMESTAMP - !!! NOT TIMESTAMPTZ !!!
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data TIMESTAMP)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT to_char(input_data, 'YYYY-MM-DD HH24:MI:SS.US');
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIMESTAMP) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIMESTAMP) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIMESTAMP) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIMESTAMP) TO db_user;

-- 6. immutable overloaded function for TIME - !!! NOT TIMETZ !!!
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data TIME)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT to_char(input_data, 'HH24:MI:SS.US');
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIME) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIME) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIME) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(TIME) TO db_user;

-- 7. immutable overloaded function for BOOLEAN (TRUE, FALSE, NULL)
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data BOOLEAN)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT CASE WHEN input_data THEN 'true' WHEN NOT input_data THEN 'false' ELSE 'null' END;
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(BOOLEAN) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BOOLEAN) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BOOLEAN) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BOOLEAN) TO db_user;

-- 8. immutable overloaded function for BYTEA (Binärdaten)
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data BYTEA)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT encode(input_data, 'hex');
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(BYTEA) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BYTEA) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BYTEA) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(BYTEA) TO db_user;

-- 9. immutable overloaded function for UUID (Universally Unique Identifier)
------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.to_char_immutable(input_data UUID)
RETURNS TEXT
SECURITY DEFINER
AS $$
  SELECT input_data::TEXT;
$$ LANGUAGE SQL IMMUTABLE;

GRANT EXECUTE ON FUNCTION db.to_char_immutable(UUID) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(UUID) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(UUID) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.to_char_immutable(UUID) TO db_user;
