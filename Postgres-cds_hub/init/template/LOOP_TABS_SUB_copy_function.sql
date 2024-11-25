    -- Start <%TABLE_NAME%>
    SELECT res FROM pg_background_result(pg_background_launch('SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'))  AS t(res TEXT) INTO timestamp_ent_start;
    PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' <%COPY_FUNC_NAME%> - <%TABLE_NAME%>'' WHERE pc_name=''timepoint_2_cron_job_data_transfer''');

    data_count:=0; data_count_update:=0; data_count_new:=0;
    SELECT COUNT(1) INTO data_count_all FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>; -- Counting new records in the source
    data_count_pro_all:=data_count_pro_all+data_count_all; -- Adding the new records
    FOR current_record IN (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                WHERE <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_COMPARE%>
                      ;

                IF data_count = 0
                THEN
                    data_count_new:=data_count_new+1;
                    INSERT INTO <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
                        <%TABLE_NAME%>_id,
                        <%IF TAGS "\bTYPED\b" "<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                        <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_COLUMNS%>
                        input_datetime,
                        last_check_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.<%TABLE_NAME%>_id,
                        <%IF TAGS "\bTYPED\b" "current_record.<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                        <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_CURRENT_RECORD%>
                        current_record.input_datetime,
                        last_pro_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
                ELSE
                data_count_update:=data_count_update+1;
                UPDATE <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                    SET last_check_datetime = last_pro_datetime
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    , last_processing_nr = last_pro_nr
                    WHERE <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_COMPARE%>
                    ;

                    -- Delete updatet datasets
                    DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%>
                    SET last_check_datetime = last_pro_datetime
                    , current_dataset_status = 'ERROR func: <%COPY_FUNC_NAME%>'
                    , last_processing_nr = last_pro_nr
                    WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
            END;
    END LOOP;

    IF data_import_hist_every_dataset=1 and data_count_all>0 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT <%TABLE_NAME%>_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , '<%OWNER_SCHEMA%>' AS schema_name, '<%TABLE_NAME%>' AS table_name, last_pro_datetime, current_dataset_status, '<%COPY_FUNC_NAME%>' AS function_name FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> d WHERE d.last_processing_nr=last_pro_nr
        EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
        );
    END IF;

    -- Collect and save counts for the entity
    IF data_count_all>0 THEN -- only if where are new data
        data_count_pro_new:=data_count_pro_new+data_count_new;
        -- calculation of the time period
        SELECT res FROM pg_background_result(pg_background_launch('SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'))  AS t(res TEXT) INTO timestamp_ent_end;    
        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;
    
        INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_new', '<%OWNER_SCHEMA%>', '<%TABLE_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_new, tmp_sec, temp);
    
        INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_update', '<%OWNER_SCHEMA%>', '<%TABLE_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_update, tmp_sec, temp);
    
        INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_all', '<%OWNER_SCHEMA%>', '<%TABLE_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_all, tmp_sec, temp);
    END IF;
    -- END <%TABLE_NAME%>
    -----------------------------------------------------------------------------------------------------------------------
