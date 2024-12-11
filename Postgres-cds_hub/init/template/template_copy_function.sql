------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    record_count INT:=0;
    current_record record;
    data_count INT:=0; -- Variable for process decision
    data_count_all INT:=0; -- Counting all new records of the entity
    data_count_new INT:=0; -- Count the newly inserted records of the entity
    data_count_update INT:=0; -- Counting the entitys verified records (update)
    data_count_pro_all INT:=0; -- Counting all records in this run
    data_count_pro_new INT:=0; -- Counting all new inserted records in this run
    last_pro_nr INT; -- Last processing number
    temp VARCHAR; -- Temporary variable for interim results
    last_pro_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP; -- Last time function is startet
    data_import_hist_every_dataset INT:=0; -- Value for documentation of each individual data record switch off
    tmp_sec DOUBLE PRECISION:=0; -- Temporary variable to store execution time
    session_id TEXT; -- session id
    timestamp_start VARCHAR;
    timestamp_end VARCHAR;
    timestamp_ent_start VARCHAR;
    timestamp_ent_end VARCHAR;
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
    erg VARCHAR;
BEGIN
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
    -- set start time
	SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
    ))  AS t(res TEXT) INTO timestamp_start;
 
    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' <%COPY_FUNC_NAME%>'' WHERE pc_name=''timepoint_1_cron_job_data_transfer'''
    ) ) AS t(res TEXT) INTO erg;
 
    -- Copy Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>
    err_section:='HEAD-05';    err_schema:='db_config';    err_table:='db_parameter';
    SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes'; -- Get value for documentation of each individual data record

<%LOOP_TABS_SUB_copy_function%>

    err_section:='BOTTON-01';  err_schema:='db_log';    err_table:='data_import_hist';

    -- Collect and save counts for the function
    IF data_count_pro_all>0 THEN
        -- calculation of the time period
        SELECT res FROM pg_background_result(pg_background_launch(
        'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US''
        )'))  AS t(res TEXT) INTO timestamp_end;

        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;
    
        INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_all', '<%OWNER_SCHEMA%>', '<%COPY_FUNC_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );

        INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_new', '<%OWNER_SCHEMA%>', '<%COPY_FUNC_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_pro_new, tmp_sec, 'Count all new Datasetzs '||temp);
    END IF;
    err_section:='BOTTON-10';  err_schema:='/';    err_table:='/';

    RETURN 'Done db.<%COPY_FUNC_NAME%> - last_pro_nr:'||last_pro_nr;

EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.<%COPY_FUNC_NAME%>()' AS VARCHAR),     -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' e:'||erg AS VARCHAR),       -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler db.<%COPY_FUNC_NAME%> - '||SQLSTATE||' - last_pro_nr:'||last_pro_nr;
END;
$$ LANGUAGE plpgsql;

-- old start CopyJob CDS in 2 DB_log - SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------
