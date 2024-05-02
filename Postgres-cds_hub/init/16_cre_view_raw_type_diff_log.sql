CREATE OR REPLACE VIEW cds2db_out.v_condition_raw AS (select * from cds2db_in.Condition_rawPatient_raw where condition_raw_raw_id not in (select condition_raw_id from cds2db_in.Condition_raw));

CREATE OR REPLACE VIEW cds2db_out.v_medication_raw AS (select * from cds2db_in.Medication_rawCondition_raw where medication_raw_raw_id not in (select medication_raw_id from cds2db_in.Medication_raw));

CREATE OR REPLACE VIEW cds2db_out.v_medicationrequest_raw AS (select * from cds2db_in.MedicationRequest_rawMedication_raw where medicationrequest_raw_raw_id not in (select medicationrequest_raw_id from cds2db_in.MedicationRequest_raw));

CREATE OR REPLACE VIEW cds2db_out.v_medicationadministration_raw AS (select * from cds2db_in.MedicationAdministration_rawMedicationRequest_raw where medicationadministration_raw_raw_id not in (select medicationadministration_raw_id from cds2db_in.MedicationAdministration_raw));

CREATE OR REPLACE VIEW cds2db_out.v_medicationstatement_raw AS (select * from cds2db_in.MedicationStatement_rawMedicationAdministration_raw where medicationstatement_raw_raw_id not in (select medicationstatement_raw_id from cds2db_in.MedicationStatement_raw));

CREATE OR REPLACE VIEW cds2db_out.v_observation_raw AS (select * from cds2db_in.Observation_rawMedicationStatement_raw where observation_raw_raw_id not in (select observation_raw_id from cds2db_in.Observation_raw));

CREATE OR REPLACE VIEW cds2db_out.v_diagnosticreport_raw AS (select * from cds2db_in.DiagnosticReport_rawObservation_raw where diagnosticreport_raw_raw_id not in (select diagnosticreport_raw_id from cds2db_in.DiagnosticReport_raw));

CREATE OR REPLACE VIEW cds2db_out.v_servicerequest_raw AS (select * from cds2db_in.ServiceRequest_rawDiagnosticReport_raw where servicerequest_raw_raw_id not in (select servicerequest_raw_id from cds2db_in.ServiceRequest_raw));

CREATE OR REPLACE VIEW cds2db_out.v_procedure_raw AS (select * from cds2db_in.Procedure_rawServiceRequest_raw where procedure_raw_raw_id not in (select procedure_raw_id from cds2db_in.Procedure_raw));

CREATE OR REPLACE VIEW cds2db_out.v_consent_raw AS (select * from cds2db_in.Consent_rawProcedure_raw where consent_raw_raw_id not in (select consent_raw_id from cds2db_in.Consent_raw));

CREATE OR REPLACE VIEW cds2db_out.v_location_raw AS (select * from cds2db_in.Location_rawConsent_raw where location_raw_raw_id not in (select location_raw_id from cds2db_in.Location_raw));

CREATE OR REPLACE VIEW cds2db_out.v_pids_per_ward_raw AS (select * from cds2db_in.pids_per_ward_rawLocation_raw where pids_per_ward_raw_raw_id not in (select pids_per_ward_raw_id from cds2db_in.pids_per_ward_raw));

--SQL Role for Views in Schema cds2db_out
"
GRANT SELECT ON TABLE cds2db_out.v_encounter TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_encounter TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_patient_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_patient_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_condition_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_condition_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medication_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medication_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medicationrequest_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medicationadministration_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_medicationstatement_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_observation_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_observation_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_diagnosticreport_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_servicerequest_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_procedure_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_procedure_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_consent_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_consent_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;


GRANT SELECT ON TABLE cds2db_out.v_location_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_location_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;

GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward_raw TO cds2db_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE cds2db_out.v_pids_per_ward_raw TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA cds2db_out TO cds2db_user;
