--Create SQL Table in Schema db_log
CREATE TABLE IF NOT EXISTS db_log.patient_fe (
patient_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
record_id varchar, -- Record ID RedCap
patient_id_pk int, -- Datenbank-PK ID des Patienten (intern)
pat_id varchar, -- Patient-identifier
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

CREATE TABLE IF NOT EXISTS db_log.fall_fe (
fall_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
fall_id varchar, -- Fall-ID RedCap
fall_id_pk int, -- Datenbank-PK ID des Falls (intern)
patient_id_fk int, -- Datenbank-FK ID des Patienten (intern)
redcap_repeat_instrument varchar, -- RedCap interne Datensatzzuordnung
redcap_repeat_instance varchar, -- RedCap interne Datensatzzuordnung
fall_studienphase varchar, -- Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) )
fall_station varchar, -- Station wie vom DIZ Definiert
fall_aufn_dat date, -- Aufnahmedatum
fall_aufn_diag varchar, -- <div class=rich-text-field-label><p><span style=color: #e03e2d;>Diagnose(n) bei Aufnahme (wird nur zum lesen sein)</span></p></div>
fall_gewicht_aktuell double precision, -- aktuelles Gewicht (Kg)
fall_gewicht_aktl_einheit double precision, -- 
fall_groesse double precision, -- Größe (cm)
fall_groesse_einheit double precision, -- 
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

CREATE TABLE IF NOT EXISTS db_log.medikationsanalyse_fe (
medikationsanalyse_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
meda_id_pk int, -- Datenbank-PK ID der Medikationsanalyse (intern)
fall_id_fk int, -- Datenbank-FK ID des Falls (intern)
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

CREATE TABLE IF NOT EXISTS db_log.mrpdokumentation_validierung_fe (
mrpdokumentation_validierung_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
mrp_id_pk int, -- Datenbank-PK ID des MRPs (intern)
meda_id_fk int, -- Datenbank-FK ID der Medikationsanalyse (intern)
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
mrp_ip_klasse varchar, -- MRP-Klasse (INTERPOLAR)
mrp_ip_klasse_disease varchar, -- Disease
mrp_ip_klasse_labor varchar, -- Labor
mrp_massn_am varchar, -- <div class=rich-text-field-label><p>AM: Arzneimittel</p></div>
mrp_massn_orga varchar, -- <div class=rich-text-field-label><p>ORGA: Organisatorisch</p></div>
mrp_notiz varchar, -- Notiz
mrp_dokup_hand_emp_akz varchar, -- Handlungsempfehlung akzeptiert?
mrp_merp varchar, -- NCC MERP Score
mrp_wiedervorlage varchar, -- MRP Wiedervorlage
mrpdokumentation_validierung_complete varchar, -- Frontend Complete-Status
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db_log.risikofaktor_fe (
risikofaktor_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
rskfk_id_pk int, -- Datenbank-PK ID des Risikofaktors (intern)
patient_id_fk int, -- Datenbank-FK ID des zugehörigen Patienten (intern)
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

CREATE TABLE IF NOT EXISTS db_log.trigger_fe (
trigger_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
trg_id_pk int, -- Datenbank-PK ID des Triggers (intern)
patient_id_fk int, -- Datenbank-FK ID des zugehörigen Patienten (intern)
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

--SQL Role / Trigger in Schema db_log
GRANT SELECT ON TABLE db_log.patient_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_user;
GRANT SELECT ON TABLE db_log.patient_fe TO db_log_user;
GRANT TRIGGER ON db_log.patient_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
ALTER TABLE db_log.patient_fe ALTER COLUMN patient_fe_id SET DEFAULT (nextval('db_log.db_log_seq'));
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

CREATE OR REPLACE FUNCTION db_log.patient_fe_tr_ins_fkt()
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
  ON  db_log.patient_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db_log.patient_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db_log.fall_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_user;
GRANT SELECT ON TABLE db_log.fall_fe TO db_log_user;
GRANT TRIGGER ON db_log.fall_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
ALTER TABLE db_log.fall_fe ALTER COLUMN fall_fe_id SET DEFAULT (nextval('db_log.db_log_seq'));
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

CREATE OR REPLACE FUNCTION db_log.fall_fe_tr_ins_fkt()
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
  ON  db_log.fall_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db_log.fall_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db_log.medikationsanalyse_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_user;
GRANT SELECT ON TABLE db_log.medikationsanalyse_fe TO db_log_user;
GRANT TRIGGER ON db_log.medikationsanalyse_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
ALTER TABLE db_log.medikationsanalyse_fe ALTER COLUMN medikationsanalyse_fe_id SET DEFAULT (nextval('db_log.db_log_seq'));
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

CREATE OR REPLACE FUNCTION db_log.medikationsanalyse_fe_tr_ins_fkt()
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
  ON  db_log.medikationsanalyse_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db_log.medikationsanalyse_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_user;
GRANT SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT TRIGGER ON db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
ALTER TABLE db_log.mrpdokumentation_validierung_fe ALTER COLUMN mrpdokumentation_validierung_fe_id SET DEFAULT (nextval('db_log.db_log_seq'));
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

CREATE OR REPLACE FUNCTION db_log.mrpdokumentation_validierung_fe_tr_ins_fkt()
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
  ON  db_log.mrpdokumentation_validierung_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db_log.mrpdokumentation_validierung_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db_log.risikofaktor_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.risikofaktor_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.risikofaktor_fe TO db_user;
GRANT SELECT ON TABLE db_log.risikofaktor_fe TO db_log_user;
GRANT TRIGGER ON db_log.risikofaktor_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
ALTER TABLE db_log.risikofaktor_fe ALTER COLUMN risikofaktor_fe_id SET DEFAULT (nextval('db_log.db_log_seq'));
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

CREATE OR REPLACE FUNCTION db_log.risikofaktor_fe_tr_ins_fkt()
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
  ON  db_log.risikofaktor_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db_log.risikofaktor_fe_tr_ins_fkt();

GRANT SELECT ON TABLE db_log.trigger_fe TO db2frontend_user; -- Kurzstrecke für Test zu FrontEnd
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.trigger_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.trigger_fe TO db_user;
GRANT SELECT ON TABLE db_log.trigger_fe TO db_log_user;
GRANT TRIGGER ON db_log.trigger_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
ALTER TABLE db_log.trigger_fe ALTER COLUMN trigger_fe_id SET DEFAULT (nextval('db_log.db_log_seq'));
GRANT USAGE ON db_log.db_log_seq TO db_log_user;

CREATE OR REPLACE FUNCTION db_log.trigger_fe_tr_ins_fkt()
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
  ON  db_log.trigger_fe
  FOR EACH ROW
  EXECUTE PROCEDURE  db_log.trigger_fe_tr_ins_fkt();

-- Comment on Table in Schema db_log
comment on column db_log.patient_fe.record_id is 'Record ID RedCap';
comment on column db_log.patient_fe.patient_id_pk is 'Datenbank-PK ID des Patienten (intern)';
comment on column db_log.patient_fe.pat_id is 'Patient-identifier';
comment on column db_log.patient_fe.pat_name is 'Patientenname';
comment on column db_log.patient_fe.pat_vorname is 'Patientenvorname';
comment on column db_log.patient_fe.pat_gebdat is 'Geburtsdatum';
comment on column db_log.patient_fe.pat_aktuell_alter is '<div class="rich-text-field-label"><p>aktuelles Patientenalter (Jahre)</p></div>';
comment on column db_log.patient_fe.pat_geschlecht is 'Geschlecht (wie in FHIR)';
comment on column db_log.patient_fe.patient_complete is 'Frontend Complete-Status';

comment on column db_log.fall_fe.fall_id is 'Fall-ID RedCap';
comment on column db_log.fall_fe.fall_id_pk is 'Datenbank-PK ID des Falls (intern)';
comment on column db_log.fall_fe.patient_id_fk is 'Datenbank-FK ID des Patienten (intern)';
comment on column db_log.fall_fe.redcap_repeat_instrument is 'RedCap interne Datensatzzuordnung';
comment on column db_log.fall_fe.redcap_repeat_instance is 'RedCap interne Datensatzzuordnung';
comment on column db_log.fall_fe.fall_studienphase is 'Alt: (1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P) )';
comment on column db_log.fall_fe.fall_station is 'Station wie vom DIZ Definiert';
comment on column db_log.fall_fe.fall_aufn_dat is 'Aufnahmedatum';
comment on column db_log.fall_fe.fall_aufn_diag is '<div class="rich-text-field-label"><p><span style="color: #e03e2d;">Diagnose(n) bei Aufnahme (wird nur zum lesen sein)</span></p></div>';
comment on column db_log.fall_fe.fall_gewicht_aktuell is 'aktuelles Gewicht (Kg)';
comment on column db_log.fall_fe.fall_gewicht_aktl_einheit is '';
comment on column db_log.fall_fe.fall_groesse is 'Größe (cm)';
comment on column db_log.fall_fe.fall_groesse_einheit is '';
comment on column db_log.fall_fe.fall_bmi is 'BMI';
comment on column db_log.fall_fe.fall_nieren_insuf_chron is '1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz';
comment on column db_log.fall_fe.fall_nieren_insuf_ausmass is '1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2<div class="rich-text-field-label"><p>aktuelles Ausmaß</p></div>';
comment on column db_log.fall_fe.fall_nieren_insuf_dialysev is '1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren';
comment on column db_log.fall_fe.fall_leber_insuf is '1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz';
comment on column db_log.fall_fe.fall_leber_insuf_ausmass is '1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß';
comment on column db_log.fall_fe.fall_schwanger_mo is '0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9<div class="rich-text-field-label"><p><span style="color: #000000;">Schwangerschaftsmonat</span></p></div>';
comment on column db_log.fall_fe.fall_op_geplant is '1, ja | 0, nein | -1, nicht bekanntIst eine Operation geplant?';
comment on column db_log.fall_fe.fall_op_dat is 'Operationsdatum';
comment on column db_log.fall_fe.fall_status is '';
comment on column db_log.fall_fe.fall_ent_dat is 'Entlassdatum';
comment on column db_log.fall_fe.fall_complete is 'Frontend Complete-Status';

comment on column db_log.medikationsanalyse_fe.meda_id_pk is 'Datenbank-PK ID der Medikationsanalyse (intern)';
comment on column db_log.medikationsanalyse_fe.fall_id_fk is 'Datenbank-FK ID des Falls (intern)';
comment on column db_log.medikationsanalyse_fe.redcap_repeat_instrument is 'RedCap interne Datensatzzuordnung';
comment on column db_log.medikationsanalyse_fe.redcap_repeat_instance is 'RedCap interne Datensatzzuordnung';
comment on column db_log.medikationsanalyse_fe.meda_dat is 'Datum der Medikationsanalyse';
comment on column db_log.medikationsanalyse_fe.meda_typ is 'Typ der Medikationsanalyse';
comment on column db_log.medikationsanalyse_fe.meda_risiko_pat is '1, Risikopatient | 2, Medikationsanalyse / Therapieüberwachung in 24-48hMarkieren als Risikopatient';
comment on column db_log.medikationsanalyse_fe.meda_ma_thueberw is 'Medikationsanalyse / Therapieüberwachung in 24-48h';
comment on column db_log.medikationsanalyse_fe.meda_aufwand_zeit is '0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min]';
comment on column db_log.medikationsanalyse_fe.meda_aufwand_zeit_and is 'wie lange hat die Medikationsanalyse gedauert? Eingabe in Minuten. ';
comment on column db_log.medikationsanalyse_fe.meda_notiz is 'Notizfeld';
comment on column db_log.medikationsanalyse_fe.medikationsanalyse_complete is 'Frontend Complete-Status';

comment on column db_log.mrpdokumentation_validierung_fe.mrp_id_pk is 'Datenbank-PK ID des MRPs (intern)';
comment on column db_log.mrpdokumentation_validierung_fe.meda_id_fk is 'Datenbank-FK ID der Medikationsanalyse (intern)';
comment on column db_log.mrpdokumentation_validierung_fe.redcap_repeat_instrument is 'RedCap interne Datensatzzuordnung';
comment on column db_log.mrpdokumentation_validierung_fe.redcap_repeat_instance is 'RedCap interne Datensatzzuordnung';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_entd_dat is 'Datum des MRP';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_kurzbeschr is 'Kurzbeschreibung des MRPs';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_entd_algorithmisch is 'MRP vom INTERPOLAR-Algorithmus entdeckt?';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber is 'Hinweisgeber auf das MRP';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_gewissheit is 'Sicherheit des detektierten MRP';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl is 'Grund für nicht Bestätigung';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_sonst is 'Bitte näher beschreiben';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_wirkstoff is 'Wirkstoff betroffen?';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_atc1 is '1. Medikament ATC / Name:';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_atc2 is '2. Medikament ATC / Name';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_atc3 is '3. Medikament ATC / Name';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_med_prod is 'Medizinprodukt betroffen?';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_med_prod_sonst is 'Sonstigespräparat';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_dokup_fehler is '<div class="rich-text-field-label"><p>Frage / <span style="font-weight: normal;">Fehlerbeschreibung </span></p> <p><span style="font-weight: normal;">[mrp_kurzbeschr]</span></p></div>';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_dokup_intervention is '<div class="rich-text-field-label"><p>Intervention / <span style="font-weight: normal;">Vorschlag zur Fehlervermeldung</span></p></div>';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_pigrund is 'PI-Grund';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse is 'MRP-Klasse (INTERPOLAR)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_disease is 'Disease';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_labor is 'Labor';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_massn_am is '<div class="rich-text-field-label"><p>AM: Arzneimittel</p></div>';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_massn_orga is '<div class="rich-text-field-label"><p>ORGA: Organisatorisch</p></div>';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_notiz is 'Notiz';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_dokup_hand_emp_akz is 'Handlungsempfehlung akzeptiert?';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_merp is 'NCC MERP Score';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_wiedervorlage is 'MRP Wiedervorlage';
comment on column db_log.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_complete is 'Frontend Complete-Status';

comment on column db_log.risikofaktor_fe.rskfk_id_pk is 'Datenbank-PK ID des Risikofaktors (intern)';
comment on column db_log.risikofaktor_fe.patient_id_fk is 'Datenbank-FK ID des zugehörigen Patienten (intern)';
comment on column db_log.risikofaktor_fe.rskfk_gerhemmer is 'Ger.hemmer';
comment on column db_log.risikofaktor_fe.rskfk_tah is 'TAH';
comment on column db_log.risikofaktor_fe.rskfk_immunsupp is 'Immunsupp.';
comment on column db_log.risikofaktor_fe.rskfk_tumorth is 'Tumorth.';
comment on column db_log.risikofaktor_fe.rskfk_opiat is 'Opiat';
comment on column db_log.risikofaktor_fe.rskfk_atcn is 'ATC N';
comment on column db_log.risikofaktor_fe.rskfk_ait is 'AIT';
comment on column db_log.risikofaktor_fe.rskfk_anzam is 'Anz AM';
comment on column db_log.risikofaktor_fe.rskfk_priscus is 'PRISCUS';
comment on column db_log.risikofaktor_fe.rskfk_qtc is 'QTc';
comment on column db_log.risikofaktor_fe.rskfk_meld is 'MELD';
comment on column db_log.risikofaktor_fe.rskfk_dialyse is 'Dialyse';
comment on column db_log.risikofaktor_fe.rskfk_entern is 'ent. Ern.';
comment on column db_log.risikofaktor_fe.rskfkt_anz_rskamklassen is 'Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0';
comment on column db_log.risikofaktor_fe.risikofaktor_complete is 'Frontend Complete-Status';

comment on column db_log.trigger_fe.trg_id_pk is 'Datenbank-PK ID des Triggers (intern)';
comment on column db_log.trigger_fe.patient_id_fk is 'Datenbank-FK ID des zugehörigen Patienten (intern)';
comment on column db_log.trigger_fe.trg_ast is '<div class="rich-text-field-label"><p>AST<span style="font-weight: normal; font-size: 12pt;">↑</span></p></div>';
comment on column db_log.trigger_fe.trg_alt is 'ALT↑';
comment on column db_log.trigger_fe.trg_crp is 'CRP↑';
comment on column db_log.trigger_fe.trg_leuk_penie is 'Leuko↓';
comment on column db_log.trigger_fe.trg_leuk_ose is 'Leuko↑';
comment on column db_log.trigger_fe.trg_thrmb_penie is 'Thrombo↓';
comment on column db_log.trigger_fe.trg_aptt is 'aPTT';
comment on column db_log.trigger_fe.trg_hyp_haem is 'Hb↓';
comment on column db_log.trigger_fe.trg_hypo_glyk is 'Glc↓';
comment on column db_log.trigger_fe.trg_hyper_glyk is 'Glc↑';
comment on column db_log.trigger_fe.trg_hyper_bilirbnm is 'Bili↑';
comment on column db_log.trigger_fe.trg_ck is 'CK↑';
comment on column db_log.trigger_fe.trg_hypo_serablmn is 'Alb↓';
comment on column db_log.trigger_fe.trg_hypo_nat is 'Na+↓';
comment on column db_log.trigger_fe.trg_hyper_nat is 'Na+↑';
comment on column db_log.trigger_fe.trg_hyper_kal is 'K+↓';
comment on column db_log.trigger_fe.trg_hypo_kal is 'K+↑';
comment on column db_log.trigger_fe.trg_inr_ern is 'INR Antikoag↓';
comment on column db_log.trigger_fe.trg_inr_erh is 'INR ↑';
comment on column db_log.trigger_fe.trg_inr_erh_antikoa is 'INR Antikoag↑';
comment on column db_log.trigger_fe.trg_krea is 'Krea↑';
comment on column db_log.trigger_fe.trg_egfr is 'eGFR<30';
comment on column db_log.trigger_fe.trigger_complete is 'Frontend Complete-Status';