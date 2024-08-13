    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  <%OWNER_SCHEMA%>.<%TABLE_NAME%> to <%SCHEMA_2%>.<%TABLE_NAME_2%>

    -- Start <%TABLE_NAME_2%>
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT <%TABLE_NAME%>_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE <%TABLE_NAME%>_id IN 
            (SELECT <%TABLE_NAME%>_id FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE last_processing_nr=max_last_pro_nr AND last_processing_nr=last_raw_pro_nr -- only if resource part of last import
            )
            OR (last_processing_nr=last_raw_pro_nr and last_raw_pro_nr>max_last_pro_nr) -- the case that all of them had already been imported earlier but only a part was imported the last time
         )
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;


                UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%>
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE <%TABLE_NAME%>_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT <%TABLE_NAME_2%>_id AS table_primary_key, last_processing_nr, '<%SCHEMA_2%>' AS schema_name, '<%TABLE_NAME_2%>' AS table_name, last_check_datetime, current_dataset_status, 'copy_type_cds_in_to_db_log' FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End <%TABLE_NAME_2%>
    -----------------------------------------------------------------------------------------------------------------
