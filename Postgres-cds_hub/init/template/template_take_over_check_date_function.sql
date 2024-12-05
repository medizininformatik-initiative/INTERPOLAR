------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    current_record record;
    new_last_pro_nr INT; -- New processing number for these sync
    last_raw_pro_nr INT; -- Last processing number in raw data - last new dataimport (offset)
    max_last_pro_nr INT; -- Last processing number over all entities
    last_pro_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP; -- Last time function is startet
    data_import_hist_every_dataset INT:=0; -- Value for documentation of each individual data record switch off
    temp varchar; -- Temporary variable for interim results
    data_count_pro_all INT:=0; -- Counting all records in this run
    data_count_update INT:=0;
    timestamp_start varchar;
    timestamp_end varchar;
    tmp_sec double precision:=0; -- Temporary variable to store execution time
    err_section varchar;
    err_schema varchar;
    err_table varchar;
    err_pid varchar;
BEGIN
    -- Take over last check datetime Functionname: <%COPY_FUNC_NAME%> the last_pro_nr - From: <%SCHEMA_2%> (raw) -> To: <%OWNER_SCHEMA%>
   
    -- set start time
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
	SELECT res FROM public.pg_background_result(public.pg_background_launch('SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'))  AS t(res TEXT) INTO timestamp_start;
    err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' <%COPY_FUNC_NAME%>'' WHERE pc_name=''timepoint_1_cron_job_data_transfer''');

    -- Last import Nr in raw-data
    err_section:='HEAD-05';    err_schema:='db_log';    err_table:='data_import_hist';
    SELECT MAX(last_processing_nr) INTO last_raw_pro_nr FROM db_log.data_import_hist WHERE table_name like '%_raw' AND schema_name='db_log';

    err_section:='HEAD-10';    err_schema:='db_config';    err_table:='db_parameter';
    SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes'; -- Get value for documentation of each individual data record

    -- Get the last processing number across all data to mark current data across the board
    err_section:='HEAD-15';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr
    FROM ( SELECT 0 AS last_processing_nr
    <%LOOP_TABS_SUB_take_over_check_date_function2%>

    );

    err_section:='HEAD-20';    err_schema:='db_log';    err_table:='/';
    
    IF max_last_pro_nr>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

    <%LOOP_TABS_SUB_take_over_check_date_function%>

    END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
    
    -- Collect and save counts for the function
    IF data_count_pro_all>0 THEN
        -- calculation of the time period
        err_section:='BOTTOM-01';    err_schema:='/';    err_table:='/';
        SELECT res FROM pg_background_result(pg_background_launch('SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'))  AS t(res TEXT) INTO timestamp_end;
    
        err_section:='BOTTOM-05';    err_schema:='/';    err_table:='/';
        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;
    
        err_section:='BOTTOM-10';    err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( new_last_pro_nr,'data_count_pro_all', '<%OWNER_SCHEMA%>', '<%COPY_FUNC_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );
    END IF;

    err_section:='BOTTOM-20';    err_schema:='/';    err_table:='/';
    RETURN 'Done db.<%COPY_FUNC_NAME%> - last_raw_pro_nr:'||new_last_pro_nr;

EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.<%COPY_FUNC_NAME%>()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler db.<%COPY_FUNC_NAME%> - '||SQLSTATE||' - last_raw_pro_nr:'||last_raw_pro_nr;
END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
-- Move to copy function - SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------
