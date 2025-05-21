    ---- Start check <%SCHEMA_2%>.<%TABLE_NAME%> - count ----
    err_section:='CHECK-16';    err_schema:='<%SCHEMA_2%>';    err_table:='<%SCHEMA_2%>.<%TABLE_NAME%>';
    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM <%SCHEMA_2%>.<%TABLE_NAME%> r, <%SCHEMA_2%>.<%TABLE_NAME%> r2, <%SCHEMA_2%>.<%TABLE_NAME_2%> t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.<%TABLE_NAME%>_id=t.<%TABLE_NAME%>_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''<%TABLE_NAME%>'', ''<%SCHEMA_2%>'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check <%SCHEMA_2%>.<%TABLE_NAME_2%> - count ----

