------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
    data_count_all integer;
    last_pro_nr INT;
BEGIN
    -- Copy Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>
    SELECT nextval('db.db_seq') INTO last_pro_nr; -- Get the processing number for this process

<%LOOP_TABS_SUB_copy_function%>


    IF data_count_all>0 THEN
       SELECT db.take_over_last_check_date();
    END IF;
END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------


