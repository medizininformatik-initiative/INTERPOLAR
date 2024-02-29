-- Extension pg_cron
-- Doku: https://github.com/citusdata/pg_cron
-- run as superuser:
CREATE EXTENSION pg_cron;

-- optionally, grant usage to regular users:
GRANT USAGE ON SCHEMA cron TO amts_db_admin;

-- Create USER SQL
CREATE USER kds2db_user WITH PASSWORD 'kds2db' CONNECTION LIMIT 20;
CREATE USER db2frontend_user WITH PASSWORD 'db2frontend' CONNECTION LIMIT 20;
CREATE USER db2dataprocessor_user WITH PASSWORD 'db2dataprocessor' CONNECTION LIMIT 20;
CREATE USER db_user WITH PASSWORD 'db' CONNECTION LIMIT 20;
CREATE USER db_log_user WITH PASSWORD 'dblog' CONNECTION LIMIT 20;

-- Create Schema
CREATE SCHEMA db;
CREATE SCHEMA db_konfig;
CREATE SCHEMA db_log;
CREATE SCHEMA kds2db_in;
CREATE SCHEMA kds2db_out;
CREATE SCHEMA db2dataprocessor_out;
CREATE SCHEMA db2dataprocessor_in;
CREATE SCHEMA db2frontend_out;
CREATE SCHEMA db2frontend_in;

-- Create Sequenz
CREATE SEQUENCE IF NOT EXISTS db.db_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db_konfig.db_konfig_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db_log.db_log_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS kds2db_in.kds2db_in_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS kds2db_out.kds2db_out_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2dataprocessor_out.db2dataprocessor_out_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2dataprocessor_in.db2dataprocessor_in_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2frontend_out.db2frontend_out_seq INCREMENT 1 START 1;
CREATE SEQUENCE IF NOT EXISTS db2frontend_in.db2frontend_in_seq INCREMENT 1 START 1;

-- Create Comment on Schema
COMMENT ON SCHEMA db IS 'Schema um alle "Kerndaten" der MRP-DB zu speichern - MRP-DB Kern';
COMMENT ON SCHEMA db_konfig IS 'Schema um alle Konfigurations oder Organisatorische Daten zu speichern - MRP-DB Konfig';
COMMENT ON SCHEMA db_log IS 'Schema um alle Importierten FHIR Daten und relevante MRP-DB Daten zu Logen - MRP-DB Login/Backup';
COMMENT ON SCHEMA kds2db_in IS 'Schnittstellen-Schema um FHIR Daten in die MRP-Datenbank zu schreiben - Importschnittstelle FHIR';
COMMENT ON SCHEMA kds2db_out IS 'Schnittstellen-Schema um Informationen für den Import der FHIR Daten als Filter bereit zu stellen - Importschnittstelle FHIR';
COMMENT ON SCHEMA db2dataprocessor_out IS 'Schnittstellen-Schema um Daten für berechnungen z.b. mit R zur Verfügung zu stellen - QS / Harmoniesierung / MRP Berechnung';
COMMENT ON SCHEMA db2dataprocessor_in IS 'Schnittstellen-Schema um Ergebnisse der Berechnungen in die Datenbank zu übernehmen - QS / Harmoniesierung / MRP Berechnung';
COMMENT ON SCHEMA db2frontend_out IS 'Schnittstellen-Schema für Frontend lesend - FrontEnd';
COMMENT ON SCHEMA db2frontend_in IS 'Schnittstellen-Schema für Frontend schreibend - FrontEnd';

-- gesammelte allgemeine Datenbankkonfigurationen / Funktionalitäten
--  db_user darf auch Jobs anlegen/ausführen - evtl bleibt das später auch bei Admin
GRANT USAGE ON SCHEMA cron TO db_user;

-- Create SQL Table in Schema kds2db_in
<%CREATE_TABLE_STATEMENTS_KDS2DB_IN%>

--SQL Role / Trigger in Schema kds2db_in
<%GRANT_STATEMENTS_KDS2DB_IN%>

-- Comment on Table in Schema kds2db_in
<%COMMENT_STATEMENTS_KDS2DB_IN%>

-- Create SQL Table in Schema db
<%CREATE_TABLE_STATEMENTS_DB%>

--SQL Role / Trigger in Schema db
<%GRANT_STATEMENTS_DB%>

-- Comment on Table in Schema db
<%COMMENT_STATEMENTS_DB%>

-- Kleine Copy Funktion
-- Überführungsfunktion
CREATE OR REPLACE FUNCTION db.do_kds_import_to_db()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
BEGIN
    -- patient -------------------------------------------------------------------------------------------------
    FOR current_record IN (SELECT * FROM kds2db_in.patient WHERE current_dataset_status NOT LIKE 'DELETE after%')
        LOOP
            SELECT count(1) INTO data_count
            FROM db.patient target_record
            WHERE   pat_identifier_use = pat_identifier_use AND
                    pat_identifier_type_system = pat_identifier_type_system AND
                    pat_identifier_type_version = pat_identifier_type_version AND
                    pat_identifier_type_code = pat_identifier_type_code AND
                    pat_identifier_type_display = pat_identifier_type_display AND
                    pat_identifier_type_text = pat_identifier_type_text AND
                    pat_identifier_system = pat_identifier_system AND
                    pat_identifier_value = pat_identifier_value AND
                    pat_identifier_start = pat_identifier_start AND
                    pat_identifier_end = pat_identifier_end AND
                    pat_name_given = pat_name_given AND
                    pat_name_family = pat_name_family AND
                    pat_gender = pat_gender AND
                    pat_birthdate = pat_birthdate AND
                    pat_address_postalcode = pat_address_postalcode
                  ;

            IF data_count=0
            THEN
                -- Füge in die Backup-Tabelle ein, wenn kein übereinstimmender Datensatz gefunden wurde
                INSERT INTO db.patient (
                pat_identifier_use,
                pat_identifier_type_system,
                pat_identifier_type_version,
                pat_identifier_type_code,
                pat_identifier_type_display,
                pat_identifier_type_text,
                pat_identifier_system,
                pat_identifier_value,
                pat_identifier_start,
                pat_identifier_end,
                pat_name_given,
                pat_name_family,
                pat_gender,
                pat_birthdate,
                pat_address_postalcode,
                input_datetime
                )
                VALUES (
                current_record.pat_identifier_use,
                current_record.pat_identifier_type_system,
                current_record.pat_identifier_type_version,
                current_record.pat_identifier_type_code,
                current_record.pat_identifier_type_display,
                current_record.pat_identifier_type_text,
                current_record.pat_identifier_system,
                current_record.pat_identifier_value,
                current_record.pat_identifier_start,
                current_record.pat_identifier_end,
                current_record.pat_name_given,
                current_record.pat_name_family,
                current_record.pat_gender,
                current_record.pat_birthdate,
                current_record.pat_address_postalcode,
                current_record.input_datetime
                );


                -- Aktualisiere den Zeitstempel für die letzte Überprüfung/Insert
                UPDATE kds2db_in.patient
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'DELETE after db_insert '||data_count::integer
                WHERE patient_id = current_record.patient_id;
            END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create View  DB2FRONTEND_OUT
CREATE OR REPLACE VIEW db2frontend_out.patient AS
select
patient_id as record_id
, pat_id AS pat_id
, pat_name_family AS pat_name
, pat_name_given AS pat_vorname
, EXTRACT(YEAR FROM AGE(NOW(), pat_birthdate::DATE)) AS pat_ak_alter
, EXTRACT(MONTH FROM AGE(NOW(), pat_birthdate::DATE)) AS pat_ak_alter_MM
, pat_gender AS pat_gschlcht
, to_char(input_datetime,'YYYY-MM-DD HH24:MI:SS') erster_datenimport_zeitpunkt
, to_char(last_check_datetime,'YYYY-MM-DD HH24:MI:SS') letzte_datensatzaenderung_zeitpunkt
, to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS') letzter_abrufzeitpunkt_dieser_daten
from db.patient order by pat_id;

GRANT USAGE ON SCHEMA db2frontend_out to db2frontend_user;
GRANT SELECT ON db2frontend_out.patient to db2frontend_user;

-- CopyJob KDS2DB -> DB
SELECT cron.schedule('*/10 * * * *', 'SELECT db.do_kds_import_to_db();');
