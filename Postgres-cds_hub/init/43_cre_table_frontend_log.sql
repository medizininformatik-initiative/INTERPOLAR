-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-01-13 09:38:21
-- Rights definition file size        : 15240 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2025-02-08 12:23:44
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  43_cre_table_frontend_log.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db_log_user
-- OWNER_SCHEMA:  db_log
-- TAGS:  INT_ID
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _fe
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  db_log_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  62_fe_in_to_db_log.sql
-- COPY_FUNC_TEMPLATE:  template_copy_function.sql
-- COPY_FUNC_NAME:  copy_fe_fe_in_to_db_log
-- SCHEMA_2:  db2frontend_in
-- TABLE_POSTFIX_2:  _fe
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "db_log" --
-----------------------------------------------------

-- Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.patient_fe (
  patient_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  redcap_repeat_instrument varchar,   -- Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (varchar)
  redcap_repeat_instance varchar,   -- Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (varchar)
  pat_header varchar,   -- descriptive item only for frontend (varchar)
  pat_id varchar,   -- Patient-identifier FHIR Daten (varchar)
  pat_femb_1 varchar,   -- descriptive item only for frontend - Fieldembedding (femb) der Variablen pat_cis_pid, pat_name, pat_vorname, pat_gebdat,pat_geschlecht (varchar)
  pat_cis_pid varchar,   -- Patient Identifier aus dem Krankenhausinformationssystem - so wie es dem Apotheker zur verfügung steht (varchar)
  pat_name varchar,   -- Patientenname (varchar)
  pat_vorname varchar,   -- Patientenvorname (varchar)
  pat_gebdat date,   -- Geburtsdatum (date)
  pat_aktuell_alter double precision,   -- aktuelles Patientenalter (Jahre) (double precision)
  pat_geschlecht varchar,   -- Geschlecht (wie in FHIR) (varchar)
  patient_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(pat_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (pat_header)
             COALESCE(db.to_char_immutable(pat_id), '#NULL#') || '|||' || -- hash from: Patient-identifier FHIR Daten (pat_id)
             COALESCE(db.to_char_immutable(pat_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Fieldembedding (femb) der Variablen pat_cis_pid, pat_name, pat_vorname, pat_gebdat,pat_geschlecht (pat_femb_1)
             COALESCE(db.to_char_immutable(pat_cis_pid), '#NULL#') || '|||' || -- hash from: Patient Identifier aus dem Krankenhausinformationssystem - so wie es dem Apotheker zur verfügung steht (pat_cis_pid)
             COALESCE(db.to_char_immutable(pat_name), '#NULL#') || '|||' || -- hash from: Patientenname (pat_name)
             COALESCE(db.to_char_immutable(pat_vorname), '#NULL#') || '|||' || -- hash from: Patientenvorname (pat_vorname)
             COALESCE(db.to_char_immutable(pat_gebdat), '#NULL#') || '|||' || -- hash from: Geburtsdatum (pat_gebdat)
             COALESCE(db.to_char_immutable(pat_aktuell_alter), '#NULL#') || '|||' || -- hash from: aktuelles Patientenalter (Jahre) (pat_aktuell_alter)
             COALESCE(db.to_char_immutable(pat_geschlecht), '#NULL#') || '|||' || -- hash from: Geschlecht (wie in FHIR) (pat_geschlecht)
             COALESCE(db.to_char_immutable(patient_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (patient_complete)
             '#'
  ) STORED, 							-- Column collection data for index to read and kollion handling 
  hash_index_col TEXT TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(pat_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (pat_header)
             COALESCE(db.to_char_immutable(pat_id), '#NULL#') || '|||' || -- hash from: Patient-identifier FHIR Daten (pat_id)
             COALESCE(db.to_char_immutable(pat_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Fieldembedding (femb) der Variablen pat_cis_pid, pat_name, pat_vorname, pat_gebdat,pat_geschlecht (pat_femb_1)
             COALESCE(db.to_char_immutable(pat_cis_pid), '#NULL#') || '|||' || -- hash from: Patient Identifier aus dem Krankenhausinformationssystem - so wie es dem Apotheker zur verfügung steht (pat_cis_pid)
             COALESCE(db.to_char_immutable(pat_name), '#NULL#') || '|||' || -- hash from: Patientenname (pat_name)
             COALESCE(db.to_char_immutable(pat_vorname), '#NULL#') || '|||' || -- hash from: Patientenvorname (pat_vorname)
             COALESCE(db.to_char_immutable(pat_gebdat), '#NULL#') || '|||' || -- hash from: Geburtsdatum (pat_gebdat)
             COALESCE(db.to_char_immutable(pat_aktuell_alter), '#NULL#') || '|||' || -- hash from: aktuelles Patientenalter (Jahre) (pat_aktuell_alter)
             COALESCE(db.to_char_immutable(pat_geschlecht), '#NULL#') || '|||' || -- hash from: Geschlecht (wie in FHIR) (pat_geschlecht)
             COALESCE(db.to_char_immutable(patient_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (patient_complete)
             '#'
      )
  ) STORED,							-- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.fall_fe (
  fall_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  fall_header varchar,   -- descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanz  (varchar)
  fall_id varchar,   -- Fall-ID RedCap FHIR Daten (varchar)
  fall_pat_id varchar,   -- Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id) (varchar)
  patient_id_fk int,   -- Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)
  fall_femb_1 varchar,   -- descriptive item only for frontend - femb der Variablen fall_id, fall_station, fall_aufn_dat, fall_zimmernr, fall_aufn_diag, fall_gewicht_aktuell, fall_gewicht_aktl_einheit, fall_groesse, fall_groesse_einheit (varchar)
  redcap_repeat_instrument varchar,   -- Frontend interne Datensatzverwaltung - Instrument :   fall (varchar)
  redcap_repeat_instance varchar,   -- Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)
  fall_studienphase varchar,   -- Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) ) (varchar)
  fall_station varchar,   -- Station wie vom DIZ Definiert (varchar)
  fall_zimmernr varchar,   -- Zimmernummer wie vom DIZ Definiert (varchar)
  fall_aufn_dat timestamp,   -- Aufnahmedatum (timestamp)
  fall_aufn_diag varchar,   -- Diagnose(n) bei Aufnahme (wird nur zum lesen sein (varchar)
  fall_gewicht_aktuell double precision,   -- aktuelles Gewicht (Kg) (double precision)
  fall_gewicht_aktl_einheit varchar,   -- Einheit des Gewichts (varchar)
  fall_groesse double precision,   -- Größe (cm) (double precision)
  fall_groesse_einheit varchar,   -- Einheit der Größe (varchar)
  fall_bmi double precision,   -- BMI (double precision)
  fall_femb_2 varchar,   -- descriptive item only for frontend - femb der Variablen fall_nieren_insuf_chron, fall_nieren_insuf_ausmass_lbl, fall_nieren_insuf_ausmass (varchar)
  fall_femb_3 varchar,   -- descriptive item only for frontend - femb der Variablen fall_nieren_insuf_dialysev_lbl, fall_nieren_insuf_dialysev (varchar)
  fall_femb_4 varchar,   -- descriptive item only for frontend - femb der Variablen fall_leber_insuf, fall_leber_insuf_ausmass_lbl, fall_leber_insuf_ausmass (varchar)
  fall_femb_5 varchar,   -- descriptive item only for frontend - femb der Variablen fall_schwanger_mo_lbl, fall_schwanger_mo (varchar)
  fall_femb_6 varchar,   -- descriptive item only for frontend - femb der Variablen fall_status, fall_ent_dat (varchar)
  fall_nieren_insuf_chron varchar,   -- 1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (varchar)
  fall_nieren_insuf_ausmass_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  fall_nieren_insuf_ausmass varchar,   -- aktuelles Ausmaß - 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2 (varchar)
  fall_nieren_insuf_dialysev_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  fall_nieren_insuf_dialysev varchar,   -- Nierenersatzverfahren - 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (varchar)
  fall_leber_insuf varchar,   -- Leberinsuffizienz - 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (varchar)
  fall_leber_insuf_ausmass_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  fall_leber_insuf_ausmass varchar,   -- aktuelles Ausmaß -1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß  (varchar)
  fall_schwanger_mo varchar,   -- Schwangerschaftsmonat - 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9 (varchar)
  fall_schwanger_mo_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  fall_status varchar,   -- Status des Falls (varchar)
  fall_ent_dat timestamp,   -- Entlassdatum (timestamp)
  fall_complete varchar,   -- Frontend Complete-Status - Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(fall_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanz  (fall_header)
             COALESCE(db.to_char_immutable(fall_id), '#NULL#') || '|||' || -- hash from: Fall-ID RedCap FHIR Daten (fall_id)
             COALESCE(db.to_char_immutable(fall_pat_id), '#NULL#') || '|||' || -- hash from: Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id) (fall_pat_id)
             COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (patient_id_fk)
             COALESCE(db.to_char_immutable(fall_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_id, fall_station, fall_aufn_dat, fall_zimmernr, fall_aufn_diag, fall_gewicht_aktuell, fall_gewicht_aktl_einheit, fall_groesse, fall_groesse_einheit (fall_femb_1)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :   fall (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(fall_studienphase), '#NULL#') || '|||' || -- hash from: Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) ) (fall_studienphase)
             COALESCE(db.to_char_immutable(fall_station), '#NULL#') || '|||' || -- hash from: Station wie vom DIZ Definiert (fall_station)
             COALESCE(db.to_char_immutable(fall_zimmernr), '#NULL#') || '|||' || -- hash from: Zimmernummer wie vom DIZ Definiert (fall_zimmernr)
             COALESCE(db.to_char_immutable(fall_aufn_dat), '#NULL#') || '|||' || -- hash from: Aufnahmedatum (fall_aufn_dat)
             COALESCE(db.to_char_immutable(fall_aufn_diag), '#NULL#') || '|||' || -- hash from: Diagnose(n) bei Aufnahme (wird nur zum lesen sein (fall_aufn_diag)
             COALESCE(db.to_char_immutable(fall_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (Kg) (fall_gewicht_aktuell)
             COALESCE(db.to_char_immutable(fall_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: Einheit des Gewichts (fall_gewicht_aktl_einheit)
             COALESCE(db.to_char_immutable(fall_groesse), '#NULL#') || '|||' || -- hash from: Größe (cm) (fall_groesse)
             COALESCE(db.to_char_immutable(fall_groesse_einheit), '#NULL#') || '|||' || -- hash from: Einheit der Größe (fall_groesse_einheit)
             COALESCE(db.to_char_immutable(fall_bmi), '#NULL#') || '|||' || -- hash from: BMI (fall_bmi)
             COALESCE(db.to_char_immutable(fall_femb_2), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_nieren_insuf_chron, fall_nieren_insuf_ausmass_lbl, fall_nieren_insuf_ausmass (fall_femb_2)
             COALESCE(db.to_char_immutable(fall_femb_3), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_nieren_insuf_dialysev_lbl, fall_nieren_insuf_dialysev (fall_femb_3)
             COALESCE(db.to_char_immutable(fall_femb_4), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_leber_insuf, fall_leber_insuf_ausmass_lbl, fall_leber_insuf_ausmass (fall_femb_4)
             COALESCE(db.to_char_immutable(fall_femb_5), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_schwanger_mo_lbl, fall_schwanger_mo (fall_femb_5)
             COALESCE(db.to_char_immutable(fall_femb_6), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_status, fall_ent_dat (fall_femb_6)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_chron), '#NULL#') || '|||' || -- hash from: 1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (fall_nieren_insuf_chron)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_ausmass_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_nieren_insuf_ausmass_lbl)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß - 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2 (fall_nieren_insuf_ausmass)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_dialysev_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_nieren_insuf_dialysev_lbl)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_dialysev), '#NULL#') || '|||' || -- hash from: Nierenersatzverfahren - 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (fall_nieren_insuf_dialysev)
             COALESCE(db.to_char_immutable(fall_leber_insuf), '#NULL#') || '|||' || -- hash from: Leberinsuffizienz - 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (fall_leber_insuf)
             COALESCE(db.to_char_immutable(fall_leber_insuf_ausmass_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_leber_insuf_ausmass_lbl)
             COALESCE(db.to_char_immutable(fall_leber_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß -1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß  (fall_leber_insuf_ausmass)
             COALESCE(db.to_char_immutable(fall_schwanger_mo), '#NULL#') || '|||' || -- hash from: Schwangerschaftsmonat - 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9 (fall_schwanger_mo)
             COALESCE(db.to_char_immutable(fall_schwanger_mo_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_schwanger_mo_lbl)
             COALESCE(db.to_char_immutable(fall_status), '#NULL#') || '|||' || -- hash from: Status des Falls (fall_status)
             COALESCE(db.to_char_immutable(fall_ent_dat), '#NULL#') || '|||' || -- hash from: Entlassdatum (fall_ent_dat)
             COALESCE(db.to_char_immutable(fall_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - Incomplete | 1, Unverified | 2, Complete (fall_complete)
             '#'
  ) STORED, 							-- Column collection data for index to read and kollion handling 
  hash_index_col TEXT TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(fall_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanz  (fall_header)
             COALESCE(db.to_char_immutable(fall_id), '#NULL#') || '|||' || -- hash from: Fall-ID RedCap FHIR Daten (fall_id)
             COALESCE(db.to_char_immutable(fall_pat_id), '#NULL#') || '|||' || -- hash from: Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id) (fall_pat_id)
             COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (patient_id_fk)
             COALESCE(db.to_char_immutable(fall_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_id, fall_station, fall_aufn_dat, fall_zimmernr, fall_aufn_diag, fall_gewicht_aktuell, fall_gewicht_aktl_einheit, fall_groesse, fall_groesse_einheit (fall_femb_1)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :   fall (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(fall_studienphase), '#NULL#') || '|||' || -- hash from: Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) ) (fall_studienphase)
             COALESCE(db.to_char_immutable(fall_station), '#NULL#') || '|||' || -- hash from: Station wie vom DIZ Definiert (fall_station)
             COALESCE(db.to_char_immutable(fall_zimmernr), '#NULL#') || '|||' || -- hash from: Zimmernummer wie vom DIZ Definiert (fall_zimmernr)
             COALESCE(db.to_char_immutable(fall_aufn_dat), '#NULL#') || '|||' || -- hash from: Aufnahmedatum (fall_aufn_dat)
             COALESCE(db.to_char_immutable(fall_aufn_diag), '#NULL#') || '|||' || -- hash from: Diagnose(n) bei Aufnahme (wird nur zum lesen sein (fall_aufn_diag)
             COALESCE(db.to_char_immutable(fall_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (Kg) (fall_gewicht_aktuell)
             COALESCE(db.to_char_immutable(fall_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: Einheit des Gewichts (fall_gewicht_aktl_einheit)
             COALESCE(db.to_char_immutable(fall_groesse), '#NULL#') || '|||' || -- hash from: Größe (cm) (fall_groesse)
             COALESCE(db.to_char_immutable(fall_groesse_einheit), '#NULL#') || '|||' || -- hash from: Einheit der Größe (fall_groesse_einheit)
             COALESCE(db.to_char_immutable(fall_bmi), '#NULL#') || '|||' || -- hash from: BMI (fall_bmi)
             COALESCE(db.to_char_immutable(fall_femb_2), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_nieren_insuf_chron, fall_nieren_insuf_ausmass_lbl, fall_nieren_insuf_ausmass (fall_femb_2)
             COALESCE(db.to_char_immutable(fall_femb_3), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_nieren_insuf_dialysev_lbl, fall_nieren_insuf_dialysev (fall_femb_3)
             COALESCE(db.to_char_immutable(fall_femb_4), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_leber_insuf, fall_leber_insuf_ausmass_lbl, fall_leber_insuf_ausmass (fall_femb_4)
             COALESCE(db.to_char_immutable(fall_femb_5), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_schwanger_mo_lbl, fall_schwanger_mo (fall_femb_5)
             COALESCE(db.to_char_immutable(fall_femb_6), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen fall_status, fall_ent_dat (fall_femb_6)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_chron), '#NULL#') || '|||' || -- hash from: 1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (fall_nieren_insuf_chron)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_ausmass_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_nieren_insuf_ausmass_lbl)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß - 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2 (fall_nieren_insuf_ausmass)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_dialysev_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_nieren_insuf_dialysev_lbl)
             COALESCE(db.to_char_immutable(fall_nieren_insuf_dialysev), '#NULL#') || '|||' || -- hash from: Nierenersatzverfahren - 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (fall_nieren_insuf_dialysev)
             COALESCE(db.to_char_immutable(fall_leber_insuf), '#NULL#') || '|||' || -- hash from: Leberinsuffizienz - 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (fall_leber_insuf)
             COALESCE(db.to_char_immutable(fall_leber_insuf_ausmass_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_leber_insuf_ausmass_lbl)
             COALESCE(db.to_char_immutable(fall_leber_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß -1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß  (fall_leber_insuf_ausmass)
             COALESCE(db.to_char_immutable(fall_schwanger_mo), '#NULL#') || '|||' || -- hash from: Schwangerschaftsmonat - 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9 (fall_schwanger_mo)
             COALESCE(db.to_char_immutable(fall_schwanger_mo_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (fall_schwanger_mo_lbl)
             COALESCE(db.to_char_immutable(fall_status), '#NULL#') || '|||' || -- hash from: Status des Falls (fall_status)
             COALESCE(db.to_char_immutable(fall_ent_dat), '#NULL#') || '|||' || -- hash from: Entlassdatum (fall_ent_dat)
             COALESCE(db.to_char_immutable(fall_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - Incomplete | 1, Unverified | 2, Complete (fall_complete)
             '#'
      )
  ) STORED,							-- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.medikationsanalyse_fe (
  medikationsanalyse_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  meda_header varchar,   -- descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (varchar)
  meda_femb_1 varchar,   -- descriptive item only for frontend - femb der Variable meda_dat (varchar)
  meda_femb_2 varchar,   -- descriptive item only for frontend - femb der Variable meda_ma_thueberw (varchar)
  meda_femb_3 varchar,   -- descriptive item only for frontend - femb der Variablen meda_mrp_detekt, meda_aufwand_zeit, meda_aufwand_zeit_and_lbl, meda_aufwand_zeit_and, meda_notiz (varchar)
  fall_fe_id int,   -- Datenbank-FK des Falls (Fall: v_fall_all . fall_id) -> Dataprocessor setzt id: meda_dat in [fall_aufn_dat;fall_ent_dat] (int)
  redcap_repeat_instrument varchar,   -- Frontend interne Datensatzverwaltung - Instrument :  medikationsanalyse (varchar)
  redcap_repeat_instance varchar,   -- Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)
  meda_dat timestamp,   -- Datum der Medikationsanalyse (timestamp)
  meda_typ varchar,   -- Typ der Medikationsanalyse - 1, Typ 1: Einfache MA | 2a, Typ 2a: Erweiterte MA | 2b, Typ 2b: Erweiterte MA | 3, Typ 3: Umfassende MA  (varchar)
  meda_ma_thueberw varchar,   -- Medikationsanalyse / Therapieüberwachung in 24-48h - 1, Ja | 0, Nein (varchar)
  meda_mrp_detekt varchar,   -- MRP detektiert? - 1, Ja|0, Nein (varchar)
  meda_aufwand_zeit varchar,   -- Zeitaufwand Medikationsanalyse - 0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min] (varchar)
  meda_aufwand_zeit_and_lbl int,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (int)
  meda_aufwand_zeit_and int,   -- genaue Dauer in Minuten (int)
  meda_notiz varchar,   -- Notizfeld (varchar)
  medikationsanalyse_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(meda_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (meda_header)
             COALESCE(db.to_char_immutable(meda_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable meda_dat (meda_femb_1)
             COALESCE(db.to_char_immutable(meda_femb_2), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable meda_ma_thueberw (meda_femb_2)
             COALESCE(db.to_char_immutable(meda_femb_3), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen meda_mrp_detekt, meda_aufwand_zeit, meda_aufwand_zeit_and_lbl, meda_aufwand_zeit_and, meda_notiz (meda_femb_3)
             COALESCE(db.to_char_immutable(fall_fe_id), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Falls (Fall: v_fall_all . fall_id) -> Dataprocessor setzt id: meda_dat in [fall_aufn_dat;fall_ent_dat] (fall_fe_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  medikationsanalyse (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(meda_dat), '#NULL#') || '|||' || -- hash from: Datum der Medikationsanalyse (meda_dat)
             COALESCE(db.to_char_immutable(meda_typ), '#NULL#') || '|||' || -- hash from: Typ der Medikationsanalyse - 1, Typ 1: Einfache MA | 2a, Typ 2a: Erweiterte MA | 2b, Typ 2b: Erweiterte MA | 3, Typ 3: Umfassende MA  (meda_typ)
             COALESCE(db.to_char_immutable(meda_ma_thueberw), '#NULL#') || '|||' || -- hash from: Medikationsanalyse / Therapieüberwachung in 24-48h - 1, Ja | 0, Nein (meda_ma_thueberw)
             COALESCE(db.to_char_immutable(meda_mrp_detekt), '#NULL#') || '|||' || -- hash from: MRP detektiert? - 1, Ja|0, Nein (meda_mrp_detekt)
             COALESCE(db.to_char_immutable(meda_aufwand_zeit), '#NULL#') || '|||' || -- hash from: Zeitaufwand Medikationsanalyse - 0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min] (meda_aufwand_zeit)
             COALESCE(db.to_char_immutable(meda_aufwand_zeit_and_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (meda_aufwand_zeit_and_lbl)
             COALESCE(db.to_char_immutable(meda_aufwand_zeit_and), '#NULL#') || '|||' || -- hash from: genaue Dauer in Minuten (meda_aufwand_zeit_and)
             COALESCE(db.to_char_immutable(meda_notiz), '#NULL#') || '|||' || -- hash from: Notizfeld (meda_notiz)
             COALESCE(db.to_char_immutable(medikationsanalyse_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (medikationsanalyse_complete)
             '#'
  ) STORED, 							-- Column collection data for index to read and kollion handling 
  hash_index_col TEXT TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(meda_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (meda_header)
             COALESCE(db.to_char_immutable(meda_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable meda_dat (meda_femb_1)
             COALESCE(db.to_char_immutable(meda_femb_2), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable meda_ma_thueberw (meda_femb_2)
             COALESCE(db.to_char_immutable(meda_femb_3), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen meda_mrp_detekt, meda_aufwand_zeit, meda_aufwand_zeit_and_lbl, meda_aufwand_zeit_and, meda_notiz (meda_femb_3)
             COALESCE(db.to_char_immutable(fall_fe_id), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Falls (Fall: v_fall_all . fall_id) -> Dataprocessor setzt id: meda_dat in [fall_aufn_dat;fall_ent_dat] (fall_fe_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  medikationsanalyse (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(meda_dat), '#NULL#') || '|||' || -- hash from: Datum der Medikationsanalyse (meda_dat)
             COALESCE(db.to_char_immutable(meda_typ), '#NULL#') || '|||' || -- hash from: Typ der Medikationsanalyse - 1, Typ 1: Einfache MA | 2a, Typ 2a: Erweiterte MA | 2b, Typ 2b: Erweiterte MA | 3, Typ 3: Umfassende MA  (meda_typ)
             COALESCE(db.to_char_immutable(meda_ma_thueberw), '#NULL#') || '|||' || -- hash from: Medikationsanalyse / Therapieüberwachung in 24-48h - 1, Ja | 0, Nein (meda_ma_thueberw)
             COALESCE(db.to_char_immutable(meda_mrp_detekt), '#NULL#') || '|||' || -- hash from: MRP detektiert? - 1, Ja|0, Nein (meda_mrp_detekt)
             COALESCE(db.to_char_immutable(meda_aufwand_zeit), '#NULL#') || '|||' || -- hash from: Zeitaufwand Medikationsanalyse - 0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min] (meda_aufwand_zeit)
             COALESCE(db.to_char_immutable(meda_aufwand_zeit_and_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (meda_aufwand_zeit_and_lbl)
             COALESCE(db.to_char_immutable(meda_aufwand_zeit_and), '#NULL#') || '|||' || -- hash from: genaue Dauer in Minuten (meda_aufwand_zeit_and)
             COALESCE(db.to_char_immutable(meda_notiz), '#NULL#') || '|||' || -- hash from: Notizfeld (meda_notiz)
             COALESCE(db.to_char_immutable(medikationsanalyse_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (medikationsanalyse_complete)
             '#'
      )
  ) STORED,							-- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.mrpdokumentation_validierung_fe (
  mrpdokumentation_validierung_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  meda_fe_id int,   -- Datenbank-FK der Medikationsanalyse (Medikationsanalyse: medikationsanalyse_fe_id) -> Dataprocessor setzt id: mrp_entd_dat(Tag)=meda_dat(Tag) (int)
  redcap_repeat_instrument varchar,   -- Frontend interne Datensatzverwaltung - Instrument :  MRP-Dokumentation / -Validierung  (varchar)
  redcap_repeat_instance varchar,   -- Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)
  mrp_header varchar,   -- descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (varchar)
  mrp_femb_1 varchar,   -- descriptive item only for frontend - femb der Variable mrp_entd_dat (varchar)
  mrp_femb_2 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_kurzbeschr, mrp_entd_algorithmisch, mrp_hinweisgeber_lbl, mrp_hinweisgeber (varchar)
  mrp_femb_3 varchar,   -- descriptive item only for frontend - femb der Variable mrp_hinweisgeber_oth (varchar)
  mrp_pi_info varchar,   -- descriptive item only for frontend (varchar)
  mrp_pi_info___1 varchar,   -- descriptive item only for frontend (varchar)
  mrp_mf_info varchar,   -- descriptive item only for frontend (varchar)
  mrp_mf_info___1 varchar,   -- descriptive item only for frontend (varchar)
  mrp_pi_info_txt varchar,   -- descriptive item only for frontend (varchar)
  mrp_mf_info_txt varchar,   -- descriptive item only for frontend (varchar)
  mrp_femb_4 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_gewissheit_lbl, mrp_gewissheit (varchar)
  mrp_femb_5 varchar,   -- descriptive item only for frontend - femb der Variable mrp_gewissheit_oth (varchar)
  mrp_femb_6 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_lbl, mrp_gewiss_grund_abl (varchar)
  mrp_entd_dat timestamp,   -- Datum des MRP (timestamp)
  mrp_kurzbeschr varchar,   -- Kurzbeschreibung des MRPs (varchar)
  mrp_entd_algorithmisch varchar,   -- MRP vom INTERPOLAR-Algorithmus entdeckt? - 1, Ja | 0, Nein (varchar)
  mrp_hinweisgeber_lbl varchar,   -- descriptive item only for frontend (varchar)
  mrp_hinweisgeber varchar,   -- Hinweisgeber auf das MRP (varchar)
  mrp_gewissheit_lbl varchar,   -- descriptive item only for frontend (varchar)
  mrp_gewissheit varchar,   -- Sicherheit des detektierten MRP - 1, MRP bestätigt | 2, MRP möglich, weitere Informationen nötig | 3, MRP nicht bestätigt (varchar)
  mrp_femb_22 varchar,   -- descriptive item only for frontend - femb der Variablen (varchar)
  mrp_gewissheit_oth varchar,   -- Textfeld, wenn mrp_gewissheit = 2 MRP möglich, weitere Informationen nötig (varchar)
  mrp_femb_23 varchar,   -- descriptive item only for frontend (varchar)
  mrp_hinweisgeber_oth varchar,   -- Textfeld, wenn mrp_hinweisgeber = 7 (andere) (varchar)
  mrp_gewiss_grund_abl_lbl varchar,   -- descriptive item only for frontend (varchar)
  mrp_gewiss_grund_abl varchar,   -- Grund für nicht Bestätigung - 1, MRP sachlich falsch (keine Kontraindikation) | 2, MRP sachlich richtig, aber falsche Datengrundlage | 3, MRP sachlich richtig, aber klinisch nicht relevant | 4, MRP sachlich richtig, aber von Stationsapotheker vorher identifiziert | 5, Sonstiges (varchar)
  mrp_gewiss_grund_abl_sonst_lbl varchar,   -- descriptive item only for frontend (varchar)
  mrp_gewiss_grund_abl_sonst varchar,   -- Bitte näher beschreiben (varchar)
  mrp_femb_7 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_sonst_lbl, mrp_gewiss_grund_abl_sonst (varchar)
  mrp_femb_8 varchar,   -- descriptive item only for frontend - femb der Variable mrp_wirkstoff (varchar)
  mrp_femb_9 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_atc1_lbl, mrp_atc1 (varchar)
  mrp_femb_10 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_atc2_lbl, mrp_atc2 (varchar)
  mrp_femb_11 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_atc3_lbl, mrp_atc3 (varchar)
  mrp_femb_12 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_atc4_lbl, mrp_atc4 (varchar)
  mrp_wirkstoff varchar,   -- Wirkstoff betroffen? - 1, Ja | 0, Nein (varchar)
  mrp_atc1_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_atc1 varchar,   -- 1. Medikament ATC / Name- https://www.bfarm.de/SharedDocs/Downloads/DE/Kodiersysteme/ATC/atc-ddd-amtlich-2024.pdf?__blob=publicationFile (varchar)
  mrp_atc2_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_atc2 varchar,   -- 2. Medikament ATC / Name (varchar)
  mrp_atc3_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_atc3 varchar,   -- 3. Medikament ATC / Name (varchar)
  mrp_atc4_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_atc4 varchar,   -- 4. Medikament ATC / Name (varchar)
  mrp_atc5_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_atc5 varchar,   -- 5. Medikament ATC / Name (varchar)
  mrp_femb_13 varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_med_prod varchar,   -- Medizinprodukt betroffen? - 1, Ja | 0, Nein, (varchar)
  mrp_med_prod_sonst_lbl varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_med_prod_sonst varchar,   -- Bezeichnung Präparat (varchar)
  mrp_dokup_fehler varchar,   -- Frage / Fehlerbeschreibung (varchar)
  mrp_dokup_intervention varchar,   -- Intervention / Vorschlag zur Fehlervermeldung (varchar)
  mrp_femb_14 varchar,   -- descriptive item only for frontend - femb der Variablen mrp_med_prod, mrp_med_prod_sonst_lbl, mrp_med_prod_sonst (varchar)
  mrp_pigrund varchar,   -- PI-Grund (varchar)
  mrp_pigrund___1 varchar,   -- 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)
  mrp_pigrund___2 varchar,   -- 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)
  mrp_pigrund___3 varchar,   -- 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)
  mrp_pigrund___4 varchar,   -- 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)
  mrp_pigrund___5 varchar,   -- 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)
  mrp_pigrund___6 varchar,   -- 6 - AM: Übertragungsfehler (MF) (varchar)
  mrp_pigrund___7 varchar,   -- 7 - AM: Substitution aut idem/aut simile (MF) (varchar)
  mrp_pigrund___8 varchar,   -- 8 - AM: (Klare) Indikation, aber kein Medikament angeordnet (MF) (varchar)
  mrp_pigrund___9 varchar,   -- 9 - AM: Stellfehler (MF) (varchar)
  mrp_pigrund___10 varchar,   -- 10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (varchar)
  mrp_pigrund___11 varchar,   -- 11 - AM: Doppelverordnung (MF) (varchar)
  mrp_pigrund___12 varchar,   -- 12 - ANW: Applikation (Dauer) (MF) (varchar)
  mrp_pigrund___13 varchar,   -- 13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (varchar)
  mrp_pigrund___14 varchar,   -- 14 - ANW: Applikation (Art) (MF) (varchar)
  mrp_pigrund___15 varchar,   -- 15 - ANW: Anfrage zur Administration/Kompatibilität (varchar)
  mrp_pigrund___16 varchar,   -- 16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (varchar)
  mrp_pigrund___17 varchar,   -- 17 - D: (Fehlerhafte) Dosis (MF) (varchar)
  mrp_pigrund___18 varchar,   -- 18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (varchar)
  mrp_pigrund___19 varchar,   -- 19 - D: (Fehlerhaftes) Dosisinterval (MF) (varchar)
  mrp_pigrund___20 varchar,   -- 20 - Interaktion (MF) (varchar)
  mrp_pigrund___21 varchar,   -- 21 - Kontraindikation (MF) (varchar)
  mrp_pigrund___22 varchar,   -- 22 - Nebenwirkungen (varchar)
  mrp_pigrund___23 varchar,   -- 23 - S: Beratung/Auswahl eines Arzneistoffs (varchar)
  mrp_pigrund___24 varchar,   -- 24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (varchar)
  mrp_pigrund___25 varchar,   -- 25 - S: Beschaffung/Kosten (varchar)
  mrp_pigrund___26 varchar,   -- 26 - S: Keine Pause von AM, die prä-OP pausiert werden müssen (MF) (varchar)
  mrp_pigrund___27 varchar,   -- 27 - S: Schulung/Beratung eines Patienten (varchar)
  mrp_femb_15 varchar,   -- descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)
  mrp_ip_klasse varchar,   -- MRP-Klasse (INTERPOLAR) (varchar)
  mrp_ip_klasse___1 varchar,   -- 1 - Drug - Drug (varchar)
  mrp_ip_klasse___2 varchar,   -- 2 - Drug - Drug-Group (varchar)
  mrp_ip_klasse___3 varchar,   -- 3 - Drug - Disease (varchar)
  mrp_ip_klasse___4 varchar,   -- 4 - Drug - Labor (varchar)
  mrp_ip_klasse___5 varchar,   -- 5 - Drug - Age (Priscus 2.0 o. Dosis) (varchar)
  mrp_femb_16 varchar,   -- descriptive item only for frontend - femb der Variable mrp_ip_klasse (varchar)
  mrp_femb_17 varchar,   -- descriptive item only for frontend - femb der Variable mrp_ip_klasse_disease (varchar)
  mrp_ip_klasse_disease varchar,   -- Disease (varchar)
  mrp_ip_klasse_labor varchar,   -- Labor (varchar)
  mrp_femb_18 varchar,   -- descriptive item only for frontend - femb der Variable mrp_ip_klasse_labor (varchar)
  mrp_massn_am varchar,   -- AM: Arzneimitte (varchar)
  mrp_massn_am___1 varchar,   -- 1 - Anweisung für die Applikation geben (varchar)
  mrp_massn_am___2 varchar,   -- 2 - Arzneimittel ändern (varchar)
  mrp_massn_am___3 varchar,   -- 3 - Arzneimittel stoppen/pausieren (varchar)
  mrp_massn_am___4 varchar,   -- 4 - Arzneimittel neu ansetzen (varchar)
  mrp_massn_am___5 varchar,   -- 5 - Dosierung ändern (varchar)
  mrp_massn_am___6 varchar,   -- 6 - Formulierung ändern (varchar)
  mrp_massn_am___7 varchar,   -- 7 - Hilfe bei Beschaffung (varchar)
  mrp_massn_am___8 varchar,   -- 8 - Information an Arzt/Pflege (varchar)
  mrp_massn_am___9 varchar,   -- 9 - Information an Patient (varchar)
  mrp_massn_am___10 varchar,   -- 10 - TDM oder Laborkontrolle emfohlen (varchar)
  mrp_femb_19 varchar,   -- descriptive item only for frontend - femb der Variable mrp_massn_am (varchar)
  mrp_massn_orga varchar,   -- ORGA: Organisatorisch (varchar)
  mrp_massn_orga___1 varchar,   -- 1 - Aushändigung einer Information/eines Medikationsplans (varchar)
  mrp_massn_orga___2 varchar,   -- 2 - CIRS-/AMK-Meldung (varchar)
  mrp_massn_orga___3 varchar,   -- 3 - Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers (varchar)
  mrp_massn_orga___4 varchar,   -- 4 - Etablierung einer Doppelkontrolle (varchar)
  mrp_massn_orga___5 varchar,   -- 5 - Lieferantenwechsel (varchar)
  mrp_massn_orga___6 varchar,   -- 6 - Optimierung der internen und externene Kommunikation (varchar)
  mrp_massn_orga___7 varchar,   -- 7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)
  mrp_massn_orga___8 varchar,   -- 8 - Sensibilisierung/Schulung (varchar)
  mrp_femb_20 varchar,   -- descriptive item only for frontend - femb der Variable mrp_massn_orga (varchar)
  mrp_notiz varchar,   -- Notiz (varchar)
  mrp_femb_21 varchar,   -- descriptive item only for frontend - femb der Variable mrp_notiz (varchar)
  mrp_dokup_hand_emp_akz varchar,   -- Handlungsempfehlung akzeptiert? - 1, Arzt / Pflege informiert | 2, Intervention vorgeschlagen und umgesetzt | 3, Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation) | 4 , Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung) | 5, Intervention vorgeschlagen, Umsetzung unbekannt | 6, Problem nicht gelöst (varchar)
  mrp_merp varchar,   -- NCC MERP Score - A, Category A | B, Category B | C, Category C | D, Category D | E, Category E | F, Category F | G, Category G | H, Category H | I, Category I  (varchar)
  mrp_merp_info varchar,   -- descriptive item only for frontend (varchar)
  mrp_merp_info___1 varchar,   -- descriptive item only for frontend - Blendet NCC MERP Index ein/aus (varchar)
  mrp_merp_txt varchar,   -- descriptive item only for frontend - Beinhaltet NCC MERP Index als PDF (varchar)
  mrpdokumentation_validierung_complete varchar,   -- Frontend Complete-Status, wenn ein Pflichtitem fehlt Status bei Import wieder auf Incomplete setzen  - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(meda_fe_id), '#NULL#') || '|||' || -- hash from: Datenbank-FK der Medikationsanalyse (Medikationsanalyse: medikationsanalyse_fe_id) -> Dataprocessor setzt id: mrp_entd_dat(Tag)=meda_dat(Tag) (meda_fe_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  MRP-Dokumentation / -Validierung  (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(mrp_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (mrp_header)
             COALESCE(db.to_char_immutable(mrp_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_entd_dat (mrp_femb_1)
             COALESCE(db.to_char_immutable(mrp_femb_2), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_kurzbeschr, mrp_entd_algorithmisch, mrp_hinweisgeber_lbl, mrp_hinweisgeber (mrp_femb_2)
             COALESCE(db.to_char_immutable(mrp_femb_3), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_hinweisgeber_oth (mrp_femb_3)
             COALESCE(db.to_char_immutable(mrp_pi_info), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_pi_info)
             COALESCE(db.to_char_immutable(mrp_pi_info___1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_pi_info___1)
             COALESCE(db.to_char_immutable(mrp_mf_info), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_mf_info)
             COALESCE(db.to_char_immutable(mrp_mf_info___1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_mf_info___1)
             COALESCE(db.to_char_immutable(mrp_pi_info_txt), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_pi_info_txt)
             COALESCE(db.to_char_immutable(mrp_mf_info_txt), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_mf_info_txt)
             COALESCE(db.to_char_immutable(mrp_femb_4), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_gewissheit_lbl, mrp_gewissheit (mrp_femb_4)
             COALESCE(db.to_char_immutable(mrp_femb_5), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_gewissheit_oth (mrp_femb_5)
             COALESCE(db.to_char_immutable(mrp_femb_6), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_lbl, mrp_gewiss_grund_abl (mrp_femb_6)
             COALESCE(db.to_char_immutable(mrp_entd_dat), '#NULL#') || '|||' || -- hash from: Datum des MRP (mrp_entd_dat)
             COALESCE(db.to_char_immutable(mrp_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs (mrp_kurzbeschr)
             COALESCE(db.to_char_immutable(mrp_entd_algorithmisch), '#NULL#') || '|||' || -- hash from: MRP vom INTERPOLAR-Algorithmus entdeckt? - 1, Ja | 0, Nein (mrp_entd_algorithmisch)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_hinweisgeber_lbl)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber), '#NULL#') || '|||' || -- hash from: Hinweisgeber auf das MRP (mrp_hinweisgeber)
             COALESCE(db.to_char_immutable(mrp_gewissheit_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_gewissheit_lbl)
             COALESCE(db.to_char_immutable(mrp_gewissheit), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP - 1, MRP bestätigt | 2, MRP möglich, weitere Informationen nötig | 3, MRP nicht bestätigt (mrp_gewissheit)
             COALESCE(db.to_char_immutable(mrp_femb_22), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen (mrp_femb_22)
             COALESCE(db.to_char_immutable(mrp_gewissheit_oth), '#NULL#') || '|||' || -- hash from: Textfeld, wenn mrp_gewissheit = 2 MRP möglich, weitere Informationen nötig (mrp_gewissheit_oth)
             COALESCE(db.to_char_immutable(mrp_femb_23), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_femb_23)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber_oth), '#NULL#') || '|||' || -- hash from: Textfeld, wenn mrp_hinweisgeber = 7 (andere) (mrp_hinweisgeber_oth)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_gewiss_grund_abl_lbl)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung - 1, MRP sachlich falsch (keine Kontraindikation) | 2, MRP sachlich richtig, aber falsche Datengrundlage | 3, MRP sachlich richtig, aber klinisch nicht relevant | 4, MRP sachlich richtig, aber von Stationsapotheker vorher identifiziert | 5, Sonstiges (mrp_gewiss_grund_abl)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl_sonst_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_gewiss_grund_abl_sonst_lbl)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl_sonst), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (mrp_gewiss_grund_abl_sonst)
             COALESCE(db.to_char_immutable(mrp_femb_7), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_sonst_lbl, mrp_gewiss_grund_abl_sonst (mrp_femb_7)
             COALESCE(db.to_char_immutable(mrp_femb_8), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_wirkstoff (mrp_femb_8)
             COALESCE(db.to_char_immutable(mrp_femb_9), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc1_lbl, mrp_atc1 (mrp_femb_9)
             COALESCE(db.to_char_immutable(mrp_femb_10), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc2_lbl, mrp_atc2 (mrp_femb_10)
             COALESCE(db.to_char_immutable(mrp_femb_11), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc3_lbl, mrp_atc3 (mrp_femb_11)
             COALESCE(db.to_char_immutable(mrp_femb_12), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc4_lbl, mrp_atc4 (mrp_femb_12)
             COALESCE(db.to_char_immutable(mrp_wirkstoff), '#NULL#') || '|||' || -- hash from: Wirkstoff betroffen? - 1, Ja | 0, Nein (mrp_wirkstoff)
             COALESCE(db.to_char_immutable(mrp_atc1_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc1_lbl)
             COALESCE(db.to_char_immutable(mrp_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name- https://www.bfarm.de/SharedDocs/Downloads/DE/Kodiersysteme/ATC/atc-ddd-amtlich-2024.pdf?__blob=publicationFile (mrp_atc1)
             COALESCE(db.to_char_immutable(mrp_atc2_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc2_lbl)
             COALESCE(db.to_char_immutable(mrp_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (mrp_atc2)
             COALESCE(db.to_char_immutable(mrp_atc3_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc3_lbl)
             COALESCE(db.to_char_immutable(mrp_atc3), '#NULL#') || '|||' || -- hash from: 3. Medikament ATC / Name (mrp_atc3)
             COALESCE(db.to_char_immutable(mrp_atc4_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc4_lbl)
             COALESCE(db.to_char_immutable(mrp_atc4), '#NULL#') || '|||' || -- hash from: 4. Medikament ATC / Name (mrp_atc4)
             COALESCE(db.to_char_immutable(mrp_atc5_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc5_lbl)
             COALESCE(db.to_char_immutable(mrp_atc5), '#NULL#') || '|||' || -- hash from: 5. Medikament ATC / Name (mrp_atc5)
             COALESCE(db.to_char_immutable(mrp_femb_13), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_femb_13)
             COALESCE(db.to_char_immutable(mrp_med_prod), '#NULL#') || '|||' || -- hash from: Medizinprodukt betroffen? - 1, Ja | 0, Nein, (mrp_med_prod)
             COALESCE(db.to_char_immutable(mrp_med_prod_sonst_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_med_prod_sonst_lbl)
             COALESCE(db.to_char_immutable(mrp_med_prod_sonst), '#NULL#') || '|||' || -- hash from: Bezeichnung Präparat (mrp_med_prod_sonst)
             COALESCE(db.to_char_immutable(mrp_dokup_fehler), '#NULL#') || '|||' || -- hash from: Frage / Fehlerbeschreibung (mrp_dokup_fehler)
             COALESCE(db.to_char_immutable(mrp_dokup_intervention), '#NULL#') || '|||' || -- hash from: Intervention / Vorschlag zur Fehlervermeldung (mrp_dokup_intervention)
             COALESCE(db.to_char_immutable(mrp_femb_14), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_med_prod, mrp_med_prod_sonst_lbl, mrp_med_prod_sonst (mrp_femb_14)
             COALESCE(db.to_char_immutable(mrp_pigrund), '#NULL#') || '|||' || -- hash from: PI-Grund (mrp_pigrund)
             COALESCE(db.to_char_immutable(mrp_pigrund___1), '#NULL#') || '|||' || -- hash from: 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (mrp_pigrund___1)
             COALESCE(db.to_char_immutable(mrp_pigrund___2), '#NULL#') || '|||' || -- hash from: 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (mrp_pigrund___2)
             COALESCE(db.to_char_immutable(mrp_pigrund___3), '#NULL#') || '|||' || -- hash from: 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (mrp_pigrund___3)
             COALESCE(db.to_char_immutable(mrp_pigrund___4), '#NULL#') || '|||' || -- hash from: 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (mrp_pigrund___4)
             COALESCE(db.to_char_immutable(mrp_pigrund___5), '#NULL#') || '|||' || -- hash from: 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (mrp_pigrund___5)
             COALESCE(db.to_char_immutable(mrp_pigrund___6), '#NULL#') || '|||' || -- hash from: 6 - AM: Übertragungsfehler (MF) (mrp_pigrund___6)
             COALESCE(db.to_char_immutable(mrp_pigrund___7), '#NULL#') || '|||' || -- hash from: 7 - AM: Substitution aut idem/aut simile (MF) (mrp_pigrund___7)
             COALESCE(db.to_char_immutable(mrp_pigrund___8), '#NULL#') || '|||' || -- hash from: 8 - AM: (Klare) Indikation, aber kein Medikament angeordnet (MF) (mrp_pigrund___8)
             COALESCE(db.to_char_immutable(mrp_pigrund___9), '#NULL#') || '|||' || -- hash from: 9 - AM: Stellfehler (MF) (mrp_pigrund___9)
             COALESCE(db.to_char_immutable(mrp_pigrund___10), '#NULL#') || '|||' || -- hash from: 10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (mrp_pigrund___10)
             COALESCE(db.to_char_immutable(mrp_pigrund___11), '#NULL#') || '|||' || -- hash from: 11 - AM: Doppelverordnung (MF) (mrp_pigrund___11)
             COALESCE(db.to_char_immutable(mrp_pigrund___12), '#NULL#') || '|||' || -- hash from: 12 - ANW: Applikation (Dauer) (MF) (mrp_pigrund___12)
             COALESCE(db.to_char_immutable(mrp_pigrund___13), '#NULL#') || '|||' || -- hash from: 13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (mrp_pigrund___13)
             COALESCE(db.to_char_immutable(mrp_pigrund___14), '#NULL#') || '|||' || -- hash from: 14 - ANW: Applikation (Art) (MF) (mrp_pigrund___14)
             COALESCE(db.to_char_immutable(mrp_pigrund___15), '#NULL#') || '|||' || -- hash from: 15 - ANW: Anfrage zur Administration/Kompatibilität (mrp_pigrund___15)
             COALESCE(db.to_char_immutable(mrp_pigrund___16), '#NULL#') || '|||' || -- hash from: 16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (mrp_pigrund___16)
             COALESCE(db.to_char_immutable(mrp_pigrund___17), '#NULL#') || '|||' || -- hash from: 17 - D: (Fehlerhafte) Dosis (MF) (mrp_pigrund___17)
             COALESCE(db.to_char_immutable(mrp_pigrund___18), '#NULL#') || '|||' || -- hash from: 18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (mrp_pigrund___18)
             COALESCE(db.to_char_immutable(mrp_pigrund___19), '#NULL#') || '|||' || -- hash from: 19 - D: (Fehlerhaftes) Dosisinterval (MF) (mrp_pigrund___19)
             COALESCE(db.to_char_immutable(mrp_pigrund___20), '#NULL#') || '|||' || -- hash from: 20 - Interaktion (MF) (mrp_pigrund___20)
             COALESCE(db.to_char_immutable(mrp_pigrund___21), '#NULL#') || '|||' || -- hash from: 21 - Kontraindikation (MF) (mrp_pigrund___21)
             COALESCE(db.to_char_immutable(mrp_pigrund___22), '#NULL#') || '|||' || -- hash from: 22 - Nebenwirkungen (mrp_pigrund___22)
             COALESCE(db.to_char_immutable(mrp_pigrund___23), '#NULL#') || '|||' || -- hash from: 23 - S: Beratung/Auswahl eines Arzneistoffs (mrp_pigrund___23)
             COALESCE(db.to_char_immutable(mrp_pigrund___24), '#NULL#') || '|||' || -- hash from: 24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (mrp_pigrund___24)
             COALESCE(db.to_char_immutable(mrp_pigrund___25), '#NULL#') || '|||' || -- hash from: 25 - S: Beschaffung/Kosten (mrp_pigrund___25)
             COALESCE(db.to_char_immutable(mrp_pigrund___26), '#NULL#') || '|||' || -- hash from: 26 - S: Keine Pause von AM, die prä-OP pausiert werden müssen (MF) (mrp_pigrund___26)
             COALESCE(db.to_char_immutable(mrp_pigrund___27), '#NULL#') || '|||' || -- hash from: 27 - S: Schulung/Beratung eines Patienten (mrp_pigrund___27)
             COALESCE(db.to_char_immutable(mrp_femb_15), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_femb_15)
             COALESCE(db.to_char_immutable(mrp_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (mrp_ip_klasse)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___1), '#NULL#') || '|||' || -- hash from: 1 - Drug - Drug (mrp_ip_klasse___1)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___2), '#NULL#') || '|||' || -- hash from: 2 - Drug - Drug-Group (mrp_ip_klasse___2)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___3), '#NULL#') || '|||' || -- hash from: 3 - Drug - Disease (mrp_ip_klasse___3)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___4), '#NULL#') || '|||' || -- hash from: 4 - Drug - Labor (mrp_ip_klasse___4)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___5), '#NULL#') || '|||' || -- hash from: 5 - Drug - Age (Priscus 2.0 o. Dosis) (mrp_ip_klasse___5)
             COALESCE(db.to_char_immutable(mrp_femb_16), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_ip_klasse (mrp_femb_16)
             COALESCE(db.to_char_immutable(mrp_femb_17), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_ip_klasse_disease (mrp_femb_17)
             COALESCE(db.to_char_immutable(mrp_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (mrp_ip_klasse_disease)
             COALESCE(db.to_char_immutable(mrp_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (mrp_ip_klasse_labor)
             COALESCE(db.to_char_immutable(mrp_femb_18), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_ip_klasse_labor (mrp_femb_18)
             COALESCE(db.to_char_immutable(mrp_massn_am), '#NULL#') || '|||' || -- hash from: AM: Arzneimitte (mrp_massn_am)
             COALESCE(db.to_char_immutable(mrp_massn_am___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (mrp_massn_am___1)
             COALESCE(db.to_char_immutable(mrp_massn_am___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (mrp_massn_am___2)
             COALESCE(db.to_char_immutable(mrp_massn_am___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (mrp_massn_am___3)
             COALESCE(db.to_char_immutable(mrp_massn_am___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (mrp_massn_am___4)
             COALESCE(db.to_char_immutable(mrp_massn_am___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (mrp_massn_am___5)
             COALESCE(db.to_char_immutable(mrp_massn_am___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (mrp_massn_am___6)
             COALESCE(db.to_char_immutable(mrp_massn_am___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (mrp_massn_am___7)
             COALESCE(db.to_char_immutable(mrp_massn_am___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (mrp_massn_am___8)
             COALESCE(db.to_char_immutable(mrp_massn_am___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (mrp_massn_am___9)
             COALESCE(db.to_char_immutable(mrp_massn_am___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (mrp_massn_am___10)
             COALESCE(db.to_char_immutable(mrp_femb_19), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_massn_am (mrp_femb_19)
             COALESCE(db.to_char_immutable(mrp_massn_orga), '#NULL#') || '|||' || -- hash from: ORGA: Organisatorisch (mrp_massn_orga)
             COALESCE(db.to_char_immutable(mrp_massn_orga___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (mrp_massn_orga___1)
             COALESCE(db.to_char_immutable(mrp_massn_orga___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (mrp_massn_orga___2)
             COALESCE(db.to_char_immutable(mrp_massn_orga___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers (mrp_massn_orga___3)
             COALESCE(db.to_char_immutable(mrp_massn_orga___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (mrp_massn_orga___4)
             COALESCE(db.to_char_immutable(mrp_massn_orga___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (mrp_massn_orga___5)
             COALESCE(db.to_char_immutable(mrp_massn_orga___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (mrp_massn_orga___6)
             COALESCE(db.to_char_immutable(mrp_massn_orga___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (mrp_massn_orga___7)
             COALESCE(db.to_char_immutable(mrp_massn_orga___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (mrp_massn_orga___8)
             COALESCE(db.to_char_immutable(mrp_femb_20), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_massn_orga (mrp_femb_20)
             COALESCE(db.to_char_immutable(mrp_notiz), '#NULL#') || '|||' || -- hash from: Notiz (mrp_notiz)
             COALESCE(db.to_char_immutable(mrp_femb_21), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_notiz (mrp_femb_21)
             COALESCE(db.to_char_immutable(mrp_dokup_hand_emp_akz), '#NULL#') || '|||' || -- hash from: Handlungsempfehlung akzeptiert? - 1, Arzt / Pflege informiert | 2, Intervention vorgeschlagen und umgesetzt | 3, Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation) | 4 , Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung) | 5, Intervention vorgeschlagen, Umsetzung unbekannt | 6, Problem nicht gelöst (mrp_dokup_hand_emp_akz)
             COALESCE(db.to_char_immutable(mrp_merp), '#NULL#') || '|||' || -- hash from: NCC MERP Score - A, Category A | B, Category B | C, Category C | D, Category D | E, Category E | F, Category F | G, Category G | H, Category H | I, Category I  (mrp_merp)
             COALESCE(db.to_char_immutable(mrp_merp_info), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_merp_info)
             COALESCE(db.to_char_immutable(mrp_merp_info___1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Blendet NCC MERP Index ein/aus (mrp_merp_info___1)
             COALESCE(db.to_char_immutable(mrp_merp_txt), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Beinhaltet NCC MERP Index als PDF (mrp_merp_txt)
             COALESCE(db.to_char_immutable(mrpdokumentation_validierung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status, wenn ein Pflichtitem fehlt Status bei Import wieder auf Incomplete setzen  - 0, Incomplete | 1, Unverified | 2, Complete (mrpdokumentation_validierung_complete)
             '#'
  ) STORED, 							-- Column collection data for index to read and kollion handling 
  hash_index_col TEXT TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(meda_fe_id), '#NULL#') || '|||' || -- hash from: Datenbank-FK der Medikationsanalyse (Medikationsanalyse: medikationsanalyse_fe_id) -> Dataprocessor setzt id: mrp_entd_dat(Tag)=meda_dat(Tag) (meda_fe_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instrument :  MRP-Dokumentation / -Validierung  (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(mrp_header), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (mrp_header)
             COALESCE(db.to_char_immutable(mrp_femb_1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_entd_dat (mrp_femb_1)
             COALESCE(db.to_char_immutable(mrp_femb_2), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_kurzbeschr, mrp_entd_algorithmisch, mrp_hinweisgeber_lbl, mrp_hinweisgeber (mrp_femb_2)
             COALESCE(db.to_char_immutable(mrp_femb_3), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_hinweisgeber_oth (mrp_femb_3)
             COALESCE(db.to_char_immutable(mrp_pi_info), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_pi_info)
             COALESCE(db.to_char_immutable(mrp_pi_info___1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_pi_info___1)
             COALESCE(db.to_char_immutable(mrp_mf_info), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_mf_info)
             COALESCE(db.to_char_immutable(mrp_mf_info___1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_mf_info___1)
             COALESCE(db.to_char_immutable(mrp_pi_info_txt), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_pi_info_txt)
             COALESCE(db.to_char_immutable(mrp_mf_info_txt), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_mf_info_txt)
             COALESCE(db.to_char_immutable(mrp_femb_4), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_gewissheit_lbl, mrp_gewissheit (mrp_femb_4)
             COALESCE(db.to_char_immutable(mrp_femb_5), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_gewissheit_oth (mrp_femb_5)
             COALESCE(db.to_char_immutable(mrp_femb_6), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_lbl, mrp_gewiss_grund_abl (mrp_femb_6)
             COALESCE(db.to_char_immutable(mrp_entd_dat), '#NULL#') || '|||' || -- hash from: Datum des MRP (mrp_entd_dat)
             COALESCE(db.to_char_immutable(mrp_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs (mrp_kurzbeschr)
             COALESCE(db.to_char_immutable(mrp_entd_algorithmisch), '#NULL#') || '|||' || -- hash from: MRP vom INTERPOLAR-Algorithmus entdeckt? - 1, Ja | 0, Nein (mrp_entd_algorithmisch)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_hinweisgeber_lbl)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber), '#NULL#') || '|||' || -- hash from: Hinweisgeber auf das MRP (mrp_hinweisgeber)
             COALESCE(db.to_char_immutable(mrp_gewissheit_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_gewissheit_lbl)
             COALESCE(db.to_char_immutable(mrp_gewissheit), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP - 1, MRP bestätigt | 2, MRP möglich, weitere Informationen nötig | 3, MRP nicht bestätigt (mrp_gewissheit)
             COALESCE(db.to_char_immutable(mrp_femb_22), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen (mrp_femb_22)
             COALESCE(db.to_char_immutable(mrp_gewissheit_oth), '#NULL#') || '|||' || -- hash from: Textfeld, wenn mrp_gewissheit = 2 MRP möglich, weitere Informationen nötig (mrp_gewissheit_oth)
             COALESCE(db.to_char_immutable(mrp_femb_23), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_femb_23)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber_oth), '#NULL#') || '|||' || -- hash from: Textfeld, wenn mrp_hinweisgeber = 7 (andere) (mrp_hinweisgeber_oth)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_gewiss_grund_abl_lbl)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung - 1, MRP sachlich falsch (keine Kontraindikation) | 2, MRP sachlich richtig, aber falsche Datengrundlage | 3, MRP sachlich richtig, aber klinisch nicht relevant | 4, MRP sachlich richtig, aber von Stationsapotheker vorher identifiziert | 5, Sonstiges (mrp_gewiss_grund_abl)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl_sonst_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_gewiss_grund_abl_sonst_lbl)
             COALESCE(db.to_char_immutable(mrp_gewiss_grund_abl_sonst), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (mrp_gewiss_grund_abl_sonst)
             COALESCE(db.to_char_immutable(mrp_femb_7), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_sonst_lbl, mrp_gewiss_grund_abl_sonst (mrp_femb_7)
             COALESCE(db.to_char_immutable(mrp_femb_8), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_wirkstoff (mrp_femb_8)
             COALESCE(db.to_char_immutable(mrp_femb_9), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc1_lbl, mrp_atc1 (mrp_femb_9)
             COALESCE(db.to_char_immutable(mrp_femb_10), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc2_lbl, mrp_atc2 (mrp_femb_10)
             COALESCE(db.to_char_immutable(mrp_femb_11), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc3_lbl, mrp_atc3 (mrp_femb_11)
             COALESCE(db.to_char_immutable(mrp_femb_12), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_atc4_lbl, mrp_atc4 (mrp_femb_12)
             COALESCE(db.to_char_immutable(mrp_wirkstoff), '#NULL#') || '|||' || -- hash from: Wirkstoff betroffen? - 1, Ja | 0, Nein (mrp_wirkstoff)
             COALESCE(db.to_char_immutable(mrp_atc1_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc1_lbl)
             COALESCE(db.to_char_immutable(mrp_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name- https://www.bfarm.de/SharedDocs/Downloads/DE/Kodiersysteme/ATC/atc-ddd-amtlich-2024.pdf?__blob=publicationFile (mrp_atc1)
             COALESCE(db.to_char_immutable(mrp_atc2_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc2_lbl)
             COALESCE(db.to_char_immutable(mrp_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (mrp_atc2)
             COALESCE(db.to_char_immutable(mrp_atc3_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc3_lbl)
             COALESCE(db.to_char_immutable(mrp_atc3), '#NULL#') || '|||' || -- hash from: 3. Medikament ATC / Name (mrp_atc3)
             COALESCE(db.to_char_immutable(mrp_atc4_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc4_lbl)
             COALESCE(db.to_char_immutable(mrp_atc4), '#NULL#') || '|||' || -- hash from: 4. Medikament ATC / Name (mrp_atc4)
             COALESCE(db.to_char_immutable(mrp_atc5_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_atc5_lbl)
             COALESCE(db.to_char_immutable(mrp_atc5), '#NULL#') || '|||' || -- hash from: 5. Medikament ATC / Name (mrp_atc5)
             COALESCE(db.to_char_immutable(mrp_femb_13), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_femb_13)
             COALESCE(db.to_char_immutable(mrp_med_prod), '#NULL#') || '|||' || -- hash from: Medizinprodukt betroffen? - 1, Ja | 0, Nein, (mrp_med_prod)
             COALESCE(db.to_char_immutable(mrp_med_prod_sonst_lbl), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_med_prod_sonst_lbl)
             COALESCE(db.to_char_immutable(mrp_med_prod_sonst), '#NULL#') || '|||' || -- hash from: Bezeichnung Präparat (mrp_med_prod_sonst)
             COALESCE(db.to_char_immutable(mrp_dokup_fehler), '#NULL#') || '|||' || -- hash from: Frage / Fehlerbeschreibung (mrp_dokup_fehler)
             COALESCE(db.to_char_immutable(mrp_dokup_intervention), '#NULL#') || '|||' || -- hash from: Intervention / Vorschlag zur Fehlervermeldung (mrp_dokup_intervention)
             COALESCE(db.to_char_immutable(mrp_femb_14), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variablen mrp_med_prod, mrp_med_prod_sonst_lbl, mrp_med_prod_sonst (mrp_femb_14)
             COALESCE(db.to_char_immutable(mrp_pigrund), '#NULL#') || '|||' || -- hash from: PI-Grund (mrp_pigrund)
             COALESCE(db.to_char_immutable(mrp_pigrund___1), '#NULL#') || '|||' || -- hash from: 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (mrp_pigrund___1)
             COALESCE(db.to_char_immutable(mrp_pigrund___2), '#NULL#') || '|||' || -- hash from: 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (mrp_pigrund___2)
             COALESCE(db.to_char_immutable(mrp_pigrund___3), '#NULL#') || '|||' || -- hash from: 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (mrp_pigrund___3)
             COALESCE(db.to_char_immutable(mrp_pigrund___4), '#NULL#') || '|||' || -- hash from: 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (mrp_pigrund___4)
             COALESCE(db.to_char_immutable(mrp_pigrund___5), '#NULL#') || '|||' || -- hash from: 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (mrp_pigrund___5)
             COALESCE(db.to_char_immutable(mrp_pigrund___6), '#NULL#') || '|||' || -- hash from: 6 - AM: Übertragungsfehler (MF) (mrp_pigrund___6)
             COALESCE(db.to_char_immutable(mrp_pigrund___7), '#NULL#') || '|||' || -- hash from: 7 - AM: Substitution aut idem/aut simile (MF) (mrp_pigrund___7)
             COALESCE(db.to_char_immutable(mrp_pigrund___8), '#NULL#') || '|||' || -- hash from: 8 - AM: (Klare) Indikation, aber kein Medikament angeordnet (MF) (mrp_pigrund___8)
             COALESCE(db.to_char_immutable(mrp_pigrund___9), '#NULL#') || '|||' || -- hash from: 9 - AM: Stellfehler (MF) (mrp_pigrund___9)
             COALESCE(db.to_char_immutable(mrp_pigrund___10), '#NULL#') || '|||' || -- hash from: 10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (mrp_pigrund___10)
             COALESCE(db.to_char_immutable(mrp_pigrund___11), '#NULL#') || '|||' || -- hash from: 11 - AM: Doppelverordnung (MF) (mrp_pigrund___11)
             COALESCE(db.to_char_immutable(mrp_pigrund___12), '#NULL#') || '|||' || -- hash from: 12 - ANW: Applikation (Dauer) (MF) (mrp_pigrund___12)
             COALESCE(db.to_char_immutable(mrp_pigrund___13), '#NULL#') || '|||' || -- hash from: 13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (mrp_pigrund___13)
             COALESCE(db.to_char_immutable(mrp_pigrund___14), '#NULL#') || '|||' || -- hash from: 14 - ANW: Applikation (Art) (MF) (mrp_pigrund___14)
             COALESCE(db.to_char_immutable(mrp_pigrund___15), '#NULL#') || '|||' || -- hash from: 15 - ANW: Anfrage zur Administration/Kompatibilität (mrp_pigrund___15)
             COALESCE(db.to_char_immutable(mrp_pigrund___16), '#NULL#') || '|||' || -- hash from: 16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (mrp_pigrund___16)
             COALESCE(db.to_char_immutable(mrp_pigrund___17), '#NULL#') || '|||' || -- hash from: 17 - D: (Fehlerhafte) Dosis (MF) (mrp_pigrund___17)
             COALESCE(db.to_char_immutable(mrp_pigrund___18), '#NULL#') || '|||' || -- hash from: 18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (mrp_pigrund___18)
             COALESCE(db.to_char_immutable(mrp_pigrund___19), '#NULL#') || '|||' || -- hash from: 19 - D: (Fehlerhaftes) Dosisinterval (MF) (mrp_pigrund___19)
             COALESCE(db.to_char_immutable(mrp_pigrund___20), '#NULL#') || '|||' || -- hash from: 20 - Interaktion (MF) (mrp_pigrund___20)
             COALESCE(db.to_char_immutable(mrp_pigrund___21), '#NULL#') || '|||' || -- hash from: 21 - Kontraindikation (MF) (mrp_pigrund___21)
             COALESCE(db.to_char_immutable(mrp_pigrund___22), '#NULL#') || '|||' || -- hash from: 22 - Nebenwirkungen (mrp_pigrund___22)
             COALESCE(db.to_char_immutable(mrp_pigrund___23), '#NULL#') || '|||' || -- hash from: 23 - S: Beratung/Auswahl eines Arzneistoffs (mrp_pigrund___23)
             COALESCE(db.to_char_immutable(mrp_pigrund___24), '#NULL#') || '|||' || -- hash from: 24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (mrp_pigrund___24)
             COALESCE(db.to_char_immutable(mrp_pigrund___25), '#NULL#') || '|||' || -- hash from: 25 - S: Beschaffung/Kosten (mrp_pigrund___25)
             COALESCE(db.to_char_immutable(mrp_pigrund___26), '#NULL#') || '|||' || -- hash from: 26 - S: Keine Pause von AM, die prä-OP pausiert werden müssen (MF) (mrp_pigrund___26)
             COALESCE(db.to_char_immutable(mrp_pigrund___27), '#NULL#') || '|||' || -- hash from: 27 - S: Schulung/Beratung eines Patienten (mrp_pigrund___27)
             COALESCE(db.to_char_immutable(mrp_femb_15), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Label für femb (korrespondierende Variable) (mrp_femb_15)
             COALESCE(db.to_char_immutable(mrp_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (mrp_ip_klasse)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___1), '#NULL#') || '|||' || -- hash from: 1 - Drug - Drug (mrp_ip_klasse___1)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___2), '#NULL#') || '|||' || -- hash from: 2 - Drug - Drug-Group (mrp_ip_klasse___2)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___3), '#NULL#') || '|||' || -- hash from: 3 - Drug - Disease (mrp_ip_klasse___3)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___4), '#NULL#') || '|||' || -- hash from: 4 - Drug - Labor (mrp_ip_klasse___4)
             COALESCE(db.to_char_immutable(mrp_ip_klasse___5), '#NULL#') || '|||' || -- hash from: 5 - Drug - Age (Priscus 2.0 o. Dosis) (mrp_ip_klasse___5)
             COALESCE(db.to_char_immutable(mrp_femb_16), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_ip_klasse (mrp_femb_16)
             COALESCE(db.to_char_immutable(mrp_femb_17), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_ip_klasse_disease (mrp_femb_17)
             COALESCE(db.to_char_immutable(mrp_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (mrp_ip_klasse_disease)
             COALESCE(db.to_char_immutable(mrp_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (mrp_ip_klasse_labor)
             COALESCE(db.to_char_immutable(mrp_femb_18), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_ip_klasse_labor (mrp_femb_18)
             COALESCE(db.to_char_immutable(mrp_massn_am), '#NULL#') || '|||' || -- hash from: AM: Arzneimitte (mrp_massn_am)
             COALESCE(db.to_char_immutable(mrp_massn_am___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (mrp_massn_am___1)
             COALESCE(db.to_char_immutable(mrp_massn_am___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (mrp_massn_am___2)
             COALESCE(db.to_char_immutable(mrp_massn_am___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (mrp_massn_am___3)
             COALESCE(db.to_char_immutable(mrp_massn_am___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (mrp_massn_am___4)
             COALESCE(db.to_char_immutable(mrp_massn_am___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (mrp_massn_am___5)
             COALESCE(db.to_char_immutable(mrp_massn_am___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (mrp_massn_am___6)
             COALESCE(db.to_char_immutable(mrp_massn_am___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (mrp_massn_am___7)
             COALESCE(db.to_char_immutable(mrp_massn_am___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (mrp_massn_am___8)
             COALESCE(db.to_char_immutable(mrp_massn_am___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (mrp_massn_am___9)
             COALESCE(db.to_char_immutable(mrp_massn_am___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (mrp_massn_am___10)
             COALESCE(db.to_char_immutable(mrp_femb_19), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_massn_am (mrp_femb_19)
             COALESCE(db.to_char_immutable(mrp_massn_orga), '#NULL#') || '|||' || -- hash from: ORGA: Organisatorisch (mrp_massn_orga)
             COALESCE(db.to_char_immutable(mrp_massn_orga___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (mrp_massn_orga___1)
             COALESCE(db.to_char_immutable(mrp_massn_orga___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (mrp_massn_orga___2)
             COALESCE(db.to_char_immutable(mrp_massn_orga___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers (mrp_massn_orga___3)
             COALESCE(db.to_char_immutable(mrp_massn_orga___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (mrp_massn_orga___4)
             COALESCE(db.to_char_immutable(mrp_massn_orga___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (mrp_massn_orga___5)
             COALESCE(db.to_char_immutable(mrp_massn_orga___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (mrp_massn_orga___6)
             COALESCE(db.to_char_immutable(mrp_massn_orga___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (mrp_massn_orga___7)
             COALESCE(db.to_char_immutable(mrp_massn_orga___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (mrp_massn_orga___8)
             COALESCE(db.to_char_immutable(mrp_femb_20), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_massn_orga (mrp_femb_20)
             COALESCE(db.to_char_immutable(mrp_notiz), '#NULL#') || '|||' || -- hash from: Notiz (mrp_notiz)
             COALESCE(db.to_char_immutable(mrp_femb_21), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - femb der Variable mrp_notiz (mrp_femb_21)
             COALESCE(db.to_char_immutable(mrp_dokup_hand_emp_akz), '#NULL#') || '|||' || -- hash from: Handlungsempfehlung akzeptiert? - 1, Arzt / Pflege informiert | 2, Intervention vorgeschlagen und umgesetzt | 3, Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation) | 4 , Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung) | 5, Intervention vorgeschlagen, Umsetzung unbekannt | 6, Problem nicht gelöst (mrp_dokup_hand_emp_akz)
             COALESCE(db.to_char_immutable(mrp_merp), '#NULL#') || '|||' || -- hash from: NCC MERP Score - A, Category A | B, Category B | C, Category C | D, Category D | E, Category E | F, Category F | G, Category G | H, Category H | I, Category I  (mrp_merp)
             COALESCE(db.to_char_immutable(mrp_merp_info), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend (mrp_merp_info)
             COALESCE(db.to_char_immutable(mrp_merp_info___1), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Blendet NCC MERP Index ein/aus (mrp_merp_info___1)
             COALESCE(db.to_char_immutable(mrp_merp_txt), '#NULL#') || '|||' || -- hash from: descriptive item only for frontend - Beinhaltet NCC MERP Index als PDF (mrp_merp_txt)
             COALESCE(db.to_char_immutable(mrpdokumentation_validierung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status, wenn ein Pflichtitem fehlt Status bei Import wieder auf Incomplete setzen  - 0, Incomplete | 1, Unverified | 2, Complete (mrpdokumentation_validierung_complete)
             '#'
      )
  ) STORED,							-- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.risikofaktor_fe (
  risikofaktor_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  patient_id_fk int,   -- Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)
  rskfk_gerhemmer varchar,   -- Ger.hemmer (varchar)
  rskfk_tah varchar,   -- TAH (varchar)
  rskfk_immunsupp varchar,   -- Immunsupp. (varchar)
  rskfk_tumorth varchar,   -- Tumorth. (varchar)
  rskfk_opiat varchar,   -- Opiat (varchar)
  rskfk_atcn varchar,   -- ATC N (varchar)
  rskfk_ait varchar,   -- AIT (varchar)
  rskfk_anzam varchar,   -- Anz AM (varchar)
  rskfk_priscus varchar,   -- PRISCUS (varchar)
  rskfk_qtc varchar,   -- QTc (varchar)
  rskfk_meld varchar,   -- MELD (varchar)
  rskfk_dialyse varchar,   -- Dialyse (varchar)
  rskfk_entern varchar,   -- ent. Ern. (varchar)
  rskfkt_anz_rskamklassen varchar,   -- Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (varchar)
  risikofaktor_complete varchar,   -- Frontend Complete-Status (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (patient_id_fk)
             COALESCE(db.to_char_immutable(rskfk_gerhemmer), '#NULL#') || '|||' || -- hash from: Ger.hemmer (rskfk_gerhemmer)
             COALESCE(db.to_char_immutable(rskfk_tah), '#NULL#') || '|||' || -- hash from: TAH (rskfk_tah)
             COALESCE(db.to_char_immutable(rskfk_immunsupp), '#NULL#') || '|||' || -- hash from: Immunsupp. (rskfk_immunsupp)
             COALESCE(db.to_char_immutable(rskfk_tumorth), '#NULL#') || '|||' || -- hash from: Tumorth. (rskfk_tumorth)
             COALESCE(db.to_char_immutable(rskfk_opiat), '#NULL#') || '|||' || -- hash from: Opiat (rskfk_opiat)
             COALESCE(db.to_char_immutable(rskfk_atcn), '#NULL#') || '|||' || -- hash from: ATC N (rskfk_atcn)
             COALESCE(db.to_char_immutable(rskfk_ait), '#NULL#') || '|||' || -- hash from: AIT (rskfk_ait)
             COALESCE(db.to_char_immutable(rskfk_anzam), '#NULL#') || '|||' || -- hash from: Anz AM (rskfk_anzam)
             COALESCE(db.to_char_immutable(rskfk_priscus), '#NULL#') || '|||' || -- hash from: PRISCUS (rskfk_priscus)
             COALESCE(db.to_char_immutable(rskfk_qtc), '#NULL#') || '|||' || -- hash from: QTc (rskfk_qtc)
             COALESCE(db.to_char_immutable(rskfk_meld), '#NULL#') || '|||' || -- hash from: MELD (rskfk_meld)
             COALESCE(db.to_char_immutable(rskfk_dialyse), '#NULL#') || '|||' || -- hash from: Dialyse (rskfk_dialyse)
             COALESCE(db.to_char_immutable(rskfk_entern), '#NULL#') || '|||' || -- hash from: ent. Ern. (rskfk_entern)
             COALESCE(db.to_char_immutable(rskfkt_anz_rskamklassen), '#NULL#') || '|||' || -- hash from: Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (rskfkt_anz_rskamklassen)
             COALESCE(db.to_char_immutable(risikofaktor_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status (risikofaktor_complete)
             '#'
  ) STORED, 							-- Column collection data for index to read and kollion handling 
  hash_index_col TEXT TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (patient_id_fk)
             COALESCE(db.to_char_immutable(rskfk_gerhemmer), '#NULL#') || '|||' || -- hash from: Ger.hemmer (rskfk_gerhemmer)
             COALESCE(db.to_char_immutable(rskfk_tah), '#NULL#') || '|||' || -- hash from: TAH (rskfk_tah)
             COALESCE(db.to_char_immutable(rskfk_immunsupp), '#NULL#') || '|||' || -- hash from: Immunsupp. (rskfk_immunsupp)
             COALESCE(db.to_char_immutable(rskfk_tumorth), '#NULL#') || '|||' || -- hash from: Tumorth. (rskfk_tumorth)
             COALESCE(db.to_char_immutable(rskfk_opiat), '#NULL#') || '|||' || -- hash from: Opiat (rskfk_opiat)
             COALESCE(db.to_char_immutable(rskfk_atcn), '#NULL#') || '|||' || -- hash from: ATC N (rskfk_atcn)
             COALESCE(db.to_char_immutable(rskfk_ait), '#NULL#') || '|||' || -- hash from: AIT (rskfk_ait)
             COALESCE(db.to_char_immutable(rskfk_anzam), '#NULL#') || '|||' || -- hash from: Anz AM (rskfk_anzam)
             COALESCE(db.to_char_immutable(rskfk_priscus), '#NULL#') || '|||' || -- hash from: PRISCUS (rskfk_priscus)
             COALESCE(db.to_char_immutable(rskfk_qtc), '#NULL#') || '|||' || -- hash from: QTc (rskfk_qtc)
             COALESCE(db.to_char_immutable(rskfk_meld), '#NULL#') || '|||' || -- hash from: MELD (rskfk_meld)
             COALESCE(db.to_char_immutable(rskfk_dialyse), '#NULL#') || '|||' || -- hash from: Dialyse (rskfk_dialyse)
             COALESCE(db.to_char_immutable(rskfk_entern), '#NULL#') || '|||' || -- hash from: ent. Ern. (rskfk_entern)
             COALESCE(db.to_char_immutable(rskfkt_anz_rskamklassen), '#NULL#') || '|||' || -- hash from: Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (rskfkt_anz_rskamklassen)
             COALESCE(db.to_char_immutable(risikofaktor_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status (risikofaktor_complete)
             '#'
      )
  ) STORED,							-- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.trigger_fe (
  trigger_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  patient_id_fk int,   -- Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)
  record_id varchar,   -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)
  trg_ast varchar,   -- AST (varchar)
  trg_alt varchar,   -- ALT↑ (varchar)
  trg_crp varchar,   -- CRP↑ (varchar)
  trg_leuk_penie varchar,   -- Leuko↓ (varchar)
  trg_leuk_ose varchar,   -- Leuko↑ (varchar)
  trg_thrmb_penie varchar,   -- Thrombo↓ (varchar)
  trg_aptt varchar,   -- aPTT (varchar)
  trg_hyp_haem varchar,   -- Hb↓ (varchar)
  trg_hypo_glyk varchar,   -- Glc↓ (varchar)
  trg_hyper_glyk varchar,   -- Glc↑ (varchar)
  trg_hyper_bilirbnm varchar,   -- Bili↑ (varchar)
  trg_ck varchar,   -- CK↑ (varchar)
  trg_hypo_serablmn varchar,   -- Alb↓ (varchar)
  trg_hypo_nat varchar,   -- Na+↓ (varchar)
  trg_hyper_nat varchar,   -- Na+↑ (varchar)
  trg_hyper_kal varchar,   -- K+↓ (varchar)
  trg_hypo_kal varchar,   -- K+↑ (varchar)
  trg_inr_ern varchar,   -- INR Antikoag↓ (varchar)
  trg_inr_erh varchar,   -- INR ↑ (varchar)
  trg_inr_erh_antikoa varchar,   -- INR Antikoag↑ (varchar)
  trg_krea varchar,   -- Krea↑ (varchar)
  trg_egfr varchar,   -- eGFR<30 (varchar)
  trigger_complete varchar,   -- Frontend Complete-Status (varchar)
  hash_txt_col TEXT GENERATED ALWAYS AS (
             COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (patient_id_fk)
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(trg_ast), '#NULL#') || '|||' || -- hash from: AST (trg_ast)
             COALESCE(db.to_char_immutable(trg_alt), '#NULL#') || '|||' || -- hash from: ALT↑ (trg_alt)
             COALESCE(db.to_char_immutable(trg_crp), '#NULL#') || '|||' || -- hash from: CRP↑ (trg_crp)
             COALESCE(db.to_char_immutable(trg_leuk_penie), '#NULL#') || '|||' || -- hash from: Leuko↓ (trg_leuk_penie)
             COALESCE(db.to_char_immutable(trg_leuk_ose), '#NULL#') || '|||' || -- hash from: Leuko↑ (trg_leuk_ose)
             COALESCE(db.to_char_immutable(trg_thrmb_penie), '#NULL#') || '|||' || -- hash from: Thrombo↓ (trg_thrmb_penie)
             COALESCE(db.to_char_immutable(trg_aptt), '#NULL#') || '|||' || -- hash from: aPTT (trg_aptt)
             COALESCE(db.to_char_immutable(trg_hyp_haem), '#NULL#') || '|||' || -- hash from: Hb↓ (trg_hyp_haem)
             COALESCE(db.to_char_immutable(trg_hypo_glyk), '#NULL#') || '|||' || -- hash from: Glc↓ (trg_hypo_glyk)
             COALESCE(db.to_char_immutable(trg_hyper_glyk), '#NULL#') || '|||' || -- hash from: Glc↑ (trg_hyper_glyk)
             COALESCE(db.to_char_immutable(trg_hyper_bilirbnm), '#NULL#') || '|||' || -- hash from: Bili↑ (trg_hyper_bilirbnm)
             COALESCE(db.to_char_immutable(trg_ck), '#NULL#') || '|||' || -- hash from: CK↑ (trg_ck)
             COALESCE(db.to_char_immutable(trg_hypo_serablmn), '#NULL#') || '|||' || -- hash from: Alb↓ (trg_hypo_serablmn)
             COALESCE(db.to_char_immutable(trg_hypo_nat), '#NULL#') || '|||' || -- hash from: Na+↓ (trg_hypo_nat)
             COALESCE(db.to_char_immutable(trg_hyper_nat), '#NULL#') || '|||' || -- hash from: Na+↑ (trg_hyper_nat)
             COALESCE(db.to_char_immutable(trg_hyper_kal), '#NULL#') || '|||' || -- hash from: K+↓ (trg_hyper_kal)
             COALESCE(db.to_char_immutable(trg_hypo_kal), '#NULL#') || '|||' || -- hash from: K+↑ (trg_hypo_kal)
             COALESCE(db.to_char_immutable(trg_inr_ern), '#NULL#') || '|||' || -- hash from: INR Antikoag↓ (trg_inr_ern)
             COALESCE(db.to_char_immutable(trg_inr_erh), '#NULL#') || '|||' || -- hash from: INR ↑ (trg_inr_erh)
             COALESCE(db.to_char_immutable(trg_inr_erh_antikoa), '#NULL#') || '|||' || -- hash from: INR Antikoag↑ (trg_inr_erh_antikoa)
             COALESCE(db.to_char_immutable(trg_krea), '#NULL#') || '|||' || -- hash from: Krea↑ (trg_krea)
             COALESCE(db.to_char_immutable(trg_egfr), '#NULL#') || '|||' || -- hash from: eGFR<30 (trg_egfr)
             COALESCE(db.to_char_immutable(trigger_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status (trigger_complete)
             '#'
  ) STORED, 							-- Column collection data for index to read and kollion handling 
  hash_index_col TEXT TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (patient_id_fk)
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (record_id)
             COALESCE(db.to_char_immutable(trg_ast), '#NULL#') || '|||' || -- hash from: AST (trg_ast)
             COALESCE(db.to_char_immutable(trg_alt), '#NULL#') || '|||' || -- hash from: ALT↑ (trg_alt)
             COALESCE(db.to_char_immutable(trg_crp), '#NULL#') || '|||' || -- hash from: CRP↑ (trg_crp)
             COALESCE(db.to_char_immutable(trg_leuk_penie), '#NULL#') || '|||' || -- hash from: Leuko↓ (trg_leuk_penie)
             COALESCE(db.to_char_immutable(trg_leuk_ose), '#NULL#') || '|||' || -- hash from: Leuko↑ (trg_leuk_ose)
             COALESCE(db.to_char_immutable(trg_thrmb_penie), '#NULL#') || '|||' || -- hash from: Thrombo↓ (trg_thrmb_penie)
             COALESCE(db.to_char_immutable(trg_aptt), '#NULL#') || '|||' || -- hash from: aPTT (trg_aptt)
             COALESCE(db.to_char_immutable(trg_hyp_haem), '#NULL#') || '|||' || -- hash from: Hb↓ (trg_hyp_haem)
             COALESCE(db.to_char_immutable(trg_hypo_glyk), '#NULL#') || '|||' || -- hash from: Glc↓ (trg_hypo_glyk)
             COALESCE(db.to_char_immutable(trg_hyper_glyk), '#NULL#') || '|||' || -- hash from: Glc↑ (trg_hyper_glyk)
             COALESCE(db.to_char_immutable(trg_hyper_bilirbnm), '#NULL#') || '|||' || -- hash from: Bili↑ (trg_hyper_bilirbnm)
             COALESCE(db.to_char_immutable(trg_ck), '#NULL#') || '|||' || -- hash from: CK↑ (trg_ck)
             COALESCE(db.to_char_immutable(trg_hypo_serablmn), '#NULL#') || '|||' || -- hash from: Alb↓ (trg_hypo_serablmn)
             COALESCE(db.to_char_immutable(trg_hypo_nat), '#NULL#') || '|||' || -- hash from: Na+↓ (trg_hypo_nat)
             COALESCE(db.to_char_immutable(trg_hyper_nat), '#NULL#') || '|||' || -- hash from: Na+↑ (trg_hyper_nat)
             COALESCE(db.to_char_immutable(trg_hyper_kal), '#NULL#') || '|||' || -- hash from: K+↓ (trg_hyper_kal)
             COALESCE(db.to_char_immutable(trg_hypo_kal), '#NULL#') || '|||' || -- hash from: K+↑ (trg_hypo_kal)
             COALESCE(db.to_char_immutable(trg_inr_ern), '#NULL#') || '|||' || -- hash from: INR Antikoag↓ (trg_inr_ern)
             COALESCE(db.to_char_immutable(trg_inr_erh), '#NULL#') || '|||' || -- hash from: INR ↑ (trg_inr_erh)
             COALESCE(db.to_char_immutable(trg_inr_erh_antikoa), '#NULL#') || '|||' || -- hash from: INR Antikoag↑ (trg_inr_erh_antikoa)
             COALESCE(db.to_char_immutable(trg_krea), '#NULL#') || '|||' || -- hash from: Krea↑ (trg_krea)
             COALESCE(db.to_char_immutable(trg_egfr), '#NULL#') || '|||' || -- hash from: eGFR<30 (trg_egfr)
             COALESCE(db.to_char_immutable(trigger_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status (trigger_complete)
             '#'
      )
  ) STORED,							-- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);


------------------------------------------------------
-- SQL Role / Trigger in Schema "db_log" --
------------------------------------------------------


-- Table "patient_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.patient_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_user; -- Additional authorizations for testing

-- Table "fall_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.fall_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_user; -- Additional authorizations for testing

-- Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.medikationsanalyse_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_user; -- Additional authorizations for testing

-- Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_user; -- Additional authorizations for testing

-- Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.risikofaktor_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.risikofaktor_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.risikofaktor_fe TO db_user; -- Additional authorizations for testing

-- Table "trigger_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.trigger_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.trigger_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.trigger_fe TO db_user; -- Additional authorizations for testing

------------------------------------------------------
-- Comments on Tables in Schema "db_log" --
------------------------------------------------------
-- Output off
\o /dev/null

COMMENT ON COLUMN db_log.patient_fe.patient_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.patient_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_header IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_id IS 'Patient-identifier FHIR Daten (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_femb_1 IS 'descriptive item only for frontend - Fieldembedding (femb) der Variablen pat_cis_pid, pat_name, pat_vorname, pat_gebdat,pat_geschlecht (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_cis_pid IS 'Patient Identifier aus dem Krankenhausinformationssystem - so wie es dem Apotheker zur verfügung steht (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_name IS 'Patientenname (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_vorname IS 'Patientenvorname (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_gebdat IS 'Geburtsdatum (date)';
COMMENT ON COLUMN db_log.patient_fe.pat_aktuell_alter IS 'aktuelles Patientenalter (Jahre) (double precision)';
COMMENT ON COLUMN db_log.patient_fe.pat_geschlecht IS 'Geschlecht (wie in FHIR) (varchar)';
COMMENT ON COLUMN db_log.patient_fe.patient_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.patient_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.patient_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.patient_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.patient_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.patient_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db_log.fall_fe.fall_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.fall_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_header IS 'descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanz  (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_id IS 'Fall-ID RedCap FHIR Daten (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_pat_id IS 'Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id) (varchar)';
COMMENT ON COLUMN db_log.fall_fe.patient_id_fk IS 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)';
COMMENT ON COLUMN db_log.fall_fe.fall_femb_1 IS 'descriptive item only for frontend - femb der Variablen fall_id, fall_station, fall_aufn_dat, fall_zimmernr, fall_aufn_diag, fall_gewicht_aktuell, fall_gewicht_aktl_einheit, fall_groesse, fall_groesse_einheit (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :   fall (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_studienphase IS 'Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) ) (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_station IS 'Station wie vom DIZ Definiert (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_zimmernr IS 'Zimmernummer wie vom DIZ Definiert (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_aufn_dat IS 'Aufnahmedatum (timestamp)';
COMMENT ON COLUMN db_log.fall_fe.fall_aufn_diag IS 'Diagnose(n) bei Aufnahme (wird nur zum lesen sein (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_gewicht_aktuell IS 'aktuelles Gewicht (Kg) (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_gewicht_aktl_einheit IS 'Einheit des Gewichts (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_groesse IS 'Größe (cm) (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_groesse_einheit IS 'Einheit der Größe (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_bmi IS 'BMI (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_femb_2 IS 'descriptive item only for frontend - femb der Variablen fall_nieren_insuf_chron, fall_nieren_insuf_ausmass_lbl, fall_nieren_insuf_ausmass (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_femb_3 IS 'descriptive item only for frontend - femb der Variablen fall_nieren_insuf_dialysev_lbl, fall_nieren_insuf_dialysev (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_femb_4 IS 'descriptive item only for frontend - femb der Variablen fall_leber_insuf, fall_leber_insuf_ausmass_lbl, fall_leber_insuf_ausmass (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_femb_5 IS 'descriptive item only for frontend - femb der Variablen fall_schwanger_mo_lbl, fall_schwanger_mo (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_femb_6 IS 'descriptive item only for frontend - femb der Variablen fall_status, fall_ent_dat (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_nieren_insuf_chron IS '1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_nieren_insuf_ausmass_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_nieren_insuf_ausmass IS 'aktuelles Ausmaß - 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2 (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_nieren_insuf_dialysev_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_nieren_insuf_dialysev IS 'Nierenersatzverfahren - 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_leber_insuf IS 'Leberinsuffizienz - 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_leber_insuf_ausmass_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_leber_insuf_ausmass IS 'aktuelles Ausmaß -1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß  (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_schwanger_mo IS 'Schwangerschaftsmonat - 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9 (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_schwanger_mo_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_status IS 'Status des Falls (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_ent_dat IS 'Entlassdatum (timestamp)';
COMMENT ON COLUMN db_log.fall_fe.fall_complete IS 'Frontend Complete-Status - Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.fall_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.fall_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.fall_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.fall_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.fall_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db_log.medikationsanalyse_fe.medikationsanalyse_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_header IS 'descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_femb_1 IS 'descriptive item only for frontend - femb der Variable meda_dat (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_femb_2 IS 'descriptive item only for frontend - femb der Variable meda_ma_thueberw (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_femb_3 IS 'descriptive item only for frontend - femb der Variablen meda_mrp_detekt, meda_aufwand_zeit, meda_aufwand_zeit_and_lbl, meda_aufwand_zeit_and, meda_notiz (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.fall_fe_id IS 'Datenbank-FK des Falls (Fall: v_fall_all . fall_id) -> Dataprocessor setzt id: meda_dat in [fall_aufn_dat;fall_ent_dat] (int)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :  medikationsanalyse (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_dat IS 'Datum der Medikationsanalyse (timestamp)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_typ IS 'Typ der Medikationsanalyse - 1, Typ 1: Einfache MA | 2a, Typ 2a: Erweiterte MA | 2b, Typ 2b: Erweiterte MA | 3, Typ 3: Umfassende MA  (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_ma_thueberw IS 'Medikationsanalyse / Therapieüberwachung in 24-48h - 1, Ja | 0, Nein (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_mrp_detekt IS 'MRP detektiert? - 1, Ja|0, Nein (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_aufwand_zeit IS 'Zeitaufwand Medikationsanalyse - 0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min] (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_aufwand_zeit_and_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (int)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_aufwand_zeit_and IS 'genaue Dauer in Minuten (int)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_notiz IS 'Notizfeld (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.medikationsanalyse_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.meda_fe_id IS 'Datenbank-FK der Medikationsanalyse (Medikationsanalyse: medikationsanalyse_fe_id) -> Dataprocessor setzt id: mrp_entd_dat(Tag)=meda_dat(Tag) (int)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :  MRP-Dokumentation / -Validierung  (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_header IS 'descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_1 IS 'descriptive item only for frontend - femb der Variable mrp_entd_dat (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_2 IS 'descriptive item only for frontend - femb der Variablen mrp_kurzbeschr, mrp_entd_algorithmisch, mrp_hinweisgeber_lbl, mrp_hinweisgeber (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_3 IS 'descriptive item only for frontend - femb der Variable mrp_hinweisgeber_oth (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pi_info IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pi_info___1 IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_mf_info IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_mf_info___1 IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pi_info_txt IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_mf_info_txt IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_4 IS 'descriptive item only for frontend - femb der Variablen mrp_gewissheit_lbl, mrp_gewissheit (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_5 IS 'descriptive item only for frontend - femb der Variable mrp_gewissheit_oth (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_6 IS 'descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_lbl, mrp_gewiss_grund_abl (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_entd_dat IS 'Datum des MRP (timestamp)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_kurzbeschr IS 'Kurzbeschreibung des MRPs (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_entd_algorithmisch IS 'MRP vom INTERPOLAR-Algorithmus entdeckt? - 1, Ja | 0, Nein (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber IS 'Hinweisgeber auf das MRP (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_gewissheit_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_gewissheit IS 'Sicherheit des detektierten MRP - 1, MRP bestätigt | 2, MRP möglich, weitere Informationen nötig | 3, MRP nicht bestätigt (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_22 IS 'descriptive item only for frontend - femb der Variablen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_gewissheit_oth IS 'Textfeld, wenn mrp_gewissheit = 2 MRP möglich, weitere Informationen nötig (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_23 IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber_oth IS 'Textfeld, wenn mrp_hinweisgeber = 7 (andere) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl IS 'Grund für nicht Bestätigung - 1, MRP sachlich falsch (keine Kontraindikation) | 2, MRP sachlich richtig, aber falsche Datengrundlage | 3, MRP sachlich richtig, aber klinisch nicht relevant | 4, MRP sachlich richtig, aber von Stationsapotheker vorher identifiziert | 5, Sonstiges (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_sonst_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_sonst IS 'Bitte näher beschreiben (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_7 IS 'descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_sonst_lbl, mrp_gewiss_grund_abl_sonst (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_8 IS 'descriptive item only for frontend - femb der Variable mrp_wirkstoff (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_9 IS 'descriptive item only for frontend - femb der Variablen mrp_atc1_lbl, mrp_atc1 (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_10 IS 'descriptive item only for frontend - femb der Variablen mrp_atc2_lbl, mrp_atc2 (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_11 IS 'descriptive item only for frontend - femb der Variablen mrp_atc3_lbl, mrp_atc3 (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_12 IS 'descriptive item only for frontend - femb der Variablen mrp_atc4_lbl, mrp_atc4 (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_wirkstoff IS 'Wirkstoff betroffen? - 1, Ja | 0, Nein (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc1_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc1 IS '1. Medikament ATC / Name- https://www.bfarm.de/SharedDocs/Downloads/DE/Kodiersysteme/ATC/atc-ddd-amtlich-2024.pdf?__blob=publicationFile (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc2_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc2 IS '2. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc3_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc3 IS '3. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc4_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc4 IS '4. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc5_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc5 IS '5. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_13 IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_med_prod IS 'Medizinprodukt betroffen? - 1, Ja | 0, Nein, (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_med_prod_sonst_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_med_prod_sonst IS 'Bezeichnung Präparat (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_fehler IS 'Frage / Fehlerbeschreibung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_intervention IS 'Intervention / Vorschlag zur Fehlervermeldung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_14 IS 'descriptive item only for frontend - femb der Variablen mrp_med_prod, mrp_med_prod_sonst_lbl, mrp_med_prod_sonst (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund IS 'PI-Grund (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___1 IS '1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___2 IS '2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___3 IS '3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___4 IS '4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___5 IS '5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___6 IS '6 - AM: Übertragungsfehler (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___7 IS '7 - AM: Substitution aut idem/aut simile (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___8 IS '8 - AM: (Klare) Indikation, aber kein Medikament angeordnet (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___9 IS '9 - AM: Stellfehler (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___10 IS '10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___11 IS '11 - AM: Doppelverordnung (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___12 IS '12 - ANW: Applikation (Dauer) (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___13 IS '13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___14 IS '14 - ANW: Applikation (Art) (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___15 IS '15 - ANW: Anfrage zur Administration/Kompatibilität (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___16 IS '16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___17 IS '17 - D: (Fehlerhafte) Dosis (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___18 IS '18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___19 IS '19 - D: (Fehlerhaftes) Dosisinterval (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___20 IS '20 - Interaktion (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___21 IS '21 - Kontraindikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___22 IS '22 - Nebenwirkungen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___23 IS '23 - S: Beratung/Auswahl eines Arzneistoffs (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___24 IS '24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___25 IS '25 - S: Beschaffung/Kosten (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___26 IS '26 - S: Keine Pause von AM, die prä-OP pausiert werden müssen (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___27 IS '27 - S: Schulung/Beratung eines Patienten (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_15 IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse___1 IS '1 - Drug - Drug (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse___2 IS '2 - Drug - Drug-Group (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse___3 IS '3 - Drug - Disease (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse___4 IS '4 - Drug - Labor (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse___5 IS '5 - Drug - Age (Priscus 2.0 o. Dosis) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_16 IS 'descriptive item only for frontend - femb der Variable mrp_ip_klasse (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_17 IS 'descriptive item only for frontend - femb der Variable mrp_ip_klasse_disease (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_disease IS 'Disease (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_labor IS 'Labor (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_18 IS 'descriptive item only for frontend - femb der Variable mrp_ip_klasse_labor (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am IS 'AM: Arzneimitte (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___1 IS '1 - Anweisung für die Applikation geben (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___2 IS '2 - Arzneimittel ändern (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___5 IS '5 - Dosierung ändern (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___6 IS '6 - Formulierung ändern (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___7 IS '7 - Hilfe bei Beschaffung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___8 IS '8 - Information an Arzt/Pflege (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___9 IS '9 - Information an Patient (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_19 IS 'descriptive item only for frontend - femb der Variable mrp_massn_am (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga IS 'ORGA: Organisatorisch (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___3 IS '3 - Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_20 IS 'descriptive item only for frontend - femb der Variable mrp_massn_orga (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_notiz IS 'Notiz (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_femb_21 IS 'descriptive item only for frontend - femb der Variable mrp_notiz (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_hand_emp_akz IS 'Handlungsempfehlung akzeptiert? - 1, Arzt / Pflege informiert | 2, Intervention vorgeschlagen und umgesetzt | 3, Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation) | 4 , Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung) | 5, Intervention vorgeschlagen, Umsetzung unbekannt | 6, Problem nicht gelöst (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp IS 'NCC MERP Score - A, Category A | B, Category B | C, Category C | D, Category D | E, Category E | F, Category F | G, Category G | H, Category H | I, Category I  (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp_info IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp_info___1 IS 'descriptive item only for frontend - Blendet NCC MERP Index ein/aus (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp_txt IS 'descriptive item only for frontend - Beinhaltet NCC MERP Index als PDF (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_complete IS 'Frontend Complete-Status, wenn ein Pflichtitem fehlt Status bei Import wieder auf Incomplete setzen  - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db_log.risikofaktor_fe.risikofaktor_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.risikofaktor_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.patient_id_fk IS 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_gerhemmer IS 'Ger.hemmer (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_tah IS 'TAH (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_immunsupp IS 'Immunsupp. (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_tumorth IS 'Tumorth. (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_opiat IS 'Opiat (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_atcn IS 'ATC N (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_ait IS 'AIT (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_anzam IS 'Anz AM (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_priscus IS 'PRISCUS (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_qtc IS 'QTc (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_meld IS 'MELD (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_dialyse IS 'Dialyse (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_entern IS 'ent. Ern. (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfkt_anz_rskamklassen IS 'Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.risikofaktor_complete IS 'Frontend Complete-Status (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.risikofaktor_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.risikofaktor_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.risikofaktor_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.risikofaktor_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db_log.trigger_fe.trigger_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.trigger_fe.patient_id_fk IS 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)';
COMMENT ON COLUMN db_log.trigger_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_ast IS 'AST (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_alt IS 'ALT↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_crp IS 'CRP↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_leuk_penie IS 'Leuko↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_leuk_ose IS 'Leuko↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_thrmb_penie IS 'Thrombo↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_aptt IS 'aPTT (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyp_haem IS 'Hb↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_glyk IS 'Glc↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_glyk IS 'Glc↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_bilirbnm IS 'Bili↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_ck IS 'CK↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_serablmn IS 'Alb↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_nat IS 'Na+↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_nat IS 'Na+↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_kal IS 'K+↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_kal IS 'K+↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_ern IS 'INR Antikoag↓ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_erh IS 'INR ↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_erh_antikoa IS 'INR Antikoag↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_krea IS 'Krea↑ (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_egfr IS 'eGFR<30 (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trigger_complete IS 'Frontend Complete-Status (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.trigger_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.trigger_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.trigger_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.trigger_fe.last_processing_nr IS 'Last processing number of the data record';


-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "db_log" --
------------------------------------------------------

------------------------- Index for db_log - patient_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_patient_fe_id ON db_log.patient_fe ( patient_fe_id); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_patient_fe_input_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_input_dt
ON db_log.patient_fe (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_db_log_patient_fe_input_pnr for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_input_pnr
ON db_log.patient_fe (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_db_log_patient_fe_last_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_last_dt
ON db_log.patient_fe (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_db_log_patient_fe_last_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_last_pnr
ON db_log.patient_fe (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_db_log_patient_fe_hash for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_hash
ON db_log.patient_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - fall_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_fall_fe_id ON db_log.fall_fe ( fall_fe_id); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_fall_fe_input_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_input_dt
ON db_log.fall_fe (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_db_log_fall_fe_input_pnr for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_input_pnr
ON db_log.fall_fe (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_db_log_fall_fe_last_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_last_dt
ON db_log.fall_fe (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_db_log_fall_fe_last_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_last_pnr
ON db_log.fall_fe (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_db_log_fall_fe_hash for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_hash
ON db_log.fall_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - medikationsanalyse_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_medikationsanalyse_fe_id ON db_log.medikationsanalyse_fe ( medikationsanalyse_fe_id); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_medikationsanalyse_fe_input_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_input_dt
ON db_log.medikationsanalyse_fe (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_db_log_medikationsanalyse_fe_input_pnr for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_input_pnr
ON db_log.medikationsanalyse_fe (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_db_log_medikationsanalyse_fe_last_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_last_dt
ON db_log.medikationsanalyse_fe (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_db_log_medikationsanalyse_fe_last_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_last_pnr
ON db_log.medikationsanalyse_fe (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_db_log_medikationsanalyse_fe_hash for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_hash
ON db_log.medikationsanalyse_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - mrpdokumentation_validierung_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_mrpdokumentation_validierung_fe_id ON db_log.mrpdokumentation_validierung_fe ( mrpdokumentation_validierung_fe_id); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_mrpdokumentation_validierung_fe_input_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_input_dt
ON db_log.mrpdokumentation_validierung_fe (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_input_pnr for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_input_pnr
ON db_log.mrpdokumentation_validierung_fe (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_last_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_last_dt
ON db_log.mrpdokumentation_validierung_fe (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_last_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_last_pnr
ON db_log.mrpdokumentation_validierung_fe (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_hash for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_hash
ON db_log.mrpdokumentation_validierung_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - risikofaktor_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_risikofaktor_fe_id ON db_log.risikofaktor_fe ( risikofaktor_fe_id); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_risikofaktor_fe_input_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_input_dt
ON db_log.risikofaktor_fe (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_db_log_risikofaktor_fe_input_pnr for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_input_pnr
ON db_log.risikofaktor_fe (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_db_log_risikofaktor_fe_last_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_last_dt
ON db_log.risikofaktor_fe (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_db_log_risikofaktor_fe_last_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_last_pnr
ON db_log.risikofaktor_fe (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_db_log_risikofaktor_fe_hash for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_hash
ON db_log.risikofaktor_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - trigger_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_trigger_fe_id ON db_log.trigger_fe ( trigger_fe_id); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_trigger_fe_input_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_input_dt
ON db_log.trigger_fe (
   input_datetime -- Time at which the data record is inserted
);

-- Index idx_db_log_trigger_fe_input_pnr for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_input_pnr
ON db_log.trigger_fe (
   input_processing_nr -- (First) Processing number of the data record
);

-- Index idx_db_log_trigger_fe_last_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_last_dt
ON db_log.trigger_fe (
   last_check_datetime -- Time at which data record was last checked
);

-- Index idx_db_log_trigger_fe_last_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_last_pnr
ON db_log.trigger_fe (
   last_processing_nr -- Last processing number of the data record
);

-- Index idx_db_log_trigger_fe_hash for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_hash
ON db_log.trigger_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);


