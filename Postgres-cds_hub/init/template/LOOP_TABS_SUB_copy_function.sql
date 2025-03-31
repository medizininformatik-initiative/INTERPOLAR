
        -----------------------------------------------------------------------------------------------------------------------
        -- Start <%TABLE_NAME%>  --------   <%TABLE_NAME%>  --------   <%TABLE_NAME%>  --------   <%TABLE_NAME%>
        err_section:='<%TABLE_NAME%>-01';
        SELECT COUNT(1) INTO data_count_all FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            <%COPY_FUNC_NAME%>'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='<%TABLE_NAME%>-05';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';

            FOR current_record IN (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='<%TABLE_NAME%>-10';    err_schema:='<%OWNER_SCHEMA%>';    err_table:='<%TABLE_NAME%>';
                        SELECT count(1) INTO data_count
                        FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='<%TABLE_NAME%>-15';    err_schema:='<%OWNER_SCHEMA%>';    err_table:='<%TABLE_NAME%>';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
                                <%TABLE_NAME%>_id,
                                <%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                                <%LOOP_COLS "<%COLUMN_NAME%>,"%>
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.<%TABLE_NAME%>_id,
                                <%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "current_record.<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                                <%LOOP_COLS "current_record.<%COLUMN_NAME%>,"%>
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='<%TABLE_NAME%>-20';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
                            DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
                        ELSE
                            err_section:='<%TABLE_NAME%>-25';    err_schema:='<%OWNER_SCHEMA%>';    err_table:='<%TABLE_NAME%>';
                            data_count_update:=data_count_update+1;
                            UPDATE <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            -- Delete updatet datasets
                            err_section:='<%TABLE_NAME%>-30';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
                            DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='<%TABLE_NAME%>-35';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
                            UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%>
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: <%COPY_FUNC_NAME%>'
                            , last_processing_nr = last_pro_nr
                            WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.<%COPY_FUNC_NAME%>()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='<%TABLE_NAME%>-40';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
                    IF data_count_last_status_set>=COALESCE(data_count_last_status_max,10) THEN -- Info ausgeben
                        SELECT res FROM pg_background_result(pg_background_launch(
                        'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                        WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                        ))  AS t(res TEXT) INTO erg;
                        data_count_last_status_set:=0;
                    END IF;

            END LOOP;

            data_count_pro_upd:=data_count_pro_upd+data_count_update; -- count update datasets to all upd ds

            IF data_import_hist_every_dataset=1 and data_count_all>0 THEN -- documentenion is switcht on
                err_section:='<%TABLE_NAME%>-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT <%TABLE_NAME%>_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , '<%OWNER_SCHEMA%>' AS schema_name, '<%TABLE_NAME%>' AS table_name, last_pro_datetime, current_dataset_status, '<%COPY_FUNC_NAME%>' AS function_name FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='<%TABLE_NAME%>-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', '<%OWNER_SCHEMA%>', '<%TABLE_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', '<%OWNER_SCHEMA%>', '<%TABLE_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', '<%OWNER_SCHEMA%>', '<%TABLE_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='<%TABLE_NAME%>-50';    err_schema:='/';    err_table:='/';
        -- END <%TABLE_NAME%>  --------   <%TABLE_NAME%>  --------   <%TABLE_NAME%>  --------   <%TABLE_NAME%>
        -----------------------------------------------------------------------------------------------------------------------

