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
-- SCRIPTNAME:  25_adding_historical_raw_records.sql
-- TEMPLATE:  template_adding_historical_records.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_out
-- TAGS:  
-- TABLE_PREFIX:  v_
-- TABLE_POSTFIX:  _raw_last_version
-- RIGHTS:  
-- GRANT_TARGET_USER:  cds2db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  cds2db_in
-- TABLE_POSTFIX_2:  _raw
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

CREATE OR REPLACE FUNCTION db.add_hist_raw_records()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    erg VARCHAR;
BEGIN
-- Teilautomatisch erstellt - manuell nacharbeiten - Nachladen zu Patienten
-- cds2db_in.v_patient_raw_last_version Block entfernen
-- cds2db_in.v_medication_raw_last_version Block nach unten nehmen
-- cds2db_in.v_location_raw_last_version Block nach unten nehmen
-- ToDo Error log einbauen

--/* bis zur vollständig automatischen generierung auskommentiert um manuel erst zu verbessern

    ---- aus cds2db_out.v_encounter_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT encounter_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_encounter_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.enc_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.encounter_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.encounter_raw (
        encounter_raw_id,
        current_dataset_status
    )
    (
	SELECT
        encounter_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_encounter_raw_last_version q
        WHERE q.enc_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.encounter_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_condition_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT condition_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_condition_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.con_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.condition_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.condition_raw (
        condition_raw_id,
        current_dataset_status
    )
    (
	SELECT
        condition_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_condition_raw_last_version q
        WHERE q.con_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.condition_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_medicationrequest_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT medicationrequest_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_medicationrequest_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.medreq_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medicationrequest_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.medicationrequest_raw (
        medicationrequest_raw_id,
        current_dataset_status
    )
    (
	SELECT
        medicationrequest_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_medicationrequest_raw_last_version q
        WHERE q.medreq_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medicationrequest_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_medicationadministration_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT medicationadministration_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_medicationadministration_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.medadm_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medicationadministration_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.medicationadministration_raw (
        medicationadministration_raw_id,
        current_dataset_status
    )
    (
	SELECT
        medicationadministration_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_medicationadministration_raw_last_version q
        WHERE q.medadm_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medicationadministration_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_medicationstatement_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT medicationstatement_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_medicationstatement_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.medstat_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medicationstatement_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.medicationstatement_raw (
        medicationstatement_raw_id,
        current_dataset_status
    )
    (
	SELECT
        medicationstatement_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_medicationstatement_raw_last_version q
        WHERE q.medstat_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medicationstatement_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_observation_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT observation_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_observation_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.obs_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.observation_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.observation_raw (
        observation_raw_id,
        current_dataset_status
    )
    (
	SELECT
        observation_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_observation_raw_last_version q
        WHERE q.obs_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.observation_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_diagnosticreport_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT diagnosticreport_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_diagnosticreport_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.diagrep_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.diagnosticreport_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.diagnosticreport_raw (
        diagnosticreport_raw_id,
        current_dataset_status
    )
    (
	SELECT
        diagnosticreport_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_diagnosticreport_raw_last_version q
        WHERE q.diagrep_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.diagnosticreport_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_servicerequest_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT servicerequest_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_servicerequest_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.servreq_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.servicerequest_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.servicerequest_raw (
        servicerequest_raw_id,
        current_dataset_status
    )
    (
	SELECT
        servicerequest_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_servicerequest_raw_last_version q
        WHERE q.servreq_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.servicerequest_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_procedure_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT procedure_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_procedure_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.proc_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.procedure_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.procedure_raw (
        procedure_raw_id,
        current_dataset_status
    )
    (
	SELECT
        procedure_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_procedure_raw_last_version q
        WHERE q.proc_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.procedure_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_consent_raw_last_version Nachladen zu akt. Patienten --------------------------------------------
--	SELECT consent_raw_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM cds2db_out.v_consent_raw_last_version q    -- View mit letzten FHIR Daten 
--        WHERE q.cons_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.consent_raw) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.consent_raw (
        consent_raw_id,
        current_dataset_status
    )
    (
	SELECT
        consent_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_consent_raw_last_version q
        WHERE q.cons_patient_ref IN (SELECT pat_id FROM cds2db_in.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.consent_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

-- Zur Zeit noch statisch -Nachladen Resourcen ohne direkten Patientenbezug

    ---- aus cds2db_out.v_location_raw_last_--------------------------------------------
    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.location_raw (
        location_raw_id,
        current_dataset_status
    )
    (
	SELECT
        location_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_location_raw_last_version q
        WHERE q.loc_id IN (SELECT enc_location_ref FROM cds2db_in.encounter_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.location_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_medication_raw_last_version_--------------------------------------------
    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO cds2db_in.medication_raw (
        medication_raw_id,
        current_dataset_status
    )
    (
	SELECT
        medication_raw_id,
        ''reimported from database''
        FROM cds2db_out.v_medication_raw_last_version q
        WHERE q.med_id IN (SELECT medreq_medicationreference_ref FROM cds2db_in.medicationRequest_raw
                           UNION SELECT medadm_medicationreference_ref FROM cds2db_in.medicationadministration_raw
                           UNION SELECT medstat_medicationreference_ref FROM cds2db_in.medicationstatement_raw
                        )
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medication_raw)
    )'
    ))  AS t(res TEXT) INTO erg;

/**/ -- bis zur vollständig automatischen generierung auskommentiert um manuel erst zu verbessern
    RETURN 'ende';
END;
$$ LANGUAGE plpgsql;

