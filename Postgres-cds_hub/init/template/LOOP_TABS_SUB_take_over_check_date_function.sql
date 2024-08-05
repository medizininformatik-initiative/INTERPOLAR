    -- Transfer last check date from raw to data - if no data changes have occurred

    -- from  <%OWNER_SCHEMA%>.<%TABLE_NAME%> to <%SCHEMA_2%>.<%TABLE_NAME_2%>
    FOR current_record IN (SELECT DISTINCT p.<%TABLE_NAME%>_id AS id, r.last_check_datetime
                           FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> p, <%OWNER_SCHEMA%>.<%TABLE_NAME%> r
                           WHERE p.<%TABLE_NAME%>_id = r.<%TABLE_NAME_2%>_id AND (p.last_check_datetime < r.last_check_datetime OR p.last_check_datetime IS NULL)
                          )
        LOOP
            BEGIN
		        UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%> target_record
                SET last_check_datetime = current_record.last_check_datetime
                WHERE <%TABLE_NAME%>_id = current_record.id
                ;
            EXCEPTION
                WHEN OTHERS THEN
		    NULL;
            END;
    END LOOP;
    -- END <%SIMPLE_TABLE_NAME%>
