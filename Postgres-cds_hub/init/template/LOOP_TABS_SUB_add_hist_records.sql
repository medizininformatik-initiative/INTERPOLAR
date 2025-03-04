    ---- aus <%OWNER_SCHEMA%>.<%TABLE_NAME%> Nachladen zu akt. Patienten --------------------------------------------
    SELECT res FROM pg_background_result(pg_background_launch(
    'INSERT INTO <%SCHEMA_2%>.<%TABLE_NAME_2%> (
        <%TABLE_NAME_2%>_id,
		<%LOOP_COLS "<%COLUMN_NAME%>,"%>
        current_dataset_status
    )
    (
	SELECT
        <%TABLE_NAME_2%>_id,
		<%LOOP_COLS "<%COLUMN_NAME%>,"%>
        ''reimported from database''
        FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> q
        WHERE q.<%COLUMN_PREFIX%>_patient_ref IN (SELECT pat_id FROM <%SCHEMA_2%>.patient_raw)
        AND q.hash_index_col NOT IN (SELECT hash_index_col FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
    )'
    ))  AS t(res TEXT) INTO erg;

