-- View "v_cron_jobs" in schema "db_config" - Übersicht der cron jobs
----------------------------------------------------
CREATE OR REPLACE VIEW db_config.v_cron_jobs AS
SELECT command, count(1) anzahl
,  (SELECT to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') FROM cron.job_run_details s WHERE command=m.command AND s.status='succeeded') last_succeeded_run
,  (SELECT to_char(min(s.end_time),'YYYY-MM-DD HH24:MI:SS') FROM cron.job_run_details s WHERE command=m.command AND s.status='succeeded') first_succeeded_run
,  (SELECT to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') FROM cron.job_run_details s WHERE command=m.command AND s.status!='succeeded') last_faild_run
FROM cron.job_run_details m group by command ORDER BY 3 desc;

GRANT SELECT ON db_config.v_cron_jobs TO db_user;

-- Cronjpob der immer um Mitternacht alle erfolgreichen cronjob-logs löscht, die älter als 2 Tage sind
SELECT cron.schedule('0 0 * * *', $$DELETE FROM cron.job_run_details 
WHERE status='succeeded' AND end_time < now() - interval '2 days'$$);

-- Table "db_parameter" in schema "db_config" - Parameter für Ablauf in der Datenbank
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_parameter (
  id SERIAL,
  parameter_name VARCHAR UNIQUE,
  parameter_value VARCHAR,
  parameter_description VARCHAR,
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

GRANT INSERT ON db_config.db_parameter TO db_user;
GRANT SELECT ON db_config.db_parameter TO db_user;
GRANT UPDATE ON db_config.db_parameter TO db_user;

-- Table "db_process_control" in schema "db_config" - Tabele für Semaphore und Fortschrittskennzahlen
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_process_control (
  id SERIAL,
  pc_name VARCHAR UNIQUE,
  pc_value VARCHAR,
  pc_description VARCHAR,
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

GRANT INSERT ON db_config.db_process_control TO db_user;
GRANT SELECT ON db_config.db_process_control TO db_user;
GRANT UPDATE ON db_config.db_process_control TO db_user;
GRANT SELECT ON db_config.db_process_control TO cds2db_user;
GRANT SELECT ON db_config.db_process_control TO db2frontend_user;
GRANT SELECT ON db_config.db_process_control TO db2dataprocessor_user;
GRANT SELECT ON db_config.db_process_control TO db_log_user;

-- initialiesieren der notwendigen values
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','WaitForCronJob','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / Interrupted');
-- Normal Status are: WaitForCronJo--> Ongoing --> ReadyToConnect --> WaitForCronJob 
INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
VALUES ('timepoint_1_cron_job_data_transfer','none','start time that needs to be remembered (last time copy function started) Format: YYYY-MM-DD HH24:MI:SS.US');
INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
VALUES ('timepoint_2_cron_job_data_transfer','none','start time that needs to be remembered (last time copy function / table started) Format: YYYY-MM-DD HH24:MI:SS.US');
INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
VALUES ('timepoint_3_cron_job_data_transfer','none','start time that needs to be remembered Format: YYYY-MM-DD HH24:MI:SS.US');
INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
VALUES ('waitpoint_cron_job_data_transfer','none','start time that needs to be remembered Format: YYYY-MM-DD HH24:MI:SS.US');
INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
VALUES ('current_executed_function','','current executed function (db.data_transfer_status)');
INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
VALUES ('current_total_number_of_records_in_the_function','','current total number of records in the function (db.data_transfer_status)');
INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
VALUES ('currently_processed_number_of_data_records_in_the_function','','currently processed number of data records in the function (db.data_transfer_status)');


-- Table "data_import_hist" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.data_import_hist (
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

GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db_log TO cds2db_user;
GRANT USAGE ON SCHEMA db_log TO db2frontend_user;

GRANT INSERT, SELECT ON TABLE db_log.data_import_hist TO db_log_user;
GRANT INSERT, SELECT ON TABLE db_log.data_import_hist TO db_user;
GRANT INSERT, SELECT ON TABLE db_log.data_import_hist TO cds2db_user;
GRANT INSERT, SELECT ON TABLE db_log.data_import_hist TO db2dataprocessor_user;
GRANT INSERT, SELECT ON TABLE db_log.data_import_hist TO db2frontend_user;

-- View "data_count_report" in "db_config"
----------------------------------------------------
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
, round(sum(dataset_count)/sum(copy_time_in_sec)) all_ds_per_sec FROM db_log.data_import_hist a
where variable_name='data_count_pro_all' group by function_name, to_char(import_hist_cre_at,'YYYY-MM-DD')
) a
left join (SELECT to_char(import_hist_cre_at,'YYYY-MM-DD') day_sum, function_name, sum(dataset_count) dataset_count_new_ds, round(sum(copy_time_in_sec)) copy_time_in_sec
, round(sum(dataset_count)/sum(copy_time_in_sec)) new_ds_per_sec FROM db_log.data_import_hist a
where variable_name='data_count_pro_new' group by function_name, to_char(import_hist_cre_at,'YYYY-MM-DD')
) b on (a.day_sum=b.day_sum AND a.function_name=b.function_name)
ORDER BY day_sum DESC, function_name
;

GRANT SELECT ON db_config.v_data_count_report TO db_user;

-- Table "db_error_log" in schema "db_config" - Dokumentation bei Auftretenden Fehlern in der Datenbank
----------------------------------------------------
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
----------------------------------------------------
CREATE OR REPLACE VIEW db_config.v_db_error_log AS
SELECT input_datetime, id, err_schema, err_objekt, err_line, err_msg, err_variables, err_user, last_processing_nr FROM db_config.db_error_log
ORDER BY input_datetime desc, id desc;

GRANT SELECT ON db_config.v_db_error_log TO db_user;

-- Funktion zur Dokumentation von Fehlern
----------------------------------------------------
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

-- mutable md5 hash function
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.mutable_md5(input TEXT)
RETURNS TEXT
SECURITY DEFINER
AS $$
BEGIN
  RETURN md5(input);
END;
$$ LANGUAGE plpgsql VOLATILE;

GRANT EXECUTE ON FUNCTION db.mutable_md5(TEXT) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.mutable_md5(TEXT) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.mutable_md5(TEXT) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.mutable_md5(TEXT) TO db_user;
