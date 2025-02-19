-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-02-19 18:30:48
-- Rights definition file size        : 15524 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2025-02-19 18:33:05
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  20_take_over_check_date.sql
-- TEMPLATE:  template_take_over_check_date_function.sql
-- OWNER_USER:  
-- OWNER_SCHEMA:  db_log
-- TAGS:  
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _raw
-- RIGHTS:  
-- GRANT_TARGET_USER:  
-- COPY_FUNC_SCRIPTNAME:  template_take_over_check_date_function.sql
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  take_over_last_check_date
-- SCHEMA_2:  db_log
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

------------------------------
CREATE OR REPLACE FUNCTION db.take_over_last_check_date()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    current_record record;
    new_last_pro_nr INT; -- New processing number for these sync - !!! must remain NULL until it is really needed in individual tables !!!
    max_last_pro_nr INT; -- Last processing number over all entities
    max_ent_pro_nr INT;  -- Max processing number from a entiti
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
    -- Take over last check datetime Functionname: take_over_last_check_date the last_pro_nr - From: db_log (raw) -> To: db_log
   
    -- set start time
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
	SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
    ))  AS t(res TEXT) INTO timestamp_start;
    
    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' take_over_last_check_date'', last_change_timestamp=CURRENT_TIMESTAMP
    WHERE pc_name=''timepoint_1_cron_job_data_transfer'''
    ) ) AS t(res TEXT) INTO erg;

    err_section:='HEAD-05';    err_schema:='db_log';    err_table:='data_import_hist';

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''erg:'||erg||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- Counting datasets
    err_section:='HEAD-10';    err_schema:='db_log';    err_table:='- all_entitys -';
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''vor max_lpn'' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    ---- Start check db_log.encounter ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.encounter;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.encounter_raw er
        JOIN db_log.encounter e ON er.encounter_raw_id = e.encounter_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''encounter_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.encounter ----

    ---- Start check db_log.patient ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.patient;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.patient_raw er
        JOIN db_log.patient e ON er.patient_raw_id = e.patient_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''patient_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.patient ----

    ---- Start check db_log.condition ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.condition;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.condition_raw er
        JOIN db_log.condition e ON er.condition_raw_id = e.condition_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''condition_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.condition ----

    ---- Start check db_log.medication ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medication;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.medication_raw er
        JOIN db_log.medication e ON er.medication_raw_id = e.medication_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medication_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medication ----

    ---- Start check db_log.medicationrequest ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medicationrequest;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.medicationrequest_raw er
        JOIN db_log.medicationrequest e ON er.medicationrequest_raw_id = e.medicationrequest_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medicationrequest_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medicationrequest ----

    ---- Start check db_log.medicationadministration ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medicationadministration;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.medicationadministration_raw er
        JOIN db_log.medicationadministration e ON er.medicationadministration_raw_id = e.medicationadministration_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medicationadministration_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medicationadministration ----

    ---- Start check db_log.medicationstatement ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medicationstatement;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.medicationstatement_raw er
        JOIN db_log.medicationstatement e ON er.medicationstatement_raw_id = e.medicationstatement_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medicationstatement_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medicationstatement ----

    ---- Start check db_log.observation ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.observation;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.observation_raw er
        JOIN db_log.observation e ON er.observation_raw_id = e.observation_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''observation_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.observation ----

    ---- Start check db_log.diagnosticreport ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.diagnosticreport;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.diagnosticreport_raw er
        JOIN db_log.diagnosticreport e ON er.diagnosticreport_raw_id = e.diagnosticreport_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''diagnosticreport_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.diagnosticreport ----

    ---- Start check db_log.servicerequest ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.servicerequest;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.servicerequest_raw er
        JOIN db_log.servicerequest e ON er.servicerequest_raw_id = e.servicerequest_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''servicerequest_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.servicerequest ----

    ---- Start check db_log.procedure ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.procedure;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.procedure_raw er
        JOIN db_log.procedure e ON er.procedure_raw_id = e.procedure_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''procedure_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.procedure ----

    ---- Start check db_log.consent ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.consent;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.consent_raw er
        JOIN db_log.consent e ON er.consent_raw_id = e.consent_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''consent_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.consent ----

    ---- Start check db_log.location ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.location;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.location_raw er
        JOIN db_log.location e ON er.location_raw_id = e.location_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''location_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.location ----

    ---- Start check db_log.pids_per_ward ----
    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.pids_per_ward;
    IF max_ent_pro_nr>max_last_pro_nr AND max_ent_pro_nr IS NOT NULL THEN max_last_pro_nr:=max_ent_pro_nr; END IF;

    IF data_count_pro_all=0 AND max_ent_pro_nr IS NOT NULL THEN
        SELECT COUNT(*) INTO data_count_pro_all
        FROM db_log.pids_per_ward_raw er
        JOIN db_log.pids_per_ward e ON er.pids_per_ward_raw_id = e.pids_per_ward_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr;
--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''pids_per_ward_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.pids_per_ward ----


--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''data_count_pro_all / max_last_pro_nr:'||data_count_pro_all||' / '||max_last_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_count_pro_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
        err_section:='HEAD-15';    err_schema:='db_config';    err_table:='db_parameter';
	-- Get value for documentation of each individual data record
        SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes';

    	-- Number of data records then status have to be set
    	SELECT COALESCE(parameter_value::INT,10) INTO data_count_last_status_max FROM db_config.db_parameter WHERE parameter_name='number_of_data_records_after_which_the_status_is_updated';

        err_section:='HEAD-20';    err_schema:='db_config';    err_table:='db_process_control';
        -- Set current executed function and total number of records
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value=''db.take_over_last_check_date()'', last_change_timestamp=CURRENT_TIMESTAMP
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

        err_section:='HEAD-30';    err_schema:='db_log';    err_table:='/';

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''Vor Einzelnen Tabellen'' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    
    	    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.encounter_raw to db_log.encounter

    -- Start encounter    ----   encounter    ----    encounter
    err_section:='encounter-01';    err_schema:='db_log';    err_table:='encounter';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.encounter;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.encounter_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.encounter_raw er
        JOIN db_log.encounter e ON er.encounter_raw_id = e.encounter_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.encounter_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.encounter_raw er
        JOIN db_log.encounter e ON er.encounter_raw_id = e.encounter_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='encounter-10';    err_schema:='db_log';    err_table:='encounter';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='encounter-15';    err_schema:='db_log';    err_table:='encounter';
                UPDATE db_log.encounter
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE encounter_raw_id = current_record.id;

                -- sync done
                err_section:='encounter-20';    err_schema:='db_log';    err_table:='encounter';
                UPDATE db_log.encounter_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE encounter_raw_id = current_record.id;

                err_section:='encounter-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='encounter-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT encounter_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'encounter_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.encounter_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT encounter_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'encounter' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.encounter
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END encounter  --------  encounter  --------  encounter  --------  encounter
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.patient_raw to db_log.patient

    -- Start patient    ----   patient    ----    patient
    err_section:='patient-01';    err_schema:='db_log';    err_table:='patient';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.patient;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.patient_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.patient_raw er
        JOIN db_log.patient e ON er.patient_raw_id = e.patient_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.patient_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.patient_raw er
        JOIN db_log.patient e ON er.patient_raw_id = e.patient_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='patient-10';    err_schema:='db_log';    err_table:='patient';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='patient-15';    err_schema:='db_log';    err_table:='patient';
                UPDATE db_log.patient
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE patient_raw_id = current_record.id;

                -- sync done
                err_section:='patient-20';    err_schema:='db_log';    err_table:='patient';
                UPDATE db_log.patient_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE patient_raw_id = current_record.id;

                err_section:='patient-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='patient-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT patient_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.patient_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT patient_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.patient
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END patient  --------  patient  --------  patient  --------  patient
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.condition_raw to db_log.condition

    -- Start condition    ----   condition    ----    condition
    err_section:='condition-01';    err_schema:='db_log';    err_table:='condition';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.condition;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.condition_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.condition_raw er
        JOIN db_log.condition e ON er.condition_raw_id = e.condition_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.condition_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.condition_raw er
        JOIN db_log.condition e ON er.condition_raw_id = e.condition_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='condition-10';    err_schema:='db_log';    err_table:='condition';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='condition-15';    err_schema:='db_log';    err_table:='condition';
                UPDATE db_log.condition
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE condition_raw_id = current_record.id;

                -- sync done
                err_section:='condition-20';    err_schema:='db_log';    err_table:='condition';
                UPDATE db_log.condition_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE condition_raw_id = current_record.id;

                err_section:='condition-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='condition-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT condition_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'condition_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.condition_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT condition_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'condition' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.condition
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END condition  --------  condition  --------  condition  --------  condition
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medication_raw to db_log.medication

    -- Start medication    ----   medication    ----    medication
    err_section:='medication-01';    err_schema:='db_log';    err_table:='medication';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medication;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.medication_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medication_raw er
        JOIN db_log.medication e ON er.medication_raw_id = e.medication_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.medication_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medication_raw er
        JOIN db_log.medication e ON er.medication_raw_id = e.medication_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='medication-10';    err_schema:='db_log';    err_table:='medication';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='medication-15';    err_schema:='db_log';    err_table:='medication';
                UPDATE db_log.medication
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medication_raw_id = current_record.id;

                -- sync done
                err_section:='medication-20';    err_schema:='db_log';    err_table:='medication';
                UPDATE db_log.medication_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medication_raw_id = current_record.id;

                err_section:='medication-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='medication-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medication_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medication_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medication_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medication_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medication' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medication
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END medication  --------  medication  --------  medication  --------  medication
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationrequest_raw to db_log.medicationrequest

    -- Start medicationrequest    ----   medicationrequest    ----    medicationrequest
    err_section:='medicationrequest-01';    err_schema:='db_log';    err_table:='medicationrequest';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medicationrequest;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.medicationrequest_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medicationrequest_raw er
        JOIN db_log.medicationrequest e ON er.medicationrequest_raw_id = e.medicationrequest_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.medicationrequest_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medicationrequest_raw er
        JOIN db_log.medicationrequest e ON er.medicationrequest_raw_id = e.medicationrequest_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='medicationrequest-10';    err_schema:='db_log';    err_table:='medicationrequest';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='medicationrequest-15';    err_schema:='db_log';    err_table:='medicationrequest';
                UPDATE db_log.medicationrequest
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medicationrequest_raw_id = current_record.id;

                -- sync done
                err_section:='medicationrequest-20';    err_schema:='db_log';    err_table:='medicationrequest';
                UPDATE db_log.medicationrequest_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medicationrequest_raw_id = current_record.id;

                err_section:='medicationrequest-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='medicationrequest-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationrequest_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationrequest_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationrequest_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationrequest_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationrequest' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationrequest
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END medicationrequest  --------  medicationrequest  --------  medicationrequest  --------  medicationrequest
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationadministration_raw to db_log.medicationadministration

    -- Start medicationadministration    ----   medicationadministration    ----    medicationadministration
    err_section:='medicationadministration-01';    err_schema:='db_log';    err_table:='medicationadministration';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medicationadministration;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.medicationadministration_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medicationadministration_raw er
        JOIN db_log.medicationadministration e ON er.medicationadministration_raw_id = e.medicationadministration_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.medicationadministration_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medicationadministration_raw er
        JOIN db_log.medicationadministration e ON er.medicationadministration_raw_id = e.medicationadministration_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='medicationadministration-10';    err_schema:='db_log';    err_table:='medicationadministration';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='medicationadministration-15';    err_schema:='db_log';    err_table:='medicationadministration';
                UPDATE db_log.medicationadministration
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medicationadministration_raw_id = current_record.id;

                -- sync done
                err_section:='medicationadministration-20';    err_schema:='db_log';    err_table:='medicationadministration';
                UPDATE db_log.medicationadministration_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medicationadministration_raw_id = current_record.id;

                err_section:='medicationadministration-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='medicationadministration-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationadministration_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationadministration_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationadministration_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationadministration_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationadministration' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationadministration
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END medicationadministration  --------  medicationadministration  --------  medicationadministration  --------  medicationadministration
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationstatement_raw to db_log.medicationstatement

    -- Start medicationstatement    ----   medicationstatement    ----    medicationstatement
    err_section:='medicationstatement-01';    err_schema:='db_log';    err_table:='medicationstatement';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.medicationstatement;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.medicationstatement_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medicationstatement_raw er
        JOIN db_log.medicationstatement e ON er.medicationstatement_raw_id = e.medicationstatement_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.medicationstatement_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.medicationstatement_raw er
        JOIN db_log.medicationstatement e ON er.medicationstatement_raw_id = e.medicationstatement_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='medicationstatement-10';    err_schema:='db_log';    err_table:='medicationstatement';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='medicationstatement-15';    err_schema:='db_log';    err_table:='medicationstatement';
                UPDATE db_log.medicationstatement
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medicationstatement_raw_id = current_record.id;

                -- sync done
                err_section:='medicationstatement-20';    err_schema:='db_log';    err_table:='medicationstatement';
                UPDATE db_log.medicationstatement_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medicationstatement_raw_id = current_record.id;

                err_section:='medicationstatement-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='medicationstatement-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationstatement_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationstatement_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationstatement_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationstatement_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationstatement' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationstatement
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END medicationstatement  --------  medicationstatement  --------  medicationstatement  --------  medicationstatement
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.observation_raw to db_log.observation

    -- Start observation    ----   observation    ----    observation
    err_section:='observation-01';    err_schema:='db_log';    err_table:='observation';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.observation;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.observation_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.observation_raw er
        JOIN db_log.observation e ON er.observation_raw_id = e.observation_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.observation_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.observation_raw er
        JOIN db_log.observation e ON er.observation_raw_id = e.observation_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='observation-10';    err_schema:='db_log';    err_table:='observation';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='observation-15';    err_schema:='db_log';    err_table:='observation';
                UPDATE db_log.observation
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE observation_raw_id = current_record.id;

                -- sync done
                err_section:='observation-20';    err_schema:='db_log';    err_table:='observation';
                UPDATE db_log.observation_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE observation_raw_id = current_record.id;

                err_section:='observation-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='observation-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT observation_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'observation_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.observation_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT observation_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'observation' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.observation
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END observation  --------  observation  --------  observation  --------  observation
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.diagnosticreport_raw to db_log.diagnosticreport

    -- Start diagnosticreport    ----   diagnosticreport    ----    diagnosticreport
    err_section:='diagnosticreport-01';    err_schema:='db_log';    err_table:='diagnosticreport';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.diagnosticreport;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.diagnosticreport_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.diagnosticreport_raw er
        JOIN db_log.diagnosticreport e ON er.diagnosticreport_raw_id = e.diagnosticreport_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.diagnosticreport_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.diagnosticreport_raw er
        JOIN db_log.diagnosticreport e ON er.diagnosticreport_raw_id = e.diagnosticreport_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='diagnosticreport-10';    err_schema:='db_log';    err_table:='diagnosticreport';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='diagnosticreport-15';    err_schema:='db_log';    err_table:='diagnosticreport';
                UPDATE db_log.diagnosticreport
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE diagnosticreport_raw_id = current_record.id;

                -- sync done
                err_section:='diagnosticreport-20';    err_schema:='db_log';    err_table:='diagnosticreport';
                UPDATE db_log.diagnosticreport_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE diagnosticreport_raw_id = current_record.id;

                err_section:='diagnosticreport-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='diagnosticreport-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT diagnosticreport_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'diagnosticreport_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.diagnosticreport_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT diagnosticreport_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'diagnosticreport' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.diagnosticreport
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END diagnosticreport  --------  diagnosticreport  --------  diagnosticreport  --------  diagnosticreport
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.servicerequest_raw to db_log.servicerequest

    -- Start servicerequest    ----   servicerequest    ----    servicerequest
    err_section:='servicerequest-01';    err_schema:='db_log';    err_table:='servicerequest';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.servicerequest;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.servicerequest_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.servicerequest_raw er
        JOIN db_log.servicerequest e ON er.servicerequest_raw_id = e.servicerequest_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.servicerequest_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.servicerequest_raw er
        JOIN db_log.servicerequest e ON er.servicerequest_raw_id = e.servicerequest_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='servicerequest-10';    err_schema:='db_log';    err_table:='servicerequest';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='servicerequest-15';    err_schema:='db_log';    err_table:='servicerequest';
                UPDATE db_log.servicerequest
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE servicerequest_raw_id = current_record.id;

                -- sync done
                err_section:='servicerequest-20';    err_schema:='db_log';    err_table:='servicerequest';
                UPDATE db_log.servicerequest_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE servicerequest_raw_id = current_record.id;

                err_section:='servicerequest-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='servicerequest-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT servicerequest_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'servicerequest_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.servicerequest_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT servicerequest_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'servicerequest' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.servicerequest
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END servicerequest  --------  servicerequest  --------  servicerequest  --------  servicerequest
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.procedure_raw to db_log.procedure

    -- Start procedure    ----   procedure    ----    procedure
    err_section:='procedure-01';    err_schema:='db_log';    err_table:='procedure';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.procedure;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.procedure_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.procedure_raw er
        JOIN db_log.procedure e ON er.procedure_raw_id = e.procedure_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.procedure_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.procedure_raw er
        JOIN db_log.procedure e ON er.procedure_raw_id = e.procedure_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='procedure-10';    err_schema:='db_log';    err_table:='procedure';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='procedure-15';    err_schema:='db_log';    err_table:='procedure';
                UPDATE db_log.procedure
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE procedure_raw_id = current_record.id;

                -- sync done
                err_section:='procedure-20';    err_schema:='db_log';    err_table:='procedure';
                UPDATE db_log.procedure_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE procedure_raw_id = current_record.id;

                err_section:='procedure-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='procedure-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT procedure_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'procedure_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.procedure_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT procedure_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'procedure' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.procedure
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END procedure  --------  procedure  --------  procedure  --------  procedure
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.consent_raw to db_log.consent

    -- Start consent    ----   consent    ----    consent
    err_section:='consent-01';    err_schema:='db_log';    err_table:='consent';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.consent;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.consent_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.consent_raw er
        JOIN db_log.consent e ON er.consent_raw_id = e.consent_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.consent_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.consent_raw er
        JOIN db_log.consent e ON er.consent_raw_id = e.consent_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='consent-10';    err_schema:='db_log';    err_table:='consent';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='consent-15';    err_schema:='db_log';    err_table:='consent';
                UPDATE db_log.consent
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE consent_raw_id = current_record.id;

                -- sync done
                err_section:='consent-20';    err_schema:='db_log';    err_table:='consent';
                UPDATE db_log.consent_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE consent_raw_id = current_record.id;

                err_section:='consent-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='consent-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT consent_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'consent_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.consent_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT consent_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'consent' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.consent
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END consent  --------  consent  --------  consent  --------  consent
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.location_raw to db_log.location

    -- Start location    ----   location    ----    location
    err_section:='location-01';    err_schema:='db_log';    err_table:='location';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.location;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.location_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.location_raw er
        JOIN db_log.location e ON er.location_raw_id = e.location_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.location_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.location_raw er
        JOIN db_log.location e ON er.location_raw_id = e.location_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='location-10';    err_schema:='db_log';    err_table:='location';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='location-15';    err_schema:='db_log';    err_table:='location';
                UPDATE db_log.location
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE location_raw_id = current_record.id;

                -- sync done
                err_section:='location-20';    err_schema:='db_log';    err_table:='location';
                UPDATE db_log.location_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE location_raw_id = current_record.id;

                err_section:='location-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='location-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT location_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'location_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.location_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT location_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'location' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.location
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END location  --------  location  --------  location  --------  location
    -----------------------------------------------------------------------------------------------------------------------

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.pids_per_ward_raw to db_log.pids_per_ward

    -- Start pids_per_ward    ----   pids_per_ward    ----    pids_per_ward
    err_section:='pids_per_ward-01';    err_schema:='db_log';    err_table:='pids_per_ward';
    data_count_update:=0;

    SELECT MAX(last_processing_nr) INTO max_ent_pro_nr FROM db_log.pids_per_ward;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' vor Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
        SELECT er.pids_per_ward_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.pids_per_ward_raw er
        JOIN db_log.pids_per_ward e ON er.pids_per_ward_raw_id = e.pids_per_ward_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_ent_pro_nr
        UNION ALL
        SELECT er.pids_per_ward_raw_id AS id, er.last_check_datetime AS lcd, er.current_dataset_status AS cds
        FROM db_log.pids_per_ward_raw er
        JOIN db_log.pids_per_ward e ON er.pids_per_ward_raw_id = e.pids_per_ward_raw_id
        WHERE e.last_processing_nr=max_ent_pro_nr
        AND er.last_processing_nr<>max_last_pro_nr
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                err_section:='pids_per_ward-10';    err_schema:='db_log';    err_table:='pids_per_ward';
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                err_section:='pids_per_ward-15';    err_schema:='db_log';    err_table:='pids_per_ward';
                UPDATE db_log.pids_per_ward
                SET last_check_datetime = last_pro_datetime
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE pids_per_ward_raw_id = current_record.id;

                -- sync done
                err_section:='pids_per_ward-20';    err_schema:='db_log';    err_table:='pids_per_ward';
                UPDATE db_log.pids_per_ward_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE pids_per_ward_raw_id = current_record.id;

                err_section:='pids_per_ward-25';    err_schema:='/';    err_table:='</';
                data_count_pro_processed:=data_count_pro_processed+1; -- Add up how many data records from the last import run are set with a processing number
                data_count_last_status_set:=data_count_last_status_set+1;
                data_count_update:=data_count_update+1;   -- count for these entity
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.take_over_last_check_date()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(new_last_pro_nr AS int)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
            END;

            err_section:='pids_per_ward-25';    err_schema:='db_config';    err_table:='db_process_control';
            IF data_count_last_status_set>=data_count_last_status_max THEN -- Info ausgeben
                SELECT res FROM pg_background_result(pg_background_launch(
                'UPDATE db_config.db_process_control set pc_value='''||data_count_pro_processed||''', last_change_timestamp=CURRENT_TIMESTAMP
                WHERE pc_name=''currently_processed_number_of_data_records_in_the_function'''
                ))  AS t(res TEXT) INTO erg;
                data_count_last_status_set:=0;
            END IF;
    END LOOP;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', '' nach Loop max_ent_pro_nr:'||max_ent_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT pids_per_ward_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'pids_per_ward_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.pids_per_ward_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    
        INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT pids_per_ward_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'pids_per_ward' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.pids_per_ward
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist);
    END IF;
    -- END pids_per_ward  --------  pids_per_ward  --------  pids_per_ward  --------  pids_per_ward
    -----------------------------------------------------------------------------------------------------------------------


--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''Nach Einzelnen Tabellen'' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
  
        -- Collect and save counts for the function
        err_section:='BOTTOM-01';    err_schema:='/';    err_table:='/';
        SELECT res FROM pg_background_result(pg_background_launch(
        'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
        ))  AS t(res TEXT) INTO timestamp_end;
    
        err_section:='BOTTOM-05';    err_schema:='/';    err_table:='/';
        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;
    
        err_section:='BOTTOM-10';    err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( new_last_pro_nr,'data_count_pro_all', 'db_log', 'take_over_last_check_date', last_pro_datetime, 'take_over_last_check_date', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );

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

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''Ende takeOver'' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    err_section:='BOTTOM-30';    err_schema:='/';    err_table:='/';
    RETURN 'Done db.take_over_last_check_date - new_last_pro_nr:'||new_last_pro_nr;

EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.take_over_last_check_date()' AS VARCHAR),     -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' e:'||erg AS VARCHAR),       -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(new_last_pro_nr AS INT)            -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler db.take_over_last_check_date - '||SQLSTATE||' - new_last_pro_nr:'||new_last_pro_nr;
END;
$$ LANGUAGE plpgsql;

-----------------------------

