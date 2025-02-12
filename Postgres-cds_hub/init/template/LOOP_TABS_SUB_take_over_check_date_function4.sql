    ---- Start check <%SCHEMA_2%>.<%TABLE_NAME_2%> ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM <%SCHEMA_2%>.<%TABLE_NAME%> er
        JOIN <%SCHEMA_2%>.<%TABLE_NAME_2%> e ON er.<%TABLE_NAME%>_id = e.<%TABLE_NAME%>_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''<%TABLE_NAME%>'', ''<%SCHEMA_2%>'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check <%SCHEMA_2%>.<%TABLE_NAME_2%> ----

