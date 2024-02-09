-- Extension pg_cron 
-- Doku: https://github.com/citusdata/pg_cron
-- run as superuser:
CREATE EXTENSION pg_cron;

-- optionally, grant usage to regular users:
GRANT USAGE ON SCHEMA cron TO interpolar_admin;

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

--Create SQL Table in Schema kds2db_in
CREATE TABLE IF NOT EXISTS kds2db_in.encounter (
encounter_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
enc_id varchar (70),   -- id (70 x 1 varchar)"
enc_pat_id varchar (70),   -- subject/reference (70 x 1 varchar)
enc_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
enc_identifier_use varchar (90),   -- identifier/use (30 x 3 varchar)
enc_identifier_type_system varchar (210),   -- identifier/type/coding/system (70 x 3 varchar)
enc_identifier_type_version varchar (150),   -- identifier/type/coding/version (50 x 3 varchar)
enc_identifier_type_code varchar (90),   -- identifier/type/coding/code (30 x 3 varchar)
enc_identifier_type_display varchar (300),   -- identifier/type/coding/display (100 x 3 varchar)
enc_identifier_type_text varchar (1500),   -- identifier/type/text (500 x 3 varchar)
enc_identifier_system varchar (210),   -- identifier/system (70 x 3 varchar)
enc_identifier_value varchar (150),   -- identifier/value (50 x 3 varchar)
enc_identifier_period_start varchar (90),   -- identifier/period/start (30 x 3 varchar)
enc_identifier_period_end varchar (90),   -- identifier/period/end (30 x 3 varchar)
enc_identifier_assigner_id varchar (150),   -- identifier/assigner/reference (50 x 3 varchar)
enc_identifier_assigner_type varchar (90),   -- identifier/assigner/type (30 x 3 varchar)
enc_identifier_assigner_identifier_type_use varchar (60),   -- identifier/assigner/identifier/use (20 x 3 varchar)
enc_identifier_assigner_identifier_type_system varchar (210),   -- identifier/assigner/identifier/type/coding/system (70 x 3 varchar)
enc_identifier_assigner_identifier_type_version varchar (90),   -- identifier/assigner/identifier/type/coding/version (30 x 3 varchar)
enc_identifier_assigner_identifier_type_code varchar (90),   -- identifier/assigner/identifier/type/coding/code (30 x 3 varchar)
enc_identifier_assigner_identifier_type_display varchar (300),   -- identifier/assigner/identifier/type/coding/display (100 x 3 varchar)
enc_identifier_assigner_identifier_type_text varchar (1500),   -- identifier/assigner/identifier/type/text (500 x 3 varchar)
enc_identifier_assigner_identifier_system varchar (150),   -- identifier/assigner/identifier/system (50 x 3 varchar)
enc_identifier_assigner_identifier_value varchar (300),   -- identifier/assigner/identifier/value (100 x 3 varchar)
enc_identifier_assigner_identifier_period_start varchar (90),   -- identifier/assigner/identifier/period/start (30 x 3 varchar)
enc_identifier_assigner_identifier_period_end varchar (90),   -- identifier/assigner/identifier/period/end (30 x 3 varchar)
enc_status varchar (20),   -- status (20 x 1 varchar)
enc_class_system varchar (70),   -- class/system (70 x 1 varchar)
enc_class_version varchar (30),   -- class/version (30 x 1 varchar)
enc_class_code varchar (30),   -- class/code (30 x 1 varchar)
enc_class_display varchar (100),   -- class/display (100 x 1 varchar)
enc_type_system varchar (700),   -- type/coding/system (70 x 10 varchar)
enc_type_version varchar (300),   -- type/coding/version (30 x 10 varchar)
enc_type_code varchar (300),   -- type/coding/code (30 x 10 varchar)
enc_type_display varchar (500),   -- type/coding/display (50 x 10 varchar)
enc_type_text varchar (3000),   -- type/text (300 x 10 varchar)
enc_servicetype_system varchar (210),   -- serviceType/coding/system (70 x 3 varchar)
enc_servicetype_version varchar (90),   -- serviceType/coding/version (30 x 3 varchar)
enc_servicetype_code varchar (90),   -- serviceType/coding/code (30 x 3 varchar)
enc_servicetype_display varchar (300),   -- serviceType/coding/display (100 x 3 varchar)
enc_period_start varchar (30),   -- period/start (30 x 1 varchar)
enc_period_end varchar (30),   -- period/end (30 x 1 varchar)
enc_diagnosis_condition_id varchar (1050),   -- diagnosis/condition/reference (70 x 15 varchar)
enc_diagnosis_use_system varchar (1050),   -- diagnosis/use/coding/system (70 x 15 varchar)
enc_diagnosis_use_version varchar (450),   -- diagnosis/use/coding/version (30 x 15 varchar)
enc_diagnosis_use_code varchar (450),   -- diagnosis/use/coding/code (30 x 15 varchar)
enc_diagnosis_use_display varchar (1500),   -- diagnosis/use/coding/display (100 x 15 varchar)
enc_diagnosis_use_text varchar (7500),   -- diagnosis/use/text (500 x 15 varchar)
enc_diagnosis_rank varchar (75),   -- diagnosis/rank (5 x 15 varchar)
enc_hospitalization_admitsource_system varchar (140),   -- hospitalization/admitSource/coding/system (70 x 2 varchar)
enc_hospitalization_admitsource_version varchar (60),   -- hospitalization/admitSource/coding/version (30 x 2 varchar)
enc_hospitalization_admitsource_code varchar (60),   -- hospitalization/admitSource/coding/code (30 x 2 varchar)
enc_hospitalization_admitsource_display varchar (200),   -- hospitalization/admitSource/coding/display (100 x 2 varchar)
enc_hospitalization_admitsource_text varchar (1000),   -- hospitalization/admitSource/text (500 x 2 varchar)
enc_hospitalization_dischargedisposition_system varchar (140),   -- hospitalization/dischargeDisposition/coding/system (70 x 2 varchar)
enc_hospitalization_dischargedisposition_version varchar (60),   -- hospitalization/dischargeDisposition/coding/version (30 x 2 varchar)
enc_hospitalization_dischargedisposition_code varchar (60),   -- hospitalization/dischargeDisposition/coding/code (30 x 2 varchar)
enc_hospitalization_dischargedisposition_display varchar (200),   -- hospitalization/dischargeDisposition/coding/display (100 x 2 varchar)
enc_hospitalization_dischargedisposition_text varchar (1000),   -- hospitalization/dischargeDisposition/text (500 x 2 varchar)
enc_location_id varchar (210),   -- location/location/reference (70 x 3 varchar)
enc_location_type varchar (150),   -- location/location/type (50 x 3 varchar)
enc_location_identifier_type_use varchar (90),   -- location/location/identifier/use (30 x 3 varchar)
enc_location_identifier_type_system varchar (210),   -- location/location/identifier/type/coding/system (70 x 3 varchar)
enc_location_identifier_type_version varchar (150),   -- location/location/identifier/type/coding/version (50 x 3 varchar)
enc_location_identifier_type_code varchar (90),   -- location/location/identifier/type/coding/code (30 x 3 varchar)
enc_location_identifier_type_display varchar (300),   -- location/location/identifier/type/coding/display (100 x 3 varchar)
enc_location_identifier_type_text varchar (1500),   -- location/location/identifier/type/text (500 x 3 varchar)
enc_location_identifier_system varchar (210),   -- location/location/identifier/system (70 x 3 varchar)
enc_location_identifier_value varchar (150),   -- location/location/identifier/value (50 x 3 varchar)
enc_location_identifier_period_start varchar (90),   -- location/location/identifier/period/start (30 x 3 varchar)
enc_location_identifier_period_end varchar (90),   -- location/location/identifier/period/end (30 x 3 varchar)
enc_location_display varchar (150),   -- location/location/display (50 x 3 varchar)
enc_location_physicaltype_system varchar (210),   -- location/location/physicalType/coding/system (70 x 3 varchar)
enc_location_physicaltype_version varchar (90),   -- location/location/physicalType/coding/version (30 x 3 varchar)
enc_location_physicaltype_code varchar (150),   -- location/location/physicalType/coding/code (50 x 3 varchar)
enc_location_physicaltype_display varchar (300),   -- location/location/physicalType/coding/display (100 x 3 varchar)
enc_location_physicaltype_text varchar (1500),   -- location/location/physicalType/text (500 x 3 varchar)
enc_serviceprovider_id varchar (70),   -- serviceProvider/reference (70 x 1 varchar)
enc_serviceprovider_type varchar (500),   -- serviceProvider/type (500 x 1 varchar)
enc_serviceprovider_identifier_type_use varchar (50),   -- serviceProvider/identifier/use (50 x 1 varchar)
enc_serviceprovider_identifier_type_system varchar (70),   -- serviceProvider/identifier/type/coding/system (70 x 1 varchar)
enc_serviceprovider_identifier_type_version varchar (30),   -- serviceProvider/identifier/type/coding/version (30 x 1 varchar)
enc_serviceprovider_identifier_type_code varchar (30),   -- serviceProvider/identifier/type/coding/code (30 x 1 varchar)
enc_serviceprovider_identifier_type_display varchar (100),   -- serviceProvider/identifier/type/coding/display (100 x 1 varchar)
enc_serviceprovider_identifier_type_text varchar (500),   -- serviceProvider/identifier/type/text (500 x 1 varchar)
enc_serviceprovider_identifier_system varchar (100),   -- serviceProvider/identifier/system (100 x 1 varchar)
enc_serviceprovider_identifier_value varchar (50),   -- serviceProvider/identifier/value (50 x 1 varchar)
enc_serviceprovider_identifier_period_start varchar (30),   -- serviceProvider/identifier/period/start (30 x 1 varchar)
enc_serviceprovider_identifier_period_end varchar (30),   -- serviceProvider/identifier/period/end (30 x 1 varchar)
enc_serviceprovider_display varchar (100),   -- serviceProvider/display (100 x 1 varchar)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS kds2db_in.patient (
patient_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
pat_id varchar (70),   -- id (70 x 1 varchar)"
pat_identifier_value varchar (150),   -- identifier/value (50 x 3 varchar)
pat_identifier_system varchar (210),   -- identifier/system (70 x 3 varchar)
pat_identifier_type_system varchar (210),   -- identifier/type/coding/system (70 x 3 varchar)
pat_identifier_type_version varchar (150),   -- identifier/type/coding/version (50 x 3 varchar)
pat_identifier_type_code varchar (150),   -- identifier/type/coding/code (50 x 3 varchar)
pat_identifier_type_display varchar (300),   -- identifier/type/coding/display (100 x 3 varchar)
pat_identifier_type_text varchar (1500),   -- identifier/type/text (500 x 3 varchar)
pat_name_given varchar (100),   -- name/given (100 x 1 varchar)
pat_name_family varchar (50),   -- name/family (50 x 1 varchar)
pat_gender varchar (10),   -- gender (10 x 1 varchar)
pat_birthdate varchar (30),   -- birthDate (30 x 1 varchar)
pat_adress_postalcode varchar (10),   -- address/postalCode (10 x 1 varchar)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

--SQL Role / Trigger in Schema kds2db_in
--GRANT INSERT, SELECT ON TABLE kds2db_in.encounter TO kds2db_user; -- nach Entwicklungsphase
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE kds2db_in.encounter TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON kds2db_in.encounter TO kds2db_user;
ALTER TABLE kds2db_in.encounter ALTER COLUMN encounter_id SET DEFAULT (nextval('kds2db_in.kds2db_in_seq'));

CREATE OR REPLACE FUNCTION kds2db_in.encounter_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER encounter_tr_ins_tr
  BEFORE INSERT
  ON  kds2db_in.encounter
  FOR EACH ROW
  EXECUTE PROCEDURE  kds2db_in.encounter_tr_ins_fkt();


--GRANT INSERT, SELECT ON TABLE kds2db_in.patient TO 100; -- nach Entwicklungsphase
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE kds2db_in.patient TO ; -- Entwicklungsphase
GRANT TRIGGER ON kds2db_in.patient TO kds2db_user;
ALTER TABLE kds2db_in.patient ALTER COLUMN patient_id SET DEFAULT (nextval('kds2db_in.kds2db_in_seq'));

CREATE OR REPLACE FUNCTION kds2db_in.patient_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_tr_ins_tr
  BEFORE INSERT
  ON  kds2db_in.patient
  FOR EACH ROW
  EXECUTE PROCEDURE  kds2db_in.patient_tr_ins_fkt();


-- Comment on Table in Schema kds2db_in
comment on column kds2db_in.encounter.enc_id is 'id (70 x 1 70)';
comment on column kds2db_in.encounter.enc_pat_id is 'subject/reference (70 x 1 70)';
comment on column kds2db_in.encounter.enc_partof_id is 'partOf/reference (70 x 1 70)';
comment on column kds2db_in.encounter.enc_identifier_use is 'identifier/use (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_type_system is 'identifier/type/coding/system (70 x 3 210)';
comment on column kds2db_in.encounter.enc_identifier_type_version is 'identifier/type/coding/version (50 x 3 150)';
comment on column kds2db_in.encounter.enc_identifier_type_code is 'identifier/type/coding/code (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_type_display is 'identifier/type/coding/display (100 x 3 300)';
comment on column kds2db_in.encounter.enc_identifier_type_text is 'identifier/type/text (500 x 3 1500)';
comment on column kds2db_in.encounter.enc_identifier_system is 'identifier/system (70 x 3 210)';
comment on column kds2db_in.encounter.enc_identifier_value is 'identifier/value (50 x 3 150)';
comment on column kds2db_in.encounter.enc_identifier_period_start is 'identifier/period/start (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_period_end is 'identifier/period/end (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_assigner_id is 'identifier/assigner/reference (50 x 3 150)';
comment on column kds2db_in.encounter.enc_identifier_assigner_type is 'identifier/assigner/type (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_type_use is 'identifier/assigner/identifier/use (20 x 3 60)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_type_system is 'identifier/assigner/identifier/type/coding/system (70 x 3 210)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_type_version is 'identifier/assigner/identifier/type/coding/version (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_type_code is 'identifier/assigner/identifier/type/coding/code (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_type_display is 'identifier/assigner/identifier/type/coding/display (100 x 3 300)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_type_text is 'identifier/assigner/identifier/type/text (500 x 3 1500)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_system is 'identifier/assigner/identifier/system (50 x 3 150)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_value is 'identifier/assigner/identifier/value (100 x 3 300)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_period_start is 'identifier/assigner/identifier/period/start (30 x 3 90)';
comment on column kds2db_in.encounter.enc_identifier_assigner_identifier_period_end is 'identifier/assigner/identifier/period/end (30 x 3 90)';
comment on column kds2db_in.encounter.enc_status is 'status (20 x 1 20)';
comment on column kds2db_in.encounter.enc_class_system is 'class/system (70 x 1 70)';
comment on column kds2db_in.encounter.enc_class_version is 'class/version (30 x 1 30)';
comment on column kds2db_in.encounter.enc_class_code is 'class/code (30 x 1 30)';
comment on column kds2db_in.encounter.enc_class_display is 'class/display (100 x 1 100)';
comment on column kds2db_in.encounter.enc_type_system is 'type/coding/system (70 x 10 700)';
comment on column kds2db_in.encounter.enc_type_version is 'type/coding/version (30 x 10 300)';
comment on column kds2db_in.encounter.enc_type_code is 'type/coding/code (30 x 10 300)';
comment on column kds2db_in.encounter.enc_type_display is 'type/coding/display (50 x 10 500)';
comment on column kds2db_in.encounter.enc_type_text is 'type/text (300 x 10 3000)';
comment on column kds2db_in.encounter.enc_servicetype_system is 'serviceType/coding/system (70 x 3 210)';
comment on column kds2db_in.encounter.enc_servicetype_version is 'serviceType/coding/version (30 x 3 90)';
comment on column kds2db_in.encounter.enc_servicetype_code is 'serviceType/coding/code (30 x 3 90)';
comment on column kds2db_in.encounter.enc_servicetype_display is 'serviceType/coding/display (100 x 3 300)';
comment on column kds2db_in.encounter.enc_period_start is 'period/start (30 x 1 30)';
comment on column kds2db_in.encounter.enc_period_end is 'period/end (30 x 1 30)';
comment on column kds2db_in.encounter.enc_diagnosis_condition_id is 'diagnosis/condition/reference (70 x 15 1050)';
comment on column kds2db_in.encounter.enc_diagnosis_use_system is 'diagnosis/use/coding/system (70 x 15 1050)';
comment on column kds2db_in.encounter.enc_diagnosis_use_version is 'diagnosis/use/coding/version (30 x 15 450)';
comment on column kds2db_in.encounter.enc_diagnosis_use_code is 'diagnosis/use/coding/code (30 x 15 450)';
comment on column kds2db_in.encounter.enc_diagnosis_use_display is 'diagnosis/use/coding/display (100 x 15 1500)';
comment on column kds2db_in.encounter.enc_diagnosis_use_text is 'diagnosis/use/text (500 x 15 7500)';
comment on column kds2db_in.encounter.enc_diagnosis_rank is 'diagnosis/rank (5 x 15 75)';
comment on column kds2db_in.encounter.enc_hospitalization_admitsource_system is 'hospitalization/admitSource/coding/system (70 x 2 140)';
comment on column kds2db_in.encounter.enc_hospitalization_admitsource_version is 'hospitalization/admitSource/coding/version (30 x 2 60)';
comment on column kds2db_in.encounter.enc_hospitalization_admitsource_code is 'hospitalization/admitSource/coding/code (30 x 2 60)';
comment on column kds2db_in.encounter.enc_hospitalization_admitsource_display is 'hospitalization/admitSource/coding/display (100 x 2 200)';
comment on column kds2db_in.encounter.enc_hospitalization_admitsource_text is 'hospitalization/admitSource/text (500 x 2 1000)';
comment on column kds2db_in.encounter.enc_hospitalization_dischargedisposition_system is 'hospitalization/dischargeDisposition/coding/system (70 x 2 140)';
comment on column kds2db_in.encounter.enc_hospitalization_dischargedisposition_version is 'hospitalization/dischargeDisposition/coding/version (30 x 2 60)';
comment on column kds2db_in.encounter.enc_hospitalization_dischargedisposition_code is 'hospitalization/dischargeDisposition/coding/code (30 x 2 60)';
comment on column kds2db_in.encounter.enc_hospitalization_dischargedisposition_display is 'hospitalization/dischargeDisposition/coding/display (100 x 2 200)';
comment on column kds2db_in.encounter.enc_hospitalization_dischargedisposition_text is 'hospitalization/dischargeDisposition/text (500 x 2 1000)';
comment on column kds2db_in.encounter.enc_location_id is 'location/location/reference (70 x 3 210)';
comment on column kds2db_in.encounter.enc_location_type is 'location/location/type (50 x 3 150)';
comment on column kds2db_in.encounter.enc_location_identifier_type_use is 'location/location/identifier/use (30 x 3 90)';
comment on column kds2db_in.encounter.enc_location_identifier_type_system is 'location/location/identifier/type/coding/system (70 x 3 210)';
comment on column kds2db_in.encounter.enc_location_identifier_type_version is 'location/location/identifier/type/coding/version (50 x 3 150)';
comment on column kds2db_in.encounter.enc_location_identifier_type_code is 'location/location/identifier/type/coding/code (30 x 3 90)';
comment on column kds2db_in.encounter.enc_location_identifier_type_display is 'location/location/identifier/type/coding/display (100 x 3 300)';
comment on column kds2db_in.encounter.enc_location_identifier_type_text is 'location/location/identifier/type/text (500 x 3 1500)';
comment on column kds2db_in.encounter.enc_location_identifier_system is 'location/location/identifier/system (70 x 3 210)';
comment on column kds2db_in.encounter.enc_location_identifier_value is 'location/location/identifier/value (50 x 3 150)';
comment on column kds2db_in.encounter.enc_location_identifier_period_start is 'location/location/identifier/period/start (30 x 3 90)';
comment on column kds2db_in.encounter.enc_location_identifier_period_end is 'location/location/identifier/period/end (30 x 3 90)';
comment on column kds2db_in.encounter.enc_location_display is 'location/location/display (50 x 3 150)';
comment on column kds2db_in.encounter.enc_location_physicaltype_system is 'location/location/physicalType/coding/system (70 x 3 210)';
comment on column kds2db_in.encounter.enc_location_physicaltype_version is 'location/location/physicalType/coding/version (30 x 3 90)';
comment on column kds2db_in.encounter.enc_location_physicaltype_code is 'location/location/physicalType/coding/code (50 x 3 150)';
comment on column kds2db_in.encounter.enc_location_physicaltype_display is 'location/location/physicalType/coding/display (100 x 3 300)';
comment on column kds2db_in.encounter.enc_location_physicaltype_text is 'location/location/physicalType/text (500 x 3 1500)';
comment on column kds2db_in.encounter.enc_serviceprovider_id is 'serviceProvider/reference (70 x 1 70)';
comment on column kds2db_in.encounter.enc_serviceprovider_type is 'serviceProvider/type (500 x 1 500)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_type_use is 'serviceProvider/identifier/use (50 x 1 50)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_type_system is 'serviceProvider/identifier/type/coding/system (70 x 1 70)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_type_version is 'serviceProvider/identifier/type/coding/version (30 x 1 30)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_type_code is 'serviceProvider/identifier/type/coding/code (30 x 1 30)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_type_display is 'serviceProvider/identifier/type/coding/display (100 x 1 100)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_type_text is 'serviceProvider/identifier/type/text (500 x 1 500)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_system is 'serviceProvider/identifier/system (100 x 1 100)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_value is 'serviceProvider/identifier/value (50 x 1 50)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_period_start is 'serviceProvider/identifier/period/start (30 x 1 30)';
comment on column kds2db_in.encounter.enc_serviceprovider_identifier_period_end is 'serviceProvider/identifier/period/end (30 x 1 30)';
comment on column kds2db_in.encounter.enc_serviceprovider_display is 'serviceProvider/display (100 x 1 100)';

comment on column kds2db_in.patient.pat_id is 'id (70 x 1 70)';
comment on column kds2db_in.patient.pat_identifier_value is 'identifier/value (50 x 3 150)';
comment on column kds2db_in.patient.pat_identifier_system is 'identifier/system (70 x 3 210)';
comment on column kds2db_in.patient.pat_identifier_type_system is 'identifier/type/coding/system (70 x 3 210)';
comment on column kds2db_in.patient.pat_identifier_type_version is 'identifier/type/coding/version (50 x 3 150)';
comment on column kds2db_in.patient.pat_identifier_type_code is 'identifier/type/coding/code (50 x 3 150)';
comment on column kds2db_in.patient.pat_identifier_type_display is 'identifier/type/coding/display (100 x 3 300)';
comment on column kds2db_in.patient.pat_identifier_type_text is 'identifier/type/text (500 x 3 1500)';
comment on column kds2db_in.patient.pat_name_given is 'name/given (100 x 1 100)';
comment on column kds2db_in.patient.pat_name_family is 'name/family (50 x 1 50)';
comment on column kds2db_in.patient.pat_gender is 'gender (10 x 1 10)';
comment on column kds2db_in.patient.pat_birthdate is 'birthDate (30 x 1 30)';
comment on column kds2db_in.patient.pat_adress_postalcode is 'address/postalCode (10 x 1 10)';

--Create SQL Table in Schema db
CREATE TABLE IF NOT EXISTS db.encounter (
encounter_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
enc_id varchar (70),   -- id (70 x 1 varchar)"
enc_pat_id varchar (70),   -- subject/reference (70 x 1 varchar)
enc_partof_id varchar (70),   -- partOf/reference (70 x 1 varchar)
enc_identifier_use varchar (90),   -- identifier/use (30 x 3 varchar)
enc_identifier_type_system varchar (210),   -- identifier/type/coding/system (70 x 3 varchar)
enc_identifier_type_version varchar (150),   -- identifier/type/coding/version (50 x 3 varchar)
enc_identifier_type_code varchar (90),   -- identifier/type/coding/code (30 x 3 varchar)
enc_identifier_type_display varchar (300),   -- identifier/type/coding/display (100 x 3 varchar)
enc_identifier_type_text varchar (1500),   -- identifier/type/text (500 x 3 varchar)
enc_identifier_system varchar (210),   -- identifier/system (70 x 3 varchar)
enc_identifier_value varchar (150),   -- identifier/value (50 x 3 varchar)
enc_identifier_period_start varchar (90),   -- identifier/period/start (30 x 3 varchar)
enc_identifier_period_end varchar (90),   -- identifier/period/end (30 x 3 varchar)
enc_identifier_assigner_id varchar (150),   -- identifier/assigner/reference (50 x 3 varchar)
enc_identifier_assigner_type varchar (90),   -- identifier/assigner/type (30 x 3 varchar)
enc_identifier_assigner_identifier_type_use varchar (60),   -- identifier/assigner/identifier/use (20 x 3 varchar)
enc_identifier_assigner_identifier_type_system varchar (210),   -- identifier/assigner/identifier/type/coding/system (70 x 3 varchar)
enc_identifier_assigner_identifier_type_version varchar (90),   -- identifier/assigner/identifier/type/coding/version (30 x 3 varchar)
enc_identifier_assigner_identifier_type_code varchar (90),   -- identifier/assigner/identifier/type/coding/code (30 x 3 varchar)
enc_identifier_assigner_identifier_type_display varchar (300),   -- identifier/assigner/identifier/type/coding/display (100 x 3 varchar)
enc_identifier_assigner_identifier_type_text varchar (1500),   -- identifier/assigner/identifier/type/text (500 x 3 varchar)
enc_identifier_assigner_identifier_system varchar (150),   -- identifier/assigner/identifier/system (50 x 3 varchar)
enc_identifier_assigner_identifier_value varchar (300),   -- identifier/assigner/identifier/value (100 x 3 varchar)
enc_identifier_assigner_identifier_period_start varchar (90),   -- identifier/assigner/identifier/period/start (30 x 3 varchar)
enc_identifier_assigner_identifier_period_end varchar (90),   -- identifier/assigner/identifier/period/end (30 x 3 varchar)
enc_status varchar (20),   -- status (20 x 1 varchar)
enc_class_system varchar (70),   -- class/system (70 x 1 varchar)
enc_class_version varchar (30),   -- class/version (30 x 1 varchar)
enc_class_code varchar (30),   -- class/code (30 x 1 varchar)
enc_class_display varchar (100),   -- class/display (100 x 1 varchar)
enc_type_system varchar (700),   -- type/coding/system (70 x 10 varchar)
enc_type_version varchar (300),   -- type/coding/version (30 x 10 varchar)
enc_type_code varchar (300),   -- type/coding/code (30 x 10 varchar)
enc_type_display varchar (500),   -- type/coding/display (50 x 10 varchar)
enc_type_text varchar (3000),   -- type/text (300 x 10 varchar)
enc_servicetype_system varchar (210),   -- serviceType/coding/system (70 x 3 varchar)
enc_servicetype_version varchar (90),   -- serviceType/coding/version (30 x 3 varchar)
enc_servicetype_code varchar (90),   -- serviceType/coding/code (30 x 3 varchar)
enc_servicetype_display varchar (300),   -- serviceType/coding/display (100 x 3 varchar)
enc_period_start varchar (30),   -- period/start (30 x 1 varchar)
enc_period_end varchar (30),   -- period/end (30 x 1 varchar)
enc_diagnosis_condition_id varchar (1050),   -- diagnosis/condition/reference (70 x 15 varchar)
enc_diagnosis_use_system varchar (1050),   -- diagnosis/use/coding/system (70 x 15 varchar)
enc_diagnosis_use_version varchar (450),   -- diagnosis/use/coding/version (30 x 15 varchar)
enc_diagnosis_use_code varchar (450),   -- diagnosis/use/coding/code (30 x 15 varchar)
enc_diagnosis_use_display varchar (1500),   -- diagnosis/use/coding/display (100 x 15 varchar)
enc_diagnosis_use_text varchar (7500),   -- diagnosis/use/text (500 x 15 varchar)
enc_diagnosis_rank varchar (75),   -- diagnosis/rank (5 x 15 varchar)
enc_hospitalization_admitsource_system varchar (140),   -- hospitalization/admitSource/coding/system (70 x 2 varchar)
enc_hospitalization_admitsource_version varchar (60),   -- hospitalization/admitSource/coding/version (30 x 2 varchar)
enc_hospitalization_admitsource_code varchar (60),   -- hospitalization/admitSource/coding/code (30 x 2 varchar)
enc_hospitalization_admitsource_display varchar (200),   -- hospitalization/admitSource/coding/display (100 x 2 varchar)
enc_hospitalization_admitsource_text varchar (1000),   -- hospitalization/admitSource/text (500 x 2 varchar)
enc_hospitalization_dischargedisposition_system varchar (140),   -- hospitalization/dischargeDisposition/coding/system (70 x 2 varchar)
enc_hospitalization_dischargedisposition_version varchar (60),   -- hospitalization/dischargeDisposition/coding/version (30 x 2 varchar)
enc_hospitalization_dischargedisposition_code varchar (60),   -- hospitalization/dischargeDisposition/coding/code (30 x 2 varchar)
enc_hospitalization_dischargedisposition_display varchar (200),   -- hospitalization/dischargeDisposition/coding/display (100 x 2 varchar)
enc_hospitalization_dischargedisposition_text varchar (1000),   -- hospitalization/dischargeDisposition/text (500 x 2 varchar)
enc_location_id varchar (210),   -- location/location/reference (70 x 3 varchar)
enc_location_type varchar (150),   -- location/location/type (50 x 3 varchar)
enc_location_identifier_type_use varchar (90),   -- location/location/identifier/use (30 x 3 varchar)
enc_location_identifier_type_system varchar (210),   -- location/location/identifier/type/coding/system (70 x 3 varchar)
enc_location_identifier_type_version varchar (150),   -- location/location/identifier/type/coding/version (50 x 3 varchar)
enc_location_identifier_type_code varchar (90),   -- location/location/identifier/type/coding/code (30 x 3 varchar)
enc_location_identifier_type_display varchar (300),   -- location/location/identifier/type/coding/display (100 x 3 varchar)
enc_location_identifier_type_text varchar (1500),   -- location/location/identifier/type/text (500 x 3 varchar)
enc_location_identifier_system varchar (210),   -- location/location/identifier/system (70 x 3 varchar)
enc_location_identifier_value varchar (150),   -- location/location/identifier/value (50 x 3 varchar)
enc_location_identifier_period_start varchar (90),   -- location/location/identifier/period/start (30 x 3 varchar)
enc_location_identifier_period_end varchar (90),   -- location/location/identifier/period/end (30 x 3 varchar)
enc_location_display varchar (150),   -- location/location/display (50 x 3 varchar)
enc_location_physicaltype_system varchar (210),   -- location/location/physicalType/coding/system (70 x 3 varchar)
enc_location_physicaltype_version varchar (90),   -- location/location/physicalType/coding/version (30 x 3 varchar)
enc_location_physicaltype_code varchar (150),   -- location/location/physicalType/coding/code (50 x 3 varchar)
enc_location_physicaltype_display varchar (300),   -- location/location/physicalType/coding/display (100 x 3 varchar)
enc_location_physicaltype_text varchar (1500),   -- location/location/physicalType/text (500 x 3 varchar)
enc_serviceprovider_id varchar (70),   -- serviceProvider/reference (70 x 1 varchar)
enc_serviceprovider_type varchar (500),   -- serviceProvider/type (500 x 1 varchar)
enc_serviceprovider_identifier_type_use varchar (50),   -- serviceProvider/identifier/use (50 x 1 varchar)
enc_serviceprovider_identifier_type_system varchar (70),   -- serviceProvider/identifier/type/coding/system (70 x 1 varchar)
enc_serviceprovider_identifier_type_version varchar (30),   -- serviceProvider/identifier/type/coding/version (30 x 1 varchar)
enc_serviceprovider_identifier_type_code varchar (30),   -- serviceProvider/identifier/type/coding/code (30 x 1 varchar)
enc_serviceprovider_identifier_type_display varchar (100),   -- serviceProvider/identifier/type/coding/display (100 x 1 varchar)
enc_serviceprovider_identifier_type_text varchar (500),   -- serviceProvider/identifier/type/text (500 x 1 varchar)
enc_serviceprovider_identifier_system varchar (100),   -- serviceProvider/identifier/system (100 x 1 varchar)
enc_serviceprovider_identifier_value varchar (50),   -- serviceProvider/identifier/value (50 x 1 varchar)
enc_serviceprovider_identifier_period_start varchar (30),   -- serviceProvider/identifier/period/start (30 x 1 varchar)
enc_serviceprovider_identifier_period_end varchar (30),   -- serviceProvider/identifier/period/end (30 x 1 varchar)
enc_serviceprovider_display varchar (100),   -- serviceProvider/display (100 x 1 varchar)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db.patient (
patient_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
pat_id varchar (70),   -- id (70 x 1 varchar)
pat_identifier_value varchar (150),   -- identifier/value (50 x 3 varchar)
pat_identifier_system varchar (210),   -- identifier/system (70 x 3 varchar)
pat_identifier_type_system varchar (210),   -- identifier/type/coding/system (70 x 3 varchar)
pat_identifier_type_version varchar (150),   -- identifier/type/coding/version (50 x 3 varchar)
pat_identifier_type_code varchar (150),   -- identifier/type/coding/code (50 x 3 varchar)
pat_identifier_type_display varchar (300),   -- identifier/type/coding/display (100 x 3 varchar)
pat_identifier_type_text varchar (1500),   -- identifier/type/text (500 x 3 varchar)
pat_name_given varchar (100),   -- name/given (100 x 1 varchar)
pat_name_family varchar (50),   -- name/family (50 x 1 varchar)
pat_gender varchar (10),   -- gender (10 x 1 varchar)
pat_birthdate varchar (30),   -- birthDate (30 x 1 varchar)
pat_adress_postalcode varchar (10),   -- address/postalCode (10 x 1 varchar)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

--SQL Role / Trigger in Schema db
--GRANT INSERT, SELECT ON TABLE db.encounter TO db_user; -- nach Entwicklungsphase
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE db.encounter TO db_user; -- Entwicklungsphase
GRANT TRIGGER ON db.encounter TO db_user;
ALTER TABLE db.encounter ALTER COLUMN encounter_id SET DEFAULT (nextval('db.db_seq'));

CREATE OR REPLACE FUNCTION db.encounter_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER encounter_tr_ins_tr
  BEFORE INSERT
  ON  db.encounter
  FOR EACH ROW
  EXECUTE PROCEDURE  db.encounter_tr_ins_fkt();

--GRANT INSERT, SELECT ON TABLE db.patient TO 100; -- nach Entwicklungsphase
GRANT INSERT,SELECT, UPDATE, DELETE ON TABLE db.patient TO ; -- Entwicklungsphase
GRANT TRIGGER ON db.patient TO db_user;
ALTER TABLE db.patient ALTER COLUMN patient_id SET DEFAULT (nextval('db.db_seq'));

CREATE OR REPLACE FUNCTION db.patient_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_tr_ins_tr
  BEFORE INSERT
  ON  db.patient
  FOR EACH ROW
  EXECUTE PROCEDURE  db.patient_tr_ins_fkt();


-- Comment on Table in Schema db
comment on column db.encounter.enc_id is 'id (70 x 1 70)';
comment on column db.encounter.enc_pat_id is 'subject/reference (70 x 1 70)';
comment on column db.encounter.enc_partof_id is 'partOf/reference (70 x 1 70)';
comment on column db.encounter.enc_identifier_use is 'identifier/use (30 x 3 90)';
comment on column db.encounter.enc_identifier_type_system is 'identifier/type/coding/system (70 x 3 210)';
comment on column db.encounter.enc_identifier_type_version is 'identifier/type/coding/version (50 x 3 150)';
comment on column db.encounter.enc_identifier_type_code is 'identifier/type/coding/code (30 x 3 90)';
comment on column db.encounter.enc_identifier_type_display is 'identifier/type/coding/display (100 x 3 300)';
comment on column db.encounter.enc_identifier_type_text is 'identifier/type/text (500 x 3 1500)';
comment on column db.encounter.enc_identifier_system is 'identifier/system (70 x 3 210)';
comment on column db.encounter.enc_identifier_value is 'identifier/value (50 x 3 150)';
comment on column db.encounter.enc_identifier_period_start is 'identifier/period/start (30 x 3 90)';
comment on column db.encounter.enc_identifier_period_end is 'identifier/period/end (30 x 3 90)';
comment on column db.encounter.enc_identifier_assigner_id is 'identifier/assigner/reference (50 x 3 150)';
comment on column db.encounter.enc_identifier_assigner_type is 'identifier/assigner/type (30 x 3 90)';
comment on column db.encounter.enc_identifier_assigner_identifier_type_use is 'identifier/assigner/identifier/use (20 x 3 60)';
comment on column db.encounter.enc_identifier_assigner_identifier_type_system is 'identifier/assigner/identifier/type/coding/system (70 x 3 210)';
comment on column db.encounter.enc_identifier_assigner_identifier_type_version is 'identifier/assigner/identifier/type/coding/version (30 x 3 90)';
comment on column db.encounter.enc_identifier_assigner_identifier_type_code is 'identifier/assigner/identifier/type/coding/code (30 x 3 90)';
comment on column db.encounter.enc_identifier_assigner_identifier_type_display is 'identifier/assigner/identifier/type/coding/display (100 x 3 300)';
comment on column db.encounter.enc_identifier_assigner_identifier_type_text is 'identifier/assigner/identifier/type/text (500 x 3 1500)';
comment on column db.encounter.enc_identifier_assigner_identifier_system is 'identifier/assigner/identifier/system (50 x 3 150)';
comment on column db.encounter.enc_identifier_assigner_identifier_value is 'identifier/assigner/identifier/value (100 x 3 300)';
comment on column db.encounter.enc_identifier_assigner_identifier_period_start is 'identifier/assigner/identifier/period/start (30 x 3 90)';
comment on column db.encounter.enc_identifier_assigner_identifier_period_end is 'identifier/assigner/identifier/period/end (30 x 3 90)';
comment on column db.encounter.enc_status is 'status (20 x 1 20)';
comment on column db.encounter.enc_class_system is 'class/system (70 x 1 70)';
comment on column db.encounter.enc_class_version is 'class/version (30 x 1 30)';
comment on column db.encounter.enc_class_code is 'class/code (30 x 1 30)';
comment on column db.encounter.enc_class_display is 'class/display (100 x 1 100)';
comment on column db.encounter.enc_type_system is 'type/coding/system (70 x 10 700)';
comment on column db.encounter.enc_type_version is 'type/coding/version (30 x 10 300)';
comment on column db.encounter.enc_type_code is 'type/coding/code (30 x 10 300)';
comment on column db.encounter.enc_type_display is 'type/coding/display (50 x 10 500)';
comment on column db.encounter.enc_type_text is 'type/text (300 x 10 3000)';
comment on column db.encounter.enc_servicetype_system is 'serviceType/coding/system (70 x 3 210)';
comment on column db.encounter.enc_servicetype_version is 'serviceType/coding/version (30 x 3 90)';
comment on column db.encounter.enc_servicetype_code is 'serviceType/coding/code (30 x 3 90)';
comment on column db.encounter.enc_servicetype_display is 'serviceType/coding/display (100 x 3 300)';
comment on column db.encounter.enc_period_start is 'period/start (30 x 1 30)';
comment on column db.encounter.enc_period_end is 'period/end (30 x 1 30)';
comment on column db.encounter.enc_diagnosis_condition_id is 'diagnosis/condition/reference (70 x 15 1050)';
comment on column db.encounter.enc_diagnosis_use_system is 'diagnosis/use/coding/system (70 x 15 1050)';
comment on column db.encounter.enc_diagnosis_use_version is 'diagnosis/use/coding/version (30 x 15 450)';
comment on column db.encounter.enc_diagnosis_use_code is 'diagnosis/use/coding/code (30 x 15 450)';
comment on column db.encounter.enc_diagnosis_use_display is 'diagnosis/use/coding/display (100 x 15 1500)';
comment on column db.encounter.enc_diagnosis_use_text is 'diagnosis/use/text (500 x 15 7500)';
comment on column db.encounter.enc_diagnosis_rank is 'diagnosis/rank (5 x 15 75)';
comment on column db.encounter.enc_hospitalization_admitsource_system is 'hospitalization/admitSource/coding/system (70 x 2 140)';
comment on column db.encounter.enc_hospitalization_admitsource_version is 'hospitalization/admitSource/coding/version (30 x 2 60)';
comment on column db.encounter.enc_hospitalization_admitsource_code is 'hospitalization/admitSource/coding/code (30 x 2 60)';
comment on column db.encounter.enc_hospitalization_admitsource_display is 'hospitalization/admitSource/coding/display (100 x 2 200)';
comment on column db.encounter.enc_hospitalization_admitsource_text is 'hospitalization/admitSource/text (500 x 2 1000)';
comment on column db.encounter.enc_hospitalization_dischargedisposition_system is 'hospitalization/dischargeDisposition/coding/system (70 x 2 140)';
comment on column db.encounter.enc_hospitalization_dischargedisposition_version is 'hospitalization/dischargeDisposition/coding/version (30 x 2 60)';
comment on column db.encounter.enc_hospitalization_dischargedisposition_code is 'hospitalization/dischargeDisposition/coding/code (30 x 2 60)';
comment on column db.encounter.enc_hospitalization_dischargedisposition_display is 'hospitalization/dischargeDisposition/coding/display (100 x 2 200)';
comment on column db.encounter.enc_hospitalization_dischargedisposition_text is 'hospitalization/dischargeDisposition/text (500 x 2 1000)';
comment on column db.encounter.enc_location_id is 'location/location/reference (70 x 3 210)';
comment on column db.encounter.enc_location_type is 'location/location/type (50 x 3 150)';
comment on column db.encounter.enc_location_identifier_type_use is 'location/location/identifier/use (30 x 3 90)';
comment on column db.encounter.enc_location_identifier_type_system is 'location/location/identifier/type/coding/system (70 x 3 210)';
comment on column db.encounter.enc_location_identifier_type_version is 'location/location/identifier/type/coding/version (50 x 3 150)';
comment on column db.encounter.enc_location_identifier_type_code is 'location/location/identifier/type/coding/code (30 x 3 90)';
comment on column db.encounter.enc_location_identifier_type_display is 'location/location/identifier/type/coding/display (100 x 3 300)';
comment on column db.encounter.enc_location_identifier_type_text is 'location/location/identifier/type/text (500 x 3 1500)';
comment on column db.encounter.enc_location_identifier_system is 'location/location/identifier/system (70 x 3 210)';
comment on column db.encounter.enc_location_identifier_value is 'location/location/identifier/value (50 x 3 150)';
comment on column db.encounter.enc_location_identifier_period_start is 'location/location/identifier/period/start (30 x 3 90)';
comment on column db.encounter.enc_location_identifier_period_end is 'location/location/identifier/period/end (30 x 3 90)';
comment on column db.encounter.enc_location_display is 'location/location/display (50 x 3 150)';
comment on column db.encounter.enc_location_physicaltype_system is 'location/location/physicalType/coding/system (70 x 3 210)';
comment on column db.encounter.enc_location_physicaltype_version is 'location/location/physicalType/coding/version (30 x 3 90)';
comment on column db.encounter.enc_location_physicaltype_code is 'location/location/physicalType/coding/code (50 x 3 150)';
comment on column db.encounter.enc_location_physicaltype_display is 'location/location/physicalType/coding/display (100 x 3 300)';
comment on column db.encounter.enc_location_physicaltype_text is 'location/location/physicalType/text (500 x 3 1500)';
comment on column db.encounter.enc_serviceprovider_id is 'serviceProvider/reference (70 x 1 70)';
comment on column db.encounter.enc_serviceprovider_type is 'serviceProvider/type (500 x 1 500)';
comment on column db.encounter.enc_serviceprovider_identifier_type_use is 'serviceProvider/identifier/use (50 x 1 50)';
comment on column db.encounter.enc_serviceprovider_identifier_type_system is 'serviceProvider/identifier/type/coding/system (70 x 1 70)';
comment on column db.encounter.enc_serviceprovider_identifier_type_version is 'serviceProvider/identifier/type/coding/version (30 x 1 30)';
comment on column db.encounter.enc_serviceprovider_identifier_type_code is 'serviceProvider/identifier/type/coding/code (30 x 1 30)';
comment on column db.encounter.enc_serviceprovider_identifier_type_display is 'serviceProvider/identifier/type/coding/display (100 x 1 100)';
comment on column db.encounter.enc_serviceprovider_identifier_type_text is 'serviceProvider/identifier/type/text (500 x 1 500)';
comment on column db.encounter.enc_serviceprovider_identifier_system is 'serviceProvider/identifier/system (100 x 1 100)';
comment on column db.encounter.enc_serviceprovider_identifier_value is 'serviceProvider/identifier/value (50 x 1 50)';
comment on column db.encounter.enc_serviceprovider_identifier_period_start is 'serviceProvider/identifier/period/start (30 x 1 30)';
comment on column db.encounter.enc_serviceprovider_identifier_period_end is 'serviceProvider/identifier/period/end (30 x 1 30)';
comment on column db.encounter.enc_serviceprovider_display is 'serviceProvider/display (100 x 1 100)';

comment on column db.patient.pat_id is 'id (70 x 1 70)';
comment on column db.patient.pat_identifier_value is 'identifier/value (50 x 3 150)';
comment on column db.patient.pat_identifier_system is 'identifier/system (70 x 3 210)';
comment on column db.patient.pat_identifier_type_system is 'identifier/type/coding/system (70 x 3 210)';
comment on column db.patient.pat_identifier_type_version is 'identifier/type/coding/version (50 x 3 150)';
comment on column db.patient.pat_identifier_type_code is 'identifier/type/coding/code (50 x 3 150)';
comment on column db.patient.pat_identifier_type_display is 'identifier/type/coding/display (100 x 3 300)';
comment on column db.patient.pat_identifier_type_text is 'identifier/type/text (500 x 3 1500)';
comment on column db.patient.pat_name_given is 'name/given (100 x 1 100)';
comment on column db.patient.pat_name_family is 'name/family (50 x 1 50)';
comment on column db.patient.pat_gender is 'gender (10 x 1 10)';
comment on column db.patient.pat_birthdate is 'birthDate (30 x 1 30)';
comment on column db.patient.pat_adress_postalcode is 'address/postalCode (10 x 1 10)';

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


GRANT SELECT ON db2frontend_out.patient to db2frontend_user;

-- CopyJob KDS2DB -> DB
SELECT cron.schedule('*/10 * * * *', 'CALL db.do_kds_import_to_db();');