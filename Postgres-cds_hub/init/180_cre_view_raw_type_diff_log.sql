-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-07-01 13:49:10
-- Rights definition file size        : 16391 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2025-11-13 09:10:37
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  180_cre_view_raw_type_diff_log.sql
-- TEMPLATE:  template_cre_view_diff.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _raw_diff
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  _raw
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create SQL View not Typed Datasets in Schema cds2db_out

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_encounter_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_encounter_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_encounter_raw_diff AS (
        SELECT DISTINCT * FROM db_log.encounter_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.encounter t WHERE r.encounter_raw_id = t.encounter_raw_id)) -- ORDER BY encounter_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_patient_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_patient_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_patient_raw_diff AS (
        SELECT DISTINCT * FROM db_log.patient_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.patient t WHERE r.patient_raw_id = t.patient_raw_id)) -- ORDER BY patient_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_condition_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_condition_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_condition_raw_diff AS (
        SELECT DISTINCT * FROM db_log.condition_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.condition t WHERE r.condition_raw_id = t.condition_raw_id)) -- ORDER BY condition_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medication_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_medication_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_medication_raw_diff AS (
        SELECT DISTINCT * FROM db_log.medication_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.medication t WHERE r.medication_raw_id = t.medication_raw_id)) -- ORDER BY medication_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationrequest_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_medicationrequest_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest_raw_diff AS (
        SELECT DISTINCT * FROM db_log.medicationrequest_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.medicationrequest t WHERE r.medicationrequest_raw_id = t.medicationrequest_raw_id)) -- ORDER BY medicationrequest_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationadministration_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_medicationadministration_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration_raw_diff AS (
        SELECT DISTINCT * FROM db_log.medicationadministration_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.medicationadministration t WHERE r.medicationadministration_raw_id = t.medicationadministration_raw_id)) -- ORDER BY medicationadministration_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationstatement_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_medicationstatement_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement_raw_diff AS (
        SELECT DISTINCT * FROM db_log.medicationstatement_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.medicationstatement t WHERE r.medicationstatement_raw_id = t.medicationstatement_raw_id)) -- ORDER BY medicationstatement_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_observation_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_observation_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_observation_raw_diff AS (
        SELECT DISTINCT * FROM db_log.observation_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.observation t WHERE r.observation_raw_id = t.observation_raw_id)) -- ORDER BY observation_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_diagnosticreport_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_diagnosticreport_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport_raw_diff AS (
        SELECT DISTINCT * FROM db_log.diagnosticreport_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.diagnosticreport t WHERE r.diagnosticreport_raw_id = t.diagnosticreport_raw_id)) -- ORDER BY diagnosticreport_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_servicerequest_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_servicerequest_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_servicerequest_raw_diff AS (
        SELECT DISTINCT * FROM db_log.servicerequest_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.servicerequest t WHERE r.servicerequest_raw_id = t.servicerequest_raw_id)) -- ORDER BY servicerequest_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_procedure_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_procedure_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_procedure_raw_diff AS (
        SELECT DISTINCT * FROM db_log.procedure_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.procedure t WHERE r.procedure_raw_id = t.procedure_raw_id)) -- ORDER BY procedure_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_consent_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_consent_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_consent_raw_diff AS (
        SELECT DISTINCT * FROM db_log.consent_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.consent t WHERE r.consent_raw_id = t.consent_raw_id)) -- ORDER BY consent_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_location_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_location_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_location_raw_diff AS (
        SELECT DISTINCT * FROM db_log.location_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.location t WHERE r.location_raw_id = t.location_raw_id)) -- ORDER BY location_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_pids_per_ward_raw_diff'
        ) THEN
            DROP VIEW cds2db_out.v_pids_per_ward_raw_diff; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward_raw_diff AS (
        SELECT DISTINCT * FROM db_log.pids_per_ward_raw r WHERE r.raw_already_processed IS NULL AND NOT (EXISTS(SELECT 1 FROM db_log.pids_per_ward t WHERE r.pids_per_ward_raw_id = t.pids_per_ward_raw_id)) -- ORDER BY pids_per_ward_raw_id
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_encounter_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_patient_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_condition_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medication_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_observation_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_procedure_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_consent_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_location_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_location_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward_raw_diff TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward_raw_diff TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

