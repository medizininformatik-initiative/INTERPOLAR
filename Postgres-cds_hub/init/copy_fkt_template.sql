CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
BEGIN
-- Copy Functionname: <%COPY_FKT_NAME%> - From: COPY_FUNC_FROM_SCHEMA -> To: <%TARGET_SCHEMA%>
    FOR current_record IN (SELECT * FROM <%COPY_FUNC_FROM_SCHEMA%>.<%TABLE_NAME%><%CFF_POSTFIX%> WHERE current_dataset_status NOT LIKE 'DELETE after%')
        LOOP
            SELECT count(1) INTO data_count
            FROM <%TARGET_SCHEMA%>.<%TABLE_NAME%><%POSTFIX%> target_record
            WHERE   target_record.* = current_record.* AND
			... Schleife Spalten mit Nutzdaten .. evtl. sind noch Organisatorsche auszuschließen
                    target_record.* = current_record.*
                  ;

            IF data_count=0
            THEN
                INSERT INTO <%TARGET_SCHEMA%>.<%TABLE_NAME%><%POSTFIX%> (
                    pat_id,
                    pat_identifier_value,
			... Schleife aller(!) Spalten die es in beiden Tabellen gibt - sollten alle sein
                    input_datetime
                )
                VALUES (
                    current_record.pat_id,
                    current_record.pat_identifier_value,
			... Schleife aller(!) Spalten
                    current_record.input_datetime
                );

                -- Aktualisiere den Zeitstempel für die letzte Überprüfung/Insert
                UPDATE <%COPY_FUNC_FROM_SCHEMA%>.<%TABLE_NAME%><%CFF_POSTFIX%>
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'DELETE after db_insert '||data_count::integer
                WHERE <%TABLE_NAME%><%CFF_POSTFIX%>_id = current_record.<%TABLE_NAME%><%POSTFIX%>_id;      
	    ELSE
	        UPDATE <%TARGET_SCHEMA%>.<%TABLE_NAME%><%POSTFIX%>
		SET last_check_datetime = CURRENT_TIMESTAMP -- Last Check/Import with same Data
        	WHERE   target_record.* = current_record.* AND
			... Schleife Spalten mit Nutzdaten .. evtl. sind noch Organisatorsche auszuschließen
                    target_record.* = current_record.*
                  ;
            END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- CopyJob Cron-Job - <%COPY_FKT_NAME%> From: COPY_FUNC_FROM_SCHEMA -> To: <%TARGET_SCHEMA%>
SELECT cron.schedule('*/10 * * * *', 'SELECT db.<%COPY_FKT_NAME%>();');

GRANT EXECUTE ON FUNCTION db.<%COPY_FKT_NAME%> TO db_user;
