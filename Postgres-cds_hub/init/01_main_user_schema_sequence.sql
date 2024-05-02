CREATE EXTENSION pg_cron;

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
CREATE SCHEMA db_konfig;
CREATE SCHEMA db_log;
CREATE SCHEMA cds2db_in;
CREATE SCHEMA cds2db_out;
CREATE SCHEMA db2dataprocessor_out;
CREATE SCHEMA db2dataprocessor_in;
CREATE SCHEMA db2frontend_out;
CREATE SCHEMA db2frontend_in;

-- Create Sequenz
CREATE SEQUENCE IF NOT EXISTS db.db_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db_konfig.db_konfig_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db_log.db_log_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS cds2db_in.cds2db_in_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS cds2db_out.cds2db_out_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2dataprocessor_out.db2dataprocessor_out_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2dataprocessor_in.db2dataprocessor_in_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2frontend_out.db2frontend_out_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2frontend_in.db2frontend_in_seq INCREMENT 1 START 1;

-- Create Comment on Schema
COMMENT ON SCHEMA db IS 'Schema um alle "Kerndaten" der MRP-DB zu speichern - MRP-DB Kern';
COMMENT ON SCHEMA db_konfig IS 'Schema um alle Konfigurations oder Organisatorische Daten zu speichern - MRP-DB Konfig';
COMMENT ON SCHEMA db_log IS 'Schema um alle Importierten FHIR Daten und relevante MRP-DB Daten zu Logen - MRP-DB Login/Backup';
COMMENT ON SCHEMA cds2db_in IS 'Schnittstellen-Schema um FHIR Daten in die MRP-Datenbank zu schreiben - Importschnittstelle FHIR';
COMMENT ON SCHEMA cds2db_out IS 'Schnittstellen-Schema um Informationen für den Import der FHIR Daten als Filter bereit zu stellen - Importschnittstelle FHIR';
COMMENT ON SCHEMA db2dataprocessor_out IS 'Schnittstellen-Schema um Daten für berechnungen z.b. mit R zur Verfügung zu stellen - QS / Harmoniesierung / MRP Berechnung';
COMMENT ON SCHEMA db2dataprocessor_in IS 'Schnittstellen-Schema um Ergebnisse der Berechnungen in die Datenbank zu übernehmen - QS / Harmoniesierung / MRP Berechnung';
COMMENT ON SCHEMA db2frontend_out IS 'Schnittstellen-Schema für Frontend lesend - FrontEnd';
COMMENT ON SCHEMA db2frontend_in IS 'Schnittstellen-Schema für Frontend schreibend - FrontEnd';

-- gesammelte allgemeine Datenbankkonfigurationen / Funktionalitäten
--  db_user darf auch Jobs anlegen/ausführen - evtl bleibt das später auch bei Admin
GRANT USAGE ON SCHEMA cron TO db_user;