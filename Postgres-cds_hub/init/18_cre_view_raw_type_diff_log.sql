--Create SQL View not Typed Datasets in Schema cds2db_out
CREATE OR REPLACE VIEW cds2db_out.v_encounter AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.encounter_raw UNION SELECT * FROM cds2db_in.encounter_raw) m WHERE m.encounter_id NOT IN (SELECT encounter_raw_id FROM db_log.encounter UNION SELECT encounter_raw_id FROM cds2db_in.encounter));
CREATE OR REPLACE VIEW cds2db_out.v_patient AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.patient_raw UNION SELECT * FROM cds2db_in.patient_raw) m WHERE m.patient_id NOT IN (SELECT patient_raw_id FROM db_log.patient UNION SELECT patient_raw_id FROM cds2db_in.patient));
CREATE OR REPLACE VIEW cds2db_out.v_condition AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.condition_raw UNION SELECT * FROM cds2db_in.condition_raw) m WHERE m.condition_id NOT IN (SELECT condition_raw_id FROM db_log.condition UNION SELECT condition_raw_id FROM cds2db_in.condition));
CREATE OR REPLACE VIEW cds2db_out.v_medication AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.medication_raw UNION SELECT * FROM cds2db_in.medication_raw) m WHERE m.medication_id NOT IN (SELECT medication_raw_id FROM db_log.medication UNION SELECT medication_raw_id FROM cds2db_in.medication));
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.medicationrequest_raw UNION SELECT * FROM cds2db_in.medicationrequest_raw) m WHERE m.medicationrequest_id NOT IN (SELECT medicationrequest_raw_id FROM db_log.medicationrequest UNION SELECT medicationrequest_raw_id FROM cds2db_in.medicationrequest));
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.medicationadministration_raw UNION SELECT * FROM cds2db_in.medicationadministration_raw) m WHERE m.medicationadministration_id NOT IN (SELECT medicationadministration_raw_id FROM db_log.medicationadministration UNION SELECT medicationadministration_raw_id FROM cds2db_in.medicationadministration));
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.medicationstatement_raw UNION SELECT * FROM cds2db_in.medicationstatement_raw) m WHERE m.medicationstatement_id NOT IN (SELECT medicationstatement_raw_id FROM db_log.medicationstatement UNION SELECT medicationstatement_raw_id FROM cds2db_in.medicationstatement));
CREATE OR REPLACE VIEW cds2db_out.v_observation AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.observation_raw UNION SELECT * FROM cds2db_in.observation_raw) m WHERE m.observation_id NOT IN (SELECT observation_raw_id FROM db_log.observation UNION SELECT observation_raw_id FROM cds2db_in.observation));
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.diagnosticreport_raw UNION SELECT * FROM cds2db_in.diagnosticreport_raw) m WHERE m.diagnosticreport_id NOT IN (SELECT diagnosticreport_raw_id FROM db_log.diagnosticreport UNION SELECT diagnosticreport_raw_id FROM cds2db_in.diagnosticreport));
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.servicerequest_raw UNION SELECT * FROM cds2db_in.servicerequest_raw) m WHERE m.servicerequest_id NOT IN (SELECT servicerequest_raw_id FROM db_log.servicerequest UNION SELECT servicerequest_raw_id FROM cds2db_in.servicerequest));
CREATE OR REPLACE VIEW cds2db_out.v_procedure AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.procedure_raw UNION SELECT * FROM cds2db_in.procedure_raw) m WHERE m.procedure_id NOT IN (SELECT procedure_raw_id FROM db_log.procedure UNION SELECT procedure_raw_id FROM cds2db_in.procedure));
CREATE OR REPLACE VIEW cds2db_out.v_consent AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.consent_raw UNION SELECT * FROM cds2db_in.consent_raw) m WHERE m.consent_id NOT IN (SELECT consent_raw_id FROM db_log.consent UNION SELECT consent_raw_id FROM cds2db_in.consent));
CREATE OR REPLACE VIEW cds2db_out.v_location AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.location_raw UNION SELECT * FROM cds2db_in.location_raw) m WHERE m.location_id NOT IN (SELECT location_raw_id FROM db_log.location UNION SELECT location_raw_id FROM cds2db_in.location));
CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward AS ( SELECT DISTINCT m.* FROM (SELECT * FROM db_log.pids_per_ward_raw UNION SELECT * FROM cds2db_in.pids_per_ward_raw) m WHERE m.pids_per_ward_id NOT IN (SELECT pids_per_ward_raw_id FROM db_log.pids_per_ward UNION SELECT pids_per_ward_raw_id FROM cds2db_in.pids_per_ward));


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


