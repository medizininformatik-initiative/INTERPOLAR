--Create SQL Table in Schema db2dataprocessor_in
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.patient_fe (
patient_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
record_id varchar, -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet
pat_id varchar, -- Patient-identifier FHIR Daten
redcap_repeat_instrument varchar, -- RedCap interne Datensatzzuordnung
redcap_repeat_instance varchar, -- RedCap interne Datensatzzuordnung
pat_name varchar, -- Patientenname
pat_vorname varchar, -- Patientenvorname
pat_gebdat date, -- Geburtsdatum
pat_aktuell_alter double precision, -- <div class=rich-text-field-label><p>aktuelles Patientenalter (Jahre)</p></div>
pat_geschlecht varchar, -- Geschlecht (wie in FHIR)
patient_complete varchar, -- Frontend Complete-Status
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db2dataprocessor_in.fall_fe (
fall_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
record_id varchar, -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet
fall_id varchar, -- Fall-ID RedCap FHIR Daten
fall_pat_id varchar, -- Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id)
patient_id_fk int, -- Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id)
fall_typ_id int, -- Datenbank-FK des getypten Falls zur Datenflussverfolgung (Fall: v_fall_all . fall_id)
redcap_repeat_instrument varchar, -- RedCap interne Datensatzzuordnung
redcap_repeat_instance varchar, -- RedCap interne Datensatzzuordnung
fall_studienphase varchar, -- Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) )
fall_station varchar, -- Station wie vom DIZ Definiert
fall_aufn_dat date, -- Aufnahmedatum
fall_aufn_diag varchar, -- <div class=rich-text-field-label><p><span style=color: #e03e2d;>Diagnose(n) bei Aufnahme (wird nur zum lesen sein)</span></p></div>
fall_gewicht_aktuell double precision, -- aktuelles Gewicht (Kg)
fall_gewicht_aktl_einheit varchar, -- 
fall_groesse double precision, -- Größe (cm)
fall_groesse_einheit varchar, -- 
fall_bmi double precision, -- BMI
fall_nieren_insuf_chron varchar, -- 1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz
fall_nieren_insuf_ausmass varchar, -- 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2<div class=rich-text-field-label><p>aktuelles Ausmaß</p></div>
fall_nieren_insuf_dialysev varchar, -- 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren
fall_leber_insuf varchar, -- 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz
fall_leber_insuf_ausmass varchar, -- 1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß
fall_schwanger_mo varchar, -- 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9<div class=rich-text-field-label><p><span style=color: #000000;>Schwangerschaftsmonat</span></p></div>
fall_op_geplant varchar, -- 1, ja | 0, nein | -1, nicht bekanntIst eine Operation geplant?
fall_op_dat date, -- Operationsdatum
fall_status varchar, -- 
fall_ent_dat date, -- Entlassdatum
fall_complete varchar, -- Frontend Complete-Status
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db2dataprocessor_in.medikationsanalyse_fe (
medikationsanalyse_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
record_id varchar, -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet
fall_typ_id int, -- Datenbank-FK des Falls (Fall: v_fall_all . fall_id) -> Dataprocessor setzt id: meda_dat in [fall_aufn_dat;fall_ent_dat]
meda_fall_id varchar, -- Fall-ID zu dem Medikationsanalyse gehört FHIR (Fall:fall_id)
redcap_repeat_instrument varchar, -- RedCap interne Datensatzzuordnung
redcap_repeat_instance varchar, -- RedCap interne Datensatzzuordnung
meda_dat date, -- Datum der Medikationsanalyse
meda_typ varchar, -- Typ der Medikationsanalyse
meda_risiko_pat varchar, -- 1, Risikopatient | 2, Medikationsanalyse / Therapieüberwachung in 24-48hMarkieren als Risikopatient
meda_ma_thueberw varchar, -- Medikationsanalyse / Therapieüberwachung in 24-48h
meda_aufwand_zeit varchar, -- 0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min]
meda_aufwand_zeit_and int, -- wie lange hat die Medikationsanalyse gedauert? Eingabe in Minuten. 
meda_notiz varchar, -- Notizfeld
medikationsanalyse_complete varchar, -- Frontend Complete-Status
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db2dataprocessor_in.mrpdokumentation_validierung_fe (
mrpdokumentation_validierung_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
record_id int, -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet
meda_typ_id int, -- Datenbank-FK der Medikationsanalyse (Medikationsanalyse: medikationsanalyse_fe_id) -> Dataprocessor setzt id: mrp_entd_dat(Tag)=meda_dat(Tag)
redcap_repeat_instrument varchar, -- RedCap interne Datensatzzuordnung
redcap_repeat_instance varchar, -- RedCap interne Datensatzzuordnung
mrp_entd_dat date, -- Datum des MRP
mrp_kurzbeschr varchar, -- Kurzbeschreibung des MRPs
mrp_entd_algorithmisch varchar, -- MRP vom INTERPOLAR-Algorithmus entdeckt?
mrp_hinweisgeber varchar, -- Hinweisgeber auf das MRP
mrp_gewissheit varchar, -- Sicherheit des detektierten MRP
mrp_gewiss_grund_abl varchar, -- Grund für nicht Bestätigung
mrp_gewiss_grund_abl_sonst varchar, -- Bitte näher beschreiben
mrp_wirkstoff varchar, -- Wirkstoff betroffen?
mrp_atc1 varchar, -- 1. Medikament ATC / Name:
mrp_atc2 varchar, -- 2. Medikament ATC / Name
mrp_atc3 varchar, -- 3. Medikament ATC / Name
mrp_med_prod varchar, -- Medizinprodukt betroffen?
mrp_med_prod_sonst varchar, -- Sonstigespräparat
mrp_dokup_fehler varchar, -- <div class=rich-text-field-label><p>Frage / <span style=font-weight: normal;>Fehlerbeschreibung </span></p> <p><span style=font-weight: normal;>[mrp_kurzbeschr]</span></p></div>
mrp_dokup_intervention varchar, -- <div class=rich-text-field-label><p>Intervention / <span style=font-weight: normal;>Vorschlag zur Fehlervermeldung</span></p></div>
mrp_pigrund varchar, -- PI-Grund
mrp_pigrund___1 varchar, -- 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF)
mrp_pigrund___2 varchar, -- 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF)
mrp_pigrund___3 varchar, -- 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF)
mrp_pigrund___4 varchar, -- 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF)
mrp_pigrund___5 varchar, -- 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF)
mrp_pigrund___6 varchar, -- 6 - AM: Übertragungsfehler (MF)
mrp_pigrund___7 varchar, -- 7 - AM: Substitution aut idem/aut simile (MF)
mrp_pigrund___8 varchar, -- 8 - AM: (Klare) Indikation, aber kein Medikament angeordnet (MF)
mrp_pigrund___9 varchar, -- 9 - AM: Stellfehler (MF)
mrp_pigrund___10 varchar, -- 10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF)
mrp_pigrund___11 varchar, -- 11 - AM: Doppelverordnung (MF)
mrp_pigrund___12 varchar, -- 12 - ANW: Applikation (Dauer) (MF)
mrp_pigrund___13 varchar, -- 13 - ANW: Inkompatibilität oder falsche Zubereitung (MF)
mrp_pigrund___14 varchar, -- 14 - ANW: Applikation (Art) (MF)
mrp_pigrund___15 varchar, -- 15 - ANW: Anfrage zur Administration/Kompatibilität
mrp_pigrund___16 varchar, -- 16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF)
mrp_pigrund___17 varchar, -- 17 - D: (Fehlerhafte) Dosis (MF)
mrp_pigrund___18 varchar, -- 18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF)
mrp_pigrund___19 varchar, -- 19 - D: (Fehlerhaftes) Dosisinterval (MF)
mrp_pigrund___20 varchar, -- 20 - Interaktion (MF)
mrp_pigrund___21 varchar, -- 21 - Kontraindikation (MF)
mrp_pigrund___22 varchar, -- 22 - Nebenwirkungen
mrp_pigrund___23 varchar, -- 23 - S: Beratung/Auswahl eines Arzneistoffs
mrp_pigrund___24 varchar, -- 24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs
mrp_pigrund___25 varchar, -- 25 - S: Beschaffung/Kosten
mrp_pigrund___26 varchar, -- 26 - S: Keine Pause von AM, die prä-OP pausiert werden müssen (MF)
mrp_pigrund___27 varchar, -- 27 - S: Schulung/Beratung eines Patienten
mrp_ip_klasse varchar, -- MRP-Klasse (INTERPOLAR)
mrp_ip_klasse___1 varchar, -- 1 - Drug - Drug
mrp_ip_klasse___2 varchar, -- 2 - Drug - Drug-Group
mrp_ip_klasse___3 varchar, -- 3 - Drug - Disease
mrp_ip_klasse___4 varchar, -- 4 - Drug - Labor
mrp_ip_klasse___5 varchar, -- 5 - Drug - Age (Priscus 2.0 o. Dosis)
mrp_ip_klasse_disease varchar, -- Disease
mrp_ip_klasse_labor varchar, -- Labor
mrp_massn_am varchar, -- AM: Arzneimitte
mrp_massn_am___1 varchar, -- 1 - Anweisung für die Applikation geben
mrp_massn_am___2 varchar, -- 2 - Arzneimittel ändern
mrp_massn_am___3 varchar, -- 3 - Arzneimittel stoppen/pausieren
mrp_massn_am___4 varchar, -- 4 - Arzneimittel neu ansetzen
mrp_massn_am___5 varchar, -- 5 - Dosierung ändern
mrp_massn_am___6 varchar, -- 6 - Formulierung ändern
mrp_massn_am___7 varchar, -- 7 - Hilfe bei Beschaffung
mrp_massn_am___8 varchar, -- 8 - Information an Arzt/Pflege
mrp_massn_am___9 varchar, -- 9 - Information an Patient
mrp_massn_am___10 varchar, -- 10 - TDM oder Laborkontrolle emfohlen
mrp_massn_orga varchar, -- ORGA: Organisatorisch
mrp_massn_orga___1 varchar, -- 1 - Aushändigung einer Information/eines Medikationsplans
mrp_massn_orga___2 varchar, -- 2 - CIRS-/AMK-Meldung
mrp_massn_orga___3 varchar, -- 3 - Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers
mrp_massn_orga___4 varchar, -- 4 - Etablierung einer Doppelkontrolle
mrp_massn_orga___5 varchar, -- 5 - Lieferantenwechsel
mrp_massn_orga___6 varchar, -- 6 - Optimierung der internen und externene Kommunikation
mrp_massn_orga___7 varchar, -- 7 - Prozessoptimierung/Etablierung einer SOP/VA
mrp_massn_orga___8 varchar, -- 8 - Sensibilisierung/Schulung
mrp_notiz varchar, -- Notiz
mrp_dokup_hand_emp_akz varchar, -- Handlungsempfehlung akzeptiert?
mrp_merp varchar, -- NCC MERP Score
mrp_wiedervorlage varchar, -- MRP Wiedervorlage
mrpdokumentation_validierung_complete varchar, -- Frontend Complete-Status
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db2dataprocessor_in.risikofaktor_fe (
risikofaktor_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
record_id varchar, -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet
patient_id_fk int, -- Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id)
rskfk_gerhemmer varchar, -- Ger.hemmer
rskfk_tah varchar, -- TAH
rskfk_immunsupp varchar, -- Immunsupp.
rskfk_tumorth varchar, -- Tumorth.
rskfk_opiat varchar, -- Opiat
rskfk_atcn varchar, -- ATC N
rskfk_ait varchar, -- AIT
rskfk_anzam varchar, -- Anz AM
rskfk_priscus varchar, -- PRISCUS
rskfk_qtc varchar, -- QTc
rskfk_meld varchar, -- MELD
rskfk_dialyse varchar, -- Dialyse
rskfk_entern varchar, -- ent. Ern.
rskfkt_anz_rskamklassen varchar, -- Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0
risikofaktor_complete varchar, -- Frontend Complete-Status
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db2dataprocessor_in.trigger_fe (
trigger_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
patient_id_fk int, -- Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id)
record_id varchar, -- Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet
trg_ast varchar, -- <div class=rich-text-field-label><p>AST<span style=font-weight: normal; font-size: 12pt;>↑</span></p></div>
trg_alt varchar, -- ALT↑
trg_crp varchar, -- CRP↑
trg_leuk_penie varchar, -- Leuko↓
trg_leuk_ose varchar, -- Leuko↑
trg_thrmb_penie varchar, -- Thrombo↓
trg_aptt varchar, -- aPTT
trg_hyp_haem varchar, -- Hb↓
trg_hypo_glyk varchar, -- Glc↓
trg_hyper_glyk varchar, -- Glc↑
trg_hyper_bilirbnm varchar, -- Bili↑
trg_ck varchar, -- CK↑
trg_hypo_serablmn varchar, -- Alb↓
trg_hypo_nat varchar, -- Na+↓
trg_hyper_nat varchar, -- Na+↑
trg_hyper_kal varchar, -- K+↓
trg_hypo_kal varchar, -- K+↑
trg_inr_ern varchar, -- INR Antikoag↓
trg_inr_erh varchar, -- INR ↑
trg_inr_erh_antikoa varchar, -- INR Antikoag↑
trg_krea varchar, -- Krea↑
trg_egfr varchar, -- eGFR<30
trigger_complete varchar, -- Frontend Complete-Status
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

--SQL Role / Trigger in Schema db2dataprocessor_in
GRANT SELECT ON TABLE db2dataprocessor_in.patient_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.patient_fe TO db2dataprocessor_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.patient_fe TO db_user;
GRANT SELECT ON TABLE db2dataprocessor_in.patient_fe TO db_log_user;
GRANT TRIGGER ON db2dataprocessor_in.patient_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
ALTER TABLE db2dataprocessor_in.patient_fe ALTER COLUMN patient_fe_id SET DEFAULT (nextval('db2dataprocessor_in.db2dataprocessor_in_seq'));
GRANT USAGE ON db2dataprocessor_in.db2dataprocessor_in_seq TO db2dataprocessor_user;

CREATE OR REPLACE FUNCTION db2dataprocessor_in.patient_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    IF NEW.input_datetime IS NULL THEN
        NEW.input_datetime := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_fe_tr_ins_tr
  BEFORE INSERT
  ON  db2dataprocessor_in.patient_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db2dataprocessor_in.patient_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db2dataprocessor_in.fall_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.fall_fe TO db2dataprocessor_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.fall_fe TO db_user;
GRANT SELECT ON TABLE db2dataprocessor_in.fall_fe TO db_log_user;
GRANT TRIGGER ON db2dataprocessor_in.fall_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
ALTER TABLE db2dataprocessor_in.fall_fe ALTER COLUMN fall_fe_id SET DEFAULT (nextval('db2dataprocessor_in.db2dataprocessor_in_seq'));
GRANT USAGE ON db2dataprocessor_in.db2dataprocessor_in_seq TO db2dataprocessor_user;

CREATE OR REPLACE FUNCTION db2dataprocessor_in.fall_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    IF NEW.input_datetime IS NULL THEN
        NEW.input_datetime := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER fall_fe_tr_ins_tr
  BEFORE INSERT
  ON  db2dataprocessor_in.fall_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db2dataprocessor_in.fall_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db2dataprocessor_in.medikationsanalyse_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.medikationsanalyse_fe TO db2dataprocessor_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.medikationsanalyse_fe TO db_user;
GRANT SELECT ON TABLE db2dataprocessor_in.medikationsanalyse_fe TO db_log_user;
GRANT TRIGGER ON db2dataprocessor_in.medikationsanalyse_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
ALTER TABLE db2dataprocessor_in.medikationsanalyse_fe ALTER COLUMN medikationsanalyse_fe_id SET DEFAULT (nextval('db2dataprocessor_in.db2dataprocessor_in_seq'));
GRANT USAGE ON db2dataprocessor_in.db2dataprocessor_in_seq TO db2dataprocessor_user;

CREATE OR REPLACE FUNCTION db2dataprocessor_in.medikationsanalyse_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    IF NEW.input_datetime IS NULL THEN
        NEW.input_datetime := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medikationsanalyse_fe_tr_ins_tr
  BEFORE INSERT
  ON  db2dataprocessor_in.medikationsanalyse_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db2dataprocessor_in.medikationsanalyse_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe TO db2dataprocessor_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe TO db_user;
GRANT SELECT ON TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe TO db_log_user;
GRANT TRIGGER ON db2dataprocessor_in.mrpdokumentation_validierung_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
ALTER TABLE db2dataprocessor_in.mrpdokumentation_validierung_fe ALTER COLUMN mrpdokumentation_validierung_fe_id SET DEFAULT (nextval('db2dataprocessor_in.db2dataprocessor_in_seq'));
GRANT USAGE ON db2dataprocessor_in.db2dataprocessor_in_seq TO db2dataprocessor_user;

CREATE OR REPLACE FUNCTION db2dataprocessor_in.mrpdokumentation_validierung_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    IF NEW.input_datetime IS NULL THEN
        NEW.input_datetime := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER mrpdokumentation_validierung_fe_tr_ins_tr
  BEFORE INSERT
  ON  db2dataprocessor_in.mrpdokumentation_validierung_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db2dataprocessor_in.mrpdokumentation_validierung_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db2dataprocessor_in.risikofaktor_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.risikofaktor_fe TO db2dataprocessor_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.risikofaktor_fe TO db_user;
GRANT SELECT ON TABLE db2dataprocessor_in.risikofaktor_fe TO db_log_user;
GRANT TRIGGER ON db2dataprocessor_in.risikofaktor_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
ALTER TABLE db2dataprocessor_in.risikofaktor_fe ALTER COLUMN risikofaktor_fe_id SET DEFAULT (nextval('db2dataprocessor_in.db2dataprocessor_in_seq'));
GRANT USAGE ON db2dataprocessor_in.db2dataprocessor_in_seq TO db2dataprocessor_user;

CREATE OR REPLACE FUNCTION db2dataprocessor_in.risikofaktor_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    IF NEW.input_datetime IS NULL THEN
        NEW.input_datetime := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER risikofaktor_fe_tr_ins_tr
  BEFORE INSERT
  ON  db2dataprocessor_in.risikofaktor_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db2dataprocessor_in.risikofaktor_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db2dataprocessor_in.trigger_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.trigger_fe TO db2dataprocessor_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.trigger_fe TO db_user;
GRANT SELECT ON TABLE db2dataprocessor_in.trigger_fe TO db_log_user;
GRANT TRIGGER ON db2dataprocessor_in.trigger_fe TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
ALTER TABLE db2dataprocessor_in.trigger_fe ALTER COLUMN trigger_fe_id SET DEFAULT (nextval('db2dataprocessor_in.db2dataprocessor_in_seq'));
GRANT USAGE ON db2dataprocessor_in.db2dataprocessor_in_seq TO db2dataprocessor_user;

CREATE OR REPLACE FUNCTION db2dataprocessor_in.trigger_fe_tr_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Eintragen des aktuellen Zeitpunkts
    IF NEW.input_datetime IS NULL THEN
        NEW.input_datetime := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_fe_tr_ins_tr
  BEFORE INSERT
  ON  db2dataprocessor_in.trigger_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db2dataprocessor_in.trigger_fe_tr_ins_fkt();


-- Comment on Table in Schema db2dataprocessor_in
comment on column db2dataprocessor_in.patient_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet';
comment on column db2dataprocessor_in.patient_fe.pat_id is 'Patient-identifier FHIR Daten';
comment on column db2dataprocessor_in.patient_fe.redcap_repeat_instrument is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.patient_fe.redcap_repeat_instance is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.patient_fe.pat_name is 'Patientenname';
comment on column db2dataprocessor_in.patient_fe.pat_vorname is 'Patientenvorname';
comment on column db2dataprocessor_in.patient_fe.pat_gebdat is 'Geburtsdatum';
comment on column db2dataprocessor_in.patient_fe.pat_aktuell_alter is '<div class="rich-text-field-label"><p>aktuelles Patientenalter (Jahre)</p></div>';
comment on column db2dataprocessor_in.patient_fe.pat_geschlecht is 'Geschlecht (wie in FHIR)';
comment on column db2dataprocessor_in.patient_fe.patient_complete is 'Frontend Complete-Status';

comment on column db2dataprocessor_in.fall_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet';
comment on column db2dataprocessor_in.fall_fe.fall_id is 'Fall-ID RedCap FHIR Daten';
comment on column db2dataprocessor_in.fall_fe.fall_pat_id is 'Patienten-ID zu dem Fall gehört (FHIR Patient:pat_id)';
comment on column db2dataprocessor_in.fall_fe.patient_id_fk is 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id)';
comment on column db2dataprocessor_in.fall_fe.fall_typ_id is 'Datenbank-FK des getypten Falls zur Datenflussverfolgung (Fall: v_fall_all . fall_id)';
comment on column db2dataprocessor_in.fall_fe.redcap_repeat_instrument is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.fall_fe.redcap_repeat_instance is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.fall_fe.fall_studienphase is 'Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) )';
comment on column db2dataprocessor_in.fall_fe.fall_station is 'Station wie vom DIZ Definiert';
comment on column db2dataprocessor_in.fall_fe.fall_aufn_dat is 'Aufnahmedatum';
comment on column db2dataprocessor_in.fall_fe.fall_aufn_diag is '<div class="rich-text-field-label"><p><span style="color: #e03e2d;">Diagnose(n) bei Aufnahme (wird nur zum lesen sein)</span></p></div>';
comment on column db2dataprocessor_in.fall_fe.fall_gewicht_aktuell is 'aktuelles Gewicht (Kg)';
comment on column db2dataprocessor_in.fall_fe.fall_gewicht_aktl_einheit is '';
comment on column db2dataprocessor_in.fall_fe.fall_groesse is 'Größe (cm)';
comment on column db2dataprocessor_in.fall_fe.fall_groesse_einheit is '';
comment on column db2dataprocessor_in.fall_fe.fall_bmi is 'BMI';
comment on column db2dataprocessor_in.fall_fe.fall_nieren_insuf_chron is '1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz';
comment on column db2dataprocessor_in.fall_fe.fall_nieren_insuf_ausmass is '1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2<div class="rich-text-field-label"><p>aktuelles Ausmaß</p></div>';
comment on column db2dataprocessor_in.fall_fe.fall_nieren_insuf_dialysev is '1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren';
comment on column db2dataprocessor_in.fall_fe.fall_leber_insuf is '1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz';
comment on column db2dataprocessor_in.fall_fe.fall_leber_insuf_ausmass is '1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß';
comment on column db2dataprocessor_in.fall_fe.fall_schwanger_mo is '0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9<div class="rich-text-field-label"><p><span style="color: #000000;">Schwangerschaftsmonat</span></p></div>';
comment on column db2dataprocessor_in.fall_fe.fall_op_geplant is '1, ja | 0, nein | -1, nicht bekanntIst eine Operation geplant?';
comment on column db2dataprocessor_in.fall_fe.fall_op_dat is 'Operationsdatum';
comment on column db2dataprocessor_in.fall_fe.fall_status is '';
comment on column db2dataprocessor_in.fall_fe.fall_ent_dat is 'Entlassdatum';
comment on column db2dataprocessor_in.fall_fe.fall_complete is 'Frontend Complete-Status';

comment on column db2dataprocessor_in.medikationsanalyse_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet';
comment on column db2dataprocessor_in.medikationsanalyse_fe.fall_typ_id is 'Datenbank-FK des Falls (Fall: v_fall_all . fall_id) -> Dataprocessor setzt id: meda_dat in [fall_aufn_dat;fall_ent_dat]';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_fall_id is 'Fall-ID zu dem Medikationsanalyse gehört FHIR (Fall:fall_id)';
comment on column db2dataprocessor_in.medikationsanalyse_fe.redcap_repeat_instrument is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.medikationsanalyse_fe.redcap_repeat_instance is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_dat is 'Datum der Medikationsanalyse';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_typ is 'Typ der Medikationsanalyse';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_risiko_pat is '1, Risikopatient | 2, Medikationsanalyse / Therapieüberwachung in 24-48hMarkieren als Risikopatient';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_ma_thueberw is 'Medikationsanalyse / Therapieüberwachung in 24-48h';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_aufwand_zeit is '0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min]';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_aufwand_zeit_and is 'wie lange hat die Medikationsanalyse gedauert? Eingabe in Minuten. ';
comment on column db2dataprocessor_in.medikationsanalyse_fe.meda_notiz is 'Notizfeld';
comment on column db2dataprocessor_in.medikationsanalyse_fe.medikationsanalyse_complete is 'Frontend Complete-Status';

comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.meda_typ_id is 'Datenbank-FK der Medikationsanalyse (Medikationsanalyse: medikationsanalyse_fe_id) -> Dataprocessor setzt id: mrp_entd_dat(Tag)=meda_dat(Tag)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.redcap_repeat_instrument is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.redcap_repeat_instance is 'RedCap interne Datensatzzuordnung';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_entd_dat is 'Datum des MRP';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_kurzbeschr is 'Kurzbeschreibung des MRPs';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_entd_algorithmisch is 'MRP vom INTERPOLAR-Algorithmus entdeckt?';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_hinweisgeber is 'Hinweisgeber auf das MRP';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewissheit is 'Sicherheit des detektierten MRP';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl is 'Grund für nicht Bestätigung';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_sonst is 'Bitte näher beschreiben';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_wirkstoff is 'Wirkstoff betroffen?';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc1 is '1. Medikament ATC / Name:';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc2 is '2. Medikament ATC / Name';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_atc3 is '3. Medikament ATC / Name';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_med_prod is 'Medizinprodukt betroffen?';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_med_prod_sonst is 'Sonstigespräparat';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_dokup_fehler is 'Fehlerbeschreibung ';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_dokup_intervention is 'Intervention -Vorschlag zur Fehlervermeldung';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund is 'PI-Grund';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___1 is '1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___2 is '2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___3 is '3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___4 is '4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___5 is '5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___6 is '6 - AM: Übertragungsfehler (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___7 is '7 - AM: Substitution aut idem/aut simile (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___8 is '8 - AM: (Klare) Indikation, aber kein Medikament angeordnet (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___9 is '9 - AM: Stellfehler (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___10 is '10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___11 is '11 - AM: Doppelverordnung (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___12 is '12 - ANW: Applikation (Dauer) (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___13 is '13 - ANW: Inkompatibilität oder falsche Zubereitung (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___14 is '14 - ANW: Applikation (Art) (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___15 is '15 - ANW: Anfrage zur Administration/Kompatibilität';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___16 is '16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___17 is '17 - D: (Fehlerhafte) Dosis (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___18 is '18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___19 is '19 - D: (Fehlerhaftes) Dosisinterval (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___20 is '20 - Interaktion (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___21 is '21 - Kontraindikation (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___22 is '22 - Nebenwirkungen';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___23 is '23 - S: Beratung/Auswahl eines Arzneistoffs';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___24 is '24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___25 is '25 - S: Beschaffung/Kosten';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___26 is '26 - S: Keine Pause von AM, die prä-OP pausiert werden müssen (MF)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_pigrund___27 is '27 - S: Schulung/Beratung eines Patienten';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse is 'MRP-Klasse (INTERPOLAR)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___1 is '1 - Drug - Drug';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___2 is '2 - Drug - Drug-Group';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___3 is '3 - Drug - Disease';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___4 is '4 - Drug - Labor';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse___5 is '5 - Drug - Age (Priscus 2.0 o. Dosis)';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse_disease is 'Disease';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_ip_klasse_labor is 'Labor';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am is 'AM: Arzneimitte';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___1 is '1 - Anweisung für die Applikation geben';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___2 is '2 - Arzneimittel ändern';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___3 is '3 - Arzneimittel stoppen/pausieren';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___4 is '4 - Arzneimittel neu ansetzen';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___5 is '5 - Dosierung ändern';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___6 is '6 - Formulierung ändern';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___7 is '7 - Hilfe bei Beschaffung';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___8 is '8 - Information an Arzt/Pflege';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___9 is '9 - Information an Patient';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_am___10 is '10 - TDM oder Laborkontrolle emfohlen';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga is 'ORGA: Organisatorisch';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___1 is '1 - Aushändigung einer Information/eines Medikationsplans';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___2 is '2 - CIRS-/AMK-Meldung';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___3 is '3 - Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___4 is '4 - Etablierung einer Doppelkontrolle';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___5 is '5 - Lieferantenwechsel';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___6 is '6 - Optimierung der internen und externene Kommunikation';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___7 is '7 - Prozessoptimierung/Etablierung einer SOP/VA';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_massn_orga___8 is '8 - Sensibilisierung/Schulung';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_notiz is 'Notiz';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_dokup_hand_emp_akz is 'Handlungsempfehlung akzeptiert?';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_merp is 'NCC MERP Score';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrp_wiedervorlage is 'MRP Wiedervorlage';
comment on column db2dataprocessor_in.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_complete is 'Frontend Complete-Status';

comment on column db2dataprocessor_in.risikofaktor_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet';
comment on column db2dataprocessor_in.risikofaktor_fe.patient_id_fk is 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id)';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_gerhemmer is 'Ger.hemmer';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_tah is 'TAH';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_immunsupp is 'Immunsupp.';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_tumorth is 'Tumorth.';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_opiat is 'Opiat';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_atcn is 'ATC N';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_ait is 'AIT';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_anzam is 'Anz AM';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_priscus is 'PRISCUS';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_qtc is 'QTc';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_meld is 'MELD';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_dialyse is 'Dialyse';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfk_entern is 'ent. Ern.';
comment on column db2dataprocessor_in.risikofaktor_fe.rskfkt_anz_rskamklassen is 'Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0';
comment on column db2dataprocessor_in.risikofaktor_fe.risikofaktor_complete is 'Frontend Complete-Status';

comment on column db2dataprocessor_in.trigger_fe.patient_id_fk is 'Datenbank-FK des Patienten (Patient: patient_fe_id=Patient.record_id)';
comment on column db2dataprocessor_in.trigger_fe.record_id is 'Record ID RedCap - besetzt/vorgegeben mit Datenbankinternen ID des Patienten - wird im Redcap in allen Instanzen  des Patienten verwendet';
comment on column db2dataprocessor_in.trigger_fe.trg_ast is '<div class="rich-text-field-label"><p>AST<span style="font-weight: normal; font-size: 12pt;">↑</span></p></div>';
comment on column db2dataprocessor_in.trigger_fe.trg_alt is 'ALT↑';
comment on column db2dataprocessor_in.trigger_fe.trg_crp is 'CRP↑';
comment on column db2dataprocessor_in.trigger_fe.trg_leuk_penie is 'Leuko↓';
comment on column db2dataprocessor_in.trigger_fe.trg_leuk_ose is 'Leuko↑';
comment on column db2dataprocessor_in.trigger_fe.trg_thrmb_penie is 'Thrombo↓';
comment on column db2dataprocessor_in.trigger_fe.trg_aptt is 'aPTT';
comment on column db2dataprocessor_in.trigger_fe.trg_hyp_haem is 'Hb↓';
comment on column db2dataprocessor_in.trigger_fe.trg_hypo_glyk is 'Glc↓';
comment on column db2dataprocessor_in.trigger_fe.trg_hyper_glyk is 'Glc↑';
comment on column db2dataprocessor_in.trigger_fe.trg_hyper_bilirbnm is 'Bili↑';
comment on column db2dataprocessor_in.trigger_fe.trg_ck is 'CK↑';
comment on column db2dataprocessor_in.trigger_fe.trg_hypo_serablmn is 'Alb↓';
comment on column db2dataprocessor_in.trigger_fe.trg_hypo_nat is 'Na+↓';
comment on column db2dataprocessor_in.trigger_fe.trg_hyper_nat is 'Na+↑';
comment on column db2dataprocessor_in.trigger_fe.trg_hyper_kal is 'K+↓';
comment on column db2dataprocessor_in.trigger_fe.trg_hypo_kal is 'K+↑';
comment on column db2dataprocessor_in.trigger_fe.trg_inr_ern is 'INR Antikoag↓';
comment on column db2dataprocessor_in.trigger_fe.trg_inr_erh is 'INR ↑';
comment on column db2dataprocessor_in.trigger_fe.trg_inr_erh_antikoa is 'INR Antikoag↑';
comment on column db2dataprocessor_in.trigger_fe.trg_krea is 'Krea↑';
comment on column db2dataprocessor_in.trigger_fe.trg_egfr is 'eGFR<30';
comment on column db2dataprocessor_in.trigger_fe.trigger_complete is 'Frontend Complete-Status';
