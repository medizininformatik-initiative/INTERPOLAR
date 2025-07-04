            ----------------- Update for <%TABLE_NAME%> ----------------------------------
            err_section:='UPDATE-35';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
--/*Test_<%TABLE_NAME%>*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test_<%TABLE_NAME%>*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''main update typed'' );'
--/*Test_<%TABLE_NAME%>*/))  AS t(res TEXT) INTO erg;

--/*AltDirekteAusführung_v1*/            UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%> t SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
--/*AltDirekteAusführung_v1*/            WHERE <%TABLE_NAME%>_id IN (SELECT <%TABLE_NAME%>_ID FROM <%SCHEMA_2%>.<%TABLE_NAME%> t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
--/*AltDirekteAusführung_v1*/            AND last_processing_nr!=new_last_pro_nr;

--/*AltDirekteAusführung_v2*/	         UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%> t SET
--/*AltDirekteAusführung_v2*/            -- last_check_datetime = last_pro_datetime,
--/*AltDirekteAusführung_v2*/            last_processing_nr = new_last_pro_nr
--/*AltDirekteAusführung_v2*/            FROM ( SELECT <%TABLE_NAME%>_ID FROM <%SCHEMA_2%>.<%TABLE_NAME%> r JOIN lpn_collection l ON r.last_processing_nr = l.lpn ) sub
--/*AltDirekteAusführung_v2*/            WHERE t.<%TABLE_NAME%>_ID = sub.<%TABLE_NAME%>_ID AND t.last_processing_nr != new_last_pro_nr;

-- v3 --
            FOR current_record IN (SELECT lpn FROM lpn_collection) LOOP
                SELECT res FROM public.pg_background_result(public.pg_background_launch(
                'UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%> t SET last_processing_nr = '||new_last_pro_nr||' FROM ( SELECT DISTINCT <%TABLE_NAME%>_ID FROM <%SCHEMA_2%>.<%TABLE_NAME%> r WHERE r.last_processing_nr = '||current_record.lpn||' ) sub WHERE t.<%TABLE_NAME%>_ID = sub.<%TABLE_NAME%>_ID AND t.last_processing_nr != '||new_last_pro_nr
                ) ) AS t(res TEXT) INTO erg;
            END LOOP;
-- v3 --
          ------------------------------------------------------------------------------------
            err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='<%TABLE_NAME%>';
--/*Test_<%TABLE_NAME%>*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test_<%TABLE_NAME%>*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''main update raw - new_last_pro_nr:'||new_last_pro_nr||' c.lpn:'||current_record.lpn||''' );'
--/*Test_<%TABLE_NAME%>*/))  AS t(res TEXT) INTO erg;

--/*AltDirekteAusführung_v2*/            UPDATE <%SCHEMA_2%>.<%TABLE_NAME%> r SET
--/*AltDirekteAusführung_v2*/            -- last_check_datetime = last_pro_datetime,
--/*AltDirekteAusführung_v2*/            last_processing_nr = new_last_pro_nr
--/*AltDirekteAusführung_v2*/            FROM ( SELECT <%TABLE_NAME%>_ID FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> t JOIN lpn_collection l ON t.last_processing_nr=l.lpn) sub
--/*AltDirekteAusführung_v2*/            WHERE r.<%TABLE_NAME%>_id = sub.<%TABLE_NAME%>_ID AND r.last_processing_nr < new_last_pro_nr;

-- v3 -- Übernehmen wenn typed neu geschrieben wurden auf raw
            FOR current_record IN (SELECT lpn FROM lpn_collection) LOOP
                SELECT res FROM public.pg_background_result(public.pg_background_launch(
                'UPDATE <%SCHEMA_2%>.<%TABLE_NAME%> rz SET last_processing_nr = '||new_last_pro_nr||' FROM ( SELECT <%TABLE_NAME%>_ID FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> t WHERE t.last_processing_nr > '||current_record.lpn||' ) sub  WHERE rz.<%TABLE_NAME%>_id = sub.<%TABLE_NAME%>_ID AND rz.last_processing_nr < '||new_last_pro_nr
                ) ) AS t(res TEXT) INTO erg;
            END LOOP;
-- v3 --

          ------------------------------------------------------------------------------------
-- Übernehmen lpn von teilmengen die gleich waren zu den typed
            err_section:='UPDATE-45';    err_schema:='db_log';    err_table:='<%TABLE_NAME%>';
--/*Test_<%TABLE_NAME%>*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test_<%TABLE_NAME%>*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''main update typed - new_last_pro_nr:'||new_last_pro_nr||' c.lpn:'||current_record.lpn||''' );'
--/*Test_<%TABLE_NAME%>*/))  AS t(res TEXT) INTO erg;

            FOR current_record IN (SELECT lpn FROM lpn_collection) LOOP
                SELECT res FROM public.pg_background_result(public.pg_background_launch(
                'UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%> t SET last_processing_nr = sub.last_processing_nr, last_check_datetime = sub.last_check_datetime, current_dataset_status = sub.current_dataset_status FROM (SELECT r.last_processing_nr, <%TABLE_NAME%>_ID, r.last_check_datetime, r.current_dataset_status FROM <%SCHEMA_2%>.<%TABLE_NAME%> r) sub WHERE sub.<%TABLE_NAME%>_id = t.<%TABLE_NAME%>_ID and sub.last_processing_nr>t.last_processing_nr'
                ) ) AS t(res TEXT) INTO erg;
            END LOOP;
