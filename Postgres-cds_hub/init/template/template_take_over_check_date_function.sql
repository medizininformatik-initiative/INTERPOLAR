------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS VOID AS $$
DECLARE
    current_record record;
    new_last_pro_nr INT; -- New processing number for these sync
    max_last_pro_nr INT; -- Last processing number in core data
    last_raw_pro_nr INT; -- Last processing number in raw data - last new dataimport (offset)
BEGIN
    -- Take over last check datetime Functionname: <%COPY_FUNC_NAME%> the last_pro_nr - From: <%SCHEMA_2%> (raw) -> To: <%OWNER_SCHEMA%>
    
    -- Last import Nr in raw-data
    SELECT MAX(last_processing_nr) INTO last_raw_pro_nr FROM db_log.data_import_hist WHERE table_name like '%_raw' AND schema_name='db_log';

<%LOOP_TABS_SUB_take_over_check_date_function%>

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------


