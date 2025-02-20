-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-02-20 23:08:28
-- Rights definition file size        : 15611 Byte
--
-- Create SQL Tables in Schema "cds2db_out"
-- Create time: 2025-02-20 23:16:43
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  23_cre_view_typ_cds2db_last_version.sql
-- TEMPLATE:  template_cre_view5.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
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

--Create SQL View for latest Version of the FHIR-Data for schema cds2db_out
-------- VIEW cds2db_out.v_encounter_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_encounter_last_version AS (
  SELECT * FROM db_log.encounter q
  , (SELECT MAX(COALESCE(i.enc_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.enc_id AS ID FROM db_log.encounter i GROUP BY i.enc_id) w
      WHERE COALESCE(q.enc_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.enc_id = w.ID
);
-------- VIEW cds2db_out.v_patient_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_patient_last_version AS (
  SELECT * FROM db_log.patient q
  , (SELECT MAX(COALESCE(i.pat_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.pat_id AS ID FROM db_log.patient i GROUP BY i.pat_id) w
      WHERE COALESCE(q.pat_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.pat_id = w.ID
);
-------- VIEW cds2db_out.v_condition_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_condition_last_version AS (
  SELECT * FROM db_log.condition q
  , (SELECT MAX(COALESCE(i.con_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.con_id AS ID FROM db_log.condition i GROUP BY i.con_id) w
      WHERE COALESCE(q.con_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.con_id = w.ID
);
-------- VIEW cds2db_out.v_medication_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_medication_last_version AS (
  SELECT * FROM db_log.medication q
  , (SELECT MAX(COALESCE(i.med_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.med_id AS ID FROM db_log.medication i GROUP BY i.med_id) w
      WHERE COALESCE(q.med_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.med_id = w.ID
);
-------- VIEW cds2db_out.v_medicationrequest_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest_last_version AS (
  SELECT * FROM db_log.medicationrequest q
  , (SELECT MAX(COALESCE(i.medreq_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.medreq_id AS ID FROM db_log.medicationrequest i GROUP BY i.medreq_id) w
      WHERE COALESCE(q.medreq_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.medreq_id = w.ID
);
-------- VIEW cds2db_out.v_medicationadministration_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration_last_version AS (
  SELECT * FROM db_log.medicationadministration q
  , (SELECT MAX(COALESCE(i.medadm_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.medadm_id AS ID FROM db_log.medicationadministration i GROUP BY i.medadm_id) w
      WHERE COALESCE(q.medadm_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.medadm_id = w.ID
);
-------- VIEW cds2db_out.v_medicationstatement_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement_last_version AS (
  SELECT * FROM db_log.medicationstatement q
  , (SELECT MAX(COALESCE(i.medstat_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.medstat_id AS ID FROM db_log.medicationstatement i GROUP BY i.medstat_id) w
      WHERE COALESCE(q.medstat_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.medstat_id = w.ID
);
-------- VIEW cds2db_out.v_observation_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_observation_last_version AS (
  SELECT * FROM db_log.observation q
  , (SELECT MAX(COALESCE(i.obs_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.obs_id AS ID FROM db_log.observation i GROUP BY i.obs_id) w
      WHERE COALESCE(q.obs_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.obs_id = w.ID
);
-------- VIEW cds2db_out.v_diagnosticreport_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport_last_version AS (
  SELECT * FROM db_log.diagnosticreport q
  , (SELECT MAX(COALESCE(i.diagrep_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.diagrep_id AS ID FROM db_log.diagnosticreport i GROUP BY i.diagrep_id) w
      WHERE COALESCE(q.diagrep_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.diagrep_id = w.ID
);
-------- VIEW cds2db_out.v_servicerequest_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest_last_version AS (
  SELECT * FROM db_log.servicerequest q
  , (SELECT MAX(COALESCE(i.servreq_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.servreq_id AS ID FROM db_log.servicerequest i GROUP BY i.servreq_id) w
      WHERE COALESCE(q.servreq_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.servreq_id = w.ID
);
-------- VIEW cds2db_out.v_procedure_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_procedure_last_version AS (
  SELECT * FROM db_log.procedure q
  , (SELECT MAX(COALESCE(i.proc_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.proc_id AS ID FROM db_log.procedure i GROUP BY i.proc_id) w
      WHERE COALESCE(q.proc_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.proc_id = w.ID
);
-------- VIEW cds2db_out.v_consent_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_consent_last_version AS (
  SELECT * FROM db_log.consent q
  , (SELECT MAX(COALESCE(i.cons_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.cons_id AS ID FROM db_log.consent i GROUP BY i.cons_id) w
      WHERE COALESCE(q.cons_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.cons_id = w.ID
);
-------- VIEW cds2db_out.v_location_last_version -------------
CREATE OR REPLACE VIEW cds2db_out.v_location_last_version AS (
  SELECT * FROM db_log.location q
  , (SELECT MAX(COALESCE(i.loc_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.loc_id AS ID FROM db_log.location i GROUP BY i.loc_id) w
      WHERE COALESCE(q.loc_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.loc_id = w.ID
);

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


