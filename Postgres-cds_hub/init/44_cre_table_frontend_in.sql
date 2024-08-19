-----------------------------------------------------
-- Create SQL Tables in Schema "db2frontend_in" --
-----------------------------------------------------

-- Table "patient_fe" in schema "db2frontend_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2frontend_in.patient_fe (
  patient_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  pat_header varchar,   -- descriptive item only for frontend (varchar)
  pat_id varchar,   -- Patient-identifier FHIR Daten (varchar)
  pat_cis_pid varchar,   -- Patient Identifier aus dem Krankenhausinformationssystem - so wie es dem Apotheker zur verfügung steht (varchar)
  redcap_repeat_instrument varchar,   -- Frontend interne Datensatzverwaltung - Instrument :  patient (varchar)
  redcap_repeat_instance varchar,   -- Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1 (varchar)
  pat_name varchar,   -- Patientenname (varchar)
  pat_vorname varchar,   -- Patientenvorname (varchar)
  pat_gebdat date,   -- Geburtsdatum (date)
  pat_aktuell_alter double precision,   -- aktuelles Patientenalter (Jahre) (double precision)
  pat_geschlecht varchar,   -- Geschlecht (wie in FHIR) (varchar)
  patient_complete varchar,   -- Frontend Complete-Status (varchar)
  input_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input',  -- Processing status of the data record
  last_processing_nr int -- Last processing number of the data record
);

-- Table "fall_fe" in schema "db2frontend_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2frontend_in.fall_fe (
  fall_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  fall_header varchar,   -- descriptive item only for frontend (varchar)
  fall_id varchar,   -- Fall-ID RedCap FHIR Daten (varchar)
  fall_pat_id varchar,   -- Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id) (varchar)
  patient_id_fk int,   -- Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)
  fall_femb varchar,   -- descriptive item only for frontend (varchar)
  redcap_repeat_instrument varchar,   -- Frontend interne Datensatzverwaltung - Instrument :   fall (varchar)
  redcap_repeat_instance varchar,   -- Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)
  fall_studienphase varchar,   -- Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) ) (varchar)
  fall_station varchar,   -- Station wie vom DIZ Definiert (varchar)
  fall_aufn_dat date,   -- Aufnahmedatum (date)
  fall_aufn_diag varchar,   -- Diagnose(n) bei Aufnahme (wird nur zum lesen sein (varchar)
  fall_gewicht_aktuell double precision,   -- aktuelles Gewicht (Kg) (double precision)
  fall_gewicht_aktl_einheit varchar,   -- Einheit des Gewichts (varchar)
  fall_groesse double precision,   -- Größe (cm) (double precision)
  fall_groesse_einheit varchar,   -- Einheit der Größe (varchar)
  fall_bmi double precision,   -- BMI (double precision)
  fall_femb_2 varchar,   -- descriptive item only for frontend (varchar)
  fall_femb_3 varchar,   -- descriptive item only for frontend (varchar)
  fall_femb_4 varchar,   -- descriptive item only for frontend (varchar)
  fall_nieren_insuf_chron varchar,   -- 1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (varchar)
  fall_nieren_insuf_ausmass_lbl varchar,   -- descriptive item only for frontend (varchar)
  fall_nieren_insuf_ausmass varchar,   -- 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, &lt; 15 ml/min/1,73 m2 (varchar)
  fall_nieren_insuf_dialysev_lbl varchar,   -- descriptive item only for frontend (varchar)
  fall_nieren_insuf_dialysev varchar,   -- 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (varchar)
  fall_leber_insuf varchar,   -- 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (varchar)
  fall_leber_insuf_ausmass_lbl varchar,   -- descriptive item only for frontend (varchar)
  fall_leber_insuf_ausmass varchar,   -- 1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß (varchar)
  fall_schwanger_mo varchar,   -- 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9 (varchar)
  fall_op_geplant varchar,   -- 1, ja | 0, nein | -1, nicht bekanntIst eine Operation geplant? (varchar)
  fall_op_dat_lbl varchar,   -- descriptive item only for frontend (varchar)
  fall_op_dat date,   -- Operationsdatum (date)
  fall_status varchar,   -- Status des Falls (varchar)
  fall_ent_dat date,   -- Entlassdatum (date)
  fall_complete varchar,   -- Frontend Complete-Status (varchar)
  input_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_check_datetime timestamp DEFAULT NULL,   -- Time at which data record was last checked
  current_dataset_status varchar DEFAULT 'input',  -- Processing status of the data record
  last_processing_nr int -- Last processing number of the data record
);


------------------------------------------------------
-- SQL Role / Trigger in Schema "db2frontend_in" --
------------------------------------------------------


-- Table "patient_fe" in schema "db2frontend_in"
----------------------------------------------------
GRANT TRIGGER ON db2frontend_in.patient_fe TO db2frontend_user;
GRANT USAGE ON SCHEMA db2frontend_in TO db2frontend_user;
GRANT USAGE ON db.db_seq TO db2frontend_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2frontend_in.patient_fe TO db2frontend_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2frontend_in.patient_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2frontend_in.patient_fe TO db_log_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db2frontend_in.patient_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_fe_tr_ins_tr
  BEFORE INSERT
  ON db2frontend_in.patient_fe
  FOR EACH ROW
  EXECUTE PROCEDURE db2frontend_in.patient_fe_tr_ins_fkt();


-- Table "fall_fe" in schema "db2frontend_in"
----------------------------------------------------
GRANT TRIGGER ON db2frontend_in.fall_fe TO db2frontend_user;
GRANT USAGE ON SCHEMA db2frontend_in TO db2frontend_user;
GRANT USAGE ON db.db_seq TO db2frontend_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2frontend_in.fall_fe TO db2frontend_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2frontend_in.fall_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2frontend_in.fall_fe TO db_log_user; -- Additional authorizations for testing

CREATE OR REPLACE FUNCTION db2frontend_in.fall_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Enter the current time
    NEW.input_datetime := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER fall_fe_tr_ins_tr
  BEFORE INSERT
  ON db2frontend_in.fall_fe
  FOR EACH ROW
  EXECUTE PROCEDURE db2frontend_in.fall_fe_tr_ins_fkt();


------------------------------------------------------
-- Comments on Tables in Schema "db2frontend_in" --
------------------------------------------------------
-- Output off
\o /dev/null

comment on column db2frontend_in.patient_fe.patient_fe_id is 'Primary key of the entity';
comment on column db2frontend_in.patient_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
comment on column db2frontend_in.patient_fe.pat_header is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.patient_fe.pat_id is 'Patient-identifier FHIR Daten (varchar)';
comment on column db2frontend_in.patient_fe.pat_cis_pid is 'Patient Identifier aus dem Krankenhausinformationssystem - so wie es dem Apotheker zur verfügung steht (varchar)';
comment on column db2frontend_in.patient_fe.redcap_repeat_instrument is 'Frontend interne Datensatzverwaltung - Instrument :  patient (varchar)';
comment on column db2frontend_in.patient_fe.redcap_repeat_instance is 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1 (varchar)';
comment on column db2frontend_in.patient_fe.pat_name is 'Patientenname (varchar)';
comment on column db2frontend_in.patient_fe.pat_vorname is 'Patientenvorname (varchar)';
comment on column db2frontend_in.patient_fe.pat_gebdat is 'Geburtsdatum (date)';
comment on column db2frontend_in.patient_fe.pat_aktuell_alter is 'aktuelles Patientenalter (Jahre) (double precision)';
comment on column db2frontend_in.patient_fe.pat_geschlecht is 'Geschlecht (wie in FHIR) (varchar)';
comment on column db2frontend_in.patient_fe.patient_complete is 'Frontend Complete-Status (varchar)';
comment on column db2frontend_in.patient_fe.input_datetime is 'Time at which the data record is inserted';
comment on column db2frontend_in.patient_fe.last_check_datetime is 'Time at which data record was last checked';
comment on column db2frontend_in.patient_fe.current_dataset_status is 'Processing status of the data record';

comment on column db2frontend_in.fall_fe.fall_fe_id is 'Primary key of the entity';
comment on column db2frontend_in.fall_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
comment on column db2frontend_in.fall_fe.fall_header is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_id is 'Fall-ID RedCap FHIR Daten (varchar)';
comment on column db2frontend_in.fall_fe.fall_pat_id is 'Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id) (varchar)';
comment on column db2frontend_in.fall_fe.patient_id_fk is 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)';
comment on column db2frontend_in.fall_fe.fall_femb is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.redcap_repeat_instrument is 'Frontend interne Datensatzverwaltung - Instrument :   fall (varchar)';
comment on column db2frontend_in.fall_fe.redcap_repeat_instance is 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)';
comment on column db2frontend_in.fall_fe.fall_studienphase is 'Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) ) (varchar)';
comment on column db2frontend_in.fall_fe.fall_station is 'Station wie vom DIZ Definiert (varchar)';
comment on column db2frontend_in.fall_fe.fall_aufn_dat is 'Aufnahmedatum (date)';
comment on column db2frontend_in.fall_fe.fall_aufn_diag is 'Diagnose(n) bei Aufnahme (wird nur zum lesen sein (varchar)';
comment on column db2frontend_in.fall_fe.fall_gewicht_aktuell is 'aktuelles Gewicht (Kg) (double precision)';
comment on column db2frontend_in.fall_fe.fall_gewicht_aktl_einheit is 'Einheit des Gewichts (varchar)';
comment on column db2frontend_in.fall_fe.fall_groesse is 'Größe (cm) (double precision)';
comment on column db2frontend_in.fall_fe.fall_groesse_einheit is 'Einheit der Größe (varchar)';
comment on column db2frontend_in.fall_fe.fall_bmi is 'BMI (double precision)';
comment on column db2frontend_in.fall_fe.fall_femb_2 is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_femb_3 is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_femb_4 is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_nieren_insuf_chron is '1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (varchar)';
comment on column db2frontend_in.fall_fe.fall_nieren_insuf_ausmass_lbl is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_nieren_insuf_ausmass is '1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, &lt; 15 ml/min/1,73 m2 (varchar)';
comment on column db2frontend_in.fall_fe.fall_nieren_insuf_dialysev_lbl is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_nieren_insuf_dialysev is '1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (varchar)';
comment on column db2frontend_in.fall_fe.fall_leber_insuf is '1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (varchar)';
comment on column db2frontend_in.fall_fe.fall_leber_insuf_ausmass_lbl is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_leber_insuf_ausmass is '1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß (varchar)';
comment on column db2frontend_in.fall_fe.fall_schwanger_mo is '0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9 (varchar)';
comment on column db2frontend_in.fall_fe.fall_op_geplant is '1, ja | 0, nein | -1, nicht bekanntIst eine Operation geplant? (varchar)';
comment on column db2frontend_in.fall_fe.fall_op_dat_lbl is 'descriptive item only for frontend (varchar)';
comment on column db2frontend_in.fall_fe.fall_op_dat is 'Operationsdatum (date)';
comment on column db2frontend_in.fall_fe.fall_status is 'Status des Falls (varchar)';
comment on column db2frontend_in.fall_fe.fall_ent_dat is 'Entlassdatum (date)';
comment on column db2frontend_in.fall_fe.fall_complete is 'Frontend Complete-Status (varchar)';
comment on column db2frontend_in.fall_fe.input_datetime is 'Time at which the data record is inserted';
comment on column db2frontend_in.fall_fe.last_check_datetime is 'Time at which data record was last checked';
comment on column db2frontend_in.fall_fe.current_dataset_status is 'Processing status of the data record';


-- Output on
\o

