-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-06-18 14:50:31
-- Rights definition file size        : 13564 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2026-06-18 16:06:10
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/190_cre_view_typ_dataproc_last_import.sql
-- TEMPLATE:  template_cre_view_last_import.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _last_import
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  db2dataprocessor_user
-- COPY_FUNC_SCRIPTNAME:
-- COPY_FUNC_TEMPLATE:
-- COPY_FUNC_NAME:
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:
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
        --Create View for frontend tables for schema db2dataprocessor_out
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
                        table_schema = 'db2dataprocessor_out'
                        AND table_name = 'v_encounter_last_import') THEN
                    DROP VIEW db2dataprocessor_out.v_encounter_last_import;
            -- first drop the view
        END IF;
    -- DROP VIEW
    ----------------------------
    CREATE OR REPLACE VIEW db2dataprocessor_out.v_encounter_last_import AS (
        SELECT
            *
        FROM
            db_log.encounter
        WHERE
            TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                SELECT
                    TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                FROM
                    db_log.encounter));
    ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_patient_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_patient_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_patient_last_import AS (
            SELECT
                *
            FROM
                db_log.patient
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.patient));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_condition_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_condition_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_condition_last_import AS (
            SELECT
                *
            FROM
                db_log.condition
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.condition));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_medication_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_medication_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_medication_last_import AS (
            SELECT
                *
            FROM
                db_log.medication
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.medication));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_medicationrequest_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_medicationrequest_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationrequest_last_import AS (
            SELECT
                *
            FROM
                db_log.medicationrequest
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.medicationrequest));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_medicationadministration_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_medicationadministration_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationadministration_last_import AS (
            SELECT
                *
            FROM
                db_log.medicationadministration
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.medicationadministration));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_medicationstatement_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_medicationstatement_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_medicationstatement_last_import AS (
            SELECT
                *
            FROM
                db_log.medicationstatement
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.medicationstatement));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_observation_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_observation_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_observation_last_import AS (
            SELECT
                *
            FROM
                db_log.observation
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.observation));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_diagnosticreport_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_diagnosticreport_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_diagnosticreport_last_import AS (
            SELECT
                *
            FROM
                db_log.diagnosticreport
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.diagnosticreport));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_servicerequest_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_servicerequest_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_servicerequest_last_import AS (
            SELECT
                *
            FROM
                db_log.servicerequest
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.servicerequest));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_procedure_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_procedure_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_procedure_last_import AS (
            SELECT
                *
            FROM
                db_log.procedure
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.procedure));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_consent_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_consent_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_consent_last_import AS (
            SELECT
                *
            FROM
                db_log.consent
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.consent));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_location_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_location_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_location_last_import AS (
            SELECT
                *
            FROM
                db_log.location
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.location));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
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
                    table_schema = 'db2dataprocessor_out'
                    AND table_name = 'v_pids_per_ward_last_import') THEN
                DROP VIEW db2dataprocessor_out.v_pids_per_ward_last_import;
        -- first drop the view
    END IF;
        -- DROP VIEW
        ----------------------------
        CREATE OR REPLACE VIEW db2dataprocessor_out.v_pids_per_ward_last_import AS (
            SELECT
                *
            FROM
                db_log.pids_per_ward
            WHERE
                TO_CHAR(COALESCE(last_check_datetime, input_datetime), 'YYYY-MM-DD HH24:MI:SS') IN (
                    SELECT
                        TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)), 'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        db_log.pids_per_ward));
        ----------------------------
END IF;
        -- do migration
END $innerview$;
    --SQL Column Comments for Views in Schema db2dataprocessor_out
    -------- COMMENTS db2dataprocessor_out.v_encounter_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_partof_ref IS 'partOf/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_partof_calculated_ref IS 'partOf/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_main_encounter_calculated_ref IS 'main/encounter/calculated/ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_class_system IS 'class/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_class_version IS 'class/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_class_code IS 'class/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_class_display IS 'class/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_type_system IS 'type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_type_version IS 'type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_type_code IS 'type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_type_display IS 'type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_type_text IS 'type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_servicetype_system IS 'serviceType/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_servicetype_version IS 'serviceType/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_servicetype_code IS 'serviceType/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_servicetype_display IS 'serviceType/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_servicetype_text IS 'serviceType/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_period_start IS 'period/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_period_end IS 'period/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_condition_ref IS 'diagnosis/condition/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_condition_calculated_ref IS 'diagnosis/condition/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_use_system IS 'diagnosis/use/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_use_version IS 'diagnosis/use/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_use_code IS 'diagnosis/use/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_use_display IS 'diagnosis/use/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_use_text IS 'diagnosis/use/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_diagnosis_rank IS 'diagnosis/rank (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_admitsource_system IS 'hospitalization/admitSource/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_admitsource_version IS 'hospitalization/admitSource/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_admitsource_code IS 'hospitalization/admitSource/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_admitsource_display IS 'hospitalization/admitSource/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_admitsource_text IS 'hospitalization/admitSource/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_dischargedisposition_system IS 'hospitalization/dischargeDisposition/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_dischargedisposition_version IS 'hospitalization/dischargeDisposition/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_dischargedisposition_code IS 'hospitalization/dischargeDisposition/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_dischargedisposition_display IS 'hospitalization/dischargeDisposition/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_hospitalization_dischargedisposition_text IS 'hospitalization/dischargeDisposition/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_ref IS 'location/location/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_type IS 'location/location/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_use IS 'location/location/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_type_system IS 'location/location/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_type_version IS 'location/location/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_type_code IS 'location/location/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_type_display IS 'location/location/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_type_text IS 'location/location/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_system IS 'location/location/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_identifier_value IS 'location/location/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_display IS 'location/location/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_status IS 'location/status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_physicaltype_system IS 'location/physicalType/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_physicaltype_version IS 'location/physicalType/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_physicaltype_code IS 'location/physicalType/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_physicaltype_display IS 'location/physicalType/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_location_physicaltype_text IS 'location/physicalType/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_ref IS 'serviceProvider/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_type IS 'serviceProvider/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_use IS 'serviceProvider/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_type_system IS 'serviceProvider/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_type_version IS 'serviceProvider/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_type_code IS 'serviceProvider/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_type_display IS 'serviceProvider/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_type_text IS 'serviceProvider/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_system IS 'serviceProvider/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_identifier_value IS 'serviceProvider/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_encounter_last_import.enc_serviceprovider_display IS 'serviceProvider/display (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_patient_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_name_use IS 'name/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_name_text IS 'name/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_name_family IS 'name/family (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_name_given IS 'name/given (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_gender IS 'gender (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_birthdate IS 'birthDate (date)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_deceaseddatetime IS 'deceasedDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_patient_last_import.pat_address_postalcode IS 'address/postalCode (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_condition_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_encounter_ref IS 'encounter/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_encounter_calculated_ref IS 'encounter/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_clinicalstatus_system IS 'clinicalStatus/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_clinicalstatus_version IS 'clinicalStatus/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_clinicalstatus_code IS 'clinicalStatus/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_clinicalstatus_display IS 'clinicalStatus/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_clinicalstatus_text IS 'clinicalStatus/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_verificationstatus_system IS 'verificationStatus/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_verificationstatus_version IS 'verificationStatus/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_verificationstatus_code IS 'verificationStatus/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_verificationstatus_display IS 'verificationStatus/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_verificationstatus_text IS 'verificationStatus/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_severity_system IS 'severity/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_severity_version IS 'severity/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_severity_code IS 'severity/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_severity_display IS 'severity/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_severity_text IS 'severity/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_code_system IS 'code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_code_version IS 'code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_code_code IS 'code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_code_display IS 'code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_code_text IS 'code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_bodysite_system IS 'bodySite/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_bodysite_version IS 'bodySite/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_bodysite_code IS 'bodySite/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_bodysite_display IS 'bodySite/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_bodysite_text IS 'bodySite/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_onsetperiod_start IS 'onsetPeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_onsetperiod_end IS 'onsetPeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_onsetdatetime IS 'onsetDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementdatetime IS 'abatementDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementage_value IS 'abatementAge/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementage_comparator IS 'abatementAge/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementage_unit IS 'abatementAge/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementage_system IS 'abatementAge/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementage_code IS 'abatementAge/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementperiod_start IS 'abatementPeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementperiod_end IS 'abatementPeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_low_value IS 'abatementRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_low_unit IS 'abatementRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_low_system IS 'abatementRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_low_code IS 'abatementRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_high_value IS 'abatementRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_high_unit IS 'abatementRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_high_system IS 'abatementRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementrange_high_code IS 'abatementRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_abatementstring IS 'abatementString (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recordeddate IS 'recordedDate (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_ref IS 'recorder/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_type IS 'recorder/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_use IS 'recorder/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_type_system IS 'recorder/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_type_version IS 'recorder/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_type_code IS 'recorder/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_type_display IS 'recorder/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_type_text IS 'recorder/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_system IS 'recorder/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_identifier_value IS 'recorder/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_recorder_display IS 'recorder/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_ref IS 'asserter/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_type IS 'asserter/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_use IS 'asserter/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_type_system IS 'asserter/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_type_version IS 'asserter/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_type_code IS 'asserter/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_type_display IS 'asserter/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_type_text IS 'asserter/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_system IS 'asserter/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_identifier_value IS 'asserter/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_asserter_display IS 'asserter/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_summary_system IS 'stage/summary/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_summary_version IS 'stage/summary/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_summary_code IS 'stage/summary/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_summary_display IS 'stage/summary/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_summary_text IS 'stage/summary/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_ref IS 'stage/assessment/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_type IS 'stage/assessment/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_use IS 'stage/assessment/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_type_system IS 'stage/assessment/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_type_version IS 'stage/assessment/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_type_code IS 'stage/assessment/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_type_display IS 'stage/assessment/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_type_text IS 'stage/assessment/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_system IS 'stage/assessment/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_identifier_value IS 'stage/assessment/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_assessment_display IS 'stage/assessment/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_type_system IS 'stage/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_type_version IS 'stage/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_type_code IS 'stage/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_type_display IS 'stage/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_stage_type_text IS 'stage/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorstring IS 'note/authorString (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_type IS 'note/authorReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_system IS 'note/authorReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_identifier_value IS 'note/authorReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_authorreference_display IS 'note/authorReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_time IS 'note/time (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_condition_last_import.con_note_text IS 'note/text (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_medication_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_code_system IS 'code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_code_version IS 'code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_code_code IS 'code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_code_display IS 'code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_code_text IS 'code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_form_system IS 'form/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_form_version IS 'form/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_form_code IS 'form/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_form_display IS 'form/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_form_text IS 'form/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_numerator_value IS 'amount/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_numerator_comparator IS 'amount/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_numerator_unit IS 'amount/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_numerator_system IS 'amount/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_numerator_code IS 'amount/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_denominator_value IS 'amount/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_denominator_comparator IS 'amount/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_denominator_unit IS 'amount/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_denominator_system IS 'amount/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_amount_denominator_code IS 'amount/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_numerator_value IS 'ingredient/strength/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_numerator_comparator IS 'ingredient/strength/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_numerator_unit IS 'ingredient/strength/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_numerator_system IS 'ingredient/strength/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_numerator_code IS 'ingredient/strength/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_denominator_value IS 'ingredient/strength/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_denominator_comparator IS 'ingredient/strength/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_denominator_unit IS 'ingredient/strength/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_denominator_system IS 'ingredient/strength/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_strength_denominator_code IS 'ingredient/strength/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemcodeableconcept_system IS 'ingredient/itemCodeableConcept/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemcodeableconcept_version IS 'ingredient/itemCodeableConcept/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemcodeableconcept_code IS 'ingredient/itemCodeableConcept/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemcodeableconcept_display IS 'ingredient/itemCodeableConcept/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemcodeableconcept_text IS 'ingredient/itemCodeableConcept/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_ref IS 'ingredient/itemReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_type IS 'ingredient/itemReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_use IS 'ingredient/itemReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_type_system IS 'ingredient/itemReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_type_version IS 'ingredient/itemReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_type_code IS 'ingredient/itemReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_type_display IS 'ingredient/itemReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_type_text IS 'ingredient/itemReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_system IS 'ingredient/itemReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_identifier_value IS 'ingredient/itemReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_itemreference_display IS 'ingredient/itemReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medication_last_import.med_ingredient_isactive IS 'ingredient/isActive (boolean)';
    -------- COMMENTS db2dataprocessor_out.v_medicationrequest_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_encounter_ref IS 'encounter/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_encounter_calculated_ref IS 'encounter/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_medicationreference_ref IS 'medicationReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_statusreason_system IS 'statusReason/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_statusreason_version IS 'statusReason/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_statusreason_code IS 'statusReason/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_statusreason_display IS 'statusReason/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_statusreason_text IS 'statusReason/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_intend IS 'intend (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_intent IS 'intent (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_priority IS 'priority (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedboolean IS 'reportedBoolean (boolean)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_ref IS 'reportedReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_type IS 'reportedReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_use IS 'reportedReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_type_system IS 'reportedReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_type_version IS 'reportedReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_type_code IS 'reportedReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_type_display IS 'reportedReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_type_text IS 'reportedReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_system IS 'reportedReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_identifier_value IS 'reportedReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reportedreference_display IS 'reportedReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_ref IS 'supportingInformation/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_type IS 'supportingInformation/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_use IS 'supportingInformation/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_type_system IS 'supportingInformation/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_type_version IS 'supportingInformation/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_type_code IS 'supportingInformation/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_type_display IS 'supportingInformation/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_type_text IS 'supportingInformation/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_system IS 'supportingInformation/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_identifier_value IS 'supportingInformation/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_supportinginformation_display IS 'supportingInformation/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_authoredon IS 'authoredOn (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_ref IS 'requester/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_type IS 'requester/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_use IS 'requester/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_type_system IS 'requester/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_type_version IS 'requester/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_type_code IS 'requester/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_type_display IS 'requester/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_type_text IS 'requester/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_system IS 'requester/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_identifier_value IS 'requester/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_requester_display IS 'requester/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasoncode_system IS 'reasonCode/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasoncode_version IS 'reasonCode/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasoncode_code IS 'reasonCode/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasoncode_display IS 'reasonCode/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasoncode_text IS 'reasonCode/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_ref IS 'reasonReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_type IS 'reasonReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_system IS 'reasonReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_identifier_value IS 'reasonReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_reasonreference_display IS 'reasonReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_ref IS 'basedOn/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_type IS 'basedOn/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_system IS 'basedOn/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_identifier_value IS 'basedOn/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_basedon_display IS 'basedOn/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorstring IS 'note/authorString (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_type IS 'note/authorReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_system IS 'note/authorReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_identifier_value IS 'note/authorReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_authorreference_display IS 'note/authorReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_time IS 'note/time (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_note_text IS 'note/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_sequence IS 'dosageInstruction/sequence (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_text IS 'dosageInstruction/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_additionalinstruction_system IS 'dosageInstruction/additionalInstruction/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_additionalinstruction_version IS 'dosageInstruction/additionalInstruction/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_additionalinstruction_code IS 'dosageInstruction/additionalInstruction/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_additionalinstruction_display IS 'dosageInstruction/additionalInstruction/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_additionalinstruction_text IS 'dosageInstruction/additionalInstruction/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_patientinstruction IS 'dosageInstruction/patientInstruction (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_event IS 'dosageInstruction/timing/event (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsduration_value IS 'dosageInstruction/timing/repeat/boundsDuration/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsduration_comparator IS 'dosageInstruction/timing/repeat/boundsDuration/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsduration_unit IS 'dosageInstruction/timing/repeat/boundsDuration/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsduration_system IS 'dosageInstruction/timing/repeat/boundsDuration/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsduration_code IS 'dosageInstruction/timing/repeat/boundsDuration/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_low_value IS 'dosageInstruction/timing/repeat/boundsRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_low_unit IS 'dosageInstruction/timing/repeat/boundsRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_low_system IS 'dosageInstruction/timing/repeat/boundsRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_low_code IS 'dosageInstruction/timing/repeat/boundsRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_high_value IS 'dosageInstruction/timing/repeat/boundsRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_high_unit IS 'dosageInstruction/timing/repeat/boundsRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_high_system IS 'dosageInstruction/timing/repeat/boundsRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsrange_high_code IS 'dosageInstruction/timing/repeat/boundsRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsperiod_start IS 'dosageInstruction/timing/repeat/boundsPeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_boundsperiod_end IS 'dosageInstruction/timing/repeat/boundsPeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_count IS 'dosageInstruction/timing/repeat/count (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_countmax IS 'dosageInstruction/timing/repeat/countMax (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_duration IS 'dosageInstruction/timing/repeat/duration (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_durationmax IS 'dosageInstruction/timing/repeat/durationMax (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_durationunit IS 'dosageInstruction/timing/repeat/durationUnit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_frequency IS 'dosageInstruction/timing/repeat/frequency (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_frequencymax IS 'dosageInstruction/timing/repeat/frequencyMax (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_period IS 'dosageInstruction/timing/repeat/period (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_periodmax IS 'dosageInstruction/timing/repeat/periodMax (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_periodunit IS 'dosageInstruction/timing/repeat/periodUnit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_dayofweek IS 'dosageInstruction/timing/repeat/dayOfWeek (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_timeofday IS 'dosageInstruction/timing/repeat/timeOfDay (time)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_when IS 'dosageInstruction/timing/repeat/when (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_repeat_offset IS 'dosageInstruction/timing/repeat/offset (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_code_system IS 'dosageInstruction/timing/code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_code_version IS 'dosageInstruction/timing/code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_code_code IS 'dosageInstruction/timing/code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_code_display IS 'dosageInstruction/timing/code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_timing_code_text IS 'dosageInstruction/timing/code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_asneededboolean IS 'dosageInstruction/asNeededBoolean (boolean)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_asneededcodeableconcept_system IS 'dosageInstruction/asNeededCodeableConcept/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_asneededcodeableconcept_version IS 'dosageInstruction/asNeededCodeableConcept/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_asneededcodeableconcept_code IS 'dosageInstruction/asNeededCodeableConcept/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_asneededcodeableconcept_display IS 'dosageInstruction/asNeededCodeableConcept/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_asneededcodeableconcept_text IS 'dosageInstruction/asNeededCodeableConcept/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_site_system IS 'dosageInstruction/site/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_site_version IS 'dosageInstruction/site/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_site_code IS 'dosageInstruction/site/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_site_display IS 'dosageInstruction/site/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_site_text IS 'dosageInstruction/site/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_route_system IS 'dosageInstruction/route/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_route_version IS 'dosageInstruction/route/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_route_code IS 'dosageInstruction/route/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_route_display IS 'dosageInstruction/route/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_route_text IS 'dosageInstruction/route/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_method_system IS 'dosageInstruction/method/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_method_version IS 'dosageInstruction/method/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_method_code IS 'dosageInstruction/method/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_method_display IS 'dosageInstruction/method/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_method_text IS 'dosageInstruction/method/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_type_system IS 'dosageInstruction/doseAndRate/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_type_version IS 'dosageInstruction/doseAndRate/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_type_code IS 'dosageInstruction/doseAndRate/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_type_display IS 'dosageInstruction/doseAndRate/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_type_text IS 'dosageInstruction/doseAndRate/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_low_value IS 'dosageInstruction/doseAndRate/doseRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_low_unit IS 'dosageInstruction/doseAndRate/doseRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_low_system IS 'dosageInstruction/doseAndRate/doseRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_low_code IS 'dosageInstruction/doseAndRate/doseRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_high_value IS 'dosageInstruction/doseAndRate/doseRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_high_unit IS 'dosageInstruction/doseAndRate/doseRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_high_system IS 'dosageInstruction/doseAndRate/doseRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_doserange_high_code IS 'dosageInstruction/doseAndRate/doseRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_dosequantity_value IS 'dosageInstruction/doseAndRate/doseQuantity/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_dosequantity_comparator IS 'dosageInstruction/doseAndRate/doseQuantity/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_dosequantity_unit IS 'dosageInstruction/doseAndRate/doseQuantity/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_dosequantity_system IS 'dosageInstruction/doseAndRate/doseQuantity/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_dosequantity_code IS 'dosageInstruction/doseAndRate/doseQuantity/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_numerator_value IS 'dosageInstruction/doseAndRate/rateRatio/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator IS 'dosageInstruction/doseAndRate/rateRatio/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_numerator_unit IS 'dosageInstruction/doseAndRate/rateRatio/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_numerator_system IS 'dosageInstruction/doseAndRate/rateRatio/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_numerator_code IS 'dosageInstruction/doseAndRate/rateRatio/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_denominator_value IS 'dosageInstruction/doseAndRate/rateRatio/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator IS 'dosageInstruction/doseAndRate/rateRatio/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_denominator_unit IS 'dosageInstruction/doseAndRate/rateRatio/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_denominator_system IS 'dosageInstruction/doseAndRate/rateRatio/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_rateratio_denominator_code IS 'dosageInstruction/doseAndRate/rateRatio/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_low_value IS 'dosageInstruction/doseAndRate/rateRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_low_unit IS 'dosageInstruction/doseAndRate/rateRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_low_system IS 'dosageInstruction/doseAndRate/rateRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_low_code IS 'dosageInstruction/doseAndRate/rateRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_high_value IS 'dosageInstruction/doseAndRate/rateRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_high_unit IS 'dosageInstruction/doseAndRate/rateRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_high_system IS 'dosageInstruction/doseAndRate/rateRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_raterange_high_code IS 'dosageInstruction/doseAndRate/rateRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_ratequantity_value IS 'dosageInstruction/doseAndRate/rateQuantity/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_ratequantity_unit IS 'dosageInstruction/doseAndRate/rateQuantity/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_ratequantity_system IS 'dosageInstruction/doseAndRate/rateQuantity/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_doseandrate_ratequantity_code IS 'dosageInstruction/doseAndRate/rateQuantity/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_numerator_value IS 'dosageInstruction/maxDosePerPeriod/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_numerator_comparator IS 'dosageInstruction/maxDosePerPeriod/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_numerator_unit IS 'dosageInstruction/maxDosePerPeriod/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_numerator_system IS 'dosageInstruction/maxDosePerPeriod/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_numerator_code IS 'dosageInstruction/maxDosePerPeriod/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_denominator_value IS 'dosageInstruction/maxDosePerPeriod/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_denominator_comparator IS 'dosageInstruction/maxDosePerPeriod/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_denominator_unit IS 'dosageInstruction/maxDosePerPeriod/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_denominator_system IS 'dosageInstruction/maxDosePerPeriod/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperperiod_denominator_code IS 'dosageInstruction/maxDosePerPeriod/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperadministration_value IS 'dosageInstruction/maxDosePerAdministration/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperadministration_unit IS 'dosageInstruction/maxDosePerAdministration/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperadministration_system IS 'dosageInstruction/maxDosePerAdministration/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperadministration_code IS 'dosageInstruction/maxDosePerAdministration/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperlifetime_value IS 'dosageInstruction/maxDosePerLifetime/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperlifetime_unit IS 'dosageInstruction/maxDosePerLifetime/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperlifetime_system IS 'dosageInstruction/maxDosePerLifetime/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_doseinstruc_maxdoseperlifetime_code IS 'dosageInstruction/maxDosePerLifetime/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_substitution_reason_system IS 'substitution/reason/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_substitution_reason_version IS 'substitution/reason/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_substitution_reason_code IS 'substitution/reason/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_substitution_reason_display IS 'substitution/reason/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationrequest_last_import.medreq_substitution_reason_text IS 'substitution/reason/text (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_medicationadministration_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_encounter_ref IS 'context/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_encounter_calculated_ref IS 'context/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_partof_ref IS 'partOf/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_statusreason_system IS 'statusReason/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_statusreason_version IS 'statusReason/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_statusreason_code IS 'statusReason/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_statusreason_display IS 'statusReason/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_statusreason_text IS 'statusReason/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_medicationreference_ref IS 'medicationReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_ref IS 'supportingInformation/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_type IS 'supportingInformation/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_use IS 'supportingInformation/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_type_system IS 'supportingInformation/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_type_version IS 'supportingInformation/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_type_code IS 'supportingInformation/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_type_display IS 'supportingInformation/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_type_text IS 'supportingInformation/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_system IS 'supportingInformation/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_identifier_value IS 'supportingInformation/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_supportinginformation_display IS 'supportingInformation/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_effectivedatetime IS 'effectiveDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_effectiveperiod_start IS 'effectivePeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_effectiveperiod_end IS 'effectivePeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_performer_function_system IS 'performer/function/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_performer_function_version IS 'performer/function/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_performer_function_code IS 'performer/function/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_performer_function_display IS 'performer/function/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_performer_function_text IS 'performer/function/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasoncode_system IS 'reasonCode/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasoncode_version IS 'reasonCode/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasoncode_code IS 'reasonCode/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasoncode_display IS 'reasonCode/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasoncode_text IS 'reasonCode/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_ref IS 'reasonReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_type IS 'reasonReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_system IS 'reasonReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_identifier_value IS 'reasonReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_reasonreference_display IS 'reasonReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_request_ref IS 'request/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorstring IS 'note/authorString (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_type IS 'note/authorReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_system IS 'note/authorReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_identifier_value IS 'note/authorReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_authorreference_display IS 'note/authorReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_time IS 'note/time (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_note_text IS 'note/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_text IS 'dosage/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_site_system IS 'dosage/site/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_site_version IS 'dosage/site/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_site_code IS 'dosage/site/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_site_display IS 'dosage/site/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_site_text IS 'dosage/site/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_route_system IS 'dosage/route/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_route_version IS 'dosage/route/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_route_code IS 'dosage/route/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_route_display IS 'dosage/route/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_route_text IS 'dosage/route/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_method_system IS 'dosage/method/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_method_version IS 'dosage/method/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_method_code IS 'dosage/method/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_method_display IS 'dosage/method/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_method_text IS 'dosage/method/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_dose_value IS 'dosage/dose/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_dose_unit IS 'dosage/dose/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_dose_system IS 'dosage/dose/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_dose_code IS 'dosage/dose/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_numerator_value IS 'dosage/rateRatio/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_numerator_comparator IS 'dosage/rateRatio/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_numerator_unit IS 'dosage/rateRatio/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_numerator_system IS 'dosage/rateRatio/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_numerator_code IS 'dosage/rateRatio/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_denominator_value IS 'dosage/rateRatio/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_denominator_comparator IS 'dosage/rateRatio/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_denominator_unit IS 'dosage/rateRatio/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_denominator_system IS 'dosage/rateRatio/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_rateratio_denominator_code IS 'dosage/rateRatio/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_ratequantity_value IS 'dosage/rateQuantity/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_ratequantity_unit IS 'dosage/rateQuantity/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_ratequantity_system IS 'dosage/rateQuantity/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationadministration_last_import.medadm_dosage_ratequantity_code IS 'dosage/rateQuantity/code (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_medicationstatement_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_encounter_ref IS 'context/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_encounter_calculated_ref IS 'context/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_partof_ref IS 'partOf/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_ref IS 'basedOn/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_type IS 'basedOn/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_system IS 'basedOn/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_identifier_value IS 'basedOn/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_basedon_display IS 'basedOn/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_statusreason_system IS 'statusReason/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_statusreason_version IS 'statusReason/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_statusreason_code IS 'statusReason/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_statusreason_display IS 'statusReason/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_statusreason_text IS 'statusReason/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_medicationreference_ref IS 'medicationReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_medicationcodeableconcept_system IS 'medicationCodeableConcept/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_medicationcodeableconcept_version IS 'medicationCodeableConcept/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_medicationcodeableconcept_code IS 'medicationCodeableConcept/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_medicationcodeableconcept_display IS 'medicationCodeableConcept/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_medicationcodeableconcept_text IS 'medicationCodeableConcept/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_effectivedatetime IS 'effectiveDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_effectiveperiod_start IS 'effectivePeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_effectiveperiod_end IS 'effectivePeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dateasserted IS 'dateAsserted (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_ref IS 'informationSource/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_type IS 'informationSource/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_use IS 'informationSource/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_type_system IS 'informationSource/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_type_version IS 'informationSource/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_type_code IS 'informationSource/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_type_display IS 'informationSource/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_type_text IS 'informationSource/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_system IS 'informationSource/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_identifier_value IS 'informationSource/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_informationsource_display IS 'informationSource/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_ref IS 'derivedFrom/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_type IS 'derivedFrom/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_use IS 'derivedFrom/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_type_system IS 'derivedFrom/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_type_version IS 'derivedFrom/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_type_code IS 'derivedFrom/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_type_display IS 'derivedFrom/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_type_text IS 'derivedFrom/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_system IS 'derivedFrom/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_identifier_value IS 'derivedFrom/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_derivedfrom_display IS 'derivedFrom/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasoncode_system IS 'reasonCode/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasoncode_version IS 'reasonCode/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasoncode_code IS 'reasonCode/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasoncode_display IS 'reasonCode/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasoncode_text IS 'reasonCode/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_ref IS 'reasonReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_type IS 'reasonReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_system IS 'reasonReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_identifier_value IS 'reasonReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_reasonreference_display IS 'reasonReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorstring IS 'note/authorString (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_type IS 'note/authorReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_system IS 'note/authorReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_identifier_value IS 'note/authorReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_authorreference_display IS 'note/authorReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_time IS 'note/time (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_note_text IS 'note/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_sequence IS 'dosage/sequence (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_text IS 'dosage/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_additionalinstruction_system IS 'dosage/additionalInstruction/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_additionalinstruction_version IS 'dosage/additionalInstruction/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_additionalinstruction_code IS 'dosage/additionalInstruction/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_additionalinstruction_display IS 'dosage/additionalInstruction/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_additionalinstruction_text IS 'dosage/additionalInstruction/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_patientinstruction IS 'dosage/patientInstruction (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_event IS 'dosage/timing/event (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsduration_value IS 'dosage/timing/repeat/boundsDuration/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsduration_comparator IS 'dosage/timing/repeat/boundsDuration/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsduration_unit IS 'dosage/timing/repeat/boundsDuration/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsduration_system IS 'dosage/timing/repeat/boundsDuration/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsduration_code IS 'dosage/timing/repeat/boundsDuration/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_low_value IS 'dosage/timing/repeat/boundsRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_low_unit IS 'dosage/timing/repeat/boundsRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_low_system IS 'dosage/timing/repeat/boundsRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_low_code IS 'dosage/timing/repeat/boundsRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_high_value IS 'dosage/timing/repeat/boundsRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_high_unit IS 'dosage/timing/repeat/boundsRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_high_system IS 'dosage/timing/repeat/boundsRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsrange_high_code IS 'dosage/timing/repeat/boundsRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsperiod_start IS 'dosage/timing/repeat/boundsPeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_boundsperiod_end IS 'dosage/timing/repeat/boundsPeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_count IS 'dosage/timing/repeat/count (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_countmax IS 'dosage/timing/repeat/countMax (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_duration IS 'dosage/timing/repeat/duration (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_durationmax IS 'dosage/timing/repeat/durationMax (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_durationunit IS 'dosage/timing/repeat/durationUnit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_frequency IS 'dosage/timing/repeat/frequency (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_frequencymax IS 'dosage/timing/repeat/frequencyMax (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_period IS 'dosage/timing/repeat/period (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_periodmax IS 'dosage/timing/repeat/periodMax (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_periodunit IS 'dosage/timing/repeat/periodUnit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_dayofweek IS 'dosage/timing/repeat/dayOfWeek (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_timeofday IS 'dosage/timing/repeat/timeOfDay (time)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_when IS 'dosage/timing/repeat/when (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_repeat_offset IS 'dosage/timing/repeat/offset (int)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_code_system IS 'dosage/timing/code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_code_version IS 'dosage/timing/code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_code_code IS 'dosage/timing/code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_code_display IS 'dosage/timing/code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_timing_code_text IS 'dosage/timing/code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_asneededboolean IS 'dosage/asNeededBoolean (boolean)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_asneededcodeableconcept_system IS 'dosage/asNeededCodeableConcept/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_asneededcodeableconcept_version IS 'dosage/asNeededCodeableConcept/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_asneededcodeableconcept_code IS 'dosage/asNeededCodeableConcept/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_asneededcodeableconcept_display IS 'dosage/asNeededCodeableConcept/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_asneededcodeableconcept_text IS 'dosage/asNeededCodeableConcept/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_site_system IS 'dosage/site/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_site_version IS 'dosage/site/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_site_code IS 'dosage/site/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_site_display IS 'dosage/site/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_site_text IS 'dosage/site/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_route_system IS 'dosage/route/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_route_version IS 'dosage/route/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_route_code IS 'dosage/route/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_route_display IS 'dosage/route/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_route_text IS 'dosage/route/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_method_system IS 'dosage/method/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_method_version IS 'dosage/method/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_method_code IS 'dosage/method/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_method_display IS 'dosage/method/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_method_text IS 'dosage/method/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_type_system IS 'dosage/doseAndRate/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_type_version IS 'dosage/doseAndRate/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_type_code IS 'dosage/doseAndRate/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_type_display IS 'dosage/doseAndRate/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_type_text IS 'dosage/doseAndRate/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_low_value IS 'dosage/doseAndRate/doseRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_low_unit IS 'dosage/doseAndRate/doseRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_low_system IS 'dosage/doseAndRate/doseRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_low_code IS 'dosage/doseAndRate/doseRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_high_value IS 'dosage/doseAndRate/doseRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_high_unit IS 'dosage/doseAndRate/doseRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_high_system IS 'dosage/doseAndRate/doseRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_doserange_high_code IS 'dosage/doseAndRate/doseRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_dosequantity_value IS 'dosage/doseAndRate/doseQuantity/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_dosequantity_comparator IS 'dosage/doseAndRate/doseQuantity/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_dosequantity_unit IS 'dosage/doseAndRate/doseQuantity/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_dosequantity_system IS 'dosage/doseAndRate/doseQuantity/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_dosequantity_code IS 'dosage/doseAndRate/doseQuantity/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_numerator_value IS 'dosage/doseAndRate/rateRatio/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_numerator_comparator IS 'dosage/doseAndRate/rateRatio/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_numerator_unit IS 'dosage/doseAndRate/rateRatio/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_numerator_system IS 'dosage/doseAndRate/rateRatio/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_numerator_code IS 'dosage/doseAndRate/rateRatio/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_denominator_value IS 'dosage/doseAndRate/rateRatio/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_denominator_comparator IS 'dosage/doseAndRate/rateRatio/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_denominator_unit IS 'dosage/doseAndRate/rateRatio/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_denominator_system IS 'dosage/doseAndRate/rateRatio/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_rateratio_denominator_code IS 'dosage/doseAndRate/rateRatio/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_low_value IS 'dosage/doseAndRate/rateRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_low_unit IS 'dosage/doseAndRate/rateRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_low_system IS 'dosage/doseAndRate/rateRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_low_code IS 'dosage/doseAndRate/rateRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_high_value IS 'dosage/doseAndRate/rateRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_high_unit IS 'dosage/doseAndRate/rateRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_high_system IS 'dosage/doseAndRate/rateRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_raterange_high_code IS 'dosage/doseAndRate/rateRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_ratequantity_value IS 'dosage/doseAndRate/rateQuantity/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_ratequantity_unit IS 'dosage/doseAndRate/rateQuantity/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_ratequantity_system IS 'dosage/doseAndRate/rateQuantity/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_doseandrate_ratequantity_code IS 'dosage/doseAndRate/rateQuantity/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_numerator_value IS 'dosage/maxDosePerPeriod/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_numerator_comparator IS 'dosage/maxDosePerPeriod/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_numerator_unit IS 'dosage/maxDosePerPeriod/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_numerator_system IS 'dosage/maxDosePerPeriod/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_numerator_code IS 'dosage/maxDosePerPeriod/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_denominator_value IS 'dosage/maxDosePerPeriod/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_denominator_comparator IS 'dosage/maxDosePerPeriod/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_denominator_unit IS 'dosage/maxDosePerPeriod/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_denominator_system IS 'dosage/maxDosePerPeriod/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperperiod_denominator_code IS 'dosage/maxDosePerPeriod/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperadministration_value IS 'dosage/maxDosePerAdministration/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperadministration_unit IS 'dosage/maxDosePerAdministration/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperadministration_system IS 'dosage/maxDosePerAdministration/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperadministration_code IS 'dosage/maxDosePerAdministration/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperlifetime_value IS 'dosage/maxDosePerLifetime/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperlifetime_unit IS 'dosage/maxDosePerLifetime/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperlifetime_system IS 'dosage/maxDosePerLifetime/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_medicationstatement_last_import.medstat_dosage_maxdoseperlifetime_code IS 'dosage/maxDosePerLifetime/code (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_observation_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_encounter_ref IS 'encounter/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_encounter_calculated_ref IS 'encounter/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_partof_ref IS 'partOf/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_ref IS 'basedOn/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_type IS 'basedOn/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_system IS 'basedOn/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_identifier_value IS 'basedOn/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_basedon_display IS 'basedOn/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_code_system IS 'code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_code_version IS 'code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_code_code IS 'code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_code_display IS 'code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_code_text IS 'code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_effectivedatetime IS 'effectiveDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_issued IS 'issued (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_low_value IS 'valueRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_low_unit IS 'valueRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_low_system IS 'valueRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_low_code IS 'valueRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_high_value IS 'valueRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_high_unit IS 'valueRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_high_system IS 'valueRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuerange_high_code IS 'valueRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_numerator_value IS 'valueRatio/numerator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_numerator_comparator IS 'valueRatio/numerator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_numerator_unit IS 'valueRatio/numerator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_numerator_system IS 'valueRatio/numerator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_numerator_code IS 'valueRatio/numerator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_denominator_value IS 'valueRatio/denominator/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_denominator_comparator IS 'valueRatio/denominator/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_denominator_unit IS 'valueRatio/denominator/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_denominator_system IS 'valueRatio/denominator/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valueratio_denominator_code IS 'valueRatio/denominator/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuequantity_value IS 'valueQuantity/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuequantity_comparator IS 'valueQuantity/comparator (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuequantity_unit IS 'valueQuantity/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuequantity_system IS 'valueQuantity/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuequantity_code IS 'valueQuantity/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuecodeableconcept_system IS 'valueCodeableConcept/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuecodeableconcept_version IS 'valueCodeableConcept/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuecodeableconcept_code IS 'valueCodeableConcept/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuecodeableconcept_display IS 'valueCodeableConcept/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_valuecodeableconcept_text IS 'valueCodeableConcept/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_dataabsentreason_system IS 'dataAbsentReason/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_dataabsentreason_version IS 'dataAbsentReason/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_dataabsentreason_code IS 'dataAbsentReason/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_dataabsentreason_display IS 'dataAbsentReason/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_dataabsentreason_text IS 'dataAbsentReason/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorstring IS 'note/authorString (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_type IS 'note/authorReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_system IS 'note/authorReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_identifier_value IS 'note/authorReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_authorreference_display IS 'note/authorReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_time IS 'note/time (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_note_text IS 'note/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_method_system IS 'method/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_method_version IS 'method/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_method_code IS 'method/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_method_display IS 'method/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_method_text IS 'method/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_ref IS 'performer/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_type IS 'performer/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_use IS 'performer/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_system IS 'performer/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_identifier_value IS 'performer/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_performer_display IS 'performer/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_low_value IS 'referenceRange/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_low_unit IS 'referenceRange/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_low_system IS 'referenceRange/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_low_code IS 'referenceRange/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_high_value IS 'referenceRange/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_high_unit IS 'referenceRange/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_high_system IS 'referenceRange/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_high_code IS 'referenceRange/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_type_system IS 'referenceRange/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_type_version IS 'referenceRange/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_type_code IS 'referenceRange/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_type_display IS 'referenceRange/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_type_text IS 'referenceRange/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_appliesto_system IS 'referenceRange/appliesTo/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_appliesto_version IS 'referenceRange/appliesTo/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_appliesto_code IS 'referenceRange/appliesTo/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_appliesto_display IS 'referenceRange/appliesTo/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_appliesto_text IS 'referenceRange/appliesTo/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_low_value IS 'referenceRange/age/low/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_low_unit IS 'referenceRange/age/low/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_low_system IS 'referenceRange/age/low/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_low_code IS 'referenceRange/age/low/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_high_value IS 'referenceRange/age/high/value (double precision)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_high_unit IS 'referenceRange/age/high/unit (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_high_system IS 'referenceRange/age/high/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_age_high_code IS 'referenceRange/age/high/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_referencerange_text IS 'referenceRange/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_ref IS 'hasMember/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_type IS 'hasMember/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_use IS 'hasMember/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_type_system IS 'hasMember/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_type_version IS 'hasMember/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_type_code IS 'hasMember/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_type_display IS 'hasMember/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_type_text IS 'hasMember/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_system IS 'hasMember/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_identifier_value IS 'hasMember/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_observation_last_import.obs_hasmember_display IS 'hasMember/display (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_diagnosticreport_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_encounter_ref IS 'encounter/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_encounter_calculated_ref IS 'encounter/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_partof_ref IS 'partOf/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_result_ref IS 'result/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_basedon_ref IS 'basedOn/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_code_system IS 'code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_code_version IS 'code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_code_code IS 'code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_code_display IS 'code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_code_text IS 'code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_effectivedatetime IS 'effectiveDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_issued IS 'issued (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_ref IS 'performer/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_type IS 'performer/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_use IS 'performer/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_system IS 'performer/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_identifier_value IS 'performer/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_performer_display IS 'performer/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_conclusion IS 'conclusion (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_conclusioncode_system IS 'conclusionCode/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_conclusioncode_version IS 'conclusionCode/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_conclusioncode_code IS 'conclusionCode/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_conclusioncode_display IS 'conclusionCode/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_diagnosticreport_last_import.diagrep_conclusioncode_text IS 'conclusionCode/text (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_servicerequest_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_encounter_ref IS 'encounter/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_encounter_calculated_ref IS 'encounter/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_ref IS 'basedOn/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_type IS 'basedOn/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_system IS 'basedOn/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_identifier_value IS 'basedOn/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_basedon_display IS 'basedOn/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_intent IS 'intent (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_code_system IS 'code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_code_version IS 'code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_code_code IS 'code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_code_display IS 'code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_code_text IS 'code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_authoredon IS 'authoredOn (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_ref IS 'requester/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_type IS 'requester/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_use IS 'requester/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_type_system IS 'requester/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_type_version IS 'requester/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_type_code IS 'requester/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_type_display IS 'requester/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_type_text IS 'requester/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_system IS 'requester/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_identifier_value IS 'requester/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_requester_display IS 'requester/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_ref IS 'performer/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_type IS 'performer/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_use IS 'performer/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_type_system IS 'performer/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_type_version IS 'performer/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_type_code IS 'performer/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_type_display IS 'performer/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_type_text IS 'performer/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_system IS 'performer/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_identifier_value IS 'performer/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_performer_display IS 'performer/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_locationcode_system IS 'locationCode/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_locationcode_version IS 'locationCode/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_locationcode_code IS 'locationCode/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_locationcode_display IS 'locationCode/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_servicerequest_last_import.servreq_locationcode_text IS 'locationCode/text (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_procedure_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_encounter_ref IS 'encounter/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_encounter_calculated_ref IS 'encounter/calculated_ref (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_patient_ref IS 'subject/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_partof_ref IS 'partOf/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_ref IS 'basedOn/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_type IS 'basedOn/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_use IS 'basedOn/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_type_system IS 'basedOn/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_type_version IS 'basedOn/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_type_code IS 'basedOn/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_type_display IS 'basedOn/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_type_text IS 'basedOn/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_system IS 'basedOn/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_identifier_value IS 'basedOn/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_basedon_display IS 'basedOn/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_statusreason_system IS 'statusReason/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_statusreason_version IS 'statusReason/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_statusreason_code IS 'statusReason/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_statusreason_display IS 'statusReason/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_statusreason_text IS 'statusReason/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_code_system IS 'code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_code_version IS 'code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_code_code IS 'code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_code_display IS 'code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_code_text IS 'code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_performeddatetime IS 'performedDateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_performedperiod_start IS 'performedPeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_performedperiod_end IS 'performedPeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasoncode_system IS 'reasonCode/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasoncode_version IS 'reasonCode/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasoncode_code IS 'reasonCode/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasoncode_display IS 'reasonCode/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasoncode_text IS 'reasonCode/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_ref IS 'reasonReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_type IS 'reasonReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_use IS 'reasonReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_type_system IS 'reasonReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_type_version IS 'reasonReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_type_code IS 'reasonReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_type_display IS 'reasonReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_type_text IS 'reasonReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_system IS 'reasonReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_identifier_value IS 'reasonReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_reasonreference_display IS 'reasonReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorstring IS 'note/authorString (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_ref IS 'note/authorReference/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_type IS 'note/authorReference/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_use IS 'note/authorReference/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_type_system IS 'note/authorReference/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_type_version IS 'note/authorReference/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_type_code IS 'note/authorReference/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_type_display IS 'note/authorReference/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_type_text IS 'note/authorReference/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_system IS 'note/authorReference/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_identifier_value IS 'note/authorReference/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_authorreference_display IS 'note/authorReference/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_time IS 'note/time (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_procedure_last_import.proc_note_text IS 'note/text (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_consent_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_patient_ref IS 'patient/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_scope_system IS 'scope/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_scope_version IS 'scope/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_scope_code IS 'scope/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_scope_display IS 'scope/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_scope_text IS 'scope/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_category_system IS 'category/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_category_version IS 'category/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_category_code IS 'category/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_category_display IS 'category/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_category_text IS 'category/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_datetime IS 'dateTime (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_policy_authority IS 'policy/authority (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_policy_uri IS 'policy/uri (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_type IS 'provision/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_period_start IS 'provision/period/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_period_end IS 'provision/period/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_role_system IS 'provision/actor/role/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_role_version IS 'provision/actor/role/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_role_code IS 'provision/actor/role/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_role_display IS 'provision/actor/role/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_role_text IS 'provision/actor/role/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_ref IS 'provision/actor/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_type IS 'provision/actor/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_use IS 'provision/actor/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_type_system IS 'provision/actor/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_type_version IS 'provision/actor/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_type_code IS 'provision/actor/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_type_display IS 'provision/actor/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_type_text IS 'provision/actor/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_system IS 'provision/actor/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_identifier_value IS 'provision/actor/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_actor_display IS 'provision/actor/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_code_system IS 'provision/code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_code_version IS 'provision/code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_code_code IS 'provision/code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_code_display IS 'provision/code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_code_text IS 'provision/code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_dataperiod_start IS 'provision/dataPeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_dataperiod_end IS 'provision/dataPeriod/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_type IS 'provision/provision/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_period_start IS 'provision/provision/period/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_period_end IS 'provision/provision/period/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_role_system IS 'provision/provision/actor/role/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_role_version IS 'provision/provision/actor/role/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_role_code IS 'provision/provision/actor/role/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_role_display IS 'provision/provision/actor/role/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_role_text IS 'provision/provision/actor/role/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_ref IS 'provision/provision/actor/reference (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_type IS 'provision/provision/actor/type (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_use IS 'provision/provision/actor/identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_type_system IS 'provision/provision/actor/identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_type_version IS 'provision/provision/actor/identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_type_code IS 'provision/provision/actor/identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_type_display IS 'provision/provision/actor/identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_type_text IS 'provision/provision/actor/identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_system IS 'provision/provision/actor/identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_identifier_value IS 'provision/provision/actor/identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_actor_display IS 'provision/provision/actor/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_code_system IS 'provision/provision/code/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_code_version IS 'provision/provision/code/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_code_code IS 'provision/provision/code/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_code_display IS 'provision/provision/code/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_code_text IS 'provision/provision/code/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_dataperiod_start IS 'provision/provision/dataPeriod/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_consent_last_import.cons_provision_provision_dataperiod_end IS 'provision/provision/dataPeriod/end (timestamp)';
    -------- COMMENTS db2dataprocessor_out.v_location_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_id IS 'id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_meta_versionid IS 'meta/versionId (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_meta_lastupdated IS 'meta/lastUpdated (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_meta_profile IS 'meta/profile (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_use IS 'identifier/use (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_type_system IS 'identifier/type/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_type_version IS 'identifier/type/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_type_code IS 'identifier/type/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_type_display IS 'identifier/type/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_type_text IS 'identifier/type/text (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_system IS 'identifier/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_value IS 'identifier/value (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_start IS 'identifier/start (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_identifier_end IS 'identifier/end (timestamp)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_status IS 'status (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_name IS 'name (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_description IS 'description (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_alias IS 'alias (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_physicaltype_system IS 'physicalType/coding/system (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_physicaltype_version IS 'physicalType/coding/version (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_physicaltype_code IS 'physicalType/coding/code (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_physicaltype_display IS 'physicalType/coding/display (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_location_last_import.loc_physicaltype_text IS 'physicalType/text (varchar)';
    -------- COMMENTS db2dataprocessor_out.v_pids_per_ward_last_import ------------
    COMMENT ON COLUMN db2dataprocessor_out.v_pids_per_ward_last_import.ward_name IS 'ward_name (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_pids_per_ward_last_import.patient_id IS 'patient_id (varchar)';
    COMMENT ON COLUMN db2dataprocessor_out.v_pids_per_ward_last_import.encounter_id IS 'encounter_id (varchar)';
    --SQL Role for Views in Schema db2dataprocessor_out
    GRANT SELECT ON TABLE db2dataprocessor_out.v_encounter_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_patient_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_condition_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_medication_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationrequest_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationadministration_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationstatement_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_observation_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_diagnosticreport_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_servicerequest_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_procedure_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_consent_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_location_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    GRANT SELECT ON TABLE db2dataprocessor_out.v_pids_per_ward_last_import TO db2dataprocessor_user;
    GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;
    --------------------------------------------------------------------
END IF;
    -- do migration
END
$$;
