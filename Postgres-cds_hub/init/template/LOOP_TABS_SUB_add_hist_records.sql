    ---- aus <%OWNER_SCHEMA%>.<%TABLE_NAME%> Nachladen zu akt. Patienten --------------------------------------------
--	SELECT <%TABLE_NAME_2%>_id,
--  !!! Aufzählung der FHIR Spalten fehlt noch !!!
--        'reimported from database'
--        FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> q    -- View mit letzten FHIR Daten 
--        WHERE q.<%COLUMN_PREFIX%>_patient_ref IN (SELECT pat_id FROM <%SCHEMA_2%>.patient_raw) -- Für alle aktuellen Patienten
--        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>) -- wenn nocht nicht vorhanden durch laden vom FHIR Server

    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO <%SCHEMA_2%>.<%TABLE_NAME_2%> (
        <%TABLE_NAME_2%>_id,
        current_dataset_status
    )
    (
	SELECT
        <%TABLE_NAME_2%>_id,
        ''reimported from database''
        FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> q
        WHERE q.<%COLUMN_PREFIX%>_patient_ref IN (SELECT pat_id FROM <%SCHEMA_2%>.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
    )'
    ))  AS t(res TEXT) INTO erg;

