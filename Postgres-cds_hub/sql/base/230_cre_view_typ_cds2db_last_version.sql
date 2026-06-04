-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-03 14:24:44
-- Rights definition file size        : 19645 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2026-06-04 17:59:40
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/230_cre_view_typ_cds2db_last_version.sql
-- TEMPLATE:  template_cre_view_last_version.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  TYPED
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _last_version
-- RIGHTS:  SELECT
-- GRANT_TARGET_USER:  cds2db_user
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
--Create SQL View for latest Version of the FHIR-Data for schema cds2db_out

-------- VIEW cds2db_out.v_encounter_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_encounter_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_encounter_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_encounter_last_version AS (
            SELECT m.* FROM db_log.encounter m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.enc_meta_lastupdated, q.enc_id FROM db_log.encounter q
                , (SELECT MAX(i.enc_meta_lastupdated) AS LAST_VERSION_DATE, i.enc_id AS ID FROM db_log.encounter i GROUP BY i.enc_id) w
	        WHERE q.enc_meta_lastupdated = w.LAST_VERSION_DATE AND q.enc_id = w.ID
                GROUP BY q.enc_meta_lastupdated, q.enc_id) f
            WHERE m.last_processing_nr = f.lpn and m.enc_meta_lastupdated = f.enc_meta_lastupdated and m.enc_id = f.enc_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_patient_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_patient_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_patient_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_patient_last_version AS (
            SELECT m.* FROM db_log.patient m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.pat_meta_lastupdated, q.pat_id FROM db_log.patient q
                , (SELECT MAX(i.pat_meta_lastupdated) AS LAST_VERSION_DATE, i.pat_id AS ID FROM db_log.patient i GROUP BY i.pat_id) w
	        WHERE q.pat_meta_lastupdated = w.LAST_VERSION_DATE AND q.pat_id = w.ID
                GROUP BY q.pat_meta_lastupdated, q.pat_id) f
            WHERE m.last_processing_nr = f.lpn and m.pat_meta_lastupdated = f.pat_meta_lastupdated and m.pat_id = f.pat_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_condition_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_condition_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_condition_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_condition_last_version AS (
            SELECT m.* FROM db_log.condition m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.con_meta_lastupdated, q.con_id FROM db_log.condition q
                , (SELECT MAX(i.con_meta_lastupdated) AS LAST_VERSION_DATE, i.con_id AS ID FROM db_log.condition i GROUP BY i.con_id) w
	        WHERE q.con_meta_lastupdated = w.LAST_VERSION_DATE AND q.con_id = w.ID
                GROUP BY q.con_meta_lastupdated, q.con_id) f
            WHERE m.last_processing_nr = f.lpn and m.con_meta_lastupdated = f.con_meta_lastupdated and m.con_id = f.con_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medication_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medication_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medication_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medication_last_version AS (
            SELECT m.* FROM db_log.medication m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.med_meta_lastupdated, q.med_id FROM db_log.medication q
                , (SELECT MAX(i.med_meta_lastupdated) AS LAST_VERSION_DATE, i.med_id AS ID FROM db_log.medication i GROUP BY i.med_id) w
	        WHERE q.med_meta_lastupdated = w.LAST_VERSION_DATE AND q.med_id = w.ID
                GROUP BY q.med_meta_lastupdated, q.med_id) f
            WHERE m.last_processing_nr = f.lpn and m.med_meta_lastupdated = f.med_meta_lastupdated and m.med_id = f.med_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medicationrequest_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationrequest_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medicationrequest_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medicationrequest_last_version AS (
            SELECT m.* FROM db_log.medicationrequest m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.medreq_meta_lastupdated, q.medreq_id FROM db_log.medicationrequest q
                , (SELECT MAX(i.medreq_meta_lastupdated) AS LAST_VERSION_DATE, i.medreq_id AS ID FROM db_log.medicationrequest i GROUP BY i.medreq_id) w
	        WHERE q.medreq_meta_lastupdated = w.LAST_VERSION_DATE AND q.medreq_id = w.ID
                GROUP BY q.medreq_meta_lastupdated, q.medreq_id) f
            WHERE m.last_processing_nr = f.lpn and m.medreq_meta_lastupdated = f.medreq_meta_lastupdated and m.medreq_id = f.medreq_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medicationadministration_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationadministration_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medicationadministration_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medicationadministration_last_version AS (
            SELECT m.* FROM db_log.medicationadministration m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.medadm_meta_lastupdated, q.medadm_id FROM db_log.medicationadministration q
                , (SELECT MAX(i.medadm_meta_lastupdated) AS LAST_VERSION_DATE, i.medadm_id AS ID FROM db_log.medicationadministration i GROUP BY i.medadm_id) w
	        WHERE q.medadm_meta_lastupdated = w.LAST_VERSION_DATE AND q.medadm_id = w.ID
                GROUP BY q.medadm_meta_lastupdated, q.medadm_id) f
            WHERE m.last_processing_nr = f.lpn and m.medadm_meta_lastupdated = f.medadm_meta_lastupdated and m.medadm_id = f.medadm_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_medicationstatement_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_medicationstatement_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_medicationstatement_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_medicationstatement_last_version AS (
            SELECT m.* FROM db_log.medicationstatement m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.medstat_meta_lastupdated, q.medstat_id FROM db_log.medicationstatement q
                , (SELECT MAX(i.medstat_meta_lastupdated) AS LAST_VERSION_DATE, i.medstat_id AS ID FROM db_log.medicationstatement i GROUP BY i.medstat_id) w
	        WHERE q.medstat_meta_lastupdated = w.LAST_VERSION_DATE AND q.medstat_id = w.ID
                GROUP BY q.medstat_meta_lastupdated, q.medstat_id) f
            WHERE m.last_processing_nr = f.lpn and m.medstat_meta_lastupdated = f.medstat_meta_lastupdated and m.medstat_id = f.medstat_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_observation_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_observation_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_observation_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_observation_last_version AS (
            SELECT m.* FROM db_log.observation m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.obs_meta_lastupdated, q.obs_id FROM db_log.observation q
                , (SELECT MAX(i.obs_meta_lastupdated) AS LAST_VERSION_DATE, i.obs_id AS ID FROM db_log.observation i GROUP BY i.obs_id) w
	        WHERE q.obs_meta_lastupdated = w.LAST_VERSION_DATE AND q.obs_id = w.ID
                GROUP BY q.obs_meta_lastupdated, q.obs_id) f
            WHERE m.last_processing_nr = f.lpn and m.obs_meta_lastupdated = f.obs_meta_lastupdated and m.obs_id = f.obs_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_diagnosticreport_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_diagnosticreport_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_diagnosticreport_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_diagnosticreport_last_version AS (
            SELECT m.* FROM db_log.diagnosticreport m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.diagrep_meta_lastupdated, q.diagrep_id FROM db_log.diagnosticreport q
                , (SELECT MAX(i.diagrep_meta_lastupdated) AS LAST_VERSION_DATE, i.diagrep_id AS ID FROM db_log.diagnosticreport i GROUP BY i.diagrep_id) w
	        WHERE q.diagrep_meta_lastupdated = w.LAST_VERSION_DATE AND q.diagrep_id = w.ID
                GROUP BY q.diagrep_meta_lastupdated, q.diagrep_id) f
            WHERE m.last_processing_nr = f.lpn and m.diagrep_meta_lastupdated = f.diagrep_meta_lastupdated and m.diagrep_id = f.diagrep_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_servicerequest_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_servicerequest_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_servicerequest_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_servicerequest_last_version AS (
            SELECT m.* FROM db_log.servicerequest m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.servreq_meta_lastupdated, q.servreq_id FROM db_log.servicerequest q
                , (SELECT MAX(i.servreq_meta_lastupdated) AS LAST_VERSION_DATE, i.servreq_id AS ID FROM db_log.servicerequest i GROUP BY i.servreq_id) w
	        WHERE q.servreq_meta_lastupdated = w.LAST_VERSION_DATE AND q.servreq_id = w.ID
                GROUP BY q.servreq_meta_lastupdated, q.servreq_id) f
            WHERE m.last_processing_nr = f.lpn and m.servreq_meta_lastupdated = f.servreq_meta_lastupdated and m.servreq_id = f.servreq_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_procedure_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_procedure_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_procedure_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_procedure_last_version AS (
            SELECT m.* FROM db_log.procedure m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.proc_meta_lastupdated, q.proc_id FROM db_log.procedure q
                , (SELECT MAX(i.proc_meta_lastupdated) AS LAST_VERSION_DATE, i.proc_id AS ID FROM db_log.procedure i GROUP BY i.proc_id) w
	        WHERE q.proc_meta_lastupdated = w.LAST_VERSION_DATE AND q.proc_id = w.ID
                GROUP BY q.proc_meta_lastupdated, q.proc_id) f
            WHERE m.last_processing_nr = f.lpn and m.proc_meta_lastupdated = f.proc_meta_lastupdated and m.proc_id = f.proc_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_consent_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_consent_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_consent_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_consent_last_version AS (
            SELECT m.* FROM db_log.consent m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.cons_meta_lastupdated, q.cons_id FROM db_log.consent q
                , (SELECT MAX(i.cons_meta_lastupdated) AS LAST_VERSION_DATE, i.cons_id AS ID FROM db_log.consent i GROUP BY i.cons_id) w
	        WHERE q.cons_meta_lastupdated = w.LAST_VERSION_DATE AND q.cons_id = w.ID
                GROUP BY q.cons_meta_lastupdated, q.cons_id) f
            WHERE m.last_processing_nr = f.lpn and m.cons_meta_lastupdated = f.cons_meta_lastupdated and m.cons_id = f.cons_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

-------- VIEW cds2db_out.v_location_last_version ------------typed
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = 'cds2db_out' AND table_name = 'v_location_last_version'
        ) THEN
            DROP VIEW cds2db_out.v_location_last_version; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW cds2db_out.v_location_last_version AS (
            SELECT m.* FROM db_log.location m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.loc_meta_lastupdated, q.loc_id FROM db_log.location q
                , (SELECT MAX(i.loc_meta_lastupdated) AS LAST_VERSION_DATE, i.loc_id AS ID FROM db_log.location i GROUP BY i.loc_id) w
	        WHERE q.loc_meta_lastupdated = w.LAST_VERSION_DATE AND q.loc_id = w.ID
                GROUP BY q.loc_meta_lastupdated, q.loc_id) f
            WHERE m.last_processing_nr = f.lpn and m.loc_meta_lastupdated = f.loc_meta_lastupdated and m.loc_id = f.loc_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;

--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_location_last_version TO cds2db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

