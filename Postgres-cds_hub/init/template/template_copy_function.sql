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
    -- Copy Functionname: copy_raw_cds_in_to_db_log - From: cds2db_in -> To: db_log

<%LOOP_TABS_SUB_copy_function%>

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log - SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------


