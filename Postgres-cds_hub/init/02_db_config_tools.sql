-- View "v_cron_jobs" in schema "db_config" - Übersicht der cron jobs
----------------------------------------------------
CREATE OR REPLACE VIEW db_config.v_cron_jobs as
select command, count(1) anzahl
,  (select to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status='succeeded') last_succeeded_run
,  (select to_char(min(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status='succeeded') first_succeeded_run
,  (select to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status!='succeeded') last_faild_run
from cron.job_run_details m group by command order by 3 desc;

GRANT SELECT ON db_config.v_cron_jobs TO db_user;

-- Cronjpob der immer um Mitternacht alle erfolgreichen cronjob-logs löscht, die älter als 2 Tage sind
SELECT cron.schedule('0 0 * * *', $$DELETE FROM cron.job_run_details 
WHERE status='succeeded' and end_time < now() - interval '2 days'$$);

-- Table "db_parameter" in schema "db_config" - Parameter für Ablauf in der Datenbank
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_parameter (
  id serial,
  parameter_name varchar unique,
  parameter_value varchar,
  parameter_description varchar,
  input_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp timestamp DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

GRANT INSERT ON db_config.db_parameter TO db_user;
GRANT SELECT ON db_config.db_parameter TO db_user;
GRANT UPDATE ON db_config.db_parameter TO db_user;

-- Table "db_process_control" in schema "db_config" - Tabele für Semaphore und Fortschrittskennzahlen
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_process_control (
  id serial,
  pc_name varchar unique,
  pc_value varchar,
  pc_description varchar,
  input_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp timestamp DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

GRANT INSERT ON db_config.db_process_control TO db_user;
GRANT SELECT ON db_config.db_process_control TO db_user;
GRANT UPDATE ON db_config.db_process_control TO db_user;
GRANT SELECT ON db_config.db_process_control TO cds2db_user;
GRANT SELECT ON db_config.db_process_control TO db2frontend_user;
GRANT SELECT ON db_config.db_process_control TO db2dataprocessor_user;
GRANT SELECT ON db_config.db_process_control TO db_log_user;

-- initialiesieren der notwendigen values
insert into db_config.db_process_control (pc_name, pc_value, pc_description)
values ('semaphor_cron_job_data_transfer','ready','semaphore to control the cron_job_data_transfer job, contains the current processing status - ongoing / pause / ready / interrupted'); -- Normal Status are: ready --> ongoing --> pause --> ready

insert into db_config.db_process_control (pc_name, pc_value, pc_description)
values ('timepoint_1_cron_job_data_transfer','none','start time that needs to be remembered (last time copy function started) Format: YYYY-MM-DD HH24:MI:SS.US');

insert into db_config.db_process_control (pc_name, pc_value, pc_description)
values ('timepoint_2_cron_job_data_transfer','none','start time that needs to be remembered (last time copy function / table started) Format: YYYY-MM-DD HH24:MI:SS.US');

insert into db_config.db_process_control (pc_name, pc_value, pc_description)
values ('timepoint_3_cron_job_data_transfer','none','start time that needs to be remembered Format: YYYY-MM-DD HH24:MI:SS.US');

-- Table "data_import_hist" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.data_import_hist (
  id serial,
  table_primary_key int, -- Primary key in the documentet table
  last_processing_nr int, -- Last processing number of the data in the table
  schema_name varchar, -- Schema
  table_name varchar, -- Table
  function_name varchar, -- Name of function
  variable_name varchar, -- Variable name of the different calculations
  dataset_count int, -- count of datasets in this session
  copy_time_in_sec double precision, -- time to process in second
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT NULL,  -- Processing status of the data record
  import_hist_cre_at timestamp DEFAULT current_timestamp -- Timestamp the HistRec wars create
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
CREATE OR REPLACE VIEW db_config.v_data_count_report as
select a.*, b.dataset_count_new_ds, b.new_ds_per_sec
from
(select to_char(import_hist_cre_at,'YYYY-MM-DD') day_sum, function_name
, CASE
    WHEN function_name = 'copy_raw_cds_in_to_db_log' THEN 'CDS2DB_IN (RAW) -> DB_LOG'
    WHEN function_name = 'copy_type_cds_in_to_db_log' THEN 'CDS2DB_IN (Typed) -> DB_LOG'
    WHEN function_name = 'copy_fe_dp_in_to_db_log' THEN 'DP (Typed) -> DB_LOG-Frontend'
    WHEN function_name = 'copy_fe_fe_in_to_db_log' THEN 'DB_LOG-Frontend -> DB_LOG'
    ELSE 'NichtDefinierteFunktion'
END dataflow
, sum(dataset_count) dataset_count_all_ds, round(sum(copy_time_in_sec)) copy_time_in_sec
, round(sum(dataset_count)/sum(copy_time_in_sec)) all_ds_per_sec from db_log.data_import_hist a
where variable_name='data_count_pro_all' group by function_name, to_char(import_hist_cre_at,'YYYY-MM-DD')
) a
left join (select to_char(import_hist_cre_at,'YYYY-MM-DD') day_sum, function_name, sum(dataset_count) dataset_count_new_ds, round(sum(copy_time_in_sec)) copy_time_in_sec
, round(sum(dataset_count)/sum(copy_time_in_sec)) new_ds_per_sec from db_log.data_import_hist a
where variable_name='data_count_pro_new' group by function_name, to_char(import_hist_cre_at,'YYYY-MM-DD')
) b on (a.day_sum=b.day_sum and a.function_name=b.function_name)
;

GRANT SELECT ON db_config.v_data_count_report TO db_user;

-- Table "db_error_log" in schema "db_config" - Dokumentation bei Auftretenden Fehlern in der Datenbank
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.db_error_log (
  id serial,
  err_schema varchar, -- Schema in which the error occurred
  err_objekt varchar, -- Table or function or other object where the error occurred
  err_user varchar, -- User
  err_msg varchar, -- Error message
  err_line varchar, -- Optionally the code line/section
  err_variables varchar, -- Optional variables for troubleshooting
  last_processing_nr int, -- Optional last_processing_nr
  input_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP   -- Time at which the error record is inserted
);

GRANT INSERT ON db_config.db_error_log TO db_user;
GRANT SELECT ON db_config.db_error_log TO db_user;
GRANT UPDATE ON db_config.db_error_log TO db_user;

-- View "v_db_error_log" in "db_config"
----------------------------------------------------
CREATE OR REPLACE VIEW db_config.v_db_error_log as
select input_datetime, id, err_schema, err_objekt, err_line, err_msg, err_variables, err_user from db_config.db_error_log
order by input_datetime desc, id desc;

GRANT SELECT ON db_config.v_db_error_log TO db_user;

-- Funktion zur Dokumentation von Fehlern
----------------------------------------------------
CREATE OR REPLACE FUNCTION db.error_log(
  err_schema varchar DEFAULT current_schema, -- Schema in which the error occurred
  err_objekt varchar DEFAULT NULL, -- Table or function or other object where the error occurred
  err_user varchar DEFAULT current_user, -- User
  err_msg varchar DEFAULT 'n.a.', -- Error message
  err_line varchar DEFAULT '', -- Optionally the code line/section
  err_variables varchar DEFAULT '', -- Optional variables for troubleshooting
  last_processing_nr int DEFAULT NULL -- Optional last_processing_nr
)
RETURNS VOID
SECURITY DEFINER
AS $$
BEGIN
    PERFORM pg_background_launch('INSERT INTO db_config.db_error_log (err_schema, err_objekt, err_user, err_msg, err_line, err_variables, last_processing_nr)
    VALUES ('''||err_schema||''','''||err_objekt||''','''||err_user||''','''||err_msg||''','''||err_line||''','''||err_variables||''','||last_processing_nr||')');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO db_config.db_error_log (err_schema, err_objekt, err_user, err_msg, err_line, err_variables, last_processing_nr)
        VALUES (err_schema, err_objekt, err_user, err_msg, err_line, err_variables, last_processing_nr);
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.error_log(varchar,varchar,varchar,varchar,varchar,varchar,int) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.error_log(varchar,varchar,varchar,varchar,varchar,varchar,int) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.error_log(varchar,varchar,varchar,varchar,varchar,varchar,int) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.error_log(varchar,varchar,varchar,varchar,varchar,varchar,int) TO db_user;
