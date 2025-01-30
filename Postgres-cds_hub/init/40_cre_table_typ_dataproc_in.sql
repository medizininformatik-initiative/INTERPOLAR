-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-12-04 16:58:23
-- Rights definition file size        : 15179 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_in"
-- Create time: 2025-01-09 17:42:45
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  40_cre_table_typ_dataproc_in.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_in
-- TAGS:  
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _fe
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- RIGHTS (3):  SELECT
-- GRANT_TARGET_USER:  db2dataprocessor_user
-- GRANT_TARGET_USER (2):  db_user
-- GRANT_TARGET_USER (3):  db_log_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "db2dataprocessor_in" --
-----------------------------------------------------

-- Table "patient_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.patient_fe (
  patient_fe_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
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
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);
-- Table "fall_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.fall_fe (
  fall_fe_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
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
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);
-- Table "medikationsanalyse_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.medikationsanalyse_fe (
  medikationsanalyse_fe_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
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
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);
-- Table "mrpdokumentation_validierung_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.mrpdokumentation_validierung_fe (
  mrpdokumentation_validierung_fe_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
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
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);
-- Table "risikofaktor_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.risikofaktor_fe (
  risikofaktor_fe_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
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
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);
-- Table "trigger_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.trigger_fe (
  trigger_fe_id int PRIMARY KEY DEFAULT nextval('db.db_seq'), -- Primary key of the entity
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
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

------------------------------------------------------
-- SQL Role / Trigger in Schema "db2dataprocessor_in" --
------------------------------------------------------


-- Table "patient_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.patient_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.patient_fe TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.patient_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.patient_fe TO db_log_user; -- Additional authorizations for testing

-- Table "fall_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.fall_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.fall_fe TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.fall_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.fall_fe TO db_log_user; -- Additional authorizations for testing

-- Table "medikationsanalyse_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.medikationsanalyse_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.medikationsanalyse_fe TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.medikationsanalyse_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.medikationsanalyse_fe TO db_log_user; -- Additional authorizations for testing

-- Table "mrpdokumentation_validierung_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.mrpdokumentation_validierung_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe TO db_log_user; -- Additional authorizations for testing

-- Table "risikofaktor_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.risikofaktor_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.risikofaktor_fe TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.risikofaktor_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.risikofaktor_fe TO db_log_user; -- Additional authorizations for testing

-- Table "trigger_fe" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.trigger_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.trigger_fe TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.trigger_fe TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.trigger_fe TO db_log_user; -- Additional authorizations for testing

------------------------------------------------------
-- Comments on Tables in Schema "db2dataprocessor_in" --
------------------------------------------------------
-- Output off
\o /dev/null

COMMENT ON COLUMN db2dataprocessor_in.patient_fe.patient_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instrument :  patient - darf nicht besetzt werden muss nur für den sycronisationsvorgang vorhanden sein (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_header IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_id IS 'Patient-identifier FHIR Daten (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_femb_1 IS 'descriptive item only for frontend - Fieldembedding (femb) der Variablen pat_cis_pid, pat_name, pat_vorname, pat_gebdat,pat_geschlecht (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_cis_pid IS 'Patient Identifier aus dem Krankenhausinformationssystem - so wie es dem Apotheker zur verfügung steht (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_name IS 'Patientenname (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_vorname IS 'Patientenvorname (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_gebdat IS 'Geburtsdatum (date)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_aktuell_alter IS 'aktuelles Patientenalter (Jahre) (double precision)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.pat_geschlecht IS 'Geschlecht (wie in FHIR) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.patient_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.patient_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_header IS 'descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanz  (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_id IS 'Fall-ID RedCap FHIR Daten (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_pat_id IS 'Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.patient_id_fk IS 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_femb_1 IS 'descriptive item only for frontend - femb der Variablen fall_id, fall_station, fall_aufn_dat, fall_zimmernr, fall_aufn_diag, fall_gewicht_aktuell, fall_gewicht_aktl_einheit, fall_groesse, fall_groesse_einheit (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :   fall (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_studienphase IS 'Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) ) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_station IS 'Station wie vom DIZ Definiert (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_zimmernr IS 'Zimmernummer wie vom DIZ Definiert (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_aufn_dat IS 'Aufnahmedatum (timestamp)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_aufn_diag IS 'Diagnose(n) bei Aufnahme (wird nur zum lesen sein (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_gewicht_aktuell IS 'aktuelles Gewicht (Kg) (double precision)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_gewicht_aktl_einheit IS 'Einheit des Gewichts (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_groesse IS 'Größe (cm) (double precision)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_groesse_einheit IS 'Einheit der Größe (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_bmi IS 'BMI (double precision)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_femb_2 IS 'descriptive item only for frontend - femb der Variablen fall_nieren_insuf_chron, fall_nieren_insuf_ausmass_lbl, fall_nieren_insuf_ausmass (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_femb_3 IS 'descriptive item only for frontend - femb der Variablen fall_nieren_insuf_dialysev_lbl, fall_nieren_insuf_dialysev (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_femb_4 IS 'descriptive item only for frontend - femb der Variablen fall_leber_insuf, fall_leber_insuf_ausmass_lbl, fall_leber_insuf_ausmass (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_femb_5 IS 'descriptive item only for frontend - femb der Variablen fall_schwanger_mo_lbl, fall_schwanger_mo (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_femb_6 IS 'descriptive item only for frontend - femb der Variablen fall_status, fall_ent_dat (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_nieren_insuf_chron IS '1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_nieren_insuf_ausmass_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_nieren_insuf_ausmass IS 'aktuelles Ausmaß - 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_nieren_insuf_dialysev_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_nieren_insuf_dialysev IS 'Nierenersatzverfahren - 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_leber_insuf IS 'Leberinsuffizienz - 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_leber_insuf_ausmass_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_leber_insuf_ausmass IS 'aktuelles Ausmaß -1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß  (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_schwanger_mo IS 'Schwangerschaftsmonat - 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_schwanger_mo_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_status IS 'Status des Falls (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_ent_dat IS 'Entlassdatum (timestamp)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.fall_complete IS 'Frontend Complete-Status - Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.fall_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.medikationsanalyse_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_header IS 'descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_femb_1 IS 'descriptive item only for frontend - femb der Variable meda_dat (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_femb_2 IS 'descriptive item only for frontend - femb der Variable meda_ma_thueberw (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_femb_3 IS 'descriptive item only for frontend - femb der Variablen meda_mrp_detekt, meda_aufwand_zeit, meda_aufwand_zeit_and_lbl, meda_aufwand_zeit_and, meda_notiz (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.fall_fe_id IS 'Datenbank-FK des Falls (Fall: v_fall_all . fall_id) -> Dataprocessor setzt id: meda_dat in [fall_aufn_dat;fall_ent_dat] (int)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :  medikationsanalyse (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_dat IS 'Datum der Medikationsanalyse (timestamp)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_typ IS 'Typ der Medikationsanalyse - 1, Typ 1: Einfache MA | 2a, Typ 2a: Erweiterte MA | 2b, Typ 2b: Erweiterte MA | 3, Typ 3: Umfassende MA  (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_ma_thueberw IS 'Medikationsanalyse / Therapieüberwachung in 24-48h - 1, Ja | 0, Nein (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_mrp_detekt IS 'MRP detektiert? - 1, Ja|0, Nein (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_aufwand_zeit IS 'Zeitaufwand Medikationsanalyse - 0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min] (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_aufwand_zeit_and_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (int)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_aufwand_zeit_and IS 'genaue Dauer in Minuten (int)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.meda_notiz IS 'Notizfeld (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.medikationsanalyse_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.medikationsanalyse_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.meda_fe_id IS 'Datenbank-FK der Medikationsanalyse (Medikationsanalyse: medikationsanalyse_fe_id) -> Dataprocessor setzt id: mrp_entd_dat(Tag)=meda_dat(Tag) (int)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.redcap_repeat_instrument IS 'Frontend interne Datensatzverwaltung - Instrument :  MRP-Dokumentation / -Validierung  (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.redcap_repeat_instance IS 'Frontend interne Datensatzverwaltung - Instanz des Instruments - Numerisch : 1…n (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_header IS 'descriptive item only for frontend - Gesamtüberischt Patienten, Falldaten, gegenwärtige Formular-Instanzen  (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_1 IS 'descriptive item only for frontend - femb der Variable mrp_entd_dat (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_2 IS 'descriptive item only for frontend - femb der Variablen mrp_kurzbeschr, mrp_entd_algorithmisch, mrp_hinweisgeber_lbl, mrp_hinweisgeber (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_3 IS 'descriptive item only for frontend - femb der Variable mrp_hinweisgeber_oth (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pi_info IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pi_info___1 IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_mf_info IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_mf_info___1 IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pi_info_txt IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_mf_info_txt IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_4 IS 'descriptive item only for frontend - femb der Variablen mrp_gewissheit_lbl, mrp_gewissheit (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_5 IS 'descriptive item only for frontend - femb der Variable mrp_gewissheit_oth (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_6 IS 'descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_lbl, mrp_gewiss_grund_abl (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_entd_dat IS 'Datum des MRP (timestamp)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_kurzbeschr IS 'Kurzbeschreibung des MRPs (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_entd_algorithmisch IS 'MRP vom INTERPOLAR-Algorithmus entdeckt? - 1, Ja | 0, Nein (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_hinweisgeber_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_hinweisgeber IS 'Hinweisgeber auf das MRP (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewissheit_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewissheit IS 'Sicherheit des detektierten MRP - 1, MRP bestätigt | 2, MRP möglich, weitere Informationen nötig | 3, MRP nicht bestätigt (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_22 IS 'descriptive item only for frontend - femb der Variablen (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewissheit_oth IS 'Textfeld, wenn mrp_gewissheit = 2 MRP möglich, weitere Informationen nötig (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_23 IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_hinweisgeber_oth IS 'Textfeld, wenn mrp_hinweisgeber = 7 (andere) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl IS 'Grund für nicht Bestätigung - 1, MRP sachlich falsch (keine Kontraindikation) | 2, MRP sachlich richtig, aber falsche Datengrundlage | 3, MRP sachlich richtig, aber klinisch nicht relevant | 4, MRP sachlich richtig, aber von Stationsapotheker vorher identifiziert | 5, Sonstiges (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_sonst_lbl IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_sonst IS 'Bitte näher beschreiben (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_7 IS 'descriptive item only for frontend - femb der Variablen mrp_gewiss_grund_abl_sonst_lbl, mrp_gewiss_grund_abl_sonst (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_8 IS 'descriptive item only for frontend - femb der Variable mrp_wirkstoff (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_9 IS 'descriptive item only for frontend - femb der Variablen mrp_atc1_lbl, mrp_atc1 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_10 IS 'descriptive item only for frontend - femb der Variablen mrp_atc2_lbl, mrp_atc2 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_11 IS 'descriptive item only for frontend - femb der Variablen mrp_atc3_lbl, mrp_atc3 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_12 IS 'descriptive item only for frontend - femb der Variablen mrp_atc4_lbl, mrp_atc4 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_wirkstoff IS 'Wirkstoff betroffen? - 1, Ja | 0, Nein (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc1_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc1 IS '1. Medikament ATC / Name- https://www.bfarm.de/SharedDocs/Downloads/DE/Kodiersysteme/ATC/atc-ddd-amtlich-2024.pdf?__blob=publicationFile (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc2_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc2 IS '2. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc3_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc3 IS '3. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc4_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc4 IS '4. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc5_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc5 IS '5. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_13 IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_med_prod IS 'Medizinprodukt betroffen? - 1, Ja | 0, Nein, (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_med_prod_sonst_lbl IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_med_prod_sonst IS 'Bezeichnung Präparat (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_dokup_fehler IS 'Frage / Fehlerbeschreibung (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_dokup_intervention IS 'Intervention / Vorschlag zur Fehlervermeldung (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_14 IS 'descriptive item only for frontend - femb der Variablen mrp_med_prod, mrp_med_prod_sonst_lbl, mrp_med_prod_sonst (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund IS 'PI-Grund (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___1 IS '1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___2 IS '2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___3 IS '3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___4 IS '4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___5 IS '5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___6 IS '6 - AM: Übertragungsfehler (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___7 IS '7 - AM: Substitution aut idem/aut simile (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___8 IS '8 - AM: (Klare) Indikation, aber kein Medikament angeordnet (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___9 IS '9 - AM: Stellfehler (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___10 IS '10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___11 IS '11 - AM: Doppelverordnung (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___12 IS '12 - ANW: Applikation (Dauer) (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___13 IS '13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___14 IS '14 - ANW: Applikation (Art) (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___15 IS '15 - ANW: Anfrage zur Administration/Kompatibilität (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___16 IS '16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___17 IS '17 - D: (Fehlerhafte) Dosis (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___18 IS '18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___19 IS '19 - D: (Fehlerhaftes) Dosisinterval (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___20 IS '20 - Interaktion (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___21 IS '21 - Kontraindikation (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___22 IS '22 - Nebenwirkungen (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___23 IS '23 - S: Beratung/Auswahl eines Arzneistoffs (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___24 IS '24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___25 IS '25 - S: Beschaffung/Kosten (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___26 IS '26 - S: Keine Pause von AM, die prä-OP pausiert werden müssen (MF) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___27 IS '27 - S: Schulung/Beratung eines Patienten (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_15 IS 'descriptive item only for frontend - Label für femb (korrespondierende Variable) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___1 IS '1 - Drug - Drug (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___2 IS '2 - Drug - Drug-Group (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___3 IS '3 - Drug - Disease (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___4 IS '4 - Drug - Labor (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___5 IS '5 - Drug - Age (Priscus 2.0 o. Dosis) (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_16 IS 'descriptive item only for frontend - femb der Variable mrp_ip_klasse (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_17 IS 'descriptive item only for frontend - femb der Variable mrp_ip_klasse_disease (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse_disease IS 'Disease (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse_labor IS 'Labor (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_18 IS 'descriptive item only for frontend - femb der Variable mrp_ip_klasse_labor (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am IS 'AM: Arzneimitte (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___1 IS '1 - Anweisung für die Applikation geben (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___2 IS '2 - Arzneimittel ändern (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___5 IS '5 - Dosierung ändern (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___6 IS '6 - Formulierung ändern (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___7 IS '7 - Hilfe bei Beschaffung (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___8 IS '8 - Information an Arzt/Pflege (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___9 IS '9 - Information an Patient (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_19 IS 'descriptive item only for frontend - femb der Variable mrp_massn_am (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga IS 'ORGA: Organisatorisch (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___3 IS '3 - Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_20 IS 'descriptive item only for frontend - femb der Variable mrp_massn_orga (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_notiz IS 'Notiz (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_femb_21 IS 'descriptive item only for frontend - femb der Variable mrp_notiz (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_dokup_hand_emp_akz IS 'Handlungsempfehlung akzeptiert? - 1, Arzt / Pflege informiert | 2, Intervention vorgeschlagen und umgesetzt | 3, Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation) | 4 , Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung) | 5, Intervention vorgeschlagen, Umsetzung unbekannt | 6, Problem nicht gelöst (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_merp IS 'NCC MERP Score - A, Category A | B, Category B | C, Category C | D, Category D | E, Category E | F, Category F | G, Category G | H, Category H | I, Category I  (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_merp_info IS 'descriptive item only for frontend (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_merp_info___1 IS 'descriptive item only for frontend - Blendet NCC MERP Index ein/aus (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_merp_txt IS 'descriptive item only for frontend - Beinhaltet NCC MERP Index als PDF (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_complete IS 'Frontend Complete-Status, wenn ein Pflichtitem fehlt Status bei Import wieder auf Incomplete setzen  - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.mrpdokumentation_validierung_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.risikofaktor_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.patient_id_fk IS 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_gerhemmer IS 'Ger.hemmer (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_tah IS 'TAH (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_immunsupp IS 'Immunsupp. (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_tumorth IS 'Tumorth. (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_opiat IS 'Opiat (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_atcn IS 'ATC N (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_ait IS 'AIT (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_anzam IS 'Anz AM (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_priscus IS 'PRISCUS (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_qtc IS 'QTc (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_meld IS 'MELD (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_dialyse IS 'Dialyse (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfk_entern IS 'ent. Ern. (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.rskfkt_anz_rskamklassen IS 'Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.risikofaktor_complete IS 'Frontend Complete-Status (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.risikofaktor_fe.last_processing_nr IS 'Last processing number of the data record';

COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trigger_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.patient_id_fk IS 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id) (int)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.record_id IS 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_ast IS 'AST (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_alt IS 'ALT↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_crp IS 'CRP↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_leuk_penie IS 'Leuko↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_leuk_ose IS 'Leuko↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_thrmb_penie IS 'Thrombo↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_aptt IS 'aPTT (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hyp_haem IS 'Hb↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hypo_glyk IS 'Glc↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hyper_glyk IS 'Glc↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hyper_bilirbnm IS 'Bili↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_ck IS 'CK↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hypo_serablmn IS 'Alb↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hypo_nat IS 'Na+↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hyper_nat IS 'Na+↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hyper_kal IS 'K+↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_hypo_kal IS 'K+↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_inr_ern IS 'INR Antikoag↓ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_inr_erh IS 'INR ↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_inr_erh_antikoa IS 'INR Antikoag↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_krea IS 'Krea↑ (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trg_egfr IS 'eGFR<30 (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.trigger_complete IS 'Frontend Complete-Status (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.trigger_fe.last_processing_nr IS 'Last processing number of the data record';


-- Output on
\o

