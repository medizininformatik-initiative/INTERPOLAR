--Create SQL Table in Schema db_log
CREATE TABLE IF NOT EXISTS db_log.patient_fe (
patient_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
record_id varchar (200),   -- Record ID (200 x 1 varchar)
pat_id varchar (200),   -- Patient-identifier (200 x 1 varchar)
pat_name varchar (200),   -- Patientenname (200 x 1 varchar)
pat_vorname varchar (200),   -- Patientenvorname (200 x 1 varchar)
pat_gebdat varchar (200),   -- Geburtsdatum (200 x 1 varchar)
pat_aktuell_alter varchar (200),   -- <div class=rich-text-field-label><p>aktuelles Patientenalter (Jahre)</p></div> (200 x 1 varchar)
pat_geschlecht numeric (10),   -- 0, nicht bekannt | 1, weiblich | 2, männlich | 3, diversGeschlecht (10 x 1 numeric)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db_log.fall_fe (
fall_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
fall_id varchar (200),   -- Fall-ID (200 x 1 varchar)
fall_studienphase numeric (10),   -- 1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P)<div class=rich-text-field-label><p><span style=color: #e03e2d;>Studienphase (wird wenn produktiv versteckt sein)</span></p></div> (10 x 1 numeric)
fall_station numeric (10),   -- 1, Station 1 | 2, Station 2 | 3, Station 3Station (10 x 1 numeric)
fall_aufn_dat varchar (200),   -- Aufnahmedatum (200 x 1 varchar)
fall_aufn_diag varchar (1000),   -- <div class=rich-text-field-label><p><span style=color: #e03e2d;>Diagnose(n) bei Aufnahme (wird nur zum lesen sein)</span></p></div> (1000 x 1 varchar)
fall_gewicht_kg_aktuell varchar (500),   -- aktuelles Gewicht (Kg) (500 x 1 varchar)
fall_groesse_cm varchar (230),   -- Größe (cm) (230 x 1 varchar)
fall_bmi varchar (200),   -- BMI (200 x 1 varchar)
fall_nieren_insuf_chron numeric (10),   -- 1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (10 x 1 numeric)
fall_nieren_insuf_ausmass numeric (10),   -- 1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2<div class=rich-text-field-label><p>aktuelles Ausmaß</p></div> (10 x 1 numeric)
fall_nieren_insuf_dialysev numeric (10),   -- 1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (10 x 1 numeric)
fall_leber_insuf numeric (10),   -- 1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (10 x 1 numeric)
fall_leber_insuf_ausmass numeric (10),   -- 1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß (10 x 1 numeric)
fall_schwanger_mo numeric (10),   -- 0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9<div class=rich-text-field-label><p><span style=color: #000000;>Schwangerschaftsmonat</span></p></div> (10 x 1 numeric)
fall_op_geplant numeric (10),   -- 1, ja | 0, nein | -1, nicht bekanntIst eine Operation geplant? (10 x 1 numeric)
fall_op_dat varchar (200),   -- Operationsdatum (200 x 1 varchar)
fall_status numeric (10),   -- 1, aktuell / neu | 2, nicht relevant | 3, verlegt<div class=rich-text-field-label><p><span style=color: #e03e2d;><span style=color: #000000;>Fallstatus:</span><br></span></p></div> (10 x 1 numeric)
fall_ent_dat varchar (200),   -- Entlassdatum (200 x 1 varchar)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db_log.medikationsanalyse_fe (
medikationsanalyse_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
meda_dat varchar (200),   -- Datum der Medikationsanalyse (200 x 1 varchar)
meda_typ numeric (10),   -- 1, Typ 1: Einfache | 2, Typ 2a: Erweiterte | 3, Typ 2b: Erweiterte | 4, Typ 3: Umfassende MedikationsanalyseTyp der Medikationsanalyse (10 x 1 numeric)
meda_risiko_pat numeric (10),   -- 1, Risikopatient | 2, Medikationsanalyse / Therapieüberwachung in 24-48hMarkieren als Risikopatient (10 x 1 numeric)
meda_aufwand_zeit numeric (10),   -- 0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min] (10 x 1 numeric)
meda_aufwand_zeit_and varchar (200),   -- wie lange hat die Medikationsanalyse gedauert? Eingabe in Minuten.  (200 x 1 varchar)
meda_notiz varchar (1000),   -- Notizfeld (1000 x 1 varchar)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);

CREATE TABLE IF NOT EXISTS db_log.mrpdokumentation_validierung_fe (
mrpdokumentation_validierung_fe_id serial PRIMARY KEY not null, -- Primärschlüssel der Entität
mrp_entd_dat varchar (200),   -- Datum des MRP (200 x 1 varchar)
mrp_kurzbeschr varchar (1000),   -- Kurzbeschreibung des MRPs (1000 x 1 varchar)
mrp_entd_algorithmisch numeric (10),   -- 1, Ja | 0, NeinMRP vom INTERPOLAR-Algorithmus entdeckt? (10 x 1 numeric)
mrp_hinweisgeber numeric (10),   -- 1, Apotheker*in (Station) | 2, Apotheker*in (UnitDose) | 3, Arzt / Ärztin | 4, Pflege | 5, Patient*in / Angehörige*r | 6, unbekannt | 7, andereHinweisgeber auf das MRP (10 x 1 numeric)
mrp_gewissheit numeric (10),   -- 1, MRP bestätigt | 2, MRP möglich, weitere Informationen nötig | 3, MRP nicht bestätigtSicherheit des detektierten MRP (10 x 1 numeric)
mrp_gewiss_grund_abl numeric (10),   -- 1, MRP sachlich falsch (keine Kontraindikation) | 2, MRP sachlich richtig, aber falsche Datengrundlage | 3, MRP sachlich richtig, aber klinisch nicht relevant | 4, MRP sachlich richtig, aber von Stationsapotheker vorher identifiziert | 5, SonstigesGrund für nicht Bestätigung (10 x 1 numeric)
mrp_gewiss_grund_abl_sonst varchar (200),   -- Bitte näher beschreiben (200 x 1 varchar)
mrp_wirkstoff numeric (10),   -- 1, Ja | 0, NeinWirkstoff betroffen? (10 x 1 numeric)
mrp_atc1 numeric (10),   -- 7298, J05AF06 - Abacavir | 7299, H05AA04 - Abaloparatid | 7300, P03AX07 - Abametapir | 7301, L02BX01 - Abarelix | 7302, L04AA24 - Abatacept | 7303, B01AC13 - Abciximab | 7304, L01EF03 - Abemaciclib | 7305, L04AA22 - Abetimus | 7306, S01LA07 - Abicipar peg1. Medikament ATC / Name: (10 x 1 numeric)
mrp_atc2 numeric (10),   -- 7298, J05AF06 - Abacavir | 7299, H05AA04 - Abaloparatid | 7300, P03AX07 - Abametapir | 7301, L02BX01 - Abarelix | 7302, L04AA24 - Abatacept | 7303, B01AC13 - Abciximab | 7304, L01EF03 - Abemaciclib | 7305, L04AA22 - Abetimus | 7306, S01LA07 - Abicipar peg2. Medikament ATC / Name (10 x 1 numeric)
mrp_atc3 numeric (10),   -- 7298, J05AF06 - Abacavir | 7299, H05AA04 - Abaloparatid | 7300, P03AX07 - Abametapir | 7301, L02BX01 - Abarelix | 7302, L04AA24 - Abatacept | 7303, B01AC13 - Abciximab | 7304, L01EF03 - Abemaciclib | 7305, L04AA22 - Abetimus | 7306, S01LA07 - Abicipar peg3. Medikament ATC / Name (10 x 1 numeric)
mrp_med_prod numeric (10),   -- 1, Ja | 0, NeinMedizinprodukt betroffen? (10 x 1 numeric)
mrp_med_prod_sonst varchar (200),   -- Sonstigespräparat (200 x 1 varchar)
mrp_dokup_fehler varchar (200),   -- <div class=rich-text-field-label><p>Frage / <span style=font-weight: normal;>Fehlerbeschreibung </span></p> <p><span style=font-weight: normal;>[mrp_kurzbeschr]</span></p></div> (200 x 1 varchar)
mrp_dokup_intervention varchar (200),   -- <div class=rich-text-field-label><p>Intervention / <span style=font-weight: normal;>Vorschlag zur Fehlervermeldung</span></p></div> (200 x 1 varchar)
mrp_pi_grund_am numeric (10),   -- 1, (Klare) Indikation nicht (mehr) gegeben (MF) | 2, Verordnung/Dokumentation unvollständig/fehlerhaft (MF) | 3, Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) | 4, Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) | 5, Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) | 6, Übertragungsfehler (MF) | 7, Substitution aut idem/aut simile (MF) | 11, (Klare) Indikation, aber kein Medikament angeordnet (MF) | 12, Stellfehler (MF) | 13, Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) | 14, Doppelverordnung (MF)<div class=rich-text-field-label><p style=text-align: left;>AM: Arzneimittel</p></div> (10 x 1 numeric)
mrp_pi_grund_anw numeric (10),   -- 1, Applikation (Dauer) (MF) | 2, Inkompatibilität oder falsche Zubereitung (MF) | 3, Applikation (Art) (MF) | 4, Anfrage zur Administration/KompatibilitätANW: Anwendung (10 x 1 numeric)
mrp_pigrund_d numeric (10),   -- 1, Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) | 2, (Fehlerhafte) Dosis (MF) | 3, (Fehlende) Dosisanpassung (Organfunktion) (MF) | 4, (Fehlerhaftes) Dosisinterval (MF)D: Dosis (10 x 1 numeric)
mrp_pigrund_and numeric (10),   -- 1, Interaktion (MF) | 2, Kontraindikation (MF) | 3, Nebenwirkungen (10 x 1 numeric)
mrp_ip_klasse numeric (10),   -- 1, Drug - Drug | 2, Drug - Drug-Group | 3, Drug - Disease | 4, Drug - Labor | 5, Drug - Age (Priscus 2.0 o. Dosis)MRP-Klasse (INTERPOLAR) (10 x 1 numeric)
mrp_ip_klasse_disease varchar (200),   -- Disease (200 x 1 varchar)
mrp_ip_klasse_labor varchar (200),   -- Labor (200 x 1 varchar)
mrp_pigrund_s numeric (10),   -- 1, Beratung/Auswahl eines Arzneistoffs | 2, Beratung/Auswahl zur Dosierung eines Arzneistoffs | 3, Beschaffung/Kosten | 4, Keine Pause von AM, die prä-OP pausiert werden müssen (MF) | 5, Schulung/Beratung eines PatientenS: sonstiges (10 x 1 numeric)
mrp_massn_am numeric (10),   -- 1, Anweisung für die Applikation geben | 2, Arzneimittel ändern | 3, Arzneimittel stoppen/pausieren | 4, Arzneimittel neu ansetzen | 5, Dosierung ändern | 6, Formulierung ändern | 7, Hilfe bei Beschaffung | 8, Information an Arzt/Pflege | 9, Information an Patient | 10, TDM oder Laborkontrolle emfohlen<div class=rich-text-field-label><p>AM: Arzneimittel</p></div> (10 x 1 numeric)
mrp_massn_orga numeric (10),   -- 1, Aushändigung einer Information/eines Medikationsplans | 2, CIRS-/AMK-Meldung | 3, Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers | 4, Etablierung einer Doppelkontrolle | 5, Lieferantenwechsel | 6, Optimierung der internen und externene Kommunikation | 7, Prozessoptimierung/Etablierung einer SOP/VA | 8, Sensibilisierung/Schulung<div class=rich-text-field-label><p>ORGA: Organisatorisch</p></div> (10 x 1 numeric)
mrp_notiz varchar (1000),   -- Notiz (1000 x 1 varchar)
mrp_dokup_hand_emp_akz numeric (10),   -- 1, Arzt / Pflege informiert | 2, Intervention vorgeschlagen und umgesetzt | 3, Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation) | 4, Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung) | 5, Intervention vorgeschlagen, Umsetzung unbekannt | 6, Problem nicht gelöstHandlungsempfehlung akzeptiert? (10 x 1 numeric)
mrp_wiedervorlage numeric (10),   -- 1, Ja | 0, NeinMRP Wiedervorlage (10 x 1 numeric)
mrp_abschluss_dat varchar (200),   --  (200 x 1 varchar)
input_datetime timestamp not null default CURRENT_TIMESTAMP,   -- Zeitpunkt an dem der Datensatz eingefügt wird
last_check_datetime timestamp DEFAULT NULL,   -- Zeitpunkt an dem Datensatz zuletzt Überprüft wurde
current_dataset_status varchar(50) DEFAULT 'input'   -- Bearbeitungstatus des Datensatzes
);


--SQL Role / Trigger in Schema db_log
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_user;
GRANT SELECT ON TABLE db_log.patient_fe TO cds2db_user;
GRANT SELECT ON TABLE db_log.patient_fe TO db_log_user;
GRANT TRIGGER ON db_log.patient_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;

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

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_user;
GRANT SELECT ON TABLE db_log.fall_fe TO cds2db_user;
GRANT SELECT ON TABLE db_log.fall_fe TO db_log_user;
GRANT TRIGGER ON db_log.fall_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;

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

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_user;
GRANT SELECT ON TABLE db_log.medikationsanalyse_fe TO cds2db_user;
GRANT SELECT ON TABLE db_log.medikationsanalyse_fe TO db_log_user;
GRANT TRIGGER ON db_log.medikationsanalyse_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;


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


GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_user;
GRANT SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO cds2db_user;
GRANT SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT TRIGGER ON db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;


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

-- Comment on Table in Schema db_log
comment on column db_log.patient_fe.record_id is 'Record ID (200 x 1 200 - varchar)';
comment on column db_log.patient_fe.pat_id is 'Patient-identifier (200 x 1 200 - varchar)';
comment on column db_log.patient_fe.pat_name is 'Patientenname (200 x 1 200 - varchar)';
comment on column db_log.patient_fe.pat_vorname is 'Patientenvorname (200 x 1 200 - varchar)';
comment on column db_log.patient_fe.pat_gebdat is 'Geburtsdatum (200 x 1 200 - varchar)';
comment on column db_log.patient_fe.pat_aktuell_alter is '<div class="rich-text-field-label"><p>aktuelles Patientenalter (Jahre)</p></div> (200 x 1 200 - varchar)';
comment on column db_log.patient_fe.pat_geschlecht is '0, nicht bekannt | 1, weiblich | 2, männlich | 3, diversGeschlecht (10 x 1 10 - numeric)';

comment on column db_log.fall_fe.fall_id is 'Fall-ID (200 x 1 200 - varchar)';
comment on column db_log.fall_fe.fall_studienphase is '1, Usual Care (UC) | 2, Interventional Care (IC) | 3, Pilotphase (P)<div class="rich-text-field-label"><p><span style="color: #e03e2d;">Studienphase (wird wenn produktiv versteckt sein)</span></p></div> (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_station is '1, Station 1 | 2, Station 2 | 3, Station 3Station (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_aufn_dat is 'Aufnahmedatum (200 x 1 200 - varchar)';
comment on column db_log.fall_fe.fall_aufn_diag is '<div class="rich-text-field-label"><p><span style="color: #e03e2d;">Diagnose(n) bei Aufnahme (wird nur zum lesen sein)</span></p></div> (1000 x 1 1000 - varchar)';
comment on column db_log.fall_fe.fall_gewicht_kg_aktuell is 'aktuelles Gewicht (Kg) (500 x 1 500 - varchar)';
comment on column db_log.fall_fe.fall_groesse_cm is 'Größe (cm) (230 x 1 230 - varchar)';
comment on column db_log.fall_fe.fall_bmi is 'BMI (200 x 1 200 - varchar)';
comment on column db_log.fall_fe.fall_nieren_insuf_chron is '1, ja | 0, nein | -1, nicht bekanntChronische Niereninsuffizienz (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_nieren_insuf_ausmass is '1, Ausmaß unbekannt | 2, 45-59 ml/min/1,73 m2 | 3, 30-44 ml/min/1,73 m2 | 4, 15-29 ml/min/1,73 m2 | 5, < 15 ml/min/1,73 m2<div class="rich-text-field-label"><p>aktuelles Ausmaß</p></div> (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_nieren_insuf_dialysev is '1, Hämodialyse | 2, Kont. Hämofiltration | 3, Peritonealdialyse | 4, keineDialyseverfahren (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_leber_insuf is '1, ja | 0, nein | -1, nicht bekanntLeberinsuffizienz (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_leber_insuf_ausmass is '1, Ausmaß unbekannt | 2, Leicht (Child-Pugh A) | 3, Mittel (Child-Pugh B) | 4, Schwer (Child-Pugh C)aktuelles Ausmaß (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_schwanger_mo is '0, keine Schwangerschaft | 1, 1 | 2, 2 | 3, 3 | 4, 4 | 5, 5 | 6, 6 | 7, 7 | 8, 8 | 9, 9<div class="rich-text-field-label"><p><span style="color: #000000;">Schwangerschaftsmonat</span></p></div> (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_op_geplant is '1, ja | 0, nein | -1, nicht bekanntIst eine Operation geplant? (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_op_dat is 'Operationsdatum (200 x 1 200 - varchar)';
comment on column db_log.fall_fe.fall_status is '1, aktuell / neu | 2, nicht relevant | 3, verlegt<div class="rich-text-field-label"><p><span style="color: #e03e2d;"><span style="color: #000000;">Fallstatus:</span><br></span></p></div> (10 x 1 10 - numeric)';
comment on column db_log.fall_fe.fall_ent_dat is 'Entlassdatum (200 x 1 200 - varchar)';

comment on column db_log.medikationsanalyse_fe.meda_dat is 'Datum der Medikationsanalyse (200 x 1 200 - varchar)';
comment on column db_log.medikationsanalyse_fe.meda_typ is '1, Typ 1: Einfache | 2, Typ 2a: Erweiterte | 3, Typ 2b: Erweiterte | 4, Typ 3: Umfassende MedikationsanalyseTyp der Medikationsanalyse (10 x 1 10 - numeric)';
comment on column db_log.medikationsanalyse_fe.meda_risiko_pat is '1, Risikopatient | 2, Medikationsanalyse / Therapieüberwachung in 24-48hMarkieren als Risikopatient (10 x 1 10 - numeric)';
comment on column db_log.medikationsanalyse_fe.meda_aufwand_zeit is '0, <= 5 min | 1, 6-10 min | 2, 11-20 min | 3, 21-30 min | 4, >30 min | 5, Angabe abgelehntZeitaufwand Medikationsanalyse [Min] (10 x 1 10 - numeric)';
comment on column db_log.medikationsanalyse_fe.meda_aufwand_zeit_and is 'wie lange hat die Medikationsanalyse gedauert? Eingabe in Minuten.  (200 x 1 200 - varchar)';
comment on column db_log.medikationsanalyse_fe.meda_notiz is 'Notizfeld (1000 x 1 1000 - varchar)';

comment on column db_log.mrpdokumentation_validierung_fe.mrp_entd_dat is 'Datum des MRP (200 x 1 200 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_kurzbeschr is 'Kurzbeschreibung des MRPs (1000 x 1 1000 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_entd_algorithmisch is '1, Ja | 0, NeinMRP vom INTERPOLAR-Algorithmus entdeckt? (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber is '1, Apotheker*in (Station) | 2, Apotheker*in (UnitDose) | 3, Arzt / Ärztin | 4, Pflege | 5, Patient*in / Angehörige*r | 6, unbekannt | 7, andereHinweisgeber auf das MRP (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_gewissheit is '1, MRP bestätigt | 2, MRP möglich, weitere Informationen nötig | 3, MRP nicht bestätigtSicherheit des detektierten MRP (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl is '1, MRP sachlich falsch (keine Kontraindikation) | 2, MRP sachlich richtig, aber falsche Datengrundlage | 3, MRP sachlich richtig, aber klinisch nicht relevant | 4, MRP sachlich richtig, aber von Stationsapotheker vorher identifiziert | 5, SonstigesGrund für nicht Bestätigung (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_gewiss_grund_abl_sonst is 'Bitte näher beschreiben (200 x 1 200 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_wirkstoff is '1, Ja | 0, NeinWirkstoff betroffen? (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_atc1 is '7298, J05AF06 - Abacavir | 7299, H05AA04 - Abaloparatid | 7300, P03AX07 - Abametapir | 7301, L02BX01 - Abarelix | 7302, L04AA24 - Abatacept | 7303, B01AC13 - Abciximab | 7304, L01EF03 - Abemaciclib | 7305, L04AA22 - Abetimus | 7306, S01LA07 - Abicipar peg1. Medikament ATC / Name: (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_atc2 is '7298, J05AF06 - Abacavir | 7299, H05AA04 - Abaloparatid | 7300, P03AX07 - Abametapir | 7301, L02BX01 - Abarelix | 7302, L04AA24 - Abatacept | 7303, B01AC13 - Abciximab | 7304, L01EF03 - Abemaciclib | 7305, L04AA22 - Abetimus | 7306, S01LA07 - Abicipar peg2. Medikament ATC / Name (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_atc3 is '7298, J05AF06 - Abacavir | 7299, H05AA04 - Abaloparatid | 7300, P03AX07 - Abametapir | 7301, L02BX01 - Abarelix | 7302, L04AA24 - Abatacept | 7303, B01AC13 - Abciximab | 7304, L01EF03 - Abemaciclib | 7305, L04AA22 - Abetimus | 7306, S01LA07 - Abicipar peg3. Medikament ATC / Name (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_med_prod is '1, Ja | 0, NeinMedizinprodukt betroffen? (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_med_prod_sonst is 'Sonstigespräparat (200 x 1 200 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_dokup_fehler is '<div class="rich-text-field-label"><p>Frage / <span style="font-weight: normal;">Fehlerbeschreibung </span></p> <p><span style="font-weight: normal;">[mrp_kurzbeschr]</span></p></div> (200 x 1 200 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_dokup_intervention is '<div class="rich-text-field-label"><p>Intervention / <span style="font-weight: normal;">Vorschlag zur Fehlervermeldung</span></p></div> (200 x 1 200 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_pi_grund_am is '1, (Klare) Indikation nicht (mehr) gegeben (MF) | 2, Verordnung/Dokumentation unvollständig/fehlerhaft (MF) | 3, Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) | 4, Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) | 5, Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) | 6, Übertragungsfehler (MF) | 7, Substitution aut idem/aut simile (MF) | 11, (Klare) Indikation, aber kein Medikament angeordnet (MF) | 12, Stellfehler (MF) | 13, Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) | 14, Doppelverordnung (MF)<div class="rich-text-field-label"><p style="text-align: left;">AM: Arzneimittel</p></div> (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_pi_grund_anw is '1, Applikation (Dauer) (MF) | 2, Inkompatibilität oder falsche Zubereitung (MF) | 3, Applikation (Art) (MF) | 4, Anfrage zur Administration/KompatibilitätANW: Anwendung (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_pigrund_d is '1, Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) | 2, (Fehlerhafte) Dosis (MF) | 3, (Fehlende) Dosisanpassung (Organfunktion) (MF) | 4, (Fehlerhaftes) Dosisinterval (MF)D: Dosis (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_pigrund_and is '1, Interaktion (MF) | 2, Kontraindikation (MF) | 3, Nebenwirkungen (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse is '1, Drug - Drug | 2, Drug - Drug-Group | 3, Drug - Disease | 4, Drug - Labor | 5, Drug - Age (Priscus 2.0 o. Dosis)MRP-Klasse (INTERPOLAR) (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_disease is 'Disease (200 x 1 200 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_labor is 'Labor (200 x 1 200 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_pigrund_s is '1, Beratung/Auswahl eines Arzneistoffs | 2, Beratung/Auswahl zur Dosierung eines Arzneistoffs | 3, Beschaffung/Kosten | 4, Keine Pause von AM, die prä-OP pausiert werden müssen (MF) | 5, Schulung/Beratung eines PatientenS: sonstiges (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_massn_am is '1, Anweisung für die Applikation geben | 2, Arzneimittel ändern | 3, Arzneimittel stoppen/pausieren | 4, Arzneimittel neu ansetzen | 5, Dosierung ändern | 6, Formulierung ändern | 7, Hilfe bei Beschaffung | 8, Information an Arzt/Pflege | 9, Information an Patient | 10, TDM oder Laborkontrolle emfohlen<div class="rich-text-field-label"><p>AM: Arzneimittel</p></div> (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_massn_orga is '1, Aushändigung einer Information/eines Medikationsplans | 2, CIRS-/AMK-Meldung | 3, Einbindung anderer Berurfsgruppen z.B. des Stationsapothekers | 4, Etablierung einer Doppelkontrolle | 5, Lieferantenwechsel | 6, Optimierung der internen und externene Kommunikation | 7, Prozessoptimierung/Etablierung einer SOP/VA | 8, Sensibilisierung/Schulung<div class="rich-text-field-label"><p>ORGA: Organisatorisch</p></div> (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_notiz is 'Notiz (1000 x 1 1000 - varchar)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_dokup_hand_emp_akz is '1, Arzt / Pflege informiert | 2, Intervention vorgeschlagen und umgesetzt | 3, Intervention vorgeschlagen, nicht umgesetzt (keine Kooperation) | 4, Intervention vorgeschlagen, nicht umgesetzt (Nutzen-Risiko-Abwägung) | 5, Intervention vorgeschlagen, Umsetzung unbekannt | 6, Problem nicht gelöstHandlungsempfehlung akzeptiert? (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_wiedervorlage is '1, Ja | 0, NeinMRP Wiedervorlage (10 x 1 10 - numeric)';
comment on column db_log.mrpdokumentation_validierung_fe.mrp_abschluss_dat is ' (200 x 1 200 - varchar)';
