-- Extensions installieren -----------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_background;

-- optionally, grant usage to regular users ------------------------------------------------------
GRANT USAGE ON SCHEMA cron TO cds_hub_db_admin;


DO
$$
BEGIN
-- Create USER SQL -------------------------------------------------------------------------------
   -- cds2db_user
   IF NOT EXISTS (
      SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = 'cds2db_user'
   ) THEN
      CREATE USER cds2db_user WITH PASSWORD 'cds2db' CONNECTION LIMIT 20; -- <-- lokales Passort angeben !!!
   END IF;

   -- db2frontend_user
   IF NOT EXISTS (
      SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = 'db2frontend_user'
   ) THEN
      CREATE USER db2frontend_user WITH PASSWORD 'db2frontend' CONNECTION LIMIT 20; -- <-- lokales Passort angeben !!!
   END IF;

   -- db2dataprocessor_user
   IF NOT EXISTS (
      SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = 'db2dataprocessor_user'
   ) THEN
      CREATE USER db2dataprocessor_user WITH PASSWORD 'db2dataprocessor' CONNECTION LIMIT 20; -- <-- lokales Passort angeben !!!
   END IF;

   -- db_user
   IF NOT EXISTS (
      SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = 'db_user'
   ) THEN
      CREATE USER db_user WITH PASSWORD 'db' CONNECTION LIMIT 20; -- <-- lokales Passort angeben !!!
   END IF;

   -- db_log_user
   IF NOT EXISTS (
      SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = 'db_log_user'
   ) THEN
      CREATE USER db_log_user WITH PASSWORD 'dblog' CONNECTION LIMIT 20; -- <-- lokales Passort angeben !!!
   END IF;

-- Create Schema ---------------------------------------------------------------------------------
   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'db'
   ) THEN
      EXECUTE 'CREATE SCHEMA db';
   END IF;
   COMMENT ON SCHEMA db IS 'Schema to store all “core data” of the MRP-DB - MRP-DB Core';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'db_config'
   ) THEN
      EXECUTE 'CREATE SCHEMA db_config';
   END IF;
   COMMENT ON SCHEMA db_config IS 'Schema to store all configuration or organizational data - MRP-DB Config';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'db_log'
   ) THEN
      EXECUTE 'CREATE SCHEMA db_log';
   END IF;
   COMMENT ON SCHEMA db_log IS 'Schema to log all imported FHIR data and relevant MRP-DB data - MRP-DB login/backup';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cds2db_in'
   ) THEN
      EXECUTE 'CREATE SCHEMA cds2db_in';
   END IF;
   COMMENT ON SCHEMA cds2db_in IS 'Interface schema for writing FHIR data to the MRP database - FHIR import interface';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'cds2db_out'
   ) THEN
      EXECUTE 'CREATE SCHEMA cds2db_out';
   END IF;
   COMMENT ON SCHEMA cds2db_out IS 'Interface schema to provide information for the import of FHIR data as a filter - FHIR import interface';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'db2dataprocessor_out'
   ) THEN
      EXECUTE 'CREATE SCHEMA db2dataprocessor_out';
   END IF;
   COMMENT ON SCHEMA db2dataprocessor_out IS 'Interface schema for providing data for calculations, e.g. with R - QA / harmonization / MRP calculation';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'db2dataprocessor_in'
   ) THEN
      EXECUTE 'CREATE SCHEMA db2dataprocessor_in';
   END IF;
   COMMENT ON SCHEMA db2dataprocessor_in IS 'Interface schema to transfer the results of the calculations to the database - QA / harmonization / MRP calculation';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'db2frontend_out'
   ) THEN
      EXECUTE 'CREATE SCHEMA db2frontend_out';
   END IF;
   COMMENT ON SCHEMA db2frontend_out IS 'Interface schema for frontend reading - FrontEnd';

   IF NOT EXISTS (
      SELECT 1 FROM information_schema.schemata WHERE schema_name = 'db2frontend_in'
   ) THEN
      EXECUTE 'CREATE SCHEMA db2frontend_in';
   END IF;
   COMMENT ON SCHEMA db2frontend_in IS 'Interface schema for frontend writing - FrontEnd';
END
$$;

-- Create Sequenz --------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS db.db_seq INCREMENT 1 START 1; -- Using a central sequence

-- Collected general database configurations / functionalities -----------------------------------
-- db_user may also create/execute jobs - this may later remain with Admin
GRANT USAGE ON SCHEMA cron TO db_user;

-- Schemazugriff für User um auf Funktionen zugreifen zu können - noch nicht die Berechtigung der einzelnen Funktionen
GRANT USAGE ON SCHEMA db TO cds2db_user;
GRANT USAGE ON SCHEMA db TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db TO db2frontend_user;
GRANT USAGE ON SCHEMA db TO db_user;
