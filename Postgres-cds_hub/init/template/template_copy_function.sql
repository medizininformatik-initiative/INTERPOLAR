------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS VOID AS $$
DECLARE
    record_count INT:=0;
    current_record record;
    data_count INT:=0;
    data_count_all INT:=0;
    last_pro_nr INT; -- Last processing number
    temp varchar;
    last_pro_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP; -- Last time function is startet
    timestamp_point timestamp not null DEFAULT CURRENT_TIMESTAMP; -- timestamp for different points in the function
BEGIN
    -- Copy Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>

<%LOOP_TABS_SUB_copy_function%>

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log - SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------


