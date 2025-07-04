    ---- Start check <%SCHEMA_2%>.<%TABLE_NAME%> - count ----
    err_section:='CHECK-16';    err_schema:='<%SCHEMA_2%>';    err_table:='<%SCHEMA_2%>.<%TABLE_NAME%>';
    IF data_count_pro_all=0 AND COALESCE(max_last_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen und es eine max lpn gibt - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO temp_int FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE last_processing_nr=max_last_pro_nr; -- erst schauen ob es Treffer in dieser Tabelle gibt mit letzter processing number
        IF temp_int>0 THEN
            SELECT COUNT(1) INTO temp_int FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE last_processing_nr=max_last_pro_nr; -- und es auch Treffer in dieser Tabelle gibt mit nicht letzter processing number
            IF temp_int>0 THEN
                SELECT COUNT(1) INTO data_count_pro_all
    	        FROM (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE last_processing_nr!=max_last_pro_nr) r
                , (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE last_processing_nr=max_last_pro_nr) t
                , <%SCHEMA_2%>.<%TABLE_NAME%> r2
    	        WHERE r.last_processing_nr=r2.last_processing_nr AND r2.<%TABLE_NAME%>_id=t.<%TABLE_NAME%>_id;
            END IF;
        END IF;

--/*Test_<%TABLE_NAME%>*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test_<%TABLE_NAME%>*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''<%TABLE_NAME%>'', ''<%SCHEMA_2%>'', ''max_last_pro_nr / data_count_pro_all / count :'||max_last_pro_nr||' / '||data_count_pro_all||' / '||temp_int||''' );'
--/*Test_<%TABLE_NAME%>*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check <%SCHEMA_2%>.<%TABLE_NAME_2%> - count ----

