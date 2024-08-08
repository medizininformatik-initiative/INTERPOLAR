    -- Start <%TABLE_NAME%>
    FOR current_record IN (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                WHERE <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_COMPARE%>
                      ;

                IF data_count = 0
                THEN
                    INSERT INTO <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
                        <%TABLE_NAME%>_id,
                        <%IF TAGS "\bTYPED\b" "<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                        <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_COLUMNS%>
                        input_datetime
                    )
                    VALUES (
                        current_record.<%TABLE_NAME%>_id,
                        <%IF TAGS "\bTYPED\b" "current_record.<%SIMPLE_TABLE_NAME%>_raw_id,"%>
                        <%LOOP_COLS_SUB_LOOP_TABS_SUB_copy_function_CURRENT_RECORD%>
                        current_record.input_datetime
                    );

                    -- Delete importet datasets
                    DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
                ELSE
                UPDATE <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
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
                    WHERE <%TABLE_NAME%>_id = current_record.<%TABLE_NAME%>_id;
            END;
    END LOOP;
    -- END <%TABLE_NAME%>

