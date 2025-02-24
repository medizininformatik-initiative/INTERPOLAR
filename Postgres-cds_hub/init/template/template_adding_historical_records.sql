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

<%LOOP_TABS_SUB_add_hist_records%>

-- Zur Zeit noch statisch -Nachladen Resourcen ohne direkten Patientenbezug

    ---- aus cds2db_out.v_location_raw_last_--------------------------------------------
-- Temp    SELECT res FROM pg_background_result(pg_background_launch(
-- Temp    'INSERT INTO cds2db_in.location_raw (
-- Temp        location_raw_id,
-- Temp        current_dataset_status
-- Temp    )
-- Temp    (
-- Temp	SELECT
-- Temp        location_raw_id,
-- Temp        ''reimported from database''
-- Temp        FROM cds2db_out.v_location_raw_last_version q
-- Temp        WHERE q.loc_id IN (SELECT enc_location_ref FROM cds2db_in.encounter_raw)
-- Temp        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.location_raw)
-- Temp    )'
-- Temp    ))  AS t(res TEXT) INTO erg;

    ---- aus cds2db_out.v_medication_raw_last_version_--------------------------------------------
-- Temp    SELECT res FROM pg_background_result(pg_background_launch(
-- Temp    'INSERT INTO cds2db_in.medication_raw (
-- Temp        medication_raw_id,
-- Temp        current_dataset_status
-- Temp    )
-- Temp    (
-- Temp	SELECT
-- Temp        medication_raw_id,
-- Temp        ''reimported from database''
-- Temp        FROM cds2db_out.v_medication_raw_last_version q
-- Temp        WHERE q.med_id IN (SELECT medreq_medicationreference_ref FROM cds2db_in.medicationRequest_raw
-- Temp                           UNION SELECT medadm_medicationreference_ref FROM cds2db_in.medicationadministration_raw
-- Temp                           UNION SELECT medstat_medicationreference_ref FROM cds2db_in.medicationstatement_raw
-- Temp                        )
-- Temp        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.medication_raw)
-- Temp    )'
-- Temp    ))  AS t(res TEXT) INTO erg;

    RETURN 'Ende ohne Funktionsausführung';
END;
$$ LANGUAGE plpgsql;
