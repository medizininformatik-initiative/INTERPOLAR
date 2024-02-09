-- Extension pg_cron 
-- Doku: https://github.com/citusdata/pg_cron
-- run as superuser:
CREATE EXTENSION pg_cron;

-- optionally, grant usage to regular users:
GRANT USAGE ON SCHEMA cron TO interpolar_admin;
