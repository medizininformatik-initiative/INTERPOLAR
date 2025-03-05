-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-03-05 12:14:14
-- Rights definition file size        : 15641 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2025-03-05 14:46:28
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
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.patient_fe (
  patient_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
  redcap_repeat_instrument varchar,   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
  redcap_repeat_instance varchar,   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
  redcap_data_access_group varchar,   -- Function as dataset filter by stations (varchar)
  pat_id varchar,   -- Patient-identifier (FHIR) (varchar)
  pat_cis_pid varchar,   -- Patient-identifier (KIS) (varchar)
  pat_name varchar,   -- Patientenname (varchar)
  pat_vorname varchar,   -- Patientenvorname (varchar)
  pat_gebdat date,   -- Geburtsdatum (date)
  pat_aktuell_alter double precision,   -- aktuelles Patientenalter (Jahre) (double precision)
  pat_geschlecht varchar,   -- Geschlecht (varchar)
  patient_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
             COALESCE(db.to_char_immutable(pat_id), '#NULL#') || '|||' || -- hash from: Patient-identifier (FHIR) (pat_id)
             COALESCE(db.to_char_immutable(pat_cis_pid), '#NULL#') || '|||' || -- hash from: Patient-identifier (KIS) (pat_cis_pid)
             COALESCE(db.to_char_immutable(pat_name), '#NULL#') || '|||' || -- hash from: Patientenname (pat_name)
             COALESCE(db.to_char_immutable(pat_vorname), '#NULL#') || '|||' || -- hash from: Patientenvorname (pat_vorname)
             COALESCE(db.to_char_immutable(pat_gebdat), '#NULL#') || '|||' || -- hash from: Geburtsdatum (pat_gebdat)
             COALESCE(db.to_char_immutable(pat_aktuell_alter), '#NULL#') || '|||' || -- hash from: aktuelles Patientenalter (Jahre) (pat_aktuell_alter)
             COALESCE(db.to_char_immutable(pat_geschlecht), '#NULL#') || '|||' || -- hash from: Geschlecht (pat_geschlecht)
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
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.fall_fe (
  fall_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
  redcap_repeat_instrument varchar,   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
  redcap_repeat_instance varchar,   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
  redcap_data_access_group varchar,   -- Function as dataset filter by stations (varchar)
  patient_id_fk int,   -- verstecktes Feld für patient_id_fk (int)
  fall_pat_id varchar,   -- verstecktes Feld für fall_pat_id (varchar)
  fall_id varchar,   -- Fall-ID (varchar)
  fall_studienphase varchar,   -- Studienphase (varchar)
  fall_station varchar,   -- Station (varchar)
  fall_aufn_dat timestamp,   -- Aufnahmedatum (timestamp)
  fall_zimmernr varchar,   -- Zimmer-Nr. (varchar)
  fall_aufn_diag varchar,   -- Diagnose(n) bei Aufnahme (varchar)
  fall_gewicht_aktuell double precision,   -- aktuelles Gewicht (double precision)
  fall_gewicht_aktl_einheit varchar,   -- aktuelles Gewicht: Einheit (varchar)
  fall_groesse double precision,   -- Größe (double precision)
  fall_groesse_einheit varchar,   -- Größe: Einheit (varchar)
  fall_bmi double precision,   -- BMI (double precision)
  fall_status varchar,   -- Fallstatus (varchar)
  fall_ent_dat timestamp,   -- Entlassdatum (timestamp)
  fall_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
             COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: verstecktes Feld für patient_id_fk (patient_id_fk)
             COALESCE(db.to_char_immutable(fall_pat_id), '#NULL#') || '|||' || -- hash from: verstecktes Feld für fall_pat_id (fall_pat_id)
             COALESCE(db.to_char_immutable(fall_id), '#NULL#') || '|||' || -- hash from: Fall-ID (fall_id)
             COALESCE(db.to_char_immutable(fall_studienphase), '#NULL#') || '|||' || -- hash from: Studienphase (fall_studienphase)
             COALESCE(db.to_char_immutable(fall_station), '#NULL#') || '|||' || -- hash from: Station (fall_station)
             COALESCE(db.to_char_immutable(fall_aufn_dat), '#NULL#') || '|||' || -- hash from: Aufnahmedatum (fall_aufn_dat)
             COALESCE(db.to_char_immutable(fall_zimmernr), '#NULL#') || '|||' || -- hash from: Zimmer-Nr. (fall_zimmernr)
             COALESCE(db.to_char_immutable(fall_aufn_diag), '#NULL#') || '|||' || -- hash from: Diagnose(n) bei Aufnahme (fall_aufn_diag)
             COALESCE(db.to_char_immutable(fall_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (fall_gewicht_aktuell)
             COALESCE(db.to_char_immutable(fall_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht: Einheit (fall_gewicht_aktl_einheit)
             COALESCE(db.to_char_immutable(fall_groesse), '#NULL#') || '|||' || -- hash from: Größe (fall_groesse)
             COALESCE(db.to_char_immutable(fall_groesse_einheit), '#NULL#') || '|||' || -- hash from: Größe: Einheit (fall_groesse_einheit)
             COALESCE(db.to_char_immutable(fall_bmi), '#NULL#') || '|||' || -- hash from: BMI (fall_bmi)
             COALESCE(db.to_char_immutable(fall_status), '#NULL#') || '|||' || -- hash from: Fallstatus (fall_status)
             COALESCE(db.to_char_immutable(fall_ent_dat), '#NULL#') || '|||' || -- hash from: Entlassdatum (fall_ent_dat)
             COALESCE(db.to_char_immutable(fall_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (fall_complete)
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
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.medikationsanalyse_fe (
  medikationsanalyse_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
  redcap_repeat_instrument varchar,   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
  redcap_repeat_instance varchar,   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
  redcap_data_access_group varchar,   -- Function as dataset filter by stations (varchar)
  meda_anlage varchar,   -- Formular angelegt von (varchar)
  meda_edit varchar,   -- Formular zuletzt bearbeitet von (varchar)
  fall_meda_id varchar,   -- Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse -> Fall (varchar)
  meda_id varchar,   -- ID Medikationsanalyse (varchar)
  meda_typ varchar,   -- Typ der Medikationsanalyse (MA) (varchar)
  meda_dat timestamp,   -- Datum der Medikationsanalyse (timestamp)
  meda_gewicht_aktuell double precision,   -- aktuelles Gewicht (double precision)
  meda_gewicht_aktl_einheit varchar,   -- aktuelles Gewicht: Einheit (varchar)
  meda_groesse double precision,   -- Größe (double precision)
  meda_groesse_einheit varchar,   -- Größe: Einheit (varchar)
  meda_bmi double precision,   -- BMI (double precision)
  meda_nieren_insuf_chron varchar,   -- Chronische Niereninsuffizienz (varchar)
  meda_nieren_insuf_ausmass varchar,   -- aktuelles Ausmaß (varchar)
  meda_nieren_insuf_dialysev varchar,   -- Nierenersatzverfahren (varchar)
  meda_leber_insuf varchar,   -- Leberinsuffizienz (varchar)
  meda_leber_insuf_ausmass varchar,   -- aktuelles Ausmaß (varchar)
  meda_schwanger_mo varchar,   -- Schwangerschaftsmonat (varchar)
  meda_ma_thueberw varchar,   -- Wiedervorlage Medikationsanalyse in 24-48h (varchar)
  meda_mrp_detekt varchar,   -- MRP detektiert? (varchar)
  meda_aufwand_zeit varchar,   -- Zeitaufwand Medikationsanalyse (varchar)
  meda_aufwand_zeit_and int,   -- genaue Dauer in Minuten (int)
  meda_notiz varchar,   -- Notizfeld (varchar)
  medikationsanalyse_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
             COALESCE(db.to_char_immutable(meda_anlage), '#NULL#') || '|||' || -- hash from: Formular angelegt von (meda_anlage)
             COALESCE(db.to_char_immutable(meda_edit), '#NULL#') || '|||' || -- hash from: Formular zuletzt bearbeitet von (meda_edit)
             COALESCE(db.to_char_immutable(fall_meda_id), '#NULL#') || '|||' || -- hash from: Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse -> Fall (fall_meda_id)
             COALESCE(db.to_char_immutable(meda_id), '#NULL#') || '|||' || -- hash from: ID Medikationsanalyse (meda_id)
             COALESCE(db.to_char_immutable(meda_typ), '#NULL#') || '|||' || -- hash from: Typ der Medikationsanalyse (MA) (meda_typ)
             COALESCE(db.to_char_immutable(meda_dat), '#NULL#') || '|||' || -- hash from: Datum der Medikationsanalyse (meda_dat)
             COALESCE(db.to_char_immutable(meda_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (meda_gewicht_aktuell)
             COALESCE(db.to_char_immutable(meda_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht: Einheit (meda_gewicht_aktl_einheit)
             COALESCE(db.to_char_immutable(meda_groesse), '#NULL#') || '|||' || -- hash from: Größe (meda_groesse)
             COALESCE(db.to_char_immutable(meda_groesse_einheit), '#NULL#') || '|||' || -- hash from: Größe: Einheit (meda_groesse_einheit)
             COALESCE(db.to_char_immutable(meda_bmi), '#NULL#') || '|||' || -- hash from: BMI (meda_bmi)
             COALESCE(db.to_char_immutable(meda_nieren_insuf_chron), '#NULL#') || '|||' || -- hash from: Chronische Niereninsuffizienz (meda_nieren_insuf_chron)
             COALESCE(db.to_char_immutable(meda_nieren_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß (meda_nieren_insuf_ausmass)
             COALESCE(db.to_char_immutable(meda_nieren_insuf_dialysev), '#NULL#') || '|||' || -- hash from: Nierenersatzverfahren (meda_nieren_insuf_dialysev)
             COALESCE(db.to_char_immutable(meda_leber_insuf), '#NULL#') || '|||' || -- hash from: Leberinsuffizienz (meda_leber_insuf)
             COALESCE(db.to_char_immutable(meda_leber_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß (meda_leber_insuf_ausmass)
             COALESCE(db.to_char_immutable(meda_schwanger_mo), '#NULL#') || '|||' || -- hash from: Schwangerschaftsmonat (meda_schwanger_mo)
             COALESCE(db.to_char_immutable(meda_ma_thueberw), '#NULL#') || '|||' || -- hash from: Wiedervorlage Medikationsanalyse in 24-48h (meda_ma_thueberw)
             COALESCE(db.to_char_immutable(meda_mrp_detekt), '#NULL#') || '|||' || -- hash from: MRP detektiert? (meda_mrp_detekt)
             COALESCE(db.to_char_immutable(meda_aufwand_zeit), '#NULL#') || '|||' || -- hash from: Zeitaufwand Medikationsanalyse (meda_aufwand_zeit)
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
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.mrpdokumentation_validierung_fe (
  mrpdokumentation_validierung_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
  redcap_repeat_instrument varchar,   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
  redcap_repeat_instance varchar,   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
  redcap_data_access_group varchar,   -- Function as dataset filter by stations (varchar)
  mrp_anlage varchar,   -- Formular angelegt von (varchar)
  mrp_edit varchar,   -- Formular zuletzt bearbeitet von (varchar)
  mrp_meda_id varchar,   -- Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse -> MRP (varchar)
  mrp_id varchar,   -- MRP-ID (varchar)
  mrp_entd_dat timestamp,   -- Datum des MRP (timestamp)
  mrp_entd_algorithmisch varchar,   -- MRP vom INTERPOLAR-Algorithmus entdeckt? (varchar)
  mrp_kurzbeschr varchar,   -- Kurzbeschreibung des MRPs (varchar)
  mrp_hinweisgeber varchar,   -- Hinweisgeber auf das MRP (varchar)
  mrp_hinweisgeber_oth varchar,   -- Anderer Hinweisgeber (varchar)
  mrp_wirkstoff varchar,   -- Wirkstoff betroffen? (varchar)
  mrp_atc1 varchar,   -- 1. Medikament ATC / Name: (varchar)
  mrp_atc2 varchar,   -- 2. Medikament ATC / Name (varchar)
  mrp_atc3 varchar,   -- 3. Medikament ATC / Name (varchar)
  mrp_atc4 varchar,   -- 4. Medikament ATC / Name (varchar)
  mrp_atc5 varchar,   -- 5. Medikament ATC / Name (varchar)
  mrp_med_prod varchar,   -- Medizinprodukt betroffen? (varchar)
  mrp_med_prod_sonst varchar,   -- Bezeichnung Präparat (varchar)
  mrp_dokup_fehler varchar,   -- Frage / Fehlerbeschreibung    (varchar)
  mrp_dokup_intervention varchar,   -- Intervention / Vorschlag zur Fehlervermeldung (varchar)
  mrp_pigrund___1 varchar,   -- 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)
  mrp_pigrund___2 varchar,   -- 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)
  mrp_pigrund___3 varchar,   -- 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)
  mrp_pigrund___4 varchar,   -- 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)
  mrp_pigrund___5 varchar,   -- 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)
  mrp_pigrund___6 varchar,   -- 6 - AM: Übertragungsfehler (MF) (varchar)
  mrp_pigrund___7 varchar,   -- 7 - AM: Substitution aut idem/aut simile (MF) (varchar)
  mrp_pigrund___8 varchar,   -- 8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (varchar)
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
  mrp_pigrund___26 varchar,   -- 26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (varchar)
  mrp_pigrund___27 varchar,   -- 27 - S: Schulung/Beratung eines Patienten (varchar)
  mrp_ip_klasse varchar,   -- MRP-Klasse (INTERPOLAR) (varchar)
  mrp_ip_klasse_disease varchar,   -- Disease (varchar)
  mrp_ip_klasse_labor varchar,   -- Labor (varchar)
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
  mrp_massn_orga___1 varchar,   -- 1 - Aushändigung einer Information/eines Medikationsplans (varchar)
  mrp_massn_orga___2 varchar,   -- 2 - CIRS-/AMK-Meldung (varchar)
  mrp_massn_orga___3 varchar,   -- 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)
  mrp_massn_orga___4 varchar,   -- 4 - Etablierung einer Doppelkontrolle (varchar)
  mrp_massn_orga___5 varchar,   -- 5 - Lieferantenwechsel (varchar)
  mrp_massn_orga___6 varchar,   -- 6 - Optimierung der internen und externene Kommunikation (varchar)
  mrp_massn_orga___7 varchar,   -- 7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)
  mrp_massn_orga___8 varchar,   -- 8 - Sensibilisierung/Schulung (varchar)
  mrp_notiz varchar,   -- Notiz (varchar)
  mrp_dokup_hand_emp_akz varchar,   -- Handlungsempfehlung akzeptiert? (varchar)
  mrp_merp varchar,   -- NCC MERP Score (varchar)
  mrp_merp_info___1 varchar,   -- 1 - NCC MERP Index (varchar)
  mrpdokumentation_validierung_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
             COALESCE(db.to_char_immutable(mrp_anlage), '#NULL#') || '|||' || -- hash from: Formular angelegt von (mrp_anlage)
             COALESCE(db.to_char_immutable(mrp_edit), '#NULL#') || '|||' || -- hash from: Formular zuletzt bearbeitet von (mrp_edit)
             COALESCE(db.to_char_immutable(mrp_meda_id), '#NULL#') || '|||' || -- hash from: Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse -> MRP (mrp_meda_id)
             COALESCE(db.to_char_immutable(mrp_id), '#NULL#') || '|||' || -- hash from: MRP-ID (mrp_id)
             COALESCE(db.to_char_immutable(mrp_entd_dat), '#NULL#') || '|||' || -- hash from: Datum des MRP (mrp_entd_dat)
             COALESCE(db.to_char_immutable(mrp_entd_algorithmisch), '#NULL#') || '|||' || -- hash from: MRP vom INTERPOLAR-Algorithmus entdeckt? (mrp_entd_algorithmisch)
             COALESCE(db.to_char_immutable(mrp_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs (mrp_kurzbeschr)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber), '#NULL#') || '|||' || -- hash from: Hinweisgeber auf das MRP (mrp_hinweisgeber)
             COALESCE(db.to_char_immutable(mrp_hinweisgeber_oth), '#NULL#') || '|||' || -- hash from: Anderer Hinweisgeber (mrp_hinweisgeber_oth)
             COALESCE(db.to_char_immutable(mrp_wirkstoff), '#NULL#') || '|||' || -- hash from: Wirkstoff betroffen? (mrp_wirkstoff)
             COALESCE(db.to_char_immutable(mrp_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name: (mrp_atc1)
             COALESCE(db.to_char_immutable(mrp_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (mrp_atc2)
             COALESCE(db.to_char_immutable(mrp_atc3), '#NULL#') || '|||' || -- hash from: 3. Medikament ATC / Name (mrp_atc3)
             COALESCE(db.to_char_immutable(mrp_atc4), '#NULL#') || '|||' || -- hash from: 4. Medikament ATC / Name (mrp_atc4)
             COALESCE(db.to_char_immutable(mrp_atc5), '#NULL#') || '|||' || -- hash from: 5. Medikament ATC / Name (mrp_atc5)
             COALESCE(db.to_char_immutable(mrp_med_prod), '#NULL#') || '|||' || -- hash from: Medizinprodukt betroffen? (mrp_med_prod)
             COALESCE(db.to_char_immutable(mrp_med_prod_sonst), '#NULL#') || '|||' || -- hash from: Bezeichnung Präparat (mrp_med_prod_sonst)
             COALESCE(db.to_char_immutable(mrp_dokup_fehler), '#NULL#') || '|||' || -- hash from: Frage / Fehlerbeschreibung    (mrp_dokup_fehler)
             COALESCE(db.to_char_immutable(mrp_dokup_intervention), '#NULL#') || '|||' || -- hash from: Intervention / Vorschlag zur Fehlervermeldung (mrp_dokup_intervention)
             COALESCE(db.to_char_immutable(mrp_pigrund___1), '#NULL#') || '|||' || -- hash from: 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (mrp_pigrund___1)
             COALESCE(db.to_char_immutable(mrp_pigrund___2), '#NULL#') || '|||' || -- hash from: 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (mrp_pigrund___2)
             COALESCE(db.to_char_immutable(mrp_pigrund___3), '#NULL#') || '|||' || -- hash from: 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (mrp_pigrund___3)
             COALESCE(db.to_char_immutable(mrp_pigrund___4), '#NULL#') || '|||' || -- hash from: 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (mrp_pigrund___4)
             COALESCE(db.to_char_immutable(mrp_pigrund___5), '#NULL#') || '|||' || -- hash from: 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (mrp_pigrund___5)
             COALESCE(db.to_char_immutable(mrp_pigrund___6), '#NULL#') || '|||' || -- hash from: 6 - AM: Übertragungsfehler (MF) (mrp_pigrund___6)
             COALESCE(db.to_char_immutable(mrp_pigrund___7), '#NULL#') || '|||' || -- hash from: 7 - AM: Substitution aut idem/aut simile (MF) (mrp_pigrund___7)
             COALESCE(db.to_char_immutable(mrp_pigrund___8), '#NULL#') || '|||' || -- hash from: 8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (mrp_pigrund___8)
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
             COALESCE(db.to_char_immutable(mrp_pigrund___26), '#NULL#') || '|||' || -- hash from: 26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (mrp_pigrund___26)
             COALESCE(db.to_char_immutable(mrp_pigrund___27), '#NULL#') || '|||' || -- hash from: 27 - S: Schulung/Beratung eines Patienten (mrp_pigrund___27)
             COALESCE(db.to_char_immutable(mrp_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (mrp_ip_klasse)
             COALESCE(db.to_char_immutable(mrp_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (mrp_ip_klasse_disease)
             COALESCE(db.to_char_immutable(mrp_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (mrp_ip_klasse_labor)
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
             COALESCE(db.to_char_immutable(mrp_massn_orga___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (mrp_massn_orga___1)
             COALESCE(db.to_char_immutable(mrp_massn_orga___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (mrp_massn_orga___2)
             COALESCE(db.to_char_immutable(mrp_massn_orga___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (mrp_massn_orga___3)
             COALESCE(db.to_char_immutable(mrp_massn_orga___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (mrp_massn_orga___4)
             COALESCE(db.to_char_immutable(mrp_massn_orga___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (mrp_massn_orga___5)
             COALESCE(db.to_char_immutable(mrp_massn_orga___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (mrp_massn_orga___6)
             COALESCE(db.to_char_immutable(mrp_massn_orga___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (mrp_massn_orga___7)
             COALESCE(db.to_char_immutable(mrp_massn_orga___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (mrp_massn_orga___8)
             COALESCE(db.to_char_immutable(mrp_notiz), '#NULL#') || '|||' || -- hash from: Notiz (mrp_notiz)
             COALESCE(db.to_char_immutable(mrp_dokup_hand_emp_akz), '#NULL#') || '|||' || -- hash from: Handlungsempfehlung akzeptiert? (mrp_dokup_hand_emp_akz)
             COALESCE(db.to_char_immutable(mrp_merp), '#NULL#') || '|||' || -- hash from: NCC MERP Score (mrp_merp)
             COALESCE(db.to_char_immutable(mrp_merp_info___1), '#NULL#') || '|||' || -- hash from: 1 - NCC MERP Index (mrp_merp_info___1)
             COALESCE(db.to_char_immutable(mrpdokumentation_validierung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (mrpdokumentation_validierung_complete)
             '#'
      )
  ) STORED,							-- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Time at which the data record is inserted
  last_check_datetime TIMESTAMP DEFAULT NULL,                   -- Time at which data record was last checked
  current_dataset_status VARCHAR DEFAULT 'input',               -- Processing status of the data record
  input_processing_nr INT,                                      -- (First) Processing number of the data record
  last_processing_nr INT                                        -- Last processing number of the data record
);

-- Table "retrolektive_mrpbewertung_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.retrolektive_mrpbewertung_fe (
  retrolektive_mrpbewertung_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
  redcap_repeat_instrument varchar,   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
  redcap_repeat_instance varchar,   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
  redcap_data_access_group varchar,   -- Function as dataset filter by stations (varchar)
  ret_bewerter1 varchar,   -- 1. Bewertung von (varchar)
  ret_id varchar,   -- Retrolektive MRP-ID (varchar)
  ret_meda_id varchar,   -- Zuordnung Meda -> rMRP (varchar)
  ret_meda_dat1 timestamp,   -- Datum der retrolektiven Betrachtung* (timestamp)
  ret_kurzbeschr varchar,   -- Kurzbeschreibung des MRPs (varchar)
  ret_ip_klasse varchar,   -- MRP-Klasse (INTERPOLAR) (varchar)
  ret_atc1 varchar,   -- 1. Medikament ATC / Name: (varchar)
  ret_atc2 varchar,   -- 2. Medikament ATC / Name (varchar)
  ret_ip_klasse_disease varchar,   -- Disease (varchar)
  ret_ip_klasse_labor varchar,   -- Labor (varchar)
  ret_gewissheit1 varchar,   -- Sicherheit des detektierten MRP (varchar)
  ret_mrp_zuordnung1 varchar,   -- Zuordnung zu manuellem MRP (varchar)
  ret_gewissheit_oth1 varchar,   -- Weitere Informationen (varchar)
  ret_gewiss_grund_abl1 varchar,   -- Grund für nicht Bestätigung (varchar)
  ret_gewiss_grund_abl_sonst1 varchar,   -- Bitte näher beschreiben (varchar)
  ret_massn_am1___1 varchar,   -- 1 - Anweisung für die Applikation geben (varchar)
  ret_massn_am1___2 varchar,   -- 2 - Arzneimittel ändern (varchar)
  ret_massn_am1___3 varchar,   -- 3 - Arzneimittel stoppen/pausieren (varchar)
  ret_massn_am1___4 varchar,   -- 4 - Arzneimittel neu ansetzen (varchar)
  ret_massn_am1___5 varchar,   -- 5 - Dosierung ändern (varchar)
  ret_massn_am1___6 varchar,   -- 6 - Formulierung ändern (varchar)
  ret_massn_am1___7 varchar,   -- 7 - Hilfe bei Beschaffung (varchar)
  ret_massn_am1___8 varchar,   -- 8 - Information an Arzt/Pflege (varchar)
  ret_massn_am1___9 varchar,   -- 9 - Information an Patient (varchar)
  ret_massn_am1___10 varchar,   -- 10 - TDM oder Laborkontrolle emfohlen (varchar)
  ret_massn_orga1___1 varchar,   -- 1 - Aushändigung einer Information/eines Medikationsplans (varchar)
  ret_massn_orga1___2 varchar,   -- 2 - CIRS-/AMK-Meldung (varchar)
  ret_massn_orga1___3 varchar,   -- 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)
  ret_massn_orga1___4 varchar,   -- 4 - Etablierung einer Doppelkontrolle (varchar)
  ret_massn_orga1___5 varchar,   -- 5 - Lieferantenwechsel (varchar)
  ret_massn_orga1___6 varchar,   -- 6 - Optimierung der internen und externene Kommunikation (varchar)
  ret_massn_orga1___7 varchar,   -- 7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)
  ret_massn_orga1___8 varchar,   -- 8 - Sensibilisierung/Schulung (varchar)
  ret_notiz1 varchar,   -- Notiz (varchar)
  ret_meda_dat2 timestamp,   -- Datum der retrolektiven Betrachtung* (timestamp)
  ret_2ndbewertung___1 varchar,   -- 1 - 2nd Look (varchar)
  ret_2ndbewertung___Zweite MRP-Bewertung durchführen varchar,   -- Zweite MRP-Bewertung durchführen (varchar)
  ret_bewerter2_pipeline varchar,   -- Bewerter2 Pipeline (varchar)
  ret_bewerter2 varchar,   -- 2. Bewertung von (varchar)
  ret_gewissheit2 varchar,   -- Sicherheit des detektierten MRP (varchar)
  ret_mrp_zuordnung2 varchar,   -- Zuordnung zu manuellem MRP (varchar)
  ret_gewissheit2_oth varchar,   -- Weitere Informationen (varchar)
  ret_gewiss_grund2_abl varchar,   -- Grund für nicht Bestätigung (varchar)
  ret_gewiss_grund_abl_sonst2 varchar,   -- Bitte näher beschreiben (varchar)
  ret_massn_am2___1 varchar,   -- 1 - Anweisung für die Applikation geben (varchar)
  ret_massn_am2___2 varchar,   -- 2 - Arzneimittel ändern (varchar)
  ret_massn_am2___3 varchar,   -- 3 - Arzneimittel stoppen/pausieren (varchar)
  ret_massn_am2___4 varchar,   -- 4 - Arzneimittel neu ansetzen (varchar)
  ret_massn_am2___5 varchar,   -- 5 - Dosierung ändern (varchar)
  ret_massn_am2___6 varchar,   -- 6 - Formulierung ändern (varchar)
  ret_massn_am2___7 varchar,   -- 7 - Hilfe bei Beschaffung (varchar)
  ret_massn_am2___8 varchar,   -- 8 - Information an Arzt/Pflege (varchar)
  ret_massn_am2___9 varchar,   -- 9 - Information an Patient (varchar)
  ret_massn_am2___10 varchar,   -- 10 - TDM oder Laborkontrolle emfohlen (varchar)
  ret_massn_orga2___1 varchar,   -- 1 - Aushändigung einer Information/eines Medikationsplans (varchar)
  ret_massn_orga2___2 varchar,   -- 2 - CIRS-/AMK-Meldung (varchar)
  ret_massn_orga2___3 varchar,   -- 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)
  ret_massn_orga2___4 varchar,   -- 4 - Etablierung einer Doppelkontrolle (varchar)
  ret_massn_orga2___5 varchar,   -- 5 - Lieferantenwechsel (varchar)
  ret_massn_orga2___6 varchar,   -- 6 - Optimierung der internen und externene Kommunikation (varchar)
  ret_massn_orga2___7 varchar,   -- 7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)
  ret_massn_orga2___8 varchar,   -- 8 - Sensibilisierung/Schulung (varchar)
  ret_notiz2 varchar,   -- Notiz (varchar)
  retrolektive_mrpbewertung_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
             COALESCE(db.to_char_immutable(ret_bewerter1), '#NULL#') || '|||' || -- hash from: 1. Bewertung von (ret_bewerter1)
             COALESCE(db.to_char_immutable(ret_id), '#NULL#') || '|||' || -- hash from: Retrolektive MRP-ID (ret_id)
             COALESCE(db.to_char_immutable(ret_meda_id), '#NULL#') || '|||' || -- hash from: Zuordnung Meda -> rMRP (ret_meda_id)
             COALESCE(db.to_char_immutable(ret_meda_dat1), '#NULL#') || '|||' || -- hash from: Datum der retrolektiven Betrachtung* (ret_meda_dat1)
             COALESCE(db.to_char_immutable(ret_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs (ret_kurzbeschr)
             COALESCE(db.to_char_immutable(ret_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (ret_ip_klasse)
             COALESCE(db.to_char_immutable(ret_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name: (ret_atc1)
             COALESCE(db.to_char_immutable(ret_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (ret_atc2)
             COALESCE(db.to_char_immutable(ret_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (ret_ip_klasse_disease)
             COALESCE(db.to_char_immutable(ret_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (ret_ip_klasse_labor)
             COALESCE(db.to_char_immutable(ret_gewissheit1), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP (ret_gewissheit1)
             COALESCE(db.to_char_immutable(ret_mrp_zuordnung1), '#NULL#') || '|||' || -- hash from: Zuordnung zu manuellem MRP (ret_mrp_zuordnung1)
             COALESCE(db.to_char_immutable(ret_gewissheit_oth1), '#NULL#') || '|||' || -- hash from: Weitere Informationen (ret_gewissheit_oth1)
             COALESCE(db.to_char_immutable(ret_gewiss_grund_abl1), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung (ret_gewiss_grund_abl1)
             COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst1), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (ret_gewiss_grund_abl_sonst1)
             COALESCE(db.to_char_immutable(ret_massn_am1___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (ret_massn_am1___1)
             COALESCE(db.to_char_immutable(ret_massn_am1___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (ret_massn_am1___2)
             COALESCE(db.to_char_immutable(ret_massn_am1___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (ret_massn_am1___3)
             COALESCE(db.to_char_immutable(ret_massn_am1___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (ret_massn_am1___4)
             COALESCE(db.to_char_immutable(ret_massn_am1___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (ret_massn_am1___5)
             COALESCE(db.to_char_immutable(ret_massn_am1___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (ret_massn_am1___6)
             COALESCE(db.to_char_immutable(ret_massn_am1___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (ret_massn_am1___7)
             COALESCE(db.to_char_immutable(ret_massn_am1___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (ret_massn_am1___8)
             COALESCE(db.to_char_immutable(ret_massn_am1___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (ret_massn_am1___9)
             COALESCE(db.to_char_immutable(ret_massn_am1___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (ret_massn_am1___10)
             COALESCE(db.to_char_immutable(ret_massn_orga1___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (ret_massn_orga1___1)
             COALESCE(db.to_char_immutable(ret_massn_orga1___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (ret_massn_orga1___2)
             COALESCE(db.to_char_immutable(ret_massn_orga1___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (ret_massn_orga1___3)
             COALESCE(db.to_char_immutable(ret_massn_orga1___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (ret_massn_orga1___4)
             COALESCE(db.to_char_immutable(ret_massn_orga1___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (ret_massn_orga1___5)
             COALESCE(db.to_char_immutable(ret_massn_orga1___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (ret_massn_orga1___6)
             COALESCE(db.to_char_immutable(ret_massn_orga1___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (ret_massn_orga1___7)
             COALESCE(db.to_char_immutable(ret_massn_orga1___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (ret_massn_orga1___8)
             COALESCE(db.to_char_immutable(ret_notiz1), '#NULL#') || '|||' || -- hash from: Notiz (ret_notiz1)
             COALESCE(db.to_char_immutable(ret_meda_dat2), '#NULL#') || '|||' || -- hash from: Datum der retrolektiven Betrachtung* (ret_meda_dat2)
             COALESCE(db.to_char_immutable(ret_2ndbewertung___1), '#NULL#') || '|||' || -- hash from: 1 - 2nd Look (ret_2ndbewertung___1)
             COALESCE(db.to_char_immutable(ret_2ndbewertung___Zweite MRP-Bewertung durchführen), '#NULL#') || '|||' || -- hash from: Zweite MRP-Bewertung durchführen (ret_2ndbewertung___Zweite MRP-Bewertung durchführen)
             COALESCE(db.to_char_immutable(ret_bewerter2_pipeline), '#NULL#') || '|||' || -- hash from: Bewerter2 Pipeline (ret_bewerter2_pipeline)
             COALESCE(db.to_char_immutable(ret_bewerter2), '#NULL#') || '|||' || -- hash from: 2. Bewertung von (ret_bewerter2)
             COALESCE(db.to_char_immutable(ret_gewissheit2), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP (ret_gewissheit2)
             COALESCE(db.to_char_immutable(ret_mrp_zuordnung2), '#NULL#') || '|||' || -- hash from: Zuordnung zu manuellem MRP (ret_mrp_zuordnung2)
             COALESCE(db.to_char_immutable(ret_gewissheit2_oth), '#NULL#') || '|||' || -- hash from: Weitere Informationen (ret_gewissheit2_oth)
             COALESCE(db.to_char_immutable(ret_gewiss_grund2_abl), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung (ret_gewiss_grund2_abl)
             COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst2), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (ret_gewiss_grund_abl_sonst2)
             COALESCE(db.to_char_immutable(ret_massn_am2___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (ret_massn_am2___1)
             COALESCE(db.to_char_immutable(ret_massn_am2___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (ret_massn_am2___2)
             COALESCE(db.to_char_immutable(ret_massn_am2___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (ret_massn_am2___3)
             COALESCE(db.to_char_immutable(ret_massn_am2___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (ret_massn_am2___4)
             COALESCE(db.to_char_immutable(ret_massn_am2___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (ret_massn_am2___5)
             COALESCE(db.to_char_immutable(ret_massn_am2___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (ret_massn_am2___6)
             COALESCE(db.to_char_immutable(ret_massn_am2___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (ret_massn_am2___7)
             COALESCE(db.to_char_immutable(ret_massn_am2___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (ret_massn_am2___8)
             COALESCE(db.to_char_immutable(ret_massn_am2___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (ret_massn_am2___9)
             COALESCE(db.to_char_immutable(ret_massn_am2___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (ret_massn_am2___10)
             COALESCE(db.to_char_immutable(ret_massn_orga2___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (ret_massn_orga2___1)
             COALESCE(db.to_char_immutable(ret_massn_orga2___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (ret_massn_orga2___2)
             COALESCE(db.to_char_immutable(ret_massn_orga2___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (ret_massn_orga2___3)
             COALESCE(db.to_char_immutable(ret_massn_orga2___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (ret_massn_orga2___4)
             COALESCE(db.to_char_immutable(ret_massn_orga2___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (ret_massn_orga2___5)
             COALESCE(db.to_char_immutable(ret_massn_orga2___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (ret_massn_orga2___6)
             COALESCE(db.to_char_immutable(ret_massn_orga2___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (ret_massn_orga2___7)
             COALESCE(db.to_char_immutable(ret_massn_orga2___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (ret_massn_orga2___8)
             COALESCE(db.to_char_immutable(ret_notiz2), '#NULL#') || '|||' || -- hash from: Notiz (ret_notiz2)
             COALESCE(db.to_char_immutable(retrolektive_mrpbewertung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (retrolektive_mrpbewertung_complete)
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
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.risikofaktor_fe (
  risikofaktor_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
  redcap_repeat_instrument varchar,   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
  redcap_repeat_instance varchar,   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
  redcap_data_access_group varchar,   -- Function as dataset filter by stations (varchar)
  rskfk_gerhemmer int,   -- Ger.hemmer (int)
  rskfk_tah int,   -- TAH (int)
  rskfk_immunsupp int,   -- Immunsupp. (int)
  rskfk_tumorth int,   -- Tumorth. (int)
  rskfk_opiat int,   -- Opiat (int)
  rskfk_atcn int,   -- ATC N (int)
  rskfk_ait int,   -- AIT (int)
  rskfk_anzam int,   -- Anz AM (int)
  rskfk_priscus int,   -- PRISCUS (int)
  rskfk_qtc int,   -- QTc (int)
  rskfk_meld int,   -- MELD (int)
  rskfk_dialyse int,   -- Dialyse (int)
  rskfk_entern int,   -- ent. Ern. (int)
  rskfkt_anz_rskamklassen double precision,   -- Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (double precision)
  risikofaktor_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
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
             COALESCE(db.to_char_immutable(risikofaktor_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (risikofaktor_complete)
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
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.trigger_fe (
  trigger_fe_id int, -- Primary key of the entity - already filled in this schema - History via timestamp
  record_id varchar,   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
  redcap_repeat_instrument varchar,   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
  redcap_repeat_instance varchar,   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
  redcap_data_access_group varchar,   -- Function as dataset filter by stations (varchar)
  trg_ast int,   -- AST↑ (int)
  trg_alt int,   -- ALT↑ (int)
  trg_crp int,   -- CRP↑ (int)
  trg_leuk_penie int,   -- Leuko↓ (int)
  trg_leuk_ose int,   -- Leuko↑ (int)
  trg_thrmb_penie int,   -- Thrombo↓ (int)
  trg_aptt int,   -- aPTT (int)
  trg_hyp_haem int,   -- Hb↓ (int)
  trg_hypo_glyk int,   -- Glc↓ (int)
  trg_hyper_glyk int,   -- Glc↑ (int)
  trg_hyper_bilirbnm int,   -- Bili↑ (int)
  trg_ck int,   -- CK↑ (int)
  trg_hypo_serablmn int,   -- Alb↓ (int)
  trg_hypo_nat int,   -- Na+↓ (int)
  trg_hyper_nat int,   -- Na+↑ (int)
  trg_hyper_kal int,   -- K+↑ (int)
  trg_hypo_kal int,   -- K+↓ (int)
  trg_inr_ern int,   -- INR Antikoag↓ (int)
  trg_inr_erh int,   -- INR ↑ (int)
  trg_inr_erh_antikoa int,   -- INR Antikoag↑ (int)
  trg_krea int,   -- Krea↑ (int)
  trg_egfr int,   -- eGFR<30 (int)
  trigger_complete varchar,   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
  hash_index_col TEXT GENERATED ALWAYS AS (
      md5(
             COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
             COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
             COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
             COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
             COALESCE(db.to_char_immutable(trg_ast), '#NULL#') || '|||' || -- hash from: AST↑ (trg_ast)
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
             COALESCE(db.to_char_immutable(trg_hyper_kal), '#NULL#') || '|||' || -- hash from: K+↑ (trg_hyper_kal)
             COALESCE(db.to_char_immutable(trg_hypo_kal), '#NULL#') || '|||' || -- hash from: K+↓ (trg_hypo_kal)
             COALESCE(db.to_char_immutable(trg_inr_ern), '#NULL#') || '|||' || -- hash from: INR Antikoag↓ (trg_inr_ern)
             COALESCE(db.to_char_immutable(trg_inr_erh), '#NULL#') || '|||' || -- hash from: INR ↑ (trg_inr_erh)
             COALESCE(db.to_char_immutable(trg_inr_erh_antikoa), '#NULL#') || '|||' || -- hash from: INR Antikoag↑ (trg_inr_erh_antikoa)
             COALESCE(db.to_char_immutable(trg_krea), '#NULL#') || '|||' || -- hash from: Krea↑ (trg_krea)
             COALESCE(db.to_char_immutable(trg_egfr), '#NULL#') || '|||' || -- hash from: eGFR<30 (trg_egfr)
             COALESCE(db.to_char_immutable(trigger_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (trigger_complete)
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

-- Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.retrolektive_mrpbewertung_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.retrolektive_mrpbewertung_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.retrolektive_mrpbewertung_fe TO db_user; -- Additional authorizations for testing

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
COMMENT ON COLUMN db_log.patient_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_id IS 'Patient-identifier (FHIR) (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_cis_pid IS 'Patient-identifier (KIS) (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_name IS 'Patientenname (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_vorname IS 'Patientenvorname (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_gebdat IS 'Geburtsdatum (date)';
COMMENT ON COLUMN db_log.patient_fe.pat_aktuell_alter IS 'aktuelles Patientenalter (Jahre) (double precision)';
COMMENT ON COLUMN db_log.patient_fe.pat_geschlecht IS 'Geschlecht (varchar)';
COMMENT ON COLUMN db_log.patient_fe.patient_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.patient_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.patient_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.patient_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.patient_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.patient_fe.last_processing_nr IS 'Last processing number of the data record';
COMMENT ON COLUMN db_log.fall_fe.fall_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.fall_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.fall_fe.patient_id_fk IS 'verstecktes Feld für patient_id_fk (int)';
COMMENT ON COLUMN db_log.fall_fe.fall_pat_id IS 'verstecktes Feld für fall_pat_id (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_id IS 'Fall-ID (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_studienphase IS 'Studienphase (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_station IS 'Station (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_aufn_dat IS 'Aufnahmedatum (timestamp)';
COMMENT ON COLUMN db_log.fall_fe.fall_zimmernr IS 'Zimmer-Nr. (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_aufn_diag IS 'Diagnose(n) bei Aufnahme (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_gewicht_aktuell IS 'aktuelles Gewicht (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_gewicht_aktl_einheit IS 'aktuelles Gewicht: Einheit (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_groesse IS 'Größe (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_groesse_einheit IS 'Größe: Einheit (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_bmi IS 'BMI (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_status IS 'Fallstatus (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_ent_dat IS 'Entlassdatum (timestamp)';
COMMENT ON COLUMN db_log.fall_fe.fall_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.fall_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.fall_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.fall_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.fall_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.fall_fe.last_processing_nr IS 'Last processing number of the data record';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.medikationsanalyse_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_anlage IS 'Formular angelegt von (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_edit IS 'Formular zuletzt bearbeitet von (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.fall_meda_id IS 'Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse -> Fall (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_id IS 'ID Medikationsanalyse (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_typ IS 'Typ der Medikationsanalyse (MA) (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_dat IS 'Datum der Medikationsanalyse (timestamp)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_gewicht_aktuell IS 'aktuelles Gewicht (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_gewicht_aktl_einheit IS 'aktuelles Gewicht: Einheit (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_groesse IS 'Größe (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_groesse_einheit IS 'Größe: Einheit (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_bmi IS 'BMI (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_nieren_insuf_chron IS 'Chronische Niereninsuffizienz (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_nieren_insuf_ausmass IS 'aktuelles Ausmaß (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_nieren_insuf_dialysev IS 'Nierenersatzverfahren (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_leber_insuf IS 'Leberinsuffizienz (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_leber_insuf_ausmass IS 'aktuelles Ausmaß (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_schwanger_mo IS 'Schwangerschaftsmonat (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_ma_thueberw IS 'Wiedervorlage Medikationsanalyse in 24-48h (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_mrp_detekt IS 'MRP detektiert? (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_aufwand_zeit IS 'Zeitaufwand Medikationsanalyse (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_aufwand_zeit_and IS 'genaue Dauer in Minuten (int)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_notiz IS 'Notizfeld (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.medikationsanalyse_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.last_processing_nr IS 'Last processing number of the data record';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_anlage IS 'Formular angelegt von (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_edit IS 'Formular zuletzt bearbeitet von (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_meda_id IS 'Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse -> MRP (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_id IS 'MRP-ID (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_entd_dat IS 'Datum des MRP (timestamp)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_entd_algorithmisch IS 'MRP vom INTERPOLAR-Algorithmus entdeckt? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_kurzbeschr IS 'Kurzbeschreibung des MRPs (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber IS 'Hinweisgeber auf das MRP (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber_oth IS 'Anderer Hinweisgeber (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_wirkstoff IS 'Wirkstoff betroffen? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc1 IS '1. Medikament ATC / Name: (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc2 IS '2. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc3 IS '3. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc4 IS '4. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc5 IS '5. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_med_prod IS 'Medizinprodukt betroffen? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_med_prod_sonst IS 'Bezeichnung Präparat (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_fehler IS 'Frage / Fehlerbeschreibung    (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_intervention IS 'Intervention / Vorschlag zur Fehlervermeldung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___1 IS '1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___2 IS '2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___3 IS '3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___4 IS '4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___5 IS '5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___6 IS '6 - AM: Übertragungsfehler (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___7 IS '7 - AM: Substitution aut idem/aut simile (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___8 IS '8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (varchar)';
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
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___26 IS '26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___27 IS '27 - S: Schulung/Beratung eines Patienten (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_disease IS 'Disease (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_labor IS 'Labor (varchar)';
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
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_notiz IS 'Notiz (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_hand_emp_akz IS 'Handlungsempfehlung akzeptiert? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp IS 'NCC MERP Score (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp_info___1 IS '1 - NCC MERP Index (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.last_processing_nr IS 'Last processing number of the data record';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.retrolektive_mrpbewertung_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_bewerter1 IS '1. Bewertung von (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_id IS 'Retrolektive MRP-ID (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_meda_id IS 'Zuordnung Meda -> rMRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_meda_dat1 IS 'Datum der retrolektiven Betrachtung* (timestamp)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_kurzbeschr IS 'Kurzbeschreibung des MRPs (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_atc1 IS '1. Medikament ATC / Name: (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_atc2 IS '2. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse_disease IS 'Disease (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse_labor IS 'Labor (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit1 IS 'Sicherheit des detektierten MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_mrp_zuordnung1 IS 'Zuordnung zu manuellem MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit_oth1 IS 'Weitere Informationen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl1 IS 'Grund für nicht Bestätigung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_sonst1 IS 'Bitte näher beschreiben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___1 IS '1 - Anweisung für die Applikation geben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___2 IS '2 - Arzneimittel ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___5 IS '5 - Dosierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___6 IS '6 - Formulierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___7 IS '7 - Hilfe bei Beschaffung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___8 IS '8 - Information an Arzt/Pflege (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___9 IS '9 - Information an Patient (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_notiz1 IS 'Notiz (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_meda_dat2 IS 'Datum der retrolektiven Betrachtung* (timestamp)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_2ndbewertung___1 IS '1 - 2nd Look (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_2ndbewertung___Zweite MRP-Bewertung durchführen IS 'Zweite MRP-Bewertung durchführen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_bewerter2_pipeline IS 'Bewerter2 Pipeline (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_bewerter2 IS '2. Bewertung von (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit2 IS 'Sicherheit des detektierten MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_mrp_zuordnung2 IS 'Zuordnung zu manuellem MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit2_oth IS 'Weitere Informationen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund2_abl IS 'Grund für nicht Bestätigung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_sonst2 IS 'Bitte näher beschreiben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___1 IS '1 - Anweisung für die Applikation geben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___2 IS '2 - Arzneimittel ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___5 IS '5 - Dosierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___6 IS '6 - Formulierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___7 IS '7 - Hilfe bei Beschaffung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___8 IS '8 - Information an Arzt/Pflege (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___9 IS '9 - Information an Patient (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_notiz2 IS 'Notiz (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.retrolektive_mrpbewertung_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.last_processing_nr IS 'Last processing number of the data record';
COMMENT ON COLUMN db_log.risikofaktor_fe.risikofaktor_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.risikofaktor_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_gerhemmer IS 'Ger.hemmer (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_tah IS 'TAH (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_immunsupp IS 'Immunsupp. (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_tumorth IS 'Tumorth. (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_opiat IS 'Opiat (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_atcn IS 'ATC N (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_ait IS 'AIT (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_anzam IS 'Anz AM (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_priscus IS 'PRISCUS (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_qtc IS 'QTc (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_meld IS 'MELD (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_dialyse IS 'Dialyse (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_entern IS 'ent. Ern. (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfkt_anz_rskamklassen IS 'Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (double precision)';
COMMENT ON COLUMN db_log.risikofaktor_fe.risikofaktor_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.risikofaktor_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.risikofaktor_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.risikofaktor_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.risikofaktor_fe.last_processing_nr IS 'Last processing number of the data record';
COMMENT ON COLUMN db_log.trigger_fe.trigger_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.trigger_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_ast IS 'AST↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_alt IS 'ALT↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_crp IS 'CRP↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_leuk_penie IS 'Leuko↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_leuk_ose IS 'Leuko↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_thrmb_penie IS 'Thrombo↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_aptt IS 'aPTT (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyp_haem IS 'Hb↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_glyk IS 'Glc↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_glyk IS 'Glc↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_bilirbnm IS 'Bili↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_ck IS 'CK↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_serablmn IS 'Alb↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_nat IS 'Na+↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_nat IS 'Na+↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_kal IS 'K+↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_kal IS 'K+↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_ern IS 'INR Antikoag↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_erh IS 'INR ↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_erh_antikoa IS 'INR Antikoag↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_krea IS 'Krea↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_egfr IS 'eGFR<30 (int)';
COMMENT ON COLUMN db_log.trigger_fe.trigger_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
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
  CREATE INDEX IF NOT EXISTS idx_patient_fe_id ON db_log.patient_fe ( patient_fe_id DESC); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_patient_fe_input_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_input_dt
ON db_log.patient_fe (
   input_datetime DESC -- Time at which the data record is inserted
);

-- Index idx_db_log_patient_fe_input_pnr for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_input_pnr
ON db_log.patient_fe (
   input_processing_nr DESC -- (First) Processing number of the data record
);

-- Index idx_db_log_patient_fe_last_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_last_dt
ON db_log.patient_fe (
   last_check_datetime DESC -- Time at which data record was last checked
);

-- Index idx_db_log_patient_fe_last_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_last_pnr
ON db_log.patient_fe (
   last_processing_nr DESC -- Last processing number of the data record
);

-- Index idx_db_log_patient_fe_hash for Table "patient_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_patient_fe_hash
ON db_log.patient_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - fall_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_fall_fe_id ON db_log.fall_fe ( fall_fe_id DESC); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_fall_fe_input_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_input_dt
ON db_log.fall_fe (
   input_datetime DESC -- Time at which the data record is inserted
);

-- Index idx_db_log_fall_fe_input_pnr for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_input_pnr
ON db_log.fall_fe (
   input_processing_nr DESC -- (First) Processing number of the data record
);

-- Index idx_db_log_fall_fe_last_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_last_dt
ON db_log.fall_fe (
   last_check_datetime DESC -- Time at which data record was last checked
);

-- Index idx_db_log_fall_fe_last_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_last_pnr
ON db_log.fall_fe (
   last_processing_nr DESC -- Last processing number of the data record
);

-- Index idx_db_log_fall_fe_hash for Table "fall_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_fall_fe_hash
ON db_log.fall_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - medikationsanalyse_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_medikationsanalyse_fe_id ON db_log.medikationsanalyse_fe ( medikationsanalyse_fe_id DESC); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_medikationsanalyse_fe_input_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_input_dt
ON db_log.medikationsanalyse_fe (
   input_datetime DESC -- Time at which the data record is inserted
);

-- Index idx_db_log_medikationsanalyse_fe_input_pnr for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_input_pnr
ON db_log.medikationsanalyse_fe (
   input_processing_nr DESC -- (First) Processing number of the data record
);

-- Index idx_db_log_medikationsanalyse_fe_last_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_last_dt
ON db_log.medikationsanalyse_fe (
   last_check_datetime DESC -- Time at which data record was last checked
);

-- Index idx_db_log_medikationsanalyse_fe_last_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_last_pnr
ON db_log.medikationsanalyse_fe (
   last_processing_nr DESC -- Last processing number of the data record
);

-- Index idx_db_log_medikationsanalyse_fe_hash for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_medikationsanalyse_fe_hash
ON db_log.medikationsanalyse_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - mrpdokumentation_validierung_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_mrpdokumentation_validierung_fe_id ON db_log.mrpdokumentation_validierung_fe ( mrpdokumentation_validierung_fe_id DESC); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_mrpdokumentation_validierung_fe_input_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_input_dt
ON db_log.mrpdokumentation_validierung_fe (
   input_datetime DESC -- Time at which the data record is inserted
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_input_pnr for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_input_pnr
ON db_log.mrpdokumentation_validierung_fe (
   input_processing_nr DESC -- (First) Processing number of the data record
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_last_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_last_dt
ON db_log.mrpdokumentation_validierung_fe (
   last_check_datetime DESC -- Time at which data record was last checked
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_last_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_last_pnr
ON db_log.mrpdokumentation_validierung_fe (
   last_processing_nr DESC -- Last processing number of the data record
);

-- Index idx_db_log_mrpdokumentation_validierung_fe_hash for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_mrpdokumentation_validierung_fe_hash
ON db_log.mrpdokumentation_validierung_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - retrolektive_mrpbewertung_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_retrolektive_mrpbewertung_fe_id ON db_log.retrolektive_mrpbewertung_fe ( retrolektive_mrpbewertung_fe_id DESC); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_retrolektive_mrpbewertung_fe_input_dt for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_retrolektive_mrpbewertung_fe_input_dt
ON db_log.retrolektive_mrpbewertung_fe (
   input_datetime DESC -- Time at which the data record is inserted
);

-- Index idx_db_log_retrolektive_mrpbewertung_fe_input_pnr for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_retrolektive_mrpbewertung_fe_input_pnr
ON db_log.retrolektive_mrpbewertung_fe (
   input_processing_nr DESC -- (First) Processing number of the data record
);

-- Index idx_db_log_retrolektive_mrpbewertung_fe_last_dt for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_retrolektive_mrpbewertung_fe_last_dt
ON db_log.retrolektive_mrpbewertung_fe (
   last_check_datetime DESC -- Time at which data record was last checked
);

-- Index idx_db_log_retrolektive_mrpbewertung_fe_last_dt for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_retrolektive_mrpbewertung_fe_last_pnr
ON db_log.retrolektive_mrpbewertung_fe (
   last_processing_nr DESC -- Last processing number of the data record
);

-- Index idx_db_log_retrolektive_mrpbewertung_fe_hash for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_retrolektive_mrpbewertung_fe_hash
ON db_log.retrolektive_mrpbewertung_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - risikofaktor_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_risikofaktor_fe_id ON db_log.risikofaktor_fe ( risikofaktor_fe_id DESC); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_risikofaktor_fe_input_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_input_dt
ON db_log.risikofaktor_fe (
   input_datetime DESC -- Time at which the data record is inserted
);

-- Index idx_db_log_risikofaktor_fe_input_pnr for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_input_pnr
ON db_log.risikofaktor_fe (
   input_processing_nr DESC -- (First) Processing number of the data record
);

-- Index idx_db_log_risikofaktor_fe_last_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_last_dt
ON db_log.risikofaktor_fe (
   last_check_datetime DESC -- Time at which data record was last checked
);

-- Index idx_db_log_risikofaktor_fe_last_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_last_pnr
ON db_log.risikofaktor_fe (
   last_processing_nr DESC -- Last processing number of the data record
);

-- Index idx_db_log_risikofaktor_fe_hash for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_risikofaktor_fe_hash
ON db_log.risikofaktor_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);

------------------------- Index for db_log - trigger_fe ---------------------------------
  CREATE INDEX IF NOT EXISTS idx_trigger_fe_id ON db_log.trigger_fe ( trigger_fe_id DESC); -- Primary key of the entity - already filled in this schema - History via timestamp

-- Index idx_db_log_trigger_fe_input_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_input_dt
ON db_log.trigger_fe (
   input_datetime DESC -- Time at which the data record is inserted
);

-- Index idx_db_log_trigger_fe_input_pnr for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_input_pnr
ON db_log.trigger_fe (
   input_processing_nr DESC -- (First) Processing number of the data record
);

-- Index idx_db_log_trigger_fe_last_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_last_dt
ON db_log.trigger_fe (
   last_check_datetime DESC -- Time at which data record was last checked
);

-- Index idx_db_log_trigger_fe_last_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_last_pnr
ON db_log.trigger_fe (
   last_processing_nr DESC -- Last processing number of the data record
);

-- Index idx_db_log_trigger_fe_hash for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_db_log_trigger_fe_hash
ON db_log.trigger_fe (
   hash_index_col -- Column for automatic hash value for comparing FHIR data
);


