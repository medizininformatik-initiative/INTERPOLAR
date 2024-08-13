------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
    data_count_all integer;
    last_pro_nr INT;
    temp varchar;
BEGIN
    -- Copy Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>
    SELECT pg_sleep(floor(random() * (12) + 1)::int); -- Start jobs at different times

<%LOOP_TABS_SUB_copy_function%>

    SELECT db.take_over_last_check_date() INTO temp;
END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------


