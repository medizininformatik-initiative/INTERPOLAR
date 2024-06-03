--Create SQL View not Typed Datasets in Schema cds2db_out
CREATE OR REPLACE VIEW cds2db_out.v_encounter AS (select * from db_log.encounter_raw where encounter_id not in (select encounter_raw_id from db_log.encounter union select encounter_raw_id from cds2db_in.encounter));
CREATE OR REPLACE VIEW cds2db_out.v_patient AS (select * from db_log.patient_raw where patient_id not in (select patient_raw_id from db_log.patient union select patient_raw_id from cds2db_in.patient));
CREATE OR REPLACE VIEW cds2db_out.v_condition AS (select * from db_log.condition_raw where condition_id not in (select condition_raw_id from db_log.condition union select condition_raw_id from cds2db_in.condition));
CREATE OR REPLACE VIEW cds2db_out.v_medication AS (select * from db_log.medication_raw where medication_id not in (select medication_raw_id from db_log.medication union select medication_raw_id from cds2db_in.medication));
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest AS (select * from db_log.medicationrequest_raw where medicationrequest_id not in (select medicationrequest_raw_id from db_log.medicationrequest union select medicationrequest_raw_id from cds2db_in.medicationrequest));
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration AS (select * from db_log.medicationadministration_raw where medicationadministration_id not in (select medicationadministration_raw_id from db_log.medicationadministration union select medicationadministration_raw_id from cds2db_in.medicationadministration));
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement AS (select * from db_log.medicationstatement_raw where medicationstatement_id not in (select medicationstatement_raw_id from db_log.medicationstatement union select medicationstatement_raw_id from cds2db_in.medicationstatement));
CREATE OR REPLACE VIEW cds2db_out.v_observation AS (select * from db_log.observation_raw where observation_id not in (select observation_raw_id from db_log.observation union select observation_raw_id from cds2db_in.observation));
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport AS (select * from db_log.diagnosticreport_raw where diagnosticreport_id not in (select diagnosticreport_raw_id from db_log.diagnosticreport union select diagnosticreport_raw_id from cds2db_in.diagnosticreport));
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest AS (select * from db_log.servicerequest_raw where servicerequest_id not in (select servicerequest_raw_id from db_log.servicerequest union select servicerequest_raw_id from cds2db_in.servicerequest));
CREATE OR REPLACE VIEW cds2db_out.v_procedure AS (select * from db_log.procedure_raw where procedure_id not in (select procedure_raw_id from db_log.procedure union select procedure_raw_id from cds2db_in.procedure));
CREATE OR REPLACE VIEW cds2db_out.v_consent AS (select * from db_log.consent_raw where consent_id not in (select consent_raw_id from db_log.consent union select consent_raw_id from cds2db_in.consent));
CREATE OR REPLACE VIEW cds2db_out.v_location AS (select * from db_log.location_raw where location_id not in (select location_raw_id from db_log.location union select location_raw_id from cds2db_in.location));
CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward AS (select * from db_log.pids_per_ward_raw where pids_per_ward_id not in (select pids_per_ward_raw_id from db_log.pids_per_ward union select pids_per_ward_raw_id from cds2db_in.pids_per_ward));


--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_encounter TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_patient TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_condition TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medication TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationrequest TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationadministration TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_medicationstatement TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_observation TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_servicerequest TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_procedure TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_consent TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_location TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_location TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward TO cds2db_user;
GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward TO db_user;
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


