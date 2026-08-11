-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-06-18 14:50:31
-- Rights definition file size        : 13564 Byte
--
-- Create SQL Tables in Schema "db2frontend_out"
-- Create time: 2026-06-18 16:06:34
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  base/472_cre_view_fe_frontend_last_version.sql
-- TEMPLATE:  template_cre_view_frontend_last_version.sql
-- OWNER_USER:  db2frontend_user
-- OWNER_SCHEMA:  db2frontend_out
-- TAGS:
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _fe_last_version
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2frontend_user
-- COPY_FUNC_SCRIPTNAME:
-- COPY_FUNC_TEMPLATE:
-- COPY_FUNC_NAME:
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  _fe
-- SCHEMA_3:
-- TABLE_POSTFIX_3:
-- ########################################################################################################
DO $$
BEGIN
    IF EXISTS ( -- do migration
        SELECT
            1
        FROM
            db_config.db_parameter
        WHERE
            parameter_name = 'current_migration_flag'
            AND parameter_value = '1') THEN
        --------------------------------------------------------------------
        --Create View with last version data for typed tables for schema db2frontend_out
        ------------------------------------------------------------------------------------------------------------------
        -- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
        DO $innerview$
        BEGIN
            IF EXISTS ( -- do migration
                SELECT
                    1 s
                FROM
                    db_config.db_parameter
                WHERE
                    parameter_name = 'current_migration_flag'
                    AND parameter_value = '1') THEN
                IF EXISTS ( -- VIEW exists
                    SELECT
                        1 s
                    FROM
                        information_schema.columns
                    WHERE
                        table_schema = 'db2frontend_out'
                        AND table_name = 'v_patient_fe_last_version') THEN
                    DROP VIEW db2frontend_out.v_patient_fe_last_version;
            -- first drop the view
        END IF;
    -- DROP VIEW
    ----------------------------
    CREATE OR REPLACE VIEW db2frontend_out.v_patient_fe_last_version AS (
        SELECT
            o.*
        FROM
            db_log.patient_fe o
        WHERE (o.record_id, o.pat_id, o.last_processing_nr) IN (
            SELECT
                i.record_id,
                i.pat_id,
                MAX(i.last_processing_nr)
            FROM
                db_log.patient_fe i
            GROUP BY
                i.record_id,
                i.pat_id));
    GRANT SELECT ON db2frontend_out.v_patient_fe_last_version TO db2frontend_user;
    GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
    ----------------------------
END IF;
        -- do migration
END $innerview$;
    ------------------------------------------------------------------------------------------------------------------
    DO $innerview$
    BEGIN
        IF EXISTS ( -- do migration
            SELECT
                1 s
            FROM
                db_config.db_parameter
            WHERE
                parameter_name = 'current_migration_flag'
                AND parameter_value = '1') THEN
            IF EXISTS ( -- VIEW exists
                SELECT
                    1 s
                FROM
                    information_schema.columns
                WHERE
                    table_schema = 'db2frontend_out'
                    AND table_name = 'v_fall_fe_last_version') THEN
                DROP VIEW db2frontend_out.v_fall_fe_last_version;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_fall_fe_last_version AS (
            SELECT
                o.*
            FROM
                db_log.fall_fe o
            WHERE (o.record_id, o.fall_fhir_enc_id, o.last_processing_nr) IN (
                SELECT
                    i.record_id,
                    i.fall_fhir_enc_id,
                    MAX(i.last_processing_nr)
                FROM
                    db_log.fall_fe i
                GROUP BY
                    i.record_id,
                    i.fall_fhir_enc_id));
        GRANT SELECT ON db2frontend_out.v_fall_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
        ----------------------------
END IF;
        -- do migration
END $innerview$;
    ------------------------------------------------------------------------------------------------------------------
    DO $innerview$
    BEGIN
        IF EXISTS ( -- do migration
            SELECT
                1 s
            FROM
                db_config.db_parameter
            WHERE
                parameter_name = 'current_migration_flag'
                AND parameter_value = '1') THEN
            IF EXISTS ( -- VIEW exists
                SELECT
                    1 s
                FROM
                    information_schema.columns
                WHERE
                    table_schema = 'db2frontend_out'
                    AND table_name = 'v_medikationsanalyse_fe_last_version') THEN
                DROP VIEW db2frontend_out.v_medikationsanalyse_fe_last_version;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_medikationsanalyse_fe_last_version AS (
            SELECT
                o.*
            FROM
                db_log.medikationsanalyse_fe o
            WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (
                SELECT
                    i.record_id,
                    i.redcap_repeat_instance,
                    MAX(i.last_processing_nr)
                FROM
                    db_log.medikationsanalyse_fe i
                GROUP BY
                    i.record_id,
                    i.redcap_repeat_instance));
        GRANT SELECT ON db2frontend_out.v_medikationsanalyse_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
        ----------------------------
END IF;
        -- do migration
END $innerview$;
    ------------------------------------------------------------------------------------------------------------------
    DO $innerview$
    BEGIN
        IF EXISTS ( -- do migration
            SELECT
                1 s
            FROM
                db_config.db_parameter
            WHERE
                parameter_name = 'current_migration_flag'
                AND parameter_value = '1') THEN
            IF EXISTS ( -- VIEW exists
                SELECT
                    1 s
                FROM
                    information_schema.columns
                WHERE
                    table_schema = 'db2frontend_out'
                    AND table_name = 'v_mrpdokumentation_validierung_fe_last_version') THEN
                DROP VIEW db2frontend_out.v_mrpdokumentation_validierung_fe_last_version;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_mrpdokumentation_validierung_fe_last_version AS (
            SELECT
                o.*
            FROM
                db_log.mrpdokumentation_validierung_fe o
            WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (
                SELECT
                    i.record_id,
                    i.redcap_repeat_instance,
                    MAX(i.last_processing_nr)
                FROM
                    db_log.mrpdokumentation_validierung_fe i
                GROUP BY
                    i.record_id,
                    i.redcap_repeat_instance));
        GRANT SELECT ON db2frontend_out.v_mrpdokumentation_validierung_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
        ----------------------------
END IF;
        -- do migration
END $innerview$;
    ------------------------------------------------------------------------------------------------------------------
    DO $innerview$
    BEGIN
        IF EXISTS ( -- do migration
            SELECT
                1 s
            FROM
                db_config.db_parameter
            WHERE
                parameter_name = 'current_migration_flag'
                AND parameter_value = '1') THEN
            IF EXISTS ( -- VIEW exists
                SELECT
                    1 s
                FROM
                    information_schema.columns
                WHERE
                    table_schema = 'db2frontend_out'
                    AND table_name = 'v_retrolektive_mrpbewertung_fe_last_version') THEN
                DROP VIEW db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version AS (
            SELECT
                o.*
            FROM
                db_log.retrolektive_mrpbewertung_fe o
            WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (
                SELECT
                    i.record_id,
                    i.redcap_repeat_instance,
                    MAX(i.last_processing_nr)
                FROM
                    db_log.retrolektive_mrpbewertung_fe i
                GROUP BY
                    i.record_id,
                    i.redcap_repeat_instance));
        GRANT SELECT ON db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
        ----------------------------
END IF;
        -- do migration
END $innerview$;
    ------------------------------------------------------------------------------------------------------------------
    DO $innerview$
    BEGIN
        IF EXISTS ( -- do migration
            SELECT
                1 s
            FROM
                db_config.db_parameter
            WHERE
                parameter_name = 'current_migration_flag'
                AND parameter_value = '1') THEN
            IF EXISTS ( -- VIEW exists
                SELECT
                    1 s
                FROM
                    information_schema.columns
                WHERE
                    table_schema = 'db2frontend_out'
                    AND table_name = 'v_risikofaktor_fe_last_version') THEN
                DROP VIEW db2frontend_out.v_risikofaktor_fe_last_version;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_risikofaktor_fe_last_version AS (
            SELECT
                o.*
            FROM
                db_log.risikofaktor_fe o
            WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (
                SELECT
                    i.record_id,
                    i.redcap_repeat_instance,
                    MAX(i.last_processing_nr)
                FROM
                    db_log.risikofaktor_fe i
                GROUP BY
                    i.record_id,
                    i.redcap_repeat_instance));
        GRANT SELECT ON db2frontend_out.v_risikofaktor_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
        ----------------------------
END IF;
        -- do migration
END $innerview$;
    ------------------------------------------------------------------------------------------------------------------
    DO $innerview$
    BEGIN
        IF EXISTS ( -- do migration
            SELECT
                1 s
            FROM
                db_config.db_parameter
            WHERE
                parameter_name = 'current_migration_flag'
                AND parameter_value = '1') THEN
            IF EXISTS ( -- VIEW exists
                SELECT
                    1 s
                FROM
                    information_schema.columns
                WHERE
                    table_schema = 'db2frontend_out'
                    AND table_name = 'v_trigger_fe_last_version') THEN
                DROP VIEW db2frontend_out.v_trigger_fe_last_version;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2frontend_out.v_trigger_fe_last_version AS (
            SELECT
                o.*
            FROM
                db_log.trigger_fe o
            WHERE (o.record_id, o.redcap_repeat_instance, o.last_processing_nr) IN (
                SELECT
                    i.record_id,
                    i.redcap_repeat_instance,
                    MAX(i.last_processing_nr)
                FROM
                    db_log.trigger_fe i
                GROUP BY
                    i.record_id,
                    i.redcap_repeat_instance));
        GRANT SELECT ON db2frontend_out.v_trigger_fe_last_version TO db2frontend_user;
        GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
        ----------------------------
END IF;
        -- do migration
END $innerview$;
    ------------------------------------------------------------------------------------------------------------------
    --SQL Column Comments for Views in Schema db2frontend_out
    -------- COMMENTS db2frontend_out.v_patient_fe_last_version ------------
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.projekt_versionsnummer IS 'Versionsnummer zum Matching von REDCap-Projektversion mit weiteren Versionselementen der Toolchain (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_id IS 'Patient-identifier (FHIR) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_cis_pid IS 'Patient-identifier (KIS) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_name IS 'Patientenname (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_vorname IS 'Patientenvorname (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_gebdat IS 'Geburtsdatum (date)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_aktuell_alter IS 'aktuelles Patientenalter (Jahre) (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_geschlecht IS 'Geschlecht (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.pat_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_patient_fe_last_version.patient_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
    -------- COMMENTS db2frontend_out.v_fall_fe_last_version ------------
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.db_filter_8 IS 'Dashboard Filter 8 (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_fhir_enc_id IS 'verstecktes Feld für FHIR-ID des Encounters (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.patient_id_fk IS 'verstecktes Feld für patient_id_fk (int)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_pat_id IS 'verstecktes Feld für fall_pat_id (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_id IS 'Fall-ID Encounter-Identifier (KIS) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_studienphase IS 'Studienphase (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_station IS 'Station (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_aufn_dat IS 'Aufnahmedatum (timestamp)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_zimmernr IS 'Zimmer-Nr. (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_aufn_diag IS 'Diagnose(n) bei Aufnahme (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_gewicht_aktuell IS 'aktuelles Gewicht (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_gewicht_aktl_einheit IS 'aktuelles Gewicht: Einheit (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_groesse IS 'Größe (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_groesse_einheit IS 'Größe: Einheit (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_bmi IS 'BMI (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_status IS 'Fallstatus (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_ent_dat IS 'Entlassdatum (timestamp)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_fall_fe_last_version.fall_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
    -------- COMMENTS db2frontend_out.v_medikationsanalyse_fe_last_version ------------
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.db_filter_5 IS 'Dashboard Filter 5 (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.db_filter_7 IS 'Dashboard Filter 7 (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_anlage IS 'Formular angelegt von (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_edit IS 'Formular zuletzt bearbeitet von (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.fall_meda_id IS '1 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu Fall (Fall-ID Encounter-Identifier (KIS)) Auswahlfeld falls die aktuell dokumentierte Medikationsanalyse sich nicht auf die letzte Instanz des Falls bezieht.   (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_id IS 'ID Medikationsanalyse (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse aggregiert (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_typ IS 'Typ der Medikationsanalyse (MA) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_dat IS 'Datum der Medikationsanalyse (timestamp)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_gewicht_aktuell IS 'aktuelles Gewicht (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_gewicht_aktl_einheit IS 'aktuelles Gewicht: Einheit (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_groesse IS 'Größe (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_groesse_einheit IS 'Größe: Einheit (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_bmi IS 'BMI (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_nieren_insuf_chron IS 'Chronische Niereninsuffizienz (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_nieren_insuf_ausmass IS 'aktuelles Ausmaß (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_nieren_insuf_dialysev IS 'Nierenersatzverfahren (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_leber_insuf IS 'Leberinsuffizienz (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_leber_insuf_ausmass IS 'aktuelles Ausmaß (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_schwanger_mo IS 'Schwangerschaftsmonat (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_ma_thueberw IS 'Wiedervorlage Medikationsanalyse in 24-48h (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_mrp_detekt IS 'MRP detektiert? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_aufwand_zeit IS 'Zeitaufwand Medikationsanalyse (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_aufwand_zeit_and IS 'genaue Dauer in Minuten (int)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_notiz IS 'Notizfeld (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.meda_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_medikationsanalyse_fe_last_version.medikationsanalyse_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
    -------- COMMENTS db2frontend_out.v_mrpdokumentation_validierung_fe_last_version ------------
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.db_filter_6 IS 'Dashboard Filter 6 (double precision)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_anlage IS 'Formular angelegt von (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_edit IS 'Formular zuletzt bearbeitet von (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_meda_id IS '2 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu MRP   Auswahlfeld falls die aktuell dokumentiertes MRP  sich nicht auf die letzte Instanz der Medikationsanalyse bezieht.   (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_id IS 'MRP-ID (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse und der Instanz des aktuellen MRP aggregiert (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_entd_dat IS 'Datum des MRP (timestamp)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_entd_algorithmisch IS 'MRP vom INTERPOLAR-Algorithmus entdeckt? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_kurzbeschr IS 'Kurzbeschreibung des MRPs* (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_hinweisgeber IS 'Hinweisgeber auf das MRP (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_hinweisgeber_oth IS 'Anderer Hinweisgeber (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_wirkstoff IS 'Wirkstoff betroffen? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc1 IS '1. Medikament ATC / Name: (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc2 IS '2. Medikament ATC / Name (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc3 IS '3. Medikament ATC / Name (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc4 IS '4. Medikament ATC / Name (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc5 IS '5. Medikament ATC / Name (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc1_2026 IS '1. Medikament ATC / Name*: (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc2_2026 IS '2. Medikament ATC / Name: (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc3_2026 IS '3. Medikament ATC / Name: (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc4_2026 IS '4. Medikament ATC / Name: (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_atc5_2026 IS '5. Medikament ATC / Name: (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_med_prod IS 'Medizinprodukt betroffen? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_med_prod_sonst IS 'Bezeichnung Präparat (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_dokup_fehler IS 'Frage / Fehlerbeschreibung  (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_dokup_intervention IS 'Intervention / Vorschlag zur Fehlervermeldung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___1 IS '1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___2 IS '2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___3 IS '3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___4 IS '4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___5 IS '5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___6 IS '6 - AM: Übertragungsfehler (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___7 IS '7 - AM: Substitution aut idem/aut simile (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___8 IS '8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___9 IS '9 - AM: Stellfehler (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___10 IS '10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___11 IS '11 - AM: Doppelverordnung (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___12 IS '12 - ANW: Applikation (Dauer) (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___13 IS '13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___14 IS '14 - ANW: Applikation (Art) (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___15 IS '15 - ANW: Anfrage zur Administration/Kompatibilität (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___16 IS '16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___17 IS '17 - D: (Fehlerhafte) Dosis (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___18 IS '18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___19 IS '19 - D: (Fehlerhaftes) Dosisinterval (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___20 IS '20 - Interaktion (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___21 IS '21 - Kontraindikation (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___22 IS '22 - Nebenwirkungen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___23 IS '23 - S: Beratung/Auswahl eines Arzneistoffs (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___24 IS '24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___25 IS '25 - S: Beschaffung/Kosten (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___26 IS '26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_pigrund___27 IS '27 - S: Schulung/Beratung eines Patienten (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_ip_klasse_01 IS 'MRP-Klasse (INTERPOLAR) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_ip_klasse_disease IS 'Disease (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_ip_klasse_labor IS 'Labor (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_ip_klasse_nieren_insuf IS 'Grad der Nierenfunktionseinschränkung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___1 IS '1 - Anweisung für die Applikation geben (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___2 IS '2 - Arzneimittel ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___5 IS '5 - Dosierung ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___6 IS '6 - Formulierung ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___7 IS '7 - Hilfe bei Beschaffung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___8 IS '8 - Information an Arzt/Pflege (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___9 IS '9 - Information an Patient (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_am___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___5 IS '5 - Lieferantenwechsel (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_massn_orga___8 IS '8 - Sensibilisierung/Schulung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_notiz IS 'Notiz (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_dokup_hand_emp_akz IS 'Handlungsempfehlung akzeptiert? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_merp IS 'NCC MERP Score (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_merp_info___1 IS '1 - NCC MERP Index anzeigen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrp_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_mrpdokumentation_validierung_fe_last_version.mrpdokumentation_validierung_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
    -------- COMMENTS db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version ------------
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_bewerter1 IS '1. Bewertung von (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_id IS 'Retrolektive MRP-ID (REDCap) Hier wird die vom Datenprozessor MEDA-ID-r-Instanz aggregiert. (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_meda_id IS 'Zuordnung Meda -> rMRP (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_meda_dat_referenz IS 'Referenzdatum der Medikationsanalyse (timestamp)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_meda_dat1 IS 'Datum der retrolektiven Bewertung* (timestamp)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_kurzbeschr IS 'Kurzbeschreibung des MRPs (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_ip_klasse_01 IS 'MRP-Klasse (INTERPOLAR) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_atc1 IS '1. Medikament ATC / Name: (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_atc2 IS '2. Medikament ATC / Name (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_ip_klasse_disease IS 'Disease (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_ip_klasse_labor IS 'Labor (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_ip_klasse_nieren_insuf IS 'Grad der Nierenfunktionseinschränkung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewissheit1 IS 'Bewertung des detektierten MRP* (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_mrp_zuordnung1 IS 'Zuordnung zu manuellem MRP (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewissheit1_oth IS 'Weitere Informationen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund1_abl IS 'Grund für nicht Bestätigung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund1_abl_01 IS 'Grund für nicht Bestätigung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger1_falsch___1 IS '1 - ret_atc1 (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger1_falsch___2 IS '2 - ret_atc2 (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger1_falsch___3 IS '3 - ret_ip_klasse_disease (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger1_falsch___4 IS '4 - ret_ip_klasse_nieren_insuf (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_1___1 IS '1 - Der Indikator (bzw. alle Indikatoren - falls mehrere) liegt nicht wie in der Kurzbeschreibung angezeigt im EMR vor (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_1___2 IS '2 - Indikator/Indikatoren zum Zeitpunkt der Medikationsanalyse nicht gültig (z.B. pausiert - inaktiv - Fehldiagnose) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_1___3 IS '3 - Zusätzliche Informationen nicht berücksichtigt (z.B. aus Briefen - sonstigen Systemen) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_1___4 IS '4 - Anderer Fehler (bitte näher erläutern) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_2___1 IS '1 - Der Indikator (bzw. alle Indikatoren - falls mehrere) liegt nicht wie in der Kurzbeschreibung angezeigt im EMR vor (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_2___2 IS '2 - Indikator/Indikatoren zum Zeitpunkt der Medikationsanalyse nicht gültig (z.B. pausiert - inaktiv - Fehldiagnose) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_2___3 IS '3 - Zusätzliche Informationen nicht berücksichtigt (z.B. aus Briefen - sonstigen Systemen) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_2___4 IS '4 - Anderer Fehler (bitte näher erläutern) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_1_oth IS 'Kommentar (1. Trigger) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl1_2_oth IS 'Kommentar (2. Trigger) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_mrpkonzept1 IS 'WELCHE Indikatoren sind zu unspezifisch für den MRP-Trigger und warum? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund_abl_sonst1 IS 'Bitte näher beschreiben (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund_abl_klin1 IS 'WARUM ist das MRP nicht klinisch relevant? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund_abl_klin1_neg___1 IS '1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___1 IS '1 - Anweisung für die Applikation geben (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___2 IS '2 - Arzneimittel ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___5 IS '5 - Dosierung ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___6 IS '6 - Formulierung ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___7 IS '7 - Hilfe bei Beschaffung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___8 IS '8 - Information an Arzt/Pflege (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___9 IS '9 - Information an Patient (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am1___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___5 IS '5 - Lieferantenwechsel (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga1___8 IS '8 - Sensibilisierung/Schulung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_notiz1 IS 'Notiz (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_meda_dat2 IS 'Datum der retrolektiven Betrachtung* (timestamp)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_2ndbewertung___1 IS '1 - 2nd Look / Zweite MRP-Bewertung durchführen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_bewerter2 IS '2. Bewertung von (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_bewerter3 IS ' (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_bewerter2_pipeline IS ' (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewissheit2 IS 'Bewertung des detektierten MRP* (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_mrp_zuordnung2 IS 'Zuordnung zu manuellem MRP (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewissheit2_oth IS 'Weitere Informationen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund2_abl IS 'Grund für nicht Bestätigung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund2_abl_01 IS 'Grund für nicht Bestätigung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund_abl_sonst2 IS 'Bitte näher beschreiben (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger2_falsch___1 IS '1 - ret_atc1 (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger2_falsch___2 IS '2 - ret_atc2 (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger2_falsch___3 IS '3 - ret_ip_klasse_disease (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_trigger2_falsch___4 IS '4 - ret_ip_klasse_nieren_insuf (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_1___1 IS '1 - Der Indikator (bzw. alle Indikatoren - falls mehrere) liegt nicht wie in der Kurzbeschreibung angezeigt im EMR vor (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_1___2 IS '2 - Indikator/Indikatoren zum Zeitpunkt der Medikationsanalyse nicht gültig (z.B. pausiert - inaktiv - Fehldiagnose) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_1___3 IS '3 - Zusätzliche Informationen nicht berücksichtigt (z.B. aus Briefen - sonstigen Systemen) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_1___4 IS '4 - Anderer Fehler (bitte näher erläutern) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_2___1 IS '1 - Der Indikator (bzw. alle Indikatoren - falls mehrere) liegt nicht wie in der Kurzbeschreibung angezeigt im EMR vor (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_2___2 IS '2 - Indikator/Indikatoren zum Zeitpunkt der Medikationsanalyse nicht gültig (z.B. pausiert - inaktiv - Fehldiagnose) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_2___3 IS '3 - Zusätzliche Informationen nicht berücksichtigt (z.B. aus Briefen - sonstigen Systemen) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_2___4 IS '4 - Anderer Fehler (bitte näher erläutern) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_1_oth IS 'Kommentar (1. Trigger) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_datengrundl2_2_oth IS 'Kommentar (2. Trigger) (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_mrpkonzept2 IS 'WELCHE Indikatoren sind zu unspezifisch für den MRP-Trigger und warum? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund_abl_klin2 IS 'WARUM ist das MRP nicht klinisch relevant? (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_gewiss_grund_abl_klin2_neg___1 IS '1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___1 IS '1 - Anweisung für die Applikation geben (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___2 IS '2 - Arzneimittel ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___5 IS '5 - Dosierung ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___6 IS '6 - Formulierung ändern (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___7 IS '7 - Hilfe bei Beschaffung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___8 IS '8 - Information an Arzt/Pflege (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___9 IS '9 - Information an Patient (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_am2___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___5 IS '5 - Lieferantenwechsel (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_massn_orga2___8 IS '8 - Sensibilisierung/Schulung (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_notiz2 IS 'Notiz (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.ret_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_retrolektive_mrpbewertung_fe_last_version.retrolektive_mrpbewertung_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
    -------- COMMENTS db2frontend_out.v_risikofaktor_fe_last_version ------------
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_gerhemmer IS 'Ger.hemmer (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_tah IS 'TAH (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_immunsupp IS 'Immunsupp. (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_tumorth IS 'Tumorth. (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_opiat IS 'Opiat (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_atcn IS 'ATC N (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_ait IS 'AIT (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_anzam IS 'Anz AM (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_priscus IS 'PRISCUS (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_qtc IS 'QTc (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_meld IS 'MELD (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_dialyse IS 'Dialyse (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.rskfk_entern IS 'ent. Ern. (int)';
    COMMENT ON COLUMN db2frontend_out.v_risikofaktor_fe_last_version.risikofaktor_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
    -------- COMMENTS db2frontend_out.v_trigger_fe_last_version ------------
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_ast IS 'AST↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_alt IS 'ALT↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_crp IS 'CRP↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_leuk_penie IS 'Leuko↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_leuk_ose IS 'Leuko↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_thrmb_penie IS 'Thrombo↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_aptt IS 'aPTT (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hyp_haem IS 'Hb↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hypo_glyk IS 'Glc↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hyper_glyk IS 'Glc↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hyper_bilirbnm IS 'Bili↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_ck IS 'CK↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hypo_serablmn IS 'Alb↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hypo_nat IS 'Na+↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hyper_nat IS 'Na+↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hyper_kal IS 'K+↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_hypo_kal IS 'K+↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_inr_ern IS 'INR Antikoag↓ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_inr_erh IS 'INR ↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_inr_erh_antikoa IS 'INR Antikoag↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_krea IS 'Krea↑ (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trg_egfr IS 'eGFR<30 (int)';
    COMMENT ON COLUMN db2frontend_out.v_trigger_fe_last_version.trigger_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
    --------------------------------------------------------------------
END IF;
    -- do migration
END
$$;
