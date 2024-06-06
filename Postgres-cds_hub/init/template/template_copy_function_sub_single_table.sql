    -- Start <%SIMPLE_TABLE_NAME%>
    FOR current_record IN (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
        LOOP
            BEGIN
                SELECT count(1) INTO data_count
                FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                WHERE <%TEMPLATE_COPY_FUNCTION_SUB_COMPARE_COLUMNS%>
                      ;
    
                IF data_count = 0
                THEN
                    INSERT INTO <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
                        <%TEMPLATE_COPY_FUNCTION_SUB_COLUMNS%>,
                        input_datetime
                    )
                    VALUES (
                        <%TEMPLATE_COPY_FUNCTION_SUB_CURRENT_RECORD_COLUMNS%>,
                        current_record.input_datetime
                    );
    
                    -- Delete importet datasets
                    DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%SIMPLE_TABLE_NAME%>_id = current_record.<%SIMPLE_TABLE_NAME%>_id;
                ELSE
                UPDATE <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                    WHERE <%TEMPLATE_COPY_FUNCTION_SUB_COMPARE_COLUMNS%>
                    ;
    
                    -- Delete updatet datasets
                    DELETE FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE <%SIMPLE_TABLE_NAME%>_id = current_record.<%SIMPLE_TABLE_NAME%>_id;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%>
                    SET last_check_datetime = CURRENT_TIMESTAMP
                    , current_dataset_status = 'ERROR func: <%COPY_FUNC_NAME%> Msg:'||error_message
                    WHERE <%SIMPLE_TABLE_NAME%>_id = current_record.<%SIMPLE_TABLE_NAME%>_id;
            END;
    END LOOP;
    -- END <%SIMPLE_TABLE_NAME%>
