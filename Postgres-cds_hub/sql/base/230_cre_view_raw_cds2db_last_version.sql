-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-23 15:20:49
-- Rights definition file size        : 19645 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2026-05-21 18:52:53
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/230_cre_view_raw_cds2db_last_version.sql
-- TEMPLATE:  template_cre_view_last_version.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  RAW
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _raw_last_version
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  cds2db_user
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
--Create SQL View for latest Version of the FHIR-Data for schema cds2db_out

-------- VIEW cds2db_out.v_encounter_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_encounter_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_encounter_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_encounter_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.enc_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.enc_id AS ID
            FROM db_log.encounter_raw q
            JOIN (
                SELECT v.enc_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.enc_id,
                           COALESCE(i.enc_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.encounter_raw i
                    JOIN (
                        SELECT j.enc_id AS ID,
                               COALESCE(MAX(j.enc_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.encounter_raw j
                        GROUP BY j.enc_id
                    ) m
                    ON i.enc_id = m.ID
                       AND COALESCE(i.enc_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.enc_id, v.LAST_VERSION_DATE
            ) w
            ON q.enc_id = w.ID
               AND COALESCE(q.enc_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_patient_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_patient_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_patient_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_patient_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.pat_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.pat_id AS ID
            FROM db_log.patient_raw q
            JOIN (
                SELECT v.pat_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.pat_id,
                           COALESCE(i.pat_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.patient_raw i
                    JOIN (
                        SELECT j.pat_id AS ID,
                               COALESCE(MAX(j.pat_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.patient_raw j
                        GROUP BY j.pat_id
                    ) m
                    ON i.pat_id = m.ID
                       AND COALESCE(i.pat_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.pat_id, v.LAST_VERSION_DATE
            ) w
            ON q.pat_id = w.ID
               AND COALESCE(q.pat_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_condition_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_condition_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_condition_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_condition_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.con_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.con_id AS ID
            FROM db_log.condition_raw q
            JOIN (
                SELECT v.con_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.con_id,
                           COALESCE(i.con_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.condition_raw i
                    JOIN (
                        SELECT j.con_id AS ID,
                               COALESCE(MAX(j.con_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.condition_raw j
                        GROUP BY j.con_id
                    ) m
                    ON i.con_id = m.ID
                       AND COALESCE(i.con_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.con_id, v.LAST_VERSION_DATE
            ) w
            ON q.con_id = w.ID
               AND COALESCE(q.con_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medication_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medication_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medication_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medication_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.med_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.med_id AS ID
            FROM db_log.medication_raw q
            JOIN (
                SELECT v.med_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.med_id,
                           COALESCE(i.med_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.medication_raw i
                    JOIN (
                        SELECT j.med_id AS ID,
                               COALESCE(MAX(j.med_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.medication_raw j
                        GROUP BY j.med_id
                    ) m
                    ON i.med_id = m.ID
                       AND COALESCE(i.med_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.med_id, v.LAST_VERSION_DATE
            ) w
            ON q.med_id = w.ID
               AND COALESCE(q.med_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medicationrequest_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationrequest_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medicationrequest_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medicationrequest_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.medreq_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.medreq_id AS ID
            FROM db_log.medicationrequest_raw q
            JOIN (
                SELECT v.medreq_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.medreq_id,
                           COALESCE(i.medreq_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.medicationrequest_raw i
                    JOIN (
                        SELECT j.medreq_id AS ID,
                               COALESCE(MAX(j.medreq_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.medicationrequest_raw j
                        GROUP BY j.medreq_id
                    ) m
                    ON i.medreq_id = m.ID
                       AND COALESCE(i.medreq_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.medreq_id, v.LAST_VERSION_DATE
            ) w
            ON q.medreq_id = w.ID
               AND COALESCE(q.medreq_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medicationadministration_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationadministration_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medicationadministration_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medicationadministration_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.medadm_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.medadm_id AS ID
            FROM db_log.medicationadministration_raw q
            JOIN (
                SELECT v.medadm_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.medadm_id,
                           COALESCE(i.medadm_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.medicationadministration_raw i
                    JOIN (
                        SELECT j.medadm_id AS ID,
                               COALESCE(MAX(j.medadm_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.medicationadministration_raw j
                        GROUP BY j.medadm_id
                    ) m
                    ON i.medadm_id = m.ID
                       AND COALESCE(i.medadm_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.medadm_id, v.LAST_VERSION_DATE
            ) w
            ON q.medadm_id = w.ID
               AND COALESCE(q.medadm_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medicationstatement_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationstatement_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medicationstatement_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medicationstatement_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.medstat_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.medstat_id AS ID
            FROM db_log.medicationstatement_raw q
            JOIN (
                SELECT v.medstat_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.medstat_id,
                           COALESCE(i.medstat_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.medicationstatement_raw i
                    JOIN (
                        SELECT j.medstat_id AS ID,
                               COALESCE(MAX(j.medstat_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.medicationstatement_raw j
                        GROUP BY j.medstat_id
                    ) m
                    ON i.medstat_id = m.ID
                       AND COALESCE(i.medstat_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.medstat_id, v.LAST_VERSION_DATE
            ) w
            ON q.medstat_id = w.ID
               AND COALESCE(q.medstat_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_observation_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_observation_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_observation_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_observation_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.obs_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.obs_id AS ID
            FROM db_log.observation_raw q
            JOIN (
                SELECT v.obs_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.obs_id,
                           COALESCE(i.obs_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.observation_raw i
                    JOIN (
                        SELECT j.obs_id AS ID,
                               COALESCE(MAX(j.obs_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.observation_raw j
                        GROUP BY j.obs_id
                    ) m
                    ON i.obs_id = m.ID
                       AND COALESCE(i.obs_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.obs_id, v.LAST_VERSION_DATE
            ) w
            ON q.obs_id = w.ID
               AND COALESCE(q.obs_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_diagnosticreport_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_diagnosticreport_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_diagnosticreport_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_diagnosticreport_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.diagrep_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.diagrep_id AS ID
            FROM db_log.diagnosticreport_raw q
            JOIN (
                SELECT v.diagrep_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.diagrep_id,
                           COALESCE(i.diagrep_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.diagnosticreport_raw i
                    JOIN (
                        SELECT j.diagrep_id AS ID,
                               COALESCE(MAX(j.diagrep_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.diagnosticreport_raw j
                        GROUP BY j.diagrep_id
                    ) m
                    ON i.diagrep_id = m.ID
                       AND COALESCE(i.diagrep_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.diagrep_id, v.LAST_VERSION_DATE
            ) w
            ON q.diagrep_id = w.ID
               AND COALESCE(q.diagrep_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_servicerequest_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_servicerequest_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_servicerequest_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_servicerequest_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.servreq_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.servreq_id AS ID
            FROM db_log.servicerequest_raw q
            JOIN (
                SELECT v.servreq_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.servreq_id,
                           COALESCE(i.servreq_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.servicerequest_raw i
                    JOIN (
                        SELECT j.servreq_id AS ID,
                               COALESCE(MAX(j.servreq_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.servicerequest_raw j
                        GROUP BY j.servreq_id
                    ) m
                    ON i.servreq_id = m.ID
                       AND COALESCE(i.servreq_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.servreq_id, v.LAST_VERSION_DATE
            ) w
            ON q.servreq_id = w.ID
               AND COALESCE(q.servreq_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_procedure_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_procedure_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_procedure_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_procedure_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.proc_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.proc_id AS ID
            FROM db_log.procedure_raw q
            JOIN (
                SELECT v.proc_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.proc_id,
                           COALESCE(i.proc_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.procedure_raw i
                    JOIN (
                        SELECT j.proc_id AS ID,
                               COALESCE(MAX(j.proc_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.procedure_raw j
                        GROUP BY j.proc_id
                    ) m
                    ON i.proc_id = m.ID
                       AND COALESCE(i.proc_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.proc_id, v.LAST_VERSION_DATE
            ) w
            ON q.proc_id = w.ID
               AND COALESCE(q.proc_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_consent_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_consent_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_consent_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_consent_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.cons_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.cons_id AS ID
            FROM db_log.consent_raw q
            JOIN (
                SELECT v.cons_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.cons_id,
                           COALESCE(i.cons_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.consent_raw i
                    JOIN (
                        SELECT j.cons_id AS ID,
                               COALESCE(MAX(j.cons_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.consent_raw j
                        GROUP BY j.cons_id
                    ) m
                    ON i.cons_id = m.ID
                       AND COALESCE(i.cons_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.cons_id, v.LAST_VERSION_DATE
            ) w
            ON q.cons_id = w.ID
               AND COALESCE(q.cons_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_location_raw_last_version ------------ raw
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_location_raw_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_location_raw_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_location_raw_last_version AS (
            SELECT q.*,
                   COALESCE(q.loc_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                   q.loc_id AS ID
            FROM db_log.location_raw q
            JOIN (
                SELECT v.loc_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.loc_id,
                           COALESCE(i.loc_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM db_log.location_raw i
                    JOIN (
                        SELECT j.loc_id AS ID,
                               COALESCE(MAX(j.loc_meta_lastupdated), MAX(TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE
                        FROM db_log.location_raw j
                        GROUP BY j.loc_id
                    ) m
                    ON i.loc_id = m.ID
                       AND COALESCE(i.loc_meta_lastupdated, TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.loc_id, v.LAST_VERSION_DATE
            ) w
            ON q.loc_id = w.ID
               AND COALESCE(q.loc_meta_lastupdated, TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_location_raw_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

