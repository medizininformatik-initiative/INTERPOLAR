-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-03 14:04:41
-- Rights definition file size        : 16810 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_out"
-- Create time: 2026-02-03 14:21:55
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/230_cre_view_typ_dataproc_last_version.sql
-- TEMPLATE:  template_cre_view_last_version.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_out
-- TAGS:  TYPED
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _last_version
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

DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
--Create SQL View for latest Version of the FHIR-Data for schema db2dataprocessor_out

-------- VIEW db2dataprocessor_out.v_encounter_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_encounter_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_encounter_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_encounter_last_version AS (
            SELECT * FROM db_log.encounter q
                , (SELECT MAX(COALESCE(i.enc_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.enc_id AS ID
                FROM db_log.encounter i GROUP BY i.enc_id) w
            WHERE COALESCE(q.enc_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.enc_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_patient_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_patient_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_patient_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_patient_last_version AS (
            SELECT * FROM db_log.patient q
                , (SELECT MAX(COALESCE(i.pat_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.pat_id AS ID
                FROM db_log.patient i GROUP BY i.pat_id) w
            WHERE COALESCE(q.pat_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.pat_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_condition_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_condition_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_condition_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_condition_last_version AS (
            SELECT * FROM db_log.condition q
                , (SELECT MAX(COALESCE(i.con_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.con_id AS ID
                FROM db_log.condition i GROUP BY i.con_id) w
            WHERE COALESCE(q.con_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.con_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_medication_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_medication_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_medication_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_medication_last_version AS (
            SELECT * FROM db_log.medication q
                , (SELECT MAX(COALESCE(i.med_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.med_id AS ID
                FROM db_log.medication i GROUP BY i.med_id) w
            WHERE COALESCE(q.med_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.med_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_medicationrequest_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_medicationrequest_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_medicationrequest_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_medicationrequest_last_version AS (
            SELECT * FROM db_log.medicationrequest q
                , (SELECT MAX(COALESCE(i.medreq_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.medreq_id AS ID
                FROM db_log.medicationrequest i GROUP BY i.medreq_id) w
            WHERE COALESCE(q.medreq_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.medreq_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_medicationadministration_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_medicationadministration_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_medicationadministration_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_medicationadministration_last_version AS (
            SELECT * FROM db_log.medicationadministration q
                , (SELECT MAX(COALESCE(i.medadm_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.medadm_id AS ID
                FROM db_log.medicationadministration i GROUP BY i.medadm_id) w
            WHERE COALESCE(q.medadm_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.medadm_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_medicationstatement_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_medicationstatement_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_medicationstatement_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_medicationstatement_last_version AS (
            SELECT * FROM db_log.medicationstatement q
                , (SELECT MAX(COALESCE(i.medstat_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.medstat_id AS ID
                FROM db_log.medicationstatement i GROUP BY i.medstat_id) w
            WHERE COALESCE(q.medstat_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.medstat_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_observation_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_observation_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_observation_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_observation_last_version AS (
            SELECT * FROM db_log.observation q
                , (SELECT MAX(COALESCE(i.obs_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.obs_id AS ID
                FROM db_log.observation i GROUP BY i.obs_id) w
            WHERE COALESCE(q.obs_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.obs_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_diagnosticreport_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_diagnosticreport_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_diagnosticreport_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_diagnosticreport_last_version AS (
            SELECT * FROM db_log.diagnosticreport q
                , (SELECT MAX(COALESCE(i.diagrep_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.diagrep_id AS ID
                FROM db_log.diagnosticreport i GROUP BY i.diagrep_id) w
            WHERE COALESCE(q.diagrep_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.diagrep_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_servicerequest_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_servicerequest_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_servicerequest_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_servicerequest_last_version AS (
            SELECT * FROM db_log.servicerequest q
                , (SELECT MAX(COALESCE(i.servreq_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.servreq_id AS ID
                FROM db_log.servicerequest i GROUP BY i.servreq_id) w
            WHERE COALESCE(q.servreq_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.servreq_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_procedure_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_procedure_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_procedure_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_procedure_last_version AS (
            SELECT * FROM db_log.procedure q
                , (SELECT MAX(COALESCE(i.proc_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.proc_id AS ID
                FROM db_log.procedure i GROUP BY i.proc_id) w
            WHERE COALESCE(q.proc_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.proc_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_consent_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_consent_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_consent_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_consent_last_version AS (
            SELECT * FROM db_log.consent q
                , (SELECT MAX(COALESCE(i.cons_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.cons_id AS ID
                FROM db_log.consent i GROUP BY i.cons_id) w
            WHERE COALESCE(q.cons_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.cons_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


-------- VIEW db2dataprocessor_out.v_location_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'db2dataprocessor_out' AND table_name = 'v_location_last_version'
        ) THEN
            DROP VIEW db2dataprocessor_out.v_location_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW db2dataprocessor_out.v_location_last_version AS (
            SELECT * FROM db_log.location q
                , (SELECT MAX(COALESCE(i.loc_meta_lastupdated,                 i.last_check_datetime)) AS LAST_VERSION_DATE, i.loc_id AS ID
                FROM db_log.location i GROUP BY i.loc_id) w
            WHERE COALESCE(q.loc_meta_lastupdated,q.last_check_datetime) =             w.LAST_VERSION_DATE AND q.loc_id = w.ID
        );
----------------------------
    END IF; -- do migration
END
$innerview$;


--SQL Role for Views in Schema db2dataprocessor_out
GRANT SELECT ON TABLE db2dataprocessor_out.v_encounter_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_patient_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_condition_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medication_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationrequest_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationadministration_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_medicationstatement_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_observation_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_diagnosticreport_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_servicerequest_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_procedure_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_consent_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;

GRANT SELECT ON TABLE db2dataprocessor_out.v_location_last_version TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


GRANT USAGE ON SCHEMA db2dataprocessor_out TO db2dataprocessor_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

