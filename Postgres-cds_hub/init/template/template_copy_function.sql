------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
    last_pro_nr INT;
BEGIN
    -- Copy Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>
    SELECT nextval('db.db_seq') INTO last_pro_nr; -- Get the processing number for this process

<%LOOP_TABS_SUB_copy_function%>

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------


