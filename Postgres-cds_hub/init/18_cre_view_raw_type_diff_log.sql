--Create SQL View not Typed Datasets in Schema cds2db_out
CREATE OR REPLACE VIEW cds2db_out.v_encounter AS (select * from cds2db_in.Encounter_raw where encounter_raw_id not in (select encounter_id from cds2db_in.Encounter));
CREATE OR REPLACE VIEW cds2db_out.v_patient AS (select * from cds2db_in.Patient_raw where patient_raw_id not in (select patient_id from cds2db_in.Patient));
CREATE OR REPLACE VIEW cds2db_out.v_condition AS (select * from cds2db_in.Condition_raw where condition_raw_id not in (select condition_id from cds2db_in.Condition));
CREATE OR REPLACE VIEW cds2db_out.v_medication AS (select * from cds2db_in.Medication_raw where medication_raw_id not in (select medication_id from cds2db_in.Medication));
CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest AS (select * from cds2db_in.MedicationRequest_raw where medicationrequest_raw_id not in (select medicationrequest_id from cds2db_in.MedicationRequest));
CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration AS (select * from cds2db_in.MedicationAdministration_raw where medicationadministration_raw_id not in (select medicationadministration_id from cds2db_in.MedicationAdministration));
CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement AS (select * from cds2db_in.MedicationStatement_raw where medicationstatement_raw_id not in (select medicationstatement_id from cds2db_in.MedicationStatement));
CREATE OR REPLACE VIEW cds2db_out.v_observation AS (select * from cds2db_in.Observation_raw where observation_raw_id not in (select observation_id from cds2db_in.Observation));
CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport AS (select * from cds2db_in.DiagnosticReport_raw where diagnosticreport_raw_id not in (select diagnosticreport_id from cds2db_in.DiagnosticReport));
CREATE OR REPLACE VIEW cds2db_out.v_servicerequest AS (select * from cds2db_in.ServiceRequest_raw where servicerequest_raw_id not in (select servicerequest_id from cds2db_in.ServiceRequest));
CREATE OR REPLACE VIEW cds2db_out.v_procedure AS (select * from cds2db_in.Procedure_raw where procedure_raw_id not in (select procedure_id from cds2db_in.Procedure));
CREATE OR REPLACE VIEW cds2db_out.v_consent AS (select * from cds2db_in.Consent_raw where consent_raw_id not in (select consent_id from cds2db_in.Consent));
CREATE OR REPLACE VIEW cds2db_out.v_location AS (select * from cds2db_in.Location_raw where location_raw_id not in (select location_id from cds2db_in.Location));
CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward AS (select * from cds2db_in.pids_per_ward_raw where pids_per_ward_raw_id not in (select pids_per_ward_id from cds2db_in.pids_per_ward));


--SQL Role for Views in Schema cds2db_out
GRANT SELECT ON TABLE cds2db_out.v_encounter TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_encounter TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_patient TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_condition TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medication TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medicationrequest TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medicationadministration TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medicationstatement TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_observation TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_servicerequest TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_procedure TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_consent TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


GRANT SELECT ON TABLE cds2db_out.v_location TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_location TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;
