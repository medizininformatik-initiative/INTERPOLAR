DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
EXECUTE $f$
------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS TEXT
SECURITY DEFINER
AS $inner$
DECLARE
    record_count INT:=0;
    current_record record;
    data_count INT:=0; -- Variable for process decision
    data_count_all INT:=0; -- Counting all new records of the entity
    data_count_new INT:=0; -- Count the newly inserted records of the entity
    data_count_update INT:=0; -- Counting the entitys verified records (update)
    data_count_pro_all INT:=0; -- Counting all records in this run
    data_count_pro_new INT:=0; -- Counting all new inserted records in this run
    data_count_pro_upd INT:=0; -- Counting updatet records in this run how are still there
    data_count_pro_processed INT:=0; -- Counting all records in this run which processed
    data_count_last_status_set INT:=0; -- Number of data records since the status was last set
    data_count_last_status_max INT:=10000; -- Max number of data records since the status was last set (parameter)
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
    -- Copy datasets - Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
    -- set start time
	SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
    ))  AS t(res TEXT) INTO timestamp_start;

    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' <%COPY_FUNC_NAME%>'', last_change_timestamp=CURRENT_TIMESTAMP
    WHERE pc_name=''timepoint_1_cron_job_data_transfer'''
    ) ) AS t(res TEXT) INTO erg;

    -- Counting datasets
    err_section:='HEAD-10';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT SUM(anz) INTO data_count_pro_all
    FROM ( SELECT 0::INT AS anz
    <%LOOP_TABS_SUB_copy_function2%>
    );

    -- Counting
    IF data_count_pro_all>0 THEN
         -- Copy Functionname: <%COPY_FUNC_NAME%> - From: <%SCHEMA_2%> -> To: <%OWNER_SCHEMA%>
        err_section:='HEAD-05';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes'; -- Get value for documentation of each individual data record

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


<%LOOP_TABS_SUB_copy_function%>

        err_section:='BOTTON-01';  err_schema:='db_log';    err_table:='data_import_hist';

        -- Collect and save counts for the function
        SELECT res FROM pg_background_result(pg_background_launch(
        'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US''
        )'))  AS t(res TEXT) INTO timestamp_end;

        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;

        err_section:='BOTTON-05';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_all', '<%OWNER_SCHEMA%>', '<%COPY_FUNC_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );

        err_section:='BOTTON-10';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_new', '<%OWNER_SCHEMA%>', '<%COPY_FUNC_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_pro_new, tmp_sec, 'Count all new Datasetzs '||temp);

        err_section:='BOTTON-15';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_upd', '<%OWNER_SCHEMA%>', '<%COPY_FUNC_NAME%>', last_pro_datetime, '<%COPY_FUNC_NAME%>', data_count_pro_upd, tmp_sec, 'Count all updatetd Datasetzs '||temp);

        -- Cleer current executed function and total number of records
        err_section:='BOTTOM-20';    err_schema:='db_log';    err_table:='db_process_control';
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
$inner$ LANGUAGE plpgsql;
-----------------------------
$f$;
--------------------------------------------------------------------
    END IF; -- do migration
END
$$;