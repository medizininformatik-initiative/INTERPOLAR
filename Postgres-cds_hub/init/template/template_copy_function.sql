------------------------------
-- Start <%SIMPLE_TABLE_NAME%>
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
BEGIN
-- Copy Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>
    FOR current_record IN (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE current_dataset_status NOT LIKE 'DELETE after%')
        LOOP
            SELECT count(1) INTO data_count
            FROM <%OWNER_SCHEMA%>.<%TABLE_NAME%> target_record
            WHERE   <%TEMPLATE_COPY_FUNCTION_SUB_COMPARE_COLUMNS%>
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

                -- Update the timestamp for the last check/insert
                UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%>
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'DELETE after db_insert '||data_count::integer
                WHERE <%SIMPLE_TABLE_NAME%>_id = current_record.<%SIMPLE_TABLE_NAME%>_id;
	           ELSE
	              UPDATE <%OWNER_SCHEMA%>.<%TABLE_NAME%>
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                WHERE <%SIMPLE_TABLE_NAME%>_id = current_record.<%SIMPLE_TABLE_NAME%>_id;
            END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/10 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-- END <%SIMPLE_TABLE_NAME%>
-----------------------------


