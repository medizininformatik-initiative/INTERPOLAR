-- Übersicht der cron jobs
create or replace view db_config.v_cron_jobs as
select command, count(1) anzahl
,  (select to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status='succeeded') last_succeeded_run
,  (select to_char(min(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status='succeeded') first_succeeded_run
,  (select to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status!='succeeded') last_faild_run
from cron.job_run_details m group by command order by 3 desc;

GRANT SELECT ON db_config.v_cron_jobs TO db_user;

-- Cronjpob der immer um Mitternacht alle erfolgreichen cronjob-logs löscht, die älter als 3 Tage sind
SELECT cron.schedule('0 0 * * *', $$DELETE FROM cron.job_run_details 
WHERE status='succeeded' and end_time < now() - interval '7 days'$$);


-- Table "data_import_hist" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.data_import_hist (
  id serial,
  table_primary_key int, -- Primary key in the documentet table
  last_processing_nr int, -- Last processing number of the data in the table
  schema_name varchar,
  table_name varchar,
  function_name varchar, -- Name of function
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT NULL,  -- Processing status of the data record
  import_hist_cre_at timestamp DEFAULT timestamp -- Timestamp the HistRec wars create
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



