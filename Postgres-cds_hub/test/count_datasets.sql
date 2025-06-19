SELECT '0 select ''Schemaname . Tabellenname - Datensatzanzahl''' stmt union
SELECT 'union select '''||schemaname||'.'||relname||' - ''||count(1) from '||schemaname||'.'||relname stmt FROM pg_catalog.pg_statio_user_tables t
WHERE schemaname in ('cds2db_in','cds2db_out','cron','db','db2dataprocessor_in','db2dataprocessor_out','db2frontend_in','db2frontend_out','db_config','db_log','information_schema','pg_catalog','pg_toast')
ORDER BY 1
;
