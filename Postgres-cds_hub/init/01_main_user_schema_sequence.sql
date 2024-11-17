CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_background;

-- optionally, grant usage to regular users:
GRANT USAGE ON SCHEMA cron TO cds_hub_db_admin;

-- Create USER SQL
CREATE USER cds2db_user WITH PASSWORD 'cds2db' CONNECTION LIMIT 20;
CREATE USER db2frontend_user WITH PASSWORD 'db2frontend' CONNECTION LIMIT 20;
CREATE USER db2dataprocessor_user WITH PASSWORD 'db2dataprocessor' CONNECTION LIMIT 20;
CREATE USER db_user WITH PASSWORD 'db' CONNECTION LIMIT 20;
CREATE USER db_log_user WITH PASSWORD 'dblog' CONNECTION LIMIT 20;

-- Create Schema
CREATE SCHEMA db;
CREATE SCHEMA db_config;
CREATE SCHEMA db_log;
CREATE SCHEMA cds2db_in;
CREATE SCHEMA cds2db_out;
CREATE SCHEMA db2dataprocessor_out;
CREATE SCHEMA db2dataprocessor_in;
CREATE SCHEMA db2frontend_out;
CREATE SCHEMA db2frontend_in;

-- Create Sequenz
CREATE SEQUENCE IF NOT EXISTS db.db_seq INCREMENT 1 START 1; -- Using a central sequence

-- Create Comment on Schema
COMMENT ON SCHEMA db IS 'Schema to store all “core data” of the MRP-DB - MRP-DB Core';
COMMENT ON SCHEMA db_config IS 'Schema to store all configuration or organizational data - MRP-DB Config';
COMMENT ON SCHEMA db_log IS 'Schema to log all imported FHIR data and relevant MRP-DB data - MRP-DB login/backup';
COMMENT ON SCHEMA cds2db_in IS 'Interface schema for writing FHIR data to the MRP database - FHIR import interface';
COMMENT ON SCHEMA cds2db_out IS 'Interface schema to provide information for the import of FHIR data as a filter - FHIR import interface';
COMMENT ON SCHEMA db2dataprocessor_out IS 'Interface schema for providing data for calculations, e.g. with R - QA / harmonization / MRP calculation';
COMMENT ON SCHEMA db2dataprocessor_in IS 'Interface schema to transfer the results of the calculations to the database - QA / harmonization / MRP calculation';
COMMENT ON SCHEMA db2frontend_out IS 'Interface schema for frontend reading - FrontEnd';
COMMENT ON SCHEMA db2frontend_in IS 'Interface schema for frontend writing - FrontEnd';

-- Collected general database configurations / functionalities
-- db_user may also create/execute jobs - this may later remain with Admin
GRANT USAGE ON SCHEMA cron TO db_user;
