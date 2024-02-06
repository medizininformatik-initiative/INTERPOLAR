-- Create User
CREATE USER kds2db_user WITH PASSWORD 'kds2db' CONNECTION LIMIT 20;
CREATE USER db2frontend_user WITH PASSWORD 'db2frontend' CONNECTION LIMIT 20;
CREATE USER db2dataprocessor_user WITH PASSWORD 'db2dataprocessor' CONNECTION LIMIT 20;
CREATE USER db_user WITH PASSWORD 'db' CONNECTION LIMIT 20;
CREATE USER db_log_user WITH PASSWORD 'dblog' CONNECTION LIMIT 20;

-- Extension pg_cron 
-- Doku: https://github.com/citusdata/pg_cron
-- run as superuser:
CREATE EXTENSION pg_cron;

-- optionally, grant usage to regular users:
GRANT USAGE ON SCHEMA cron TO interpolar_admin;
