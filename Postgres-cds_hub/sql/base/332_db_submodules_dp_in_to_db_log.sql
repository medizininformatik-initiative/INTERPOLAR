-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/sql/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-02-17 09:36:28
-- Rights definition file size        : 19645 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2026-02-26 16:07:10
-- TABLE_DESCRIPTION:  ./R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx[table_description]
-- SCRIPTNAME:  base/331_cre_table_dataproc_submodules_log.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db_log_user
-- OWNER_SCHEMA:  db_log
-- TAGS:  INT_ID
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  db_log_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  base/332_db_submodules_dp_in_to_db_log.sql
-- COPY_FUNC_TEMPLATE:  template_copy_function.sql
-- COPY_FUNC_NAME:  copy_submodules_dp_in_to_db_log
-- SCHEMA_2:  db2dataprocessor_in
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------
EXECUTE $f$
------------------------------
CREATE OR REPLACE FUNCTION db.copy_submodules_dp_in_to_db_log()
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
    -- Copy datasets - Functionname: copy_submodules_dp_in_to_db_log - From: db2dataprocessor_in -> To: db_log
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
    -- set start time
	SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
    ))  AS t(res TEXT) INTO timestamp_start;

    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' copy_submodules_dp_in_to_db_log'', last_change_timestamp=CURRENT_TIMESTAMP
    WHERE pc_name=''timepoint_1_cron_job_data_transfer'''
    ) ) AS t(res TEXT) INTO erg;

    -- Counting datasets
    err_section:='HEAD-10';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT SUM(anz) INTO data_count_pro_all
    FROM ( SELECT 0::INT AS anz
        UNION SELECT COUNT(1) AS anz FROM db2dataprocessor_in.dp_mrp_calculations
    );

    -- Counting
    IF data_count_pro_all>0 THEN
         -- Copy Functionname: copy_submodules_dp_in_to_db_log - From: db2dataprocessor_in -> To: db_log
        err_section:='HEAD-05';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes'; -- Get value for documentation of each individual data record

    	-- Number of data records then status have to be set
    	SELECT COALESCE(parameter_value::INT,10) INTO data_count_last_status_max FROM db_config.db_parameter WHERE parameter_name='number_of_data_records_after_which_the_status_is_updated';

        err_section:='HEAD-20';    err_schema:='db_config';    err_table:='db_process_control';
        -- Set current executed function and total number of records
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value=''db.copy_submodules_dp_in_to_db_log()'', last_change_timestamp=CURRENT_TIMESTAMP
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



        -----------------------------------------------------------------------------------------------------------------------
        -- Start dp_mrp_calculations  --------   dp_mrp_calculations  --------   dp_mrp_calculations  --------   dp_mrp_calculations
        err_section:='dp_mrp_calculations-01';
        SELECT COUNT(1) INTO data_count_all FROM db2dataprocessor_in.dp_mrp_calculations; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_submodules_dp_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='dp_mrp_calculations-05';    err_schema:='db2dataprocessor_in';    err_table:='dp_mrp_calculations';

            FOR current_record IN (SELECT * FROM db2dataprocessor_in.dp_mrp_calculations)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='dp_mrp_calculations-10';    err_schema:='db_log';    err_table:='dp_mrp_calculations';
                        SELECT count(1) INTO data_count
                        FROM db_log.dp_mrp_calculations target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='dp_mrp_calculations-15';    err_schema:='db_log';    err_table:='dp_mrp_calculations';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.dp_mrp_calculations (
                                dp_mrp_calculations_id,
                                enc_id,
                                mrp_calculation_type,
                                meda_id,
                                ward_name,
                                study_phase,
                                ret_id,
                                ret_redcap_repeat_instance,
                                atc1_medreq_fhir_id,
                                mrp_proxy_type,
                                mrp_proxy_code,
                                mrp_proxy_fhir_id,
                                input_file_processed_content_hash,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.dp_mrp_calculations_id,
                                current_record.enc_id,
                                current_record.mrp_calculation_type,
                                current_record.meda_id,
                                current_record.ward_name,
                                current_record.study_phase,
                                current_record.ret_id,
                                current_record.ret_redcap_repeat_instance,
                                current_record.atc1_medreq_fhir_id,
                                current_record.mrp_proxy_type,
                                current_record.mrp_proxy_code,
                                current_record.mrp_proxy_fhir_id,
                                current_record.input_file_processed_content_hash,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='dp_mrp_calculations-20';    err_schema:='db2dataprocessor_in';    err_table:='dp_mrp_calculations';
                            DELETE FROM db2dataprocessor_in.dp_mrp_calculations WHERE dp_mrp_calculations_id = current_record.dp_mrp_calculations_id;
                        ELSE
                            err_section:='dp_mrp_calculations-25';    err_schema:='db_log';    err_table:='dp_mrp_calculations';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.dp_mrp_calculations target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='dp_mrp_calculations-37';    err_schema:='db2dataprocessor_in';    err_table:='dp_mrp_calculations';
                            

                            -- Delete updatet datasets
                            err_section:='dp_mrp_calculations-30';    err_schema:='db2dataprocessor_in';    err_table:='dp_mrp_calculations';
                            DELETE FROM db2dataprocessor_in.dp_mrp_calculations WHERE dp_mrp_calculations_id = current_record.dp_mrp_calculations_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='dp_mrp_calculations-35';    err_schema:='db2dataprocessor_in';    err_table:='dp_mrp_calculations';
                            UPDATE db2dataprocessor_in.dp_mrp_calculations
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_submodules_dp_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE dp_mrp_calculations_id = current_record.dp_mrp_calculations_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_submodules_dp_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='dp_mrp_calculations-40';    err_schema:='db2dataprocessor_in';    err_table:='dp_mrp_calculations';
                    IF data_count_last_status_set>=COALESCE(data_count_last_status_max,10) THEN -- Info ausgeben
                        SELECT res FROM pg_background_result(pg_background_launch(
                        'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                        WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                        ))  AS t(res TEXT) INTO erg;
                        data_count_last_status_set:=0;
                    END IF;

            END LOOP;

            data_count_pro_upd:=data_count_pro_upd+data_count_update; -- count update datasets to all upd ds

            IF data_import_hist_every_dataset=1 and data_count_all>0 THEN -- documentenion is switcht on
                err_section:='dp_mrp_calculations-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT dp_mrp_calculations_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'dp_mrp_calculations' AS table_name, last_pro_datetime, current_dataset_status, 'copy_submodules_dp_in_to_db_log' AS function_name FROM db_log.dp_mrp_calculations d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='dp_mrp_calculations-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'dp_mrp_calculations', last_pro_datetime, 'copy_submodules_dp_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'dp_mrp_calculations', last_pro_datetime, 'copy_submodules_dp_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'dp_mrp_calculations', last_pro_datetime, 'copy_submodules_dp_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='dp_mrp_calculations-50';    err_schema:='/';    err_table:='/';
        -- END dp_mrp_calculations  --------   dp_mrp_calculations  --------   dp_mrp_calculations  --------   dp_mrp_calculations
        -----------------------------------------------------------------------------------------------------------------------


        err_section:='BOTTON-01';  err_schema:='db_log';    err_table:='data_import_hist';

        -- Collect and save counts for the function
        SELECT res FROM pg_background_result(pg_background_launch(
        'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US''
        )'))  AS t(res TEXT) INTO timestamp_end;

        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;

        err_section:='BOTTON-05';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_all', 'db_log', 'copy_submodules_dp_in_to_db_log', last_pro_datetime, 'copy_submodules_dp_in_to_db_log', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );

        err_section:='BOTTON-10';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_new', 'db_log', 'copy_submodules_dp_in_to_db_log', last_pro_datetime, 'copy_submodules_dp_in_to_db_log', data_count_pro_new, tmp_sec, 'Count all new Datasetzs '||temp);

        err_section:='BOTTON-15';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_upd', 'db_log', 'copy_submodules_dp_in_to_db_log', last_pro_datetime, 'copy_submodules_dp_in_to_db_log', data_count_pro_upd, tmp_sec, 'Count all updatetd Datasetzs '||temp);

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

    RETURN 'Done db.copy_submodules_dp_in_to_db_log - last_pro_nr:'||last_pro_nr;

EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.copy_submodules_dp_in_to_db_log()' AS VARCHAR),     -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' e:'||erg AS VARCHAR),       -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler db.copy_submodules_dp_in_to_db_log - '||SQLSTATE||' - last_pro_nr:'||last_pro_nr;
END;
$inner$ LANGUAGE plpgsql;
-----------------------------
$f$;
--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

