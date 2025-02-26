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
    last_pro_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Last time function is startet
    data_import_hist_every_dataset INT:=0; -- Value for documentation of each individual data record switch off
    temp VARCHAR; -- Temporary variable for INTerim results
    data_count_pro_all INT:=0; -- Counting all records in this run
    data_count_update INT:=0; -- Counting updated per resource
    data_count_pro_processed INT:=0; -- Counting all records in this run which processed
    data_count_last_status_set INT:=0; -- Number of data records since the status was last set
    data_count_last_status_max INT:=0; -- Max number of data records since the status was last set (parameter)
    timestamp_start VARCHAR;
    timestamp_end VARCHAR;
    tmp_sec double precision:=0; -- Temporary variable to store execution time
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
    err_pid VARCHAR;
    erg VARCHAR;
BEGIN
    -- Take over last check datetime Functionname: <%COPY_FUNC_NAME%> the last_pro_nr - From: <%SCHEMA_2%> (raw) -> To: <%OWNER_SCHEMA%>
   
    -- set start time
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
	SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
    ))  AS t(res TEXT) INTO timestamp_start;
    
    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' <%COPY_FUNC_NAME%>'', last_change_timestamp=CURRENT_TIMESTAMP
    WHERE pc_name=''timepoint_1_cron_job_data_transfer'''
    ) ) AS t(res TEXT) INTO erg;

    -- Last import Nr in raw-data
    err_section:='HEAD-05';    err_schema:='db_log';    err_table:='data_import_hist';
    SELECT MAX(last_processing_nr) INTO last_raw_pro_nr FROM db_log.data_import_hist WHERE table_name like '%_raw' AND schema_name='db_log';

    -- Counting datasets
    err_section:='HEAD-10';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT SUM(anz) INTO data_count_pro_all
    FROM ( SELECT 0::INT AS anz
    <%LOOP_TABS_SUB_take_over_check_date_function3%>

    );

    IF data_count_pro_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
        err_section:='HEAD-15';    err_schema:='db_config';    err_table:='db_parameter';
	-- Get value for documentation of each individual data record
        SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes';

    	-- Number of data records then status have to be set
    	SELECT COALESCE(parameter_value::INT,10) INTO data_count_last_status_max FROM db_config.db_parameter WHERE parameter_name='number_of_data_records_after_which_the_status_is_updated';

        err_section:='HEAD-20';    err_schema:='db_config';    err_table:='db_process_control';
        -- Set current executed function and total number of records
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value=''db.<%COPY_FUNC_NAME%>()'', last_change_timestamp=CURRENT_TIMESTAMP
        WHERE pc_name=''current_executed_function'''
        ))  AS t(res TEXT) INTO erg;

        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_all||''', last_change_timestamp=CURRENT_TIMESTAMP
        WHERE pc_name=''current_total_number_of_records_in_the_function'''
        ))  AS t(res TEXT) INTO erg;

        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value=''0'', last_change_timestamp=CURRENT_TIMESTAMP
        WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
        ))  AS t(res TEXT) INTO erg;

        -- Get the last processing number across all data to mark current data across the board
        err_section:='HEAD-25';    err_schema:='db_log';    err_table:='- all_entitys -';
        SELECT MAX(last_processing_nr) INTO max_last_pro_nr
        FROM ( SELECT 0 AS last_processing_nr
        	<%LOOP_TABS_SUB_take_over_check_date_function2%>
    
        );

        err_section:='HEAD-30';    err_schema:='db_log';    err_table:='/';
    
    	<%LOOP_TABS_SUB_take_over_check_date_function%>
  
        -- Collect and save counts for the function
        err_section:='BOTTOM-01';    err_schema:='/';    err_table:='/';
        SELECT res FROM pg_background_result(pg_background_launch(
        'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
        ))  AS t(res TEXT) INTO timestamp_end;
    
        err_section:='BOTTOM-05';    err_schema:='/';    err_table:='/';
        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;
    
        err_section:='BOTTOM-10';    err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( new_last_pro_nr,'data_count_pro_all', '<%OWNER_SCHEMA%>', '<%COPY_FUNC_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );

        -- Cleer current executed function and total number of records
        err_section:='BOTTOM-15';    err_schema:='db_log';    err_table:='db_process_control';
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value='''', last_change_timestamp=CURRENT_TIMESTAMP
        WHERE pc_name=''current_executed_function'''
        ))  AS t(res TEXT) INTO erg;

        err_section:='BOTTOM-20';    err_schema:='db_log';    err_table:='db_process_control';
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value='''', last_change_timestamp=CURRENT_TIMESTAMP
        WHERE pc_name=''current_total_number_of_records_in_the_function'''
        ))  AS t(res TEXT) INTO erg;

        err_section:='BOTTOM-25';    err_schema:='db_log';    err_table:='db_process_control';
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value=''0'', last_change_timestamp=CURRENT_TIMESTAMP
        WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
        ))  AS t(res TEXT) INTO erg;
    END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

    err_section:='BOTTOM-30';    err_schema:='/';    err_table:='/';
    RETURN 'Done db.take_over_last_check_date - new_last_pro_nr:'||new_last_pro_nr;

EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.<%COPY_FUNC_NAME%>()' AS VARCHAR),     -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' e:'||erg AS VARCHAR),       -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(new_last_pro_nr AS INT)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler db.<%COPY_FUNC_NAME%> - '||SQLSTATE||' - last_raw_pro_nr:'||last_raw_pro_nr;
END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
-- Move to copy function - SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------
