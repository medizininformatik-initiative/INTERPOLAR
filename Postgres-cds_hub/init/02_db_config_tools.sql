-- Übersicht der cron jobs
create or replace view db_config.v_cron_jobs as
select command, count(1) anzahl
,  (select to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status='succeeded') last_succeeded_run
,  (select to_char(min(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status='succeeded') first_succeeded_run
,  (select to_char(max(s.end_time),'YYYY-MM-DD HH24:MI:SS') from cron.job_run_details s where s.command=m.command and s.status!='succeeded') last_faild_run
from cron.job_run_details m group by command order by 3 desc;

GRANT SELECT ON db_config.v_cron_jobs TO db_user;
