CREATE OR REPLACE FUNCTION db.add_hist_raw_records()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    erg VARCHAR;
BEGIN
-- Teilautomatisch erstellt - manuell nacharbeiten - Nachladen zu Patienten
-- cds2db_in.v_patient_raw_last_version Block entfernen
-- cds2db_in.v_medication_raw_last_version Block entfernen / allgemeiner Code der nur die notwendige raw_id kopiert ist statisch unten aufgeführt
-- cds2db_in.v_location_raw_last_version Block entfernen / allgemeiner Code der nur die notwendige raw_id kopiert ist statisch unten aufgeführt
-- ToDo Error log einbauen

<%LOOP_TABS_SUB_add_hist_records%>

-- Zur Zeit noch statisch - Nachladen Resourcen ohne direkten Patientenbezug

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

    RETURN 'Ende ohne Funktionsausführung';
END;
$$ LANGUAGE plpgsql;
