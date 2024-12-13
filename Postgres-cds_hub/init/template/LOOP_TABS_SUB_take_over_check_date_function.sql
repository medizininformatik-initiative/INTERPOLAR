    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  <%OWNER_SCHEMA%>.<%TABLE_NAME%> to <%SCHEMA_2%>.<%TABLE_NAME_2%>

    -- Start <%TABLE_NAME_2%>    ----   <%TABLE_NAME_2%>    ----    <%TABLE_NAME_2%>
    err_section:='<%TABLE_NAME_2%>-01';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
    data_count_update:=0;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT <%TABLE_NAME%>_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE <%TABLE_NAME%>_id IN 
            (SELECT <%TABLE_NAME%>_id FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='<%TABLE_NAME_2%>-10';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='<%TABLE_NAME_2%>-15';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
                UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%>
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE <%TABLE_NAME%>_id = current_record.id;

                -- sync done
                err_section:='<%TABLE_NAME_2%>-20';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
                UPDATE <%OWNER_SCHEMA%>.<%TABLE_NAME%>
                SET last_processing_nr = new_last_pro_nr
                WHERE <%TABLE_NAME%>_id = current_record.id;

                err_section:='<%TABLE_NAME_2%>-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.<%COPY_FUNC_NAME%>()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='<%TABLE_NAME_2%>-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT <%TABLE_NAME%>_id AS table_primary_key, last_processing_nr, '<%OWNER_SCHEMA%>' AS schema_name, '<%TABLE_NAME%>' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%>
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT <%TABLE_NAME_2%>_id AS table_primary_key, last_processing_nr, '<%SCHEMA_2%>' AS schema_name, '<%TABLE_NAME_2%>' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- END <%TABLE_NAME_2%>  --------  <%TABLE_NAME_2%>  --------  <%TABLE_NAME_2%>  --------  <%TABLE_NAME_2%>
    -----------------------------------------------------------------------------------------------------------------------

