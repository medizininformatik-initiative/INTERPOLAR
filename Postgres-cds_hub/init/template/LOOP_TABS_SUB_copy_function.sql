    -- Start <%TABLE_NAME%>
    FOR current_record IN (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
        LOOP
            BEGIN
                IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                SELECT count(1) INTO data_count
                FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                WHERE <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_COMPARE%>
                      ;
                data_count_all := data_count_all + data_count;

                IF data_count = 0
                THEN
                    INSERT INTO <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
                        <%TABLE_NAME%>_id,
                        <%IF TAGS "\bTYPED\b" "<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                        <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_COLUMNS%>
                        input_datetime,
                        last_processing_nr
                    )
                    VALUES (
                        current_record.<%TABLE_NAME%>_id,
                        <%IF TAGS "\bTYPED\b" "current_record.<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                        <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_CURRENT_RECORD%>
                        current_record.input_datetime,
                        last_pro_nr
                    );

                    -- Delete importet datasets
                    DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
                ELSE
                UPDATE <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
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
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: <%COPY_FUNC_NAME%>'
                    , last_processing_nr = last_pro_nr
                    WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT <%TABLE_NAME%>_id AS table_primary_key, last_processing_nr, '<%OWNER_SCHEMA%>' AS schema_name, 'patient_raw' AS table_name, last_check_datetime, current_dataset_status, '<%COPY_FUNC_NAME%>' AS function_name FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%>
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- END <%TABLE_NAME%>
    -----------------------------------------------------------------------------------------------------------------------

