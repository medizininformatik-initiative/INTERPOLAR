-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-06-17 22:42:12
-- Rights definition file size        : 14274 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2025-06-17 22:50:24
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  120_cre_table_raw_db_log.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db_log_user
-- OWNER_SCHEMA:  db_log
-- TAGS:  RAW
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _raw
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  db_log_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  300_cds_in_to_db_log.sql
-- COPY_FUNC_TEMPLATE:  template_copy_function.sql
-- COPY_FUNC_NAME:  copy_raw_cds_in_to_db_log
-- SCHEMA_2:  cds2db_in
-- TABLE_POSTFIX_2:  _raw
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

------------------------------
CREATE OR REPLACE FUNCTION db.copy_raw_cds_in_to_db_log()
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
    -- Copy datasets - Functionname: copy_raw_cds_in_to_db_log - From: cds2db_in -> To: db_log
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
    -- set start time
	SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
    ))  AS t(res TEXT) INTO timestamp_start;

    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' copy_raw_cds_in_to_db_log'', last_change_timestamp=CURRENT_TIMESTAMP
    WHERE pc_name=''timepoint_1_cron_job_data_transfer'''
    ) ) AS t(res TEXT) INTO erg;

    -- Counting datasets
    err_section:='HEAD-10';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT SUM(anz) INTO data_count_pro_all
    FROM ( SELECT 0::INT AS anz
        UNION SELECT COUNT(1) AS anz FROM cds2db_in.encounter_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.patient_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.condition_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.medication_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.medicationrequest_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.medicationadministration_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.medicationstatement_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.observation_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.diagnosticreport_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.servicerequest_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.procedure_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.consent_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.location_raw
    UNION SELECT COUNT(1) AS anz FROM cds2db_in.pids_per_ward_raw
    );

    -- Counting
    IF data_count_pro_all>0 THEN
         -- Copy Functionname: copy_raw_cds_in_to_db_log - From: cds2db_in -> To: db_log
        err_section:='HEAD-05';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes'; -- Get value for documentation of each individual data record

    	-- Number of data records then status have to be set
    	SELECT COALESCE(parameter_value::INT,10) INTO data_count_last_status_max FROM db_config.db_parameter WHERE parameter_name='number_of_data_records_after_which_the_status_is_updated';

        err_section:='HEAD-20';    err_schema:='db_config';    err_table:='db_process_control';
        -- Set current executed function and total number of records
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value=''db.copy_raw_cds_in_to_db_log()'', last_change_timestamp=CURRENT_TIMESTAMP
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
        -- Start encounter_raw  --------   encounter_raw  --------   encounter_raw  --------   encounter_raw
        err_section:='encounter_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.encounter_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='encounter_raw-05';    err_schema:='cds2db_in';    err_table:='encounter_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.encounter_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='encounter_raw-10';    err_schema:='db_log';    err_table:='encounter_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.encounter_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='encounter_raw-15';    err_schema:='db_log';    err_table:='encounter_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.encounter_raw (
                                encounter_raw_id,
                                enc_id,
                                enc_meta_versionid,
                                enc_meta_lastupdated,
                                enc_meta_profile,
                                enc_identifier_use,
                                enc_identifier_type_system,
                                enc_identifier_type_version,
                                enc_identifier_type_code,
                                enc_identifier_type_display,
                                enc_identifier_type_text,
                                enc_identifier_system,
                                enc_identifier_value,
                                enc_identifier_start,
                                enc_identifier_end,
                                enc_patient_ref,
                                enc_partof_ref,
                                enc_status,
                                enc_class_system,
                                enc_class_version,
                                enc_class_code,
                                enc_class_display,
                                enc_type_system,
                                enc_type_version,
                                enc_type_code,
                                enc_type_display,
                                enc_type_text,
                                enc_servicetype_system,
                                enc_servicetype_version,
                                enc_servicetype_code,
                                enc_servicetype_display,
                                enc_servicetype_text,
                                enc_period_start,
                                enc_period_end,
                                enc_diagnosis_condition_ref,
                                enc_diagnosis_use_system,
                                enc_diagnosis_use_version,
                                enc_diagnosis_use_code,
                                enc_diagnosis_use_display,
                                enc_diagnosis_use_text,
                                enc_diagnosis_rank,
                                enc_hospitalization_admitsource_system,
                                enc_hospitalization_admitsource_version,
                                enc_hospitalization_admitsource_code,
                                enc_hospitalization_admitsource_display,
                                enc_hospitalization_admitsource_text,
                                enc_hospitalization_dischargedisposition_system,
                                enc_hospitalization_dischargedisposition_version,
                                enc_hospitalization_dischargedisposition_code,
                                enc_hospitalization_dischargedisposition_display,
                                enc_hospitalization_dischargedisposition_text,
                                enc_location_ref,
                                enc_location_type,
                                enc_location_identifier_use,
                                enc_location_identifier_type_system,
                                enc_location_identifier_type_version,
                                enc_location_identifier_type_code,
                                enc_location_identifier_type_display,
                                enc_location_identifier_type_text,
                                enc_location_identifier_system,
                                enc_location_identifier_value,
                                enc_location_display,
                                enc_location_status,
                                enc_location_physicaltype_system,
                                enc_location_physicaltype_version,
                                enc_location_physicaltype_code,
                                enc_location_physicaltype_display,
                                enc_location_physicaltype_text,
                                enc_serviceprovider_ref,
                                enc_serviceprovider_type,
                                enc_serviceprovider_identifier_use,
                                enc_serviceprovider_identifier_type_system,
                                enc_serviceprovider_identifier_type_version,
                                enc_serviceprovider_identifier_type_code,
                                enc_serviceprovider_identifier_type_display,
                                enc_serviceprovider_identifier_type_text,
                                enc_serviceprovider_identifier_system,
                                enc_serviceprovider_identifier_value,
                                enc_serviceprovider_display,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.encounter_raw_id,
                                current_record.enc_id,
                                current_record.enc_meta_versionid,
                                current_record.enc_meta_lastupdated,
                                current_record.enc_meta_profile,
                                current_record.enc_identifier_use,
                                current_record.enc_identifier_type_system,
                                current_record.enc_identifier_type_version,
                                current_record.enc_identifier_type_code,
                                current_record.enc_identifier_type_display,
                                current_record.enc_identifier_type_text,
                                current_record.enc_identifier_system,
                                current_record.enc_identifier_value,
                                current_record.enc_identifier_start,
                                current_record.enc_identifier_end,
                                current_record.enc_patient_ref,
                                current_record.enc_partof_ref,
                                current_record.enc_status,
                                current_record.enc_class_system,
                                current_record.enc_class_version,
                                current_record.enc_class_code,
                                current_record.enc_class_display,
                                current_record.enc_type_system,
                                current_record.enc_type_version,
                                current_record.enc_type_code,
                                current_record.enc_type_display,
                                current_record.enc_type_text,
                                current_record.enc_servicetype_system,
                                current_record.enc_servicetype_version,
                                current_record.enc_servicetype_code,
                                current_record.enc_servicetype_display,
                                current_record.enc_servicetype_text,
                                current_record.enc_period_start,
                                current_record.enc_period_end,
                                current_record.enc_diagnosis_condition_ref,
                                current_record.enc_diagnosis_use_system,
                                current_record.enc_diagnosis_use_version,
                                current_record.enc_diagnosis_use_code,
                                current_record.enc_diagnosis_use_display,
                                current_record.enc_diagnosis_use_text,
                                current_record.enc_diagnosis_rank,
                                current_record.enc_hospitalization_admitsource_system,
                                current_record.enc_hospitalization_admitsource_version,
                                current_record.enc_hospitalization_admitsource_code,
                                current_record.enc_hospitalization_admitsource_display,
                                current_record.enc_hospitalization_admitsource_text,
                                current_record.enc_hospitalization_dischargedisposition_system,
                                current_record.enc_hospitalization_dischargedisposition_version,
                                current_record.enc_hospitalization_dischargedisposition_code,
                                current_record.enc_hospitalization_dischargedisposition_display,
                                current_record.enc_hospitalization_dischargedisposition_text,
                                current_record.enc_location_ref,
                                current_record.enc_location_type,
                                current_record.enc_location_identifier_use,
                                current_record.enc_location_identifier_type_system,
                                current_record.enc_location_identifier_type_version,
                                current_record.enc_location_identifier_type_code,
                                current_record.enc_location_identifier_type_display,
                                current_record.enc_location_identifier_type_text,
                                current_record.enc_location_identifier_system,
                                current_record.enc_location_identifier_value,
                                current_record.enc_location_display,
                                current_record.enc_location_status,
                                current_record.enc_location_physicaltype_system,
                                current_record.enc_location_physicaltype_version,
                                current_record.enc_location_physicaltype_code,
                                current_record.enc_location_physicaltype_display,
                                current_record.enc_location_physicaltype_text,
                                current_record.enc_serviceprovider_ref,
                                current_record.enc_serviceprovider_type,
                                current_record.enc_serviceprovider_identifier_use,
                                current_record.enc_serviceprovider_identifier_type_system,
                                current_record.enc_serviceprovider_identifier_type_version,
                                current_record.enc_serviceprovider_identifier_type_code,
                                current_record.enc_serviceprovider_identifier_type_display,
                                current_record.enc_serviceprovider_identifier_type_text,
                                current_record.enc_serviceprovider_identifier_system,
                                current_record.enc_serviceprovider_identifier_value,
                                current_record.enc_serviceprovider_display,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='encounter_raw-20';    err_schema:='cds2db_in';    err_table:='encounter_raw';
                            DELETE FROM cds2db_in.encounter_raw WHERE encounter_raw_id = current_record.encounter_raw_id;
                        ELSE
                            err_section:='encounter_raw-25';    err_schema:='db_log';    err_table:='encounter_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.encounter_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='encounter_raw-37';    err_schema:='cds2db_in';    err_table:='encounter_raw';
                                                        UPDATE db_log.encounter_raw target_record SET enc_meta_versionid = current_record.enc_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(enc_meta_versionid) != db.to_char_immutable(current_record.enc_meta_versionid);
                            UPDATE db_log.encounter_raw target_record SET enc_meta_lastupdated = current_record.enc_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(enc_meta_lastupdated) != db.to_char_immutable(current_record.enc_meta_lastupdated);
                            UPDATE db_log.encounter_raw target_record SET enc_meta_profile = current_record.enc_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(enc_meta_profile) != db.to_char_immutable(current_record.enc_meta_profile);

                            -- Delete updatet datasets
                            err_section:='encounter_raw-30';    err_schema:='cds2db_in';    err_table:='encounter_raw';
                            DELETE FROM cds2db_in.encounter_raw WHERE encounter_raw_id = current_record.encounter_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='encounter_raw-35';    err_schema:='cds2db_in';    err_table:='encounter_raw';
                            UPDATE cds2db_in.encounter_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE encounter_raw_id = current_record.encounter_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='encounter_raw-40';    err_schema:='cds2db_in';    err_table:='encounter_raw';
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
                err_section:='encounter_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT encounter_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'encounter_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.encounter_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='encounter_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'encounter_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'encounter_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'encounter_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='encounter_raw-50';    err_schema:='/';    err_table:='/';
        -- END encounter_raw  --------   encounter_raw  --------   encounter_raw  --------   encounter_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start patient_raw  --------   patient_raw  --------   patient_raw  --------   patient_raw
        err_section:='patient_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.patient_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='patient_raw-05';    err_schema:='cds2db_in';    err_table:='patient_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.patient_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='patient_raw-10';    err_schema:='db_log';    err_table:='patient_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.patient_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='patient_raw-15';    err_schema:='db_log';    err_table:='patient_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.patient_raw (
                                patient_raw_id,
                                pat_id,
                                pat_meta_versionid,
                                pat_meta_lastupdated,
                                pat_meta_profile,
                                pat_identifier_use,
                                pat_identifier_type_system,
                                pat_identifier_type_version,
                                pat_identifier_type_code,
                                pat_identifier_type_display,
                                pat_identifier_type_text,
                                pat_identifier_system,
                                pat_identifier_value,
                                pat_identifier_start,
                                pat_identifier_end,
                                pat_name_use,
                                pat_name_text,
                                pat_name_family,
                                pat_name_given,
                                pat_gender,
                                pat_birthdate,
                                pat_deceaseddatetime,
                                pat_address_postalcode,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.patient_raw_id,
                                current_record.pat_id,
                                current_record.pat_meta_versionid,
                                current_record.pat_meta_lastupdated,
                                current_record.pat_meta_profile,
                                current_record.pat_identifier_use,
                                current_record.pat_identifier_type_system,
                                current_record.pat_identifier_type_version,
                                current_record.pat_identifier_type_code,
                                current_record.pat_identifier_type_display,
                                current_record.pat_identifier_type_text,
                                current_record.pat_identifier_system,
                                current_record.pat_identifier_value,
                                current_record.pat_identifier_start,
                                current_record.pat_identifier_end,
                                current_record.pat_name_use,
                                current_record.pat_name_text,
                                current_record.pat_name_family,
                                current_record.pat_name_given,
                                current_record.pat_gender,
                                current_record.pat_birthdate,
                                current_record.pat_deceaseddatetime,
                                current_record.pat_address_postalcode,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='patient_raw-20';    err_schema:='cds2db_in';    err_table:='patient_raw';
                            DELETE FROM cds2db_in.patient_raw WHERE patient_raw_id = current_record.patient_raw_id;
                        ELSE
                            err_section:='patient_raw-25';    err_schema:='db_log';    err_table:='patient_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.patient_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='patient_raw-37';    err_schema:='cds2db_in';    err_table:='patient_raw';
                                                        UPDATE db_log.patient_raw target_record SET pat_meta_versionid = current_record.pat_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(pat_meta_versionid) != db.to_char_immutable(current_record.pat_meta_versionid);
                            UPDATE db_log.patient_raw target_record SET pat_meta_lastupdated = current_record.pat_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(pat_meta_lastupdated) != db.to_char_immutable(current_record.pat_meta_lastupdated);
                            UPDATE db_log.patient_raw target_record SET pat_meta_profile = current_record.pat_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(pat_meta_profile) != db.to_char_immutable(current_record.pat_meta_profile);

                            -- Delete updatet datasets
                            err_section:='patient_raw-30';    err_schema:='cds2db_in';    err_table:='patient_raw';
                            DELETE FROM cds2db_in.patient_raw WHERE patient_raw_id = current_record.patient_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='patient_raw-35';    err_schema:='cds2db_in';    err_table:='patient_raw';
                            UPDATE cds2db_in.patient_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE patient_raw_id = current_record.patient_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='patient_raw-40';    err_schema:='cds2db_in';    err_table:='patient_raw';
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
                err_section:='patient_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT patient_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'patient_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.patient_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='patient_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'patient_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'patient_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'patient_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='patient_raw-50';    err_schema:='/';    err_table:='/';
        -- END patient_raw  --------   patient_raw  --------   patient_raw  --------   patient_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start condition_raw  --------   condition_raw  --------   condition_raw  --------   condition_raw
        err_section:='condition_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.condition_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='condition_raw-05';    err_schema:='cds2db_in';    err_table:='condition_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.condition_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='condition_raw-10';    err_schema:='db_log';    err_table:='condition_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.condition_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='condition_raw-15';    err_schema:='db_log';    err_table:='condition_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.condition_raw (
                                condition_raw_id,
                                con_id,
                                con_meta_versionid,
                                con_meta_lastupdated,
                                con_meta_profile,
                                con_identifier_use,
                                con_identifier_type_system,
                                con_identifier_type_version,
                                con_identifier_type_code,
                                con_identifier_type_display,
                                con_identifier_type_text,
                                con_identifier_system,
                                con_identifier_value,
                                con_identifier_start,
                                con_identifier_end,
                                con_encounter_ref,
                                con_patient_ref,
                                con_clinicalstatus_system,
                                con_clinicalstatus_version,
                                con_clinicalstatus_code,
                                con_clinicalstatus_display,
                                con_clinicalstatus_text,
                                con_verificationstatus_system,
                                con_verificationstatus_version,
                                con_verificationstatus_code,
                                con_verificationstatus_display,
                                con_verificationstatus_text,
                                con_category_system,
                                con_category_version,
                                con_category_code,
                                con_category_display,
                                con_category_text,
                                con_severity_system,
                                con_severity_version,
                                con_severity_code,
                                con_severity_display,
                                con_severity_text,
                                con_code_system,
                                con_code_version,
                                con_code_code,
                                con_code_display,
                                con_code_text,
                                con_bodysite_system,
                                con_bodysite_version,
                                con_bodysite_code,
                                con_bodysite_display,
                                con_bodysite_text,
                                con_onsetperiod_start,
                                con_onsetperiod_end,
                                con_onsetdatetime,
                                con_abatementdatetime,
                                con_abatementage_value,
                                con_abatementage_comparator,
                                con_abatementage_unit,
                                con_abatementage_system,
                                con_abatementage_code,
                                con_abatementperiod_start,
                                con_abatementperiod_end,
                                con_abatementrange_low_value,
                                con_abatementrange_low_unit,
                                con_abatementrange_low_system,
                                con_abatementrange_low_code,
                                con_abatementrange_high_value,
                                con_abatementrange_high_unit,
                                con_abatementrange_high_system,
                                con_abatementrange_high_code,
                                con_abatementstring,
                                con_recordeddate,
                                con_recorder_ref,
                                con_recorder_type,
                                con_recorder_identifier_use,
                                con_recorder_identifier_type_system,
                                con_recorder_identifier_type_version,
                                con_recorder_identifier_type_code,
                                con_recorder_identifier_type_display,
                                con_recorder_identifier_type_text,
                                con_recorder_identifier_system,
                                con_recorder_identifier_value,
                                con_recorder_display,
                                con_asserter_ref,
                                con_asserter_type,
                                con_asserter_identifier_use,
                                con_asserter_identifier_type_system,
                                con_asserter_identifier_type_version,
                                con_asserter_identifier_type_code,
                                con_asserter_identifier_type_display,
                                con_asserter_identifier_type_text,
                                con_asserter_identifier_system,
                                con_asserter_identifier_value,
                                con_asserter_display,
                                con_stage_summary_system,
                                con_stage_summary_version,
                                con_stage_summary_code,
                                con_stage_summary_display,
                                con_stage_summary_text,
                                con_stage_assessment_ref,
                                con_stage_assessment_type,
                                con_stage_assessment_identifier_use,
                                con_stage_assessment_identifier_type_system,
                                con_stage_assessment_identifier_type_version,
                                con_stage_assessment_identifier_type_code,
                                con_stage_assessment_identifier_type_display,
                                con_stage_assessment_identifier_type_text,
                                con_stage_assessment_identifier_system,
                                con_stage_assessment_identifier_value,
                                con_stage_assessment_display,
                                con_stage_type_system,
                                con_stage_type_version,
                                con_stage_type_code,
                                con_stage_type_display,
                                con_stage_type_text,
                                con_note_authorstring,
                                con_note_authorreference_ref,
                                con_note_authorreference_type,
                                con_note_authorreference_identifier_use,
                                con_note_authorreference_identifier_type_system,
                                con_note_authorreference_identifier_type_version,
                                con_note_authorreference_identifier_type_code,
                                con_note_authorreference_identifier_type_display,
                                con_note_authorreference_identifier_type_text,
                                con_note_authorreference_identifier_system,
                                con_note_authorreference_identifier_value,
                                con_note_authorreference_display,
                                con_note_time,
                                con_note_text,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.condition_raw_id,
                                current_record.con_id,
                                current_record.con_meta_versionid,
                                current_record.con_meta_lastupdated,
                                current_record.con_meta_profile,
                                current_record.con_identifier_use,
                                current_record.con_identifier_type_system,
                                current_record.con_identifier_type_version,
                                current_record.con_identifier_type_code,
                                current_record.con_identifier_type_display,
                                current_record.con_identifier_type_text,
                                current_record.con_identifier_system,
                                current_record.con_identifier_value,
                                current_record.con_identifier_start,
                                current_record.con_identifier_end,
                                current_record.con_encounter_ref,
                                current_record.con_patient_ref,
                                current_record.con_clinicalstatus_system,
                                current_record.con_clinicalstatus_version,
                                current_record.con_clinicalstatus_code,
                                current_record.con_clinicalstatus_display,
                                current_record.con_clinicalstatus_text,
                                current_record.con_verificationstatus_system,
                                current_record.con_verificationstatus_version,
                                current_record.con_verificationstatus_code,
                                current_record.con_verificationstatus_display,
                                current_record.con_verificationstatus_text,
                                current_record.con_category_system,
                                current_record.con_category_version,
                                current_record.con_category_code,
                                current_record.con_category_display,
                                current_record.con_category_text,
                                current_record.con_severity_system,
                                current_record.con_severity_version,
                                current_record.con_severity_code,
                                current_record.con_severity_display,
                                current_record.con_severity_text,
                                current_record.con_code_system,
                                current_record.con_code_version,
                                current_record.con_code_code,
                                current_record.con_code_display,
                                current_record.con_code_text,
                                current_record.con_bodysite_system,
                                current_record.con_bodysite_version,
                                current_record.con_bodysite_code,
                                current_record.con_bodysite_display,
                                current_record.con_bodysite_text,
                                current_record.con_onsetperiod_start,
                                current_record.con_onsetperiod_end,
                                current_record.con_onsetdatetime,
                                current_record.con_abatementdatetime,
                                current_record.con_abatementage_value,
                                current_record.con_abatementage_comparator,
                                current_record.con_abatementage_unit,
                                current_record.con_abatementage_system,
                                current_record.con_abatementage_code,
                                current_record.con_abatementperiod_start,
                                current_record.con_abatementperiod_end,
                                current_record.con_abatementrange_low_value,
                                current_record.con_abatementrange_low_unit,
                                current_record.con_abatementrange_low_system,
                                current_record.con_abatementrange_low_code,
                                current_record.con_abatementrange_high_value,
                                current_record.con_abatementrange_high_unit,
                                current_record.con_abatementrange_high_system,
                                current_record.con_abatementrange_high_code,
                                current_record.con_abatementstring,
                                current_record.con_recordeddate,
                                current_record.con_recorder_ref,
                                current_record.con_recorder_type,
                                current_record.con_recorder_identifier_use,
                                current_record.con_recorder_identifier_type_system,
                                current_record.con_recorder_identifier_type_version,
                                current_record.con_recorder_identifier_type_code,
                                current_record.con_recorder_identifier_type_display,
                                current_record.con_recorder_identifier_type_text,
                                current_record.con_recorder_identifier_system,
                                current_record.con_recorder_identifier_value,
                                current_record.con_recorder_display,
                                current_record.con_asserter_ref,
                                current_record.con_asserter_type,
                                current_record.con_asserter_identifier_use,
                                current_record.con_asserter_identifier_type_system,
                                current_record.con_asserter_identifier_type_version,
                                current_record.con_asserter_identifier_type_code,
                                current_record.con_asserter_identifier_type_display,
                                current_record.con_asserter_identifier_type_text,
                                current_record.con_asserter_identifier_system,
                                current_record.con_asserter_identifier_value,
                                current_record.con_asserter_display,
                                current_record.con_stage_summary_system,
                                current_record.con_stage_summary_version,
                                current_record.con_stage_summary_code,
                                current_record.con_stage_summary_display,
                                current_record.con_stage_summary_text,
                                current_record.con_stage_assessment_ref,
                                current_record.con_stage_assessment_type,
                                current_record.con_stage_assessment_identifier_use,
                                current_record.con_stage_assessment_identifier_type_system,
                                current_record.con_stage_assessment_identifier_type_version,
                                current_record.con_stage_assessment_identifier_type_code,
                                current_record.con_stage_assessment_identifier_type_display,
                                current_record.con_stage_assessment_identifier_type_text,
                                current_record.con_stage_assessment_identifier_system,
                                current_record.con_stage_assessment_identifier_value,
                                current_record.con_stage_assessment_display,
                                current_record.con_stage_type_system,
                                current_record.con_stage_type_version,
                                current_record.con_stage_type_code,
                                current_record.con_stage_type_display,
                                current_record.con_stage_type_text,
                                current_record.con_note_authorstring,
                                current_record.con_note_authorreference_ref,
                                current_record.con_note_authorreference_type,
                                current_record.con_note_authorreference_identifier_use,
                                current_record.con_note_authorreference_identifier_type_system,
                                current_record.con_note_authorreference_identifier_type_version,
                                current_record.con_note_authorreference_identifier_type_code,
                                current_record.con_note_authorreference_identifier_type_display,
                                current_record.con_note_authorreference_identifier_type_text,
                                current_record.con_note_authorreference_identifier_system,
                                current_record.con_note_authorreference_identifier_value,
                                current_record.con_note_authorreference_display,
                                current_record.con_note_time,
                                current_record.con_note_text,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='condition_raw-20';    err_schema:='cds2db_in';    err_table:='condition_raw';
                            DELETE FROM cds2db_in.condition_raw WHERE condition_raw_id = current_record.condition_raw_id;
                        ELSE
                            err_section:='condition_raw-25';    err_schema:='db_log';    err_table:='condition_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.condition_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='condition_raw-37';    err_schema:='cds2db_in';    err_table:='condition_raw';
                                                        UPDATE db_log.condition_raw target_record SET con_meta_versionid = current_record.con_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(con_meta_versionid) != db.to_char_immutable(current_record.con_meta_versionid);
                            UPDATE db_log.condition_raw target_record SET con_meta_lastupdated = current_record.con_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(con_meta_lastupdated) != db.to_char_immutable(current_record.con_meta_lastupdated);
                            UPDATE db_log.condition_raw target_record SET con_meta_profile = current_record.con_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(con_meta_profile) != db.to_char_immutable(current_record.con_meta_profile);

                            -- Delete updatet datasets
                            err_section:='condition_raw-30';    err_schema:='cds2db_in';    err_table:='condition_raw';
                            DELETE FROM cds2db_in.condition_raw WHERE condition_raw_id = current_record.condition_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='condition_raw-35';    err_schema:='cds2db_in';    err_table:='condition_raw';
                            UPDATE cds2db_in.condition_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE condition_raw_id = current_record.condition_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='condition_raw-40';    err_schema:='cds2db_in';    err_table:='condition_raw';
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
                err_section:='condition_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT condition_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'condition_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.condition_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='condition_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'condition_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'condition_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'condition_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='condition_raw-50';    err_schema:='/';    err_table:='/';
        -- END condition_raw  --------   condition_raw  --------   condition_raw  --------   condition_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start medication_raw  --------   medication_raw  --------   medication_raw  --------   medication_raw
        err_section:='medication_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.medication_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='medication_raw-05';    err_schema:='cds2db_in';    err_table:='medication_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.medication_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='medication_raw-10';    err_schema:='db_log';    err_table:='medication_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.medication_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='medication_raw-15';    err_schema:='db_log';    err_table:='medication_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.medication_raw (
                                medication_raw_id,
                                med_id,
                                med_meta_versionid,
                                med_meta_lastupdated,
                                med_meta_profile,
                                med_identifier_use,
                                med_identifier_type_system,
                                med_identifier_type_version,
                                med_identifier_type_code,
                                med_identifier_type_display,
                                med_identifier_type_text,
                                med_identifier_system,
                                med_identifier_value,
                                med_identifier_start,
                                med_identifier_end,
                                med_code_system,
                                med_code_version,
                                med_code_code,
                                med_code_display,
                                med_code_text,
                                med_status,
                                med_form_system,
                                med_form_version,
                                med_form_code,
                                med_form_display,
                                med_form_text,
                                med_amount_numerator_value,
                                med_amount_numerator_comparator,
                                med_amount_numerator_unit,
                                med_amount_numerator_system,
                                med_amount_numerator_code,
                                med_amount_denominator_value,
                                med_amount_denominator_comparator,
                                med_amount_denominator_unit,
                                med_amount_denominator_system,
                                med_amount_denominator_code,
                                med_ingredient_strength_numerator_value,
                                med_ingredient_strength_numerator_comparator,
                                med_ingredient_strength_numerator_unit,
                                med_ingredient_strength_numerator_system,
                                med_ingredient_strength_numerator_code,
                                med_ingredient_strength_denominator_value,
                                med_ingredient_strength_denominator_comparator,
                                med_ingredient_strength_denominator_unit,
                                med_ingredient_strength_denominator_system,
                                med_ingredient_strength_denominator_code,
                                med_ingredient_itemcodeableconcept_system,
                                med_ingredient_itemcodeableconcept_version,
                                med_ingredient_itemcodeableconcept_code,
                                med_ingredient_itemcodeableconcept_display,
                                med_ingredient_itemcodeableconcept_text,
                                med_ingredient_itemreference_ref,
                                med_ingredient_itemreference_type,
                                med_ingredient_itemreference_identifier_use,
                                med_ingredient_itemreference_identifier_type_system,
                                med_ingredient_itemreference_identifier_type_version,
                                med_ingredient_itemreference_identifier_type_code,
                                med_ingredient_itemreference_identifier_type_display,
                                med_ingredient_itemreference_identifier_type_text,
                                med_ingredient_itemreference_identifier_system,
                                med_ingredient_itemreference_identifier_value,
                                med_ingredient_itemreference_display,
                                med_ingredient_isactive,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.medication_raw_id,
                                current_record.med_id,
                                current_record.med_meta_versionid,
                                current_record.med_meta_lastupdated,
                                current_record.med_meta_profile,
                                current_record.med_identifier_use,
                                current_record.med_identifier_type_system,
                                current_record.med_identifier_type_version,
                                current_record.med_identifier_type_code,
                                current_record.med_identifier_type_display,
                                current_record.med_identifier_type_text,
                                current_record.med_identifier_system,
                                current_record.med_identifier_value,
                                current_record.med_identifier_start,
                                current_record.med_identifier_end,
                                current_record.med_code_system,
                                current_record.med_code_version,
                                current_record.med_code_code,
                                current_record.med_code_display,
                                current_record.med_code_text,
                                current_record.med_status,
                                current_record.med_form_system,
                                current_record.med_form_version,
                                current_record.med_form_code,
                                current_record.med_form_display,
                                current_record.med_form_text,
                                current_record.med_amount_numerator_value,
                                current_record.med_amount_numerator_comparator,
                                current_record.med_amount_numerator_unit,
                                current_record.med_amount_numerator_system,
                                current_record.med_amount_numerator_code,
                                current_record.med_amount_denominator_value,
                                current_record.med_amount_denominator_comparator,
                                current_record.med_amount_denominator_unit,
                                current_record.med_amount_denominator_system,
                                current_record.med_amount_denominator_code,
                                current_record.med_ingredient_strength_numerator_value,
                                current_record.med_ingredient_strength_numerator_comparator,
                                current_record.med_ingredient_strength_numerator_unit,
                                current_record.med_ingredient_strength_numerator_system,
                                current_record.med_ingredient_strength_numerator_code,
                                current_record.med_ingredient_strength_denominator_value,
                                current_record.med_ingredient_strength_denominator_comparator,
                                current_record.med_ingredient_strength_denominator_unit,
                                current_record.med_ingredient_strength_denominator_system,
                                current_record.med_ingredient_strength_denominator_code,
                                current_record.med_ingredient_itemcodeableconcept_system,
                                current_record.med_ingredient_itemcodeableconcept_version,
                                current_record.med_ingredient_itemcodeableconcept_code,
                                current_record.med_ingredient_itemcodeableconcept_display,
                                current_record.med_ingredient_itemcodeableconcept_text,
                                current_record.med_ingredient_itemreference_ref,
                                current_record.med_ingredient_itemreference_type,
                                current_record.med_ingredient_itemreference_identifier_use,
                                current_record.med_ingredient_itemreference_identifier_type_system,
                                current_record.med_ingredient_itemreference_identifier_type_version,
                                current_record.med_ingredient_itemreference_identifier_type_code,
                                current_record.med_ingredient_itemreference_identifier_type_display,
                                current_record.med_ingredient_itemreference_identifier_type_text,
                                current_record.med_ingredient_itemreference_identifier_system,
                                current_record.med_ingredient_itemreference_identifier_value,
                                current_record.med_ingredient_itemreference_display,
                                current_record.med_ingredient_isactive,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='medication_raw-20';    err_schema:='cds2db_in';    err_table:='medication_raw';
                            DELETE FROM cds2db_in.medication_raw WHERE medication_raw_id = current_record.medication_raw_id;
                        ELSE
                            err_section:='medication_raw-25';    err_schema:='db_log';    err_table:='medication_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.medication_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='medication_raw-37';    err_schema:='cds2db_in';    err_table:='medication_raw';
                                                        UPDATE db_log.medication_raw target_record SET med_meta_versionid = current_record.med_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(med_meta_versionid) != db.to_char_immutable(current_record.med_meta_versionid);
                            UPDATE db_log.medication_raw target_record SET med_meta_lastupdated = current_record.med_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(med_meta_lastupdated) != db.to_char_immutable(current_record.med_meta_lastupdated);
                            UPDATE db_log.medication_raw target_record SET med_meta_profile = current_record.med_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(med_meta_profile) != db.to_char_immutable(current_record.med_meta_profile);

                            -- Delete updatet datasets
                            err_section:='medication_raw-30';    err_schema:='cds2db_in';    err_table:='medication_raw';
                            DELETE FROM cds2db_in.medication_raw WHERE medication_raw_id = current_record.medication_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='medication_raw-35';    err_schema:='cds2db_in';    err_table:='medication_raw';
                            UPDATE cds2db_in.medication_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE medication_raw_id = current_record.medication_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='medication_raw-40';    err_schema:='cds2db_in';    err_table:='medication_raw';
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
                err_section:='medication_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT medication_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'medication_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.medication_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='medication_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'medication_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'medication_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'medication_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='medication_raw-50';    err_schema:='/';    err_table:='/';
        -- END medication_raw  --------   medication_raw  --------   medication_raw  --------   medication_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start medicationrequest_raw  --------   medicationrequest_raw  --------   medicationrequest_raw  --------   medicationrequest_raw
        err_section:='medicationrequest_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.medicationrequest_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='medicationrequest_raw-05';    err_schema:='cds2db_in';    err_table:='medicationrequest_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.medicationrequest_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='medicationrequest_raw-10';    err_schema:='db_log';    err_table:='medicationrequest_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.medicationrequest_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='medicationrequest_raw-15';    err_schema:='db_log';    err_table:='medicationrequest_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.medicationrequest_raw (
                                medicationrequest_raw_id,
                                medreq_id,
                                medreq_meta_versionid,
                                medreq_meta_lastupdated,
                                medreq_meta_profile,
                                medreq_identifier_use,
                                medreq_identifier_type_system,
                                medreq_identifier_type_version,
                                medreq_identifier_type_code,
                                medreq_identifier_type_display,
                                medreq_identifier_type_text,
                                medreq_identifier_system,
                                medreq_identifier_value,
                                medreq_identifier_start,
                                medreq_identifier_end,
                                medreq_encounter_ref,
                                medreq_patient_ref,
                                medreq_medicationreference_ref,
                                medreq_status,
                                medreq_statusreason_system,
                                medreq_statusreason_version,
                                medreq_statusreason_code,
                                medreq_statusreason_display,
                                medreq_statusreason_text,
                                medreq_intend,
                                medreq_intent,
                                medreq_category_system,
                                medreq_category_version,
                                medreq_category_code,
                                medreq_category_display,
                                medreq_category_text,
                                medreq_priority,
                                medreq_reportedboolean,
                                medreq_reportedreference_ref,
                                medreq_reportedreference_type,
                                medreq_reportedreference_identifier_use,
                                medreq_reportedreference_identifier_type_system,
                                medreq_reportedreference_identifier_type_version,
                                medreq_reportedreference_identifier_type_code,
                                medreq_reportedreference_identifier_type_display,
                                medreq_reportedreference_identifier_type_text,
                                medreq_reportedreference_identifier_system,
                                medreq_reportedreference_identifier_value,
                                medreq_reportedreference_display,
                                medreq_medicationcodeableconcept_system,
                                medreq_medicationcodeableconcept_version,
                                medreq_medicationcodeableconcept_code,
                                medreq_medicationcodeableconcept_display,
                                medreq_medicationcodeableconcept_text,
                                medreq_supportinginformation_ref,
                                medreq_supportinginformation_type,
                                medreq_supportinginformation_identifier_use,
                                medreq_supportinginformation_identifier_type_system,
                                medreq_supportinginformation_identifier_type_version,
                                medreq_supportinginformation_identifier_type_code,
                                medreq_supportinginformation_identifier_type_display,
                                medreq_supportinginformation_identifier_type_text,
                                medreq_supportinginformation_identifier_system,
                                medreq_supportinginformation_identifier_value,
                                medreq_supportinginformation_display,
                                medreq_authoredon,
                                medreq_requester_ref,
                                medreq_requester_type,
                                medreq_requester_identifier_use,
                                medreq_requester_identifier_type_system,
                                medreq_requester_identifier_type_version,
                                medreq_requester_identifier_type_code,
                                medreq_requester_identifier_type_display,
                                medreq_requester_identifier_type_text,
                                medreq_requester_identifier_system,
                                medreq_requester_identifier_value,
                                medreq_requester_display,
                                medreq_reasoncode_system,
                                medreq_reasoncode_version,
                                medreq_reasoncode_code,
                                medreq_reasoncode_display,
                                medreq_reasoncode_text,
                                medreq_reasonreference_ref,
                                medreq_reasonreference_type,
                                medreq_reasonreference_identifier_use,
                                medreq_reasonreference_identifier_type_system,
                                medreq_reasonreference_identifier_type_version,
                                medreq_reasonreference_identifier_type_code,
                                medreq_reasonreference_identifier_type_display,
                                medreq_reasonreference_identifier_type_text,
                                medreq_reasonreference_identifier_system,
                                medreq_reasonreference_identifier_value,
                                medreq_reasonreference_display,
                                medreq_basedon_ref,
                                medreq_basedon_type,
                                medreq_basedon_identifier_use,
                                medreq_basedon_identifier_type_system,
                                medreq_basedon_identifier_type_version,
                                medreq_basedon_identifier_type_code,
                                medreq_basedon_identifier_type_display,
                                medreq_basedon_identifier_type_text,
                                medreq_basedon_identifier_system,
                                medreq_basedon_identifier_value,
                                medreq_basedon_display,
                                medreq_note_authorstring,
                                medreq_note_authorreference_ref,
                                medreq_note_authorreference_type,
                                medreq_note_authorreference_identifier_use,
                                medreq_note_authorreference_identifier_type_system,
                                medreq_note_authorreference_identifier_type_version,
                                medreq_note_authorreference_identifier_type_code,
                                medreq_note_authorreference_identifier_type_display,
                                medreq_note_authorreference_identifier_type_text,
                                medreq_note_authorreference_identifier_system,
                                medreq_note_authorreference_identifier_value,
                                medreq_note_authorreference_display,
                                medreq_note_time,
                                medreq_note_text,
                                medreq_doseinstruc_sequence,
                                medreq_doseinstruc_text,
                                medreq_doseinstruc_additionalinstruction_system,
                                medreq_doseinstruc_additionalinstruction_version,
                                medreq_doseinstruc_additionalinstruction_code,
                                medreq_doseinstruc_additionalinstruction_display,
                                medreq_doseinstruc_additionalinstruction_text,
                                medreq_doseinstruc_patientinstruction,
                                medreq_doseinstruc_timing_event,
                                medreq_doseinstruc_timing_repeat_boundsduration_value,
                                medreq_doseinstruc_timing_repeat_boundsduration_comparator,
                                medreq_doseinstruc_timing_repeat_boundsduration_unit,
                                medreq_doseinstruc_timing_repeat_boundsduration_system,
                                medreq_doseinstruc_timing_repeat_boundsduration_code,
                                medreq_doseinstruc_timing_repeat_boundsrange_low_value,
                                medreq_doseinstruc_timing_repeat_boundsrange_low_unit,
                                medreq_doseinstruc_timing_repeat_boundsrange_low_system,
                                medreq_doseinstruc_timing_repeat_boundsrange_low_code,
                                medreq_doseinstruc_timing_repeat_boundsrange_high_value,
                                medreq_doseinstruc_timing_repeat_boundsrange_high_unit,
                                medreq_doseinstruc_timing_repeat_boundsrange_high_system,
                                medreq_doseinstruc_timing_repeat_boundsrange_high_code,
                                medreq_doseinstruc_timing_repeat_boundsperiod_start,
                                medreq_doseinstruc_timing_repeat_boundsperiod_end,
                                medreq_doseinstruc_timing_repeat_count,
                                medreq_doseinstruc_timing_repeat_countmax,
                                medreq_doseinstruc_timing_repeat_duration,
                                medreq_doseinstruc_timing_repeat_durationmax,
                                medreq_doseinstruc_timing_repeat_durationunit,
                                medreq_doseinstruc_timing_repeat_frequency,
                                medreq_doseinstruc_timing_repeat_frequencymax,
                                medreq_doseinstruc_timing_repeat_period,
                                medreq_doseinstruc_timing_repeat_periodmax,
                                medreq_doseinstruc_timing_repeat_periodunit,
                                medreq_doseinstruc_timing_repeat_dayofweek,
                                medreq_doseinstruc_timing_repeat_timeofday,
                                medreq_doseinstruc_timing_repeat_when,
                                medreq_doseinstruc_timing_repeat_offset,
                                medreq_doseinstruc_timing_code_system,
                                medreq_doseinstruc_timing_code_version,
                                medreq_doseinstruc_timing_code_code,
                                medreq_doseinstruc_timing_code_display,
                                medreq_doseinstruc_timing_code_text,
                                medreq_doseinstruc_asneededboolean,
                                medreq_doseinstruc_asneededcodeableconcept_system,
                                medreq_doseinstruc_asneededcodeableconcept_version,
                                medreq_doseinstruc_asneededcodeableconcept_code,
                                medreq_doseinstruc_asneededcodeableconcept_display,
                                medreq_doseinstruc_asneededcodeableconcept_text,
                                medreq_doseinstruc_site_system,
                                medreq_doseinstruc_site_version,
                                medreq_doseinstruc_site_code,
                                medreq_doseinstruc_site_display,
                                medreq_doseinstruc_site_text,
                                medreq_doseinstruc_route_system,
                                medreq_doseinstruc_route_version,
                                medreq_doseinstruc_route_code,
                                medreq_doseinstruc_route_display,
                                medreq_doseinstruc_route_text,
                                medreq_doseinstruc_method_system,
                                medreq_doseinstruc_method_version,
                                medreq_doseinstruc_method_code,
                                medreq_doseinstruc_method_display,
                                medreq_doseinstruc_method_text,
                                medreq_doseinstruc_doseandrate_type_system,
                                medreq_doseinstruc_doseandrate_type_version,
                                medreq_doseinstruc_doseandrate_type_code,
                                medreq_doseinstruc_doseandrate_type_display,
                                medreq_doseinstruc_doseandrate_type_text,
                                medreq_doseinstruc_doseandrate_doserange_low_value,
                                medreq_doseinstruc_doseandrate_doserange_low_unit,
                                medreq_doseinstruc_doseandrate_doserange_low_system,
                                medreq_doseinstruc_doseandrate_doserange_low_code,
                                medreq_doseinstruc_doseandrate_doserange_high_value,
                                medreq_doseinstruc_doseandrate_doserange_high_unit,
                                medreq_doseinstruc_doseandrate_doserange_high_system,
                                medreq_doseinstruc_doseandrate_doserange_high_code,
                                medreq_doseinstruc_doseandrate_dosequantity_value,
                                medreq_doseinstruc_doseandrate_dosequantity_comparator,
                                medreq_doseinstruc_doseandrate_dosequantity_unit,
                                medreq_doseinstruc_doseandrate_dosequantity_system,
                                medreq_doseinstruc_doseandrate_dosequantity_code,
                                medreq_doseinstruc_doseandrate_rateratio_numerator_value,
                                medreq_doseinstruc_doseandrate_rateratio_numerator_comparator,
                                medreq_doseinstruc_doseandrate_rateratio_numerator_unit,
                                medreq_doseinstruc_doseandrate_rateratio_numerator_system,
                                medreq_doseinstruc_doseandrate_rateratio_numerator_code,
                                medreq_doseinstruc_doseandrate_rateratio_denominator_value,
                                medreq_doseinstruc_doseandrate_rateratio_denominator_comparator,
                                medreq_doseinstruc_doseandrate_rateratio_denominator_unit,
                                medreq_doseinstruc_doseandrate_rateratio_denominator_system,
                                medreq_doseinstruc_doseandrate_rateratio_denominator_code,
                                medreq_doseinstruc_doseandrate_raterange_low_value,
                                medreq_doseinstruc_doseandrate_raterange_low_unit,
                                medreq_doseinstruc_doseandrate_raterange_low_system,
                                medreq_doseinstruc_doseandrate_raterange_low_code,
                                medreq_doseinstruc_doseandrate_raterange_high_value,
                                medreq_doseinstruc_doseandrate_raterange_high_unit,
                                medreq_doseinstruc_doseandrate_raterange_high_system,
                                medreq_doseinstruc_doseandrate_raterange_high_code,
                                medreq_doseinstruc_doseandrate_ratequantity_value,
                                medreq_doseinstruc_doseandrate_ratequantity_unit,
                                medreq_doseinstruc_doseandrate_ratequantity_system,
                                medreq_doseinstruc_doseandrate_ratequantity_code,
                                medreq_doseinstruc_maxdoseperperiod_numerator_value,
                                medreq_doseinstruc_maxdoseperperiod_numerator_comparator,
                                medreq_doseinstruc_maxdoseperperiod_numerator_unit,
                                medreq_doseinstruc_maxdoseperperiod_numerator_system,
                                medreq_doseinstruc_maxdoseperperiod_numerator_code,
                                medreq_doseinstruc_maxdoseperperiod_denominator_value,
                                medreq_doseinstruc_maxdoseperperiod_denominator_comparator,
                                medreq_doseinstruc_maxdoseperperiod_denominator_unit,
                                medreq_doseinstruc_maxdoseperperiod_denominator_system,
                                medreq_doseinstruc_maxdoseperperiod_denominator_code,
                                medreq_doseinstruc_maxdoseperadministration_value,
                                medreq_doseinstruc_maxdoseperadministration_unit,
                                medreq_doseinstruc_maxdoseperadministration_system,
                                medreq_doseinstruc_maxdoseperadministration_code,
                                medreq_doseinstruc_maxdoseperlifetime_value,
                                medreq_doseinstruc_maxdoseperlifetime_unit,
                                medreq_doseinstruc_maxdoseperlifetime_system,
                                medreq_doseinstruc_maxdoseperlifetime_code,
                                medreq_substitution_reason_system,
                                medreq_substitution_reason_version,
                                medreq_substitution_reason_code,
                                medreq_substitution_reason_display,
                                medreq_substitution_reason_text,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.medicationrequest_raw_id,
                                current_record.medreq_id,
                                current_record.medreq_meta_versionid,
                                current_record.medreq_meta_lastupdated,
                                current_record.medreq_meta_profile,
                                current_record.medreq_identifier_use,
                                current_record.medreq_identifier_type_system,
                                current_record.medreq_identifier_type_version,
                                current_record.medreq_identifier_type_code,
                                current_record.medreq_identifier_type_display,
                                current_record.medreq_identifier_type_text,
                                current_record.medreq_identifier_system,
                                current_record.medreq_identifier_value,
                                current_record.medreq_identifier_start,
                                current_record.medreq_identifier_end,
                                current_record.medreq_encounter_ref,
                                current_record.medreq_patient_ref,
                                current_record.medreq_medicationreference_ref,
                                current_record.medreq_status,
                                current_record.medreq_statusreason_system,
                                current_record.medreq_statusreason_version,
                                current_record.medreq_statusreason_code,
                                current_record.medreq_statusreason_display,
                                current_record.medreq_statusreason_text,
                                current_record.medreq_intend,
                                current_record.medreq_intent,
                                current_record.medreq_category_system,
                                current_record.medreq_category_version,
                                current_record.medreq_category_code,
                                current_record.medreq_category_display,
                                current_record.medreq_category_text,
                                current_record.medreq_priority,
                                current_record.medreq_reportedboolean,
                                current_record.medreq_reportedreference_ref,
                                current_record.medreq_reportedreference_type,
                                current_record.medreq_reportedreference_identifier_use,
                                current_record.medreq_reportedreference_identifier_type_system,
                                current_record.medreq_reportedreference_identifier_type_version,
                                current_record.medreq_reportedreference_identifier_type_code,
                                current_record.medreq_reportedreference_identifier_type_display,
                                current_record.medreq_reportedreference_identifier_type_text,
                                current_record.medreq_reportedreference_identifier_system,
                                current_record.medreq_reportedreference_identifier_value,
                                current_record.medreq_reportedreference_display,
                                current_record.medreq_medicationcodeableconcept_system,
                                current_record.medreq_medicationcodeableconcept_version,
                                current_record.medreq_medicationcodeableconcept_code,
                                current_record.medreq_medicationcodeableconcept_display,
                                current_record.medreq_medicationcodeableconcept_text,
                                current_record.medreq_supportinginformation_ref,
                                current_record.medreq_supportinginformation_type,
                                current_record.medreq_supportinginformation_identifier_use,
                                current_record.medreq_supportinginformation_identifier_type_system,
                                current_record.medreq_supportinginformation_identifier_type_version,
                                current_record.medreq_supportinginformation_identifier_type_code,
                                current_record.medreq_supportinginformation_identifier_type_display,
                                current_record.medreq_supportinginformation_identifier_type_text,
                                current_record.medreq_supportinginformation_identifier_system,
                                current_record.medreq_supportinginformation_identifier_value,
                                current_record.medreq_supportinginformation_display,
                                current_record.medreq_authoredon,
                                current_record.medreq_requester_ref,
                                current_record.medreq_requester_type,
                                current_record.medreq_requester_identifier_use,
                                current_record.medreq_requester_identifier_type_system,
                                current_record.medreq_requester_identifier_type_version,
                                current_record.medreq_requester_identifier_type_code,
                                current_record.medreq_requester_identifier_type_display,
                                current_record.medreq_requester_identifier_type_text,
                                current_record.medreq_requester_identifier_system,
                                current_record.medreq_requester_identifier_value,
                                current_record.medreq_requester_display,
                                current_record.medreq_reasoncode_system,
                                current_record.medreq_reasoncode_version,
                                current_record.medreq_reasoncode_code,
                                current_record.medreq_reasoncode_display,
                                current_record.medreq_reasoncode_text,
                                current_record.medreq_reasonreference_ref,
                                current_record.medreq_reasonreference_type,
                                current_record.medreq_reasonreference_identifier_use,
                                current_record.medreq_reasonreference_identifier_type_system,
                                current_record.medreq_reasonreference_identifier_type_version,
                                current_record.medreq_reasonreference_identifier_type_code,
                                current_record.medreq_reasonreference_identifier_type_display,
                                current_record.medreq_reasonreference_identifier_type_text,
                                current_record.medreq_reasonreference_identifier_system,
                                current_record.medreq_reasonreference_identifier_value,
                                current_record.medreq_reasonreference_display,
                                current_record.medreq_basedon_ref,
                                current_record.medreq_basedon_type,
                                current_record.medreq_basedon_identifier_use,
                                current_record.medreq_basedon_identifier_type_system,
                                current_record.medreq_basedon_identifier_type_version,
                                current_record.medreq_basedon_identifier_type_code,
                                current_record.medreq_basedon_identifier_type_display,
                                current_record.medreq_basedon_identifier_type_text,
                                current_record.medreq_basedon_identifier_system,
                                current_record.medreq_basedon_identifier_value,
                                current_record.medreq_basedon_display,
                                current_record.medreq_note_authorstring,
                                current_record.medreq_note_authorreference_ref,
                                current_record.medreq_note_authorreference_type,
                                current_record.medreq_note_authorreference_identifier_use,
                                current_record.medreq_note_authorreference_identifier_type_system,
                                current_record.medreq_note_authorreference_identifier_type_version,
                                current_record.medreq_note_authorreference_identifier_type_code,
                                current_record.medreq_note_authorreference_identifier_type_display,
                                current_record.medreq_note_authorreference_identifier_type_text,
                                current_record.medreq_note_authorreference_identifier_system,
                                current_record.medreq_note_authorreference_identifier_value,
                                current_record.medreq_note_authorreference_display,
                                current_record.medreq_note_time,
                                current_record.medreq_note_text,
                                current_record.medreq_doseinstruc_sequence,
                                current_record.medreq_doseinstruc_text,
                                current_record.medreq_doseinstruc_additionalinstruction_system,
                                current_record.medreq_doseinstruc_additionalinstruction_version,
                                current_record.medreq_doseinstruc_additionalinstruction_code,
                                current_record.medreq_doseinstruc_additionalinstruction_display,
                                current_record.medreq_doseinstruc_additionalinstruction_text,
                                current_record.medreq_doseinstruc_patientinstruction,
                                current_record.medreq_doseinstruc_timing_event,
                                current_record.medreq_doseinstruc_timing_repeat_boundsduration_value,
                                current_record.medreq_doseinstruc_timing_repeat_boundsduration_comparator,
                                current_record.medreq_doseinstruc_timing_repeat_boundsduration_unit,
                                current_record.medreq_doseinstruc_timing_repeat_boundsduration_system,
                                current_record.medreq_doseinstruc_timing_repeat_boundsduration_code,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_value,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_unit,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_system,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_low_code,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_value,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_unit,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_system,
                                current_record.medreq_doseinstruc_timing_repeat_boundsrange_high_code,
                                current_record.medreq_doseinstruc_timing_repeat_boundsperiod_start,
                                current_record.medreq_doseinstruc_timing_repeat_boundsperiod_end,
                                current_record.medreq_doseinstruc_timing_repeat_count,
                                current_record.medreq_doseinstruc_timing_repeat_countmax,
                                current_record.medreq_doseinstruc_timing_repeat_duration,
                                current_record.medreq_doseinstruc_timing_repeat_durationmax,
                                current_record.medreq_doseinstruc_timing_repeat_durationunit,
                                current_record.medreq_doseinstruc_timing_repeat_frequency,
                                current_record.medreq_doseinstruc_timing_repeat_frequencymax,
                                current_record.medreq_doseinstruc_timing_repeat_period,
                                current_record.medreq_doseinstruc_timing_repeat_periodmax,
                                current_record.medreq_doseinstruc_timing_repeat_periodunit,
                                current_record.medreq_doseinstruc_timing_repeat_dayofweek,
                                current_record.medreq_doseinstruc_timing_repeat_timeofday,
                                current_record.medreq_doseinstruc_timing_repeat_when,
                                current_record.medreq_doseinstruc_timing_repeat_offset,
                                current_record.medreq_doseinstruc_timing_code_system,
                                current_record.medreq_doseinstruc_timing_code_version,
                                current_record.medreq_doseinstruc_timing_code_code,
                                current_record.medreq_doseinstruc_timing_code_display,
                                current_record.medreq_doseinstruc_timing_code_text,
                                current_record.medreq_doseinstruc_asneededboolean,
                                current_record.medreq_doseinstruc_asneededcodeableconcept_system,
                                current_record.medreq_doseinstruc_asneededcodeableconcept_version,
                                current_record.medreq_doseinstruc_asneededcodeableconcept_code,
                                current_record.medreq_doseinstruc_asneededcodeableconcept_display,
                                current_record.medreq_doseinstruc_asneededcodeableconcept_text,
                                current_record.medreq_doseinstruc_site_system,
                                current_record.medreq_doseinstruc_site_version,
                                current_record.medreq_doseinstruc_site_code,
                                current_record.medreq_doseinstruc_site_display,
                                current_record.medreq_doseinstruc_site_text,
                                current_record.medreq_doseinstruc_route_system,
                                current_record.medreq_doseinstruc_route_version,
                                current_record.medreq_doseinstruc_route_code,
                                current_record.medreq_doseinstruc_route_display,
                                current_record.medreq_doseinstruc_route_text,
                                current_record.medreq_doseinstruc_method_system,
                                current_record.medreq_doseinstruc_method_version,
                                current_record.medreq_doseinstruc_method_code,
                                current_record.medreq_doseinstruc_method_display,
                                current_record.medreq_doseinstruc_method_text,
                                current_record.medreq_doseinstruc_doseandrate_type_system,
                                current_record.medreq_doseinstruc_doseandrate_type_version,
                                current_record.medreq_doseinstruc_doseandrate_type_code,
                                current_record.medreq_doseinstruc_doseandrate_type_display,
                                current_record.medreq_doseinstruc_doseandrate_type_text,
                                current_record.medreq_doseinstruc_doseandrate_doserange_low_value,
                                current_record.medreq_doseinstruc_doseandrate_doserange_low_unit,
                                current_record.medreq_doseinstruc_doseandrate_doserange_low_system,
                                current_record.medreq_doseinstruc_doseandrate_doserange_low_code,
                                current_record.medreq_doseinstruc_doseandrate_doserange_high_value,
                                current_record.medreq_doseinstruc_doseandrate_doserange_high_unit,
                                current_record.medreq_doseinstruc_doseandrate_doserange_high_system,
                                current_record.medreq_doseinstruc_doseandrate_doserange_high_code,
                                current_record.medreq_doseinstruc_doseandrate_dosequantity_value,
                                current_record.medreq_doseinstruc_doseandrate_dosequantity_comparator,
                                current_record.medreq_doseinstruc_doseandrate_dosequantity_unit,
                                current_record.medreq_doseinstruc_doseandrate_dosequantity_system,
                                current_record.medreq_doseinstruc_doseandrate_dosequantity_code,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_value,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_comparator,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_unit,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_system,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_numerator_code,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_value,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_comparator,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_unit,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_system,
                                current_record.medreq_doseinstruc_doseandrate_rateratio_denominator_code,
                                current_record.medreq_doseinstruc_doseandrate_raterange_low_value,
                                current_record.medreq_doseinstruc_doseandrate_raterange_low_unit,
                                current_record.medreq_doseinstruc_doseandrate_raterange_low_system,
                                current_record.medreq_doseinstruc_doseandrate_raterange_low_code,
                                current_record.medreq_doseinstruc_doseandrate_raterange_high_value,
                                current_record.medreq_doseinstruc_doseandrate_raterange_high_unit,
                                current_record.medreq_doseinstruc_doseandrate_raterange_high_system,
                                current_record.medreq_doseinstruc_doseandrate_raterange_high_code,
                                current_record.medreq_doseinstruc_doseandrate_ratequantity_value,
                                current_record.medreq_doseinstruc_doseandrate_ratequantity_unit,
                                current_record.medreq_doseinstruc_doseandrate_ratequantity_system,
                                current_record.medreq_doseinstruc_doseandrate_ratequantity_code,
                                current_record.medreq_doseinstruc_maxdoseperperiod_numerator_value,
                                current_record.medreq_doseinstruc_maxdoseperperiod_numerator_comparator,
                                current_record.medreq_doseinstruc_maxdoseperperiod_numerator_unit,
                                current_record.medreq_doseinstruc_maxdoseperperiod_numerator_system,
                                current_record.medreq_doseinstruc_maxdoseperperiod_numerator_code,
                                current_record.medreq_doseinstruc_maxdoseperperiod_denominator_value,
                                current_record.medreq_doseinstruc_maxdoseperperiod_denominator_comparator,
                                current_record.medreq_doseinstruc_maxdoseperperiod_denominator_unit,
                                current_record.medreq_doseinstruc_maxdoseperperiod_denominator_system,
                                current_record.medreq_doseinstruc_maxdoseperperiod_denominator_code,
                                current_record.medreq_doseinstruc_maxdoseperadministration_value,
                                current_record.medreq_doseinstruc_maxdoseperadministration_unit,
                                current_record.medreq_doseinstruc_maxdoseperadministration_system,
                                current_record.medreq_doseinstruc_maxdoseperadministration_code,
                                current_record.medreq_doseinstruc_maxdoseperlifetime_value,
                                current_record.medreq_doseinstruc_maxdoseperlifetime_unit,
                                current_record.medreq_doseinstruc_maxdoseperlifetime_system,
                                current_record.medreq_doseinstruc_maxdoseperlifetime_code,
                                current_record.medreq_substitution_reason_system,
                                current_record.medreq_substitution_reason_version,
                                current_record.medreq_substitution_reason_code,
                                current_record.medreq_substitution_reason_display,
                                current_record.medreq_substitution_reason_text,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='medicationrequest_raw-20';    err_schema:='cds2db_in';    err_table:='medicationrequest_raw';
                            DELETE FROM cds2db_in.medicationrequest_raw WHERE medicationrequest_raw_id = current_record.medicationrequest_raw_id;
                        ELSE
                            err_section:='medicationrequest_raw-25';    err_schema:='db_log';    err_table:='medicationrequest_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.medicationrequest_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='medicationrequest_raw-37';    err_schema:='cds2db_in';    err_table:='medicationrequest_raw';
                                                        UPDATE db_log.medicationrequest_raw target_record SET medreq_meta_versionid = current_record.medreq_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medreq_meta_versionid) != db.to_char_immutable(current_record.medreq_meta_versionid);
                            UPDATE db_log.medicationrequest_raw target_record SET medreq_meta_lastupdated = current_record.medreq_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medreq_meta_lastupdated) != db.to_char_immutable(current_record.medreq_meta_lastupdated);
                            UPDATE db_log.medicationrequest_raw target_record SET medreq_meta_profile = current_record.medreq_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medreq_meta_profile) != db.to_char_immutable(current_record.medreq_meta_profile);

                            -- Delete updatet datasets
                            err_section:='medicationrequest_raw-30';    err_schema:='cds2db_in';    err_table:='medicationrequest_raw';
                            DELETE FROM cds2db_in.medicationrequest_raw WHERE medicationrequest_raw_id = current_record.medicationrequest_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='medicationrequest_raw-35';    err_schema:='cds2db_in';    err_table:='medicationrequest_raw';
                            UPDATE cds2db_in.medicationrequest_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE medicationrequest_raw_id = current_record.medicationrequest_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='medicationrequest_raw-40';    err_schema:='cds2db_in';    err_table:='medicationrequest_raw';
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
                err_section:='medicationrequest_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT medicationrequest_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'medicationrequest_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.medicationrequest_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='medicationrequest_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'medicationrequest_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'medicationrequest_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'medicationrequest_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='medicationrequest_raw-50';    err_schema:='/';    err_table:='/';
        -- END medicationrequest_raw  --------   medicationrequest_raw  --------   medicationrequest_raw  --------   medicationrequest_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start medicationadministration_raw  --------   medicationadministration_raw  --------   medicationadministration_raw  --------   medicationadministration_raw
        err_section:='medicationadministration_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.medicationadministration_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='medicationadministration_raw-05';    err_schema:='cds2db_in';    err_table:='medicationadministration_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.medicationadministration_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='medicationadministration_raw-10';    err_schema:='db_log';    err_table:='medicationadministration_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.medicationadministration_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='medicationadministration_raw-15';    err_schema:='db_log';    err_table:='medicationadministration_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.medicationadministration_raw (
                                medicationadministration_raw_id,
                                medadm_id,
                                medadm_meta_versionid,
                                medadm_meta_lastupdated,
                                medadm_meta_profile,
                                medadm_identifier_use,
                                medadm_identifier_type_system,
                                medadm_identifier_type_version,
                                medadm_identifier_type_code,
                                medadm_identifier_type_display,
                                medadm_identifier_type_text,
                                medadm_identifier_system,
                                medadm_identifier_value,
                                medadm_identifier_start,
                                medadm_identifier_end,
                                medadm_encounter_ref,
                                medadm_patient_ref,
                                medadm_partof_ref,
                                medadm_status,
                                medadm_statusreason_system,
                                medadm_statusreason_version,
                                medadm_statusreason_code,
                                medadm_statusreason_display,
                                medadm_statusreason_text,
                                medadm_category_system,
                                medadm_category_version,
                                medadm_category_code,
                                medadm_category_display,
                                medadm_category_text,
                                medadm_medicationreference_ref,
                                medadm_medicationcodeableconcept_system,
                                medadm_medicationcodeableconcept_version,
                                medadm_medicationcodeableconcept_code,
                                medadm_medicationcodeableconcept_display,
                                medadm_medicationcodeableconcept_text,
                                medadm_supportinginformation_ref,
                                medadm_supportinginformation_type,
                                medadm_supportinginformation_identifier_use,
                                medadm_supportinginformation_identifier_type_system,
                                medadm_supportinginformation_identifier_type_version,
                                medadm_supportinginformation_identifier_type_code,
                                medadm_supportinginformation_identifier_type_display,
                                medadm_supportinginformation_identifier_type_text,
                                medadm_supportinginformation_identifier_system,
                                medadm_supportinginformation_identifier_value,
                                medadm_supportinginformation_display,
                                medadm_effectivedatetime,
                                medadm_effectiveperiod_start,
                                medadm_effectiveperiod_end,
                                medadm_performer_function_system,
                                medadm_performer_function_version,
                                medadm_performer_function_code,
                                medadm_performer_function_display,
                                medadm_performer_function_text,
                                medadm_reasoncode_system,
                                medadm_reasoncode_version,
                                medadm_reasoncode_code,
                                medadm_reasoncode_display,
                                medadm_reasoncode_text,
                                medadm_reasonreference_ref,
                                medadm_reasonreference_type,
                                medadm_reasonreference_identifier_use,
                                medadm_reasonreference_identifier_type_system,
                                medadm_reasonreference_identifier_type_version,
                                medadm_reasonreference_identifier_type_code,
                                medadm_reasonreference_identifier_type_display,
                                medadm_reasonreference_identifier_type_text,
                                medadm_reasonreference_identifier_system,
                                medadm_reasonreference_identifier_value,
                                medadm_reasonreference_display,
                                medadm_request_ref,
                                medadm_note_authorstring,
                                medadm_note_authorreference_ref,
                                medadm_note_authorreference_type,
                                medadm_note_authorreference_identifier_use,
                                medadm_note_authorreference_identifier_type_system,
                                medadm_note_authorreference_identifier_type_version,
                                medadm_note_authorreference_identifier_type_code,
                                medadm_note_authorreference_identifier_type_display,
                                medadm_note_authorreference_identifier_type_text,
                                medadm_note_authorreference_identifier_system,
                                medadm_note_authorreference_identifier_value,
                                medadm_note_authorreference_display,
                                medadm_note_time,
                                medadm_note_text,
                                medadm_dosage_text,
                                medadm_dosage_site_system,
                                medadm_dosage_site_version,
                                medadm_dosage_site_code,
                                medadm_dosage_site_display,
                                medadm_dosage_site_text,
                                medadm_dosage_route_system,
                                medadm_dosage_route_version,
                                medadm_dosage_route_code,
                                medadm_dosage_route_display,
                                medadm_dosage_route_text,
                                medadm_dosage_method_system,
                                medadm_dosage_method_version,
                                medadm_dosage_method_code,
                                medadm_dosage_method_display,
                                medadm_dosage_method_text,
                                medadm_dosage_dose_value,
                                medadm_dosage_dose_unit,
                                medadm_dosage_dose_system,
                                medadm_dosage_dose_code,
                                medadm_dosage_rateratio_numerator_value,
                                medadm_dosage_rateratio_numerator_comparator,
                                medadm_dosage_rateratio_numerator_unit,
                                medadm_dosage_rateratio_numerator_system,
                                medadm_dosage_rateratio_numerator_code,
                                medadm_dosage_rateratio_denominator_value,
                                medadm_dosage_rateratio_denominator_comparator,
                                medadm_dosage_rateratio_denominator_unit,
                                medadm_dosage_rateratio_denominator_system,
                                medadm_dosage_rateratio_denominator_code,
                                medadm_dosage_ratequantity_value,
                                medadm_dosage_ratequantity_unit,
                                medadm_dosage_ratequantity_system,
                                medadm_dosage_ratequantity_code,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.medicationadministration_raw_id,
                                current_record.medadm_id,
                                current_record.medadm_meta_versionid,
                                current_record.medadm_meta_lastupdated,
                                current_record.medadm_meta_profile,
                                current_record.medadm_identifier_use,
                                current_record.medadm_identifier_type_system,
                                current_record.medadm_identifier_type_version,
                                current_record.medadm_identifier_type_code,
                                current_record.medadm_identifier_type_display,
                                current_record.medadm_identifier_type_text,
                                current_record.medadm_identifier_system,
                                current_record.medadm_identifier_value,
                                current_record.medadm_identifier_start,
                                current_record.medadm_identifier_end,
                                current_record.medadm_encounter_ref,
                                current_record.medadm_patient_ref,
                                current_record.medadm_partof_ref,
                                current_record.medadm_status,
                                current_record.medadm_statusreason_system,
                                current_record.medadm_statusreason_version,
                                current_record.medadm_statusreason_code,
                                current_record.medadm_statusreason_display,
                                current_record.medadm_statusreason_text,
                                current_record.medadm_category_system,
                                current_record.medadm_category_version,
                                current_record.medadm_category_code,
                                current_record.medadm_category_display,
                                current_record.medadm_category_text,
                                current_record.medadm_medicationreference_ref,
                                current_record.medadm_medicationcodeableconcept_system,
                                current_record.medadm_medicationcodeableconcept_version,
                                current_record.medadm_medicationcodeableconcept_code,
                                current_record.medadm_medicationcodeableconcept_display,
                                current_record.medadm_medicationcodeableconcept_text,
                                current_record.medadm_supportinginformation_ref,
                                current_record.medadm_supportinginformation_type,
                                current_record.medadm_supportinginformation_identifier_use,
                                current_record.medadm_supportinginformation_identifier_type_system,
                                current_record.medadm_supportinginformation_identifier_type_version,
                                current_record.medadm_supportinginformation_identifier_type_code,
                                current_record.medadm_supportinginformation_identifier_type_display,
                                current_record.medadm_supportinginformation_identifier_type_text,
                                current_record.medadm_supportinginformation_identifier_system,
                                current_record.medadm_supportinginformation_identifier_value,
                                current_record.medadm_supportinginformation_display,
                                current_record.medadm_effectivedatetime,
                                current_record.medadm_effectiveperiod_start,
                                current_record.medadm_effectiveperiod_end,
                                current_record.medadm_performer_function_system,
                                current_record.medadm_performer_function_version,
                                current_record.medadm_performer_function_code,
                                current_record.medadm_performer_function_display,
                                current_record.medadm_performer_function_text,
                                current_record.medadm_reasoncode_system,
                                current_record.medadm_reasoncode_version,
                                current_record.medadm_reasoncode_code,
                                current_record.medadm_reasoncode_display,
                                current_record.medadm_reasoncode_text,
                                current_record.medadm_reasonreference_ref,
                                current_record.medadm_reasonreference_type,
                                current_record.medadm_reasonreference_identifier_use,
                                current_record.medadm_reasonreference_identifier_type_system,
                                current_record.medadm_reasonreference_identifier_type_version,
                                current_record.medadm_reasonreference_identifier_type_code,
                                current_record.medadm_reasonreference_identifier_type_display,
                                current_record.medadm_reasonreference_identifier_type_text,
                                current_record.medadm_reasonreference_identifier_system,
                                current_record.medadm_reasonreference_identifier_value,
                                current_record.medadm_reasonreference_display,
                                current_record.medadm_request_ref,
                                current_record.medadm_note_authorstring,
                                current_record.medadm_note_authorreference_ref,
                                current_record.medadm_note_authorreference_type,
                                current_record.medadm_note_authorreference_identifier_use,
                                current_record.medadm_note_authorreference_identifier_type_system,
                                current_record.medadm_note_authorreference_identifier_type_version,
                                current_record.medadm_note_authorreference_identifier_type_code,
                                current_record.medadm_note_authorreference_identifier_type_display,
                                current_record.medadm_note_authorreference_identifier_type_text,
                                current_record.medadm_note_authorreference_identifier_system,
                                current_record.medadm_note_authorreference_identifier_value,
                                current_record.medadm_note_authorreference_display,
                                current_record.medadm_note_time,
                                current_record.medadm_note_text,
                                current_record.medadm_dosage_text,
                                current_record.medadm_dosage_site_system,
                                current_record.medadm_dosage_site_version,
                                current_record.medadm_dosage_site_code,
                                current_record.medadm_dosage_site_display,
                                current_record.medadm_dosage_site_text,
                                current_record.medadm_dosage_route_system,
                                current_record.medadm_dosage_route_version,
                                current_record.medadm_dosage_route_code,
                                current_record.medadm_dosage_route_display,
                                current_record.medadm_dosage_route_text,
                                current_record.medadm_dosage_method_system,
                                current_record.medadm_dosage_method_version,
                                current_record.medadm_dosage_method_code,
                                current_record.medadm_dosage_method_display,
                                current_record.medadm_dosage_method_text,
                                current_record.medadm_dosage_dose_value,
                                current_record.medadm_dosage_dose_unit,
                                current_record.medadm_dosage_dose_system,
                                current_record.medadm_dosage_dose_code,
                                current_record.medadm_dosage_rateratio_numerator_value,
                                current_record.medadm_dosage_rateratio_numerator_comparator,
                                current_record.medadm_dosage_rateratio_numerator_unit,
                                current_record.medadm_dosage_rateratio_numerator_system,
                                current_record.medadm_dosage_rateratio_numerator_code,
                                current_record.medadm_dosage_rateratio_denominator_value,
                                current_record.medadm_dosage_rateratio_denominator_comparator,
                                current_record.medadm_dosage_rateratio_denominator_unit,
                                current_record.medadm_dosage_rateratio_denominator_system,
                                current_record.medadm_dosage_rateratio_denominator_code,
                                current_record.medadm_dosage_ratequantity_value,
                                current_record.medadm_dosage_ratequantity_unit,
                                current_record.medadm_dosage_ratequantity_system,
                                current_record.medadm_dosage_ratequantity_code,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='medicationadministration_raw-20';    err_schema:='cds2db_in';    err_table:='medicationadministration_raw';
                            DELETE FROM cds2db_in.medicationadministration_raw WHERE medicationadministration_raw_id = current_record.medicationadministration_raw_id;
                        ELSE
                            err_section:='medicationadministration_raw-25';    err_schema:='db_log';    err_table:='medicationadministration_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.medicationadministration_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='medicationadministration_raw-37';    err_schema:='cds2db_in';    err_table:='medicationadministration_raw';
                                                        UPDATE db_log.medicationadministration_raw target_record SET medadm_meta_versionid = current_record.medadm_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medadm_meta_versionid) != db.to_char_immutable(current_record.medadm_meta_versionid);
                            UPDATE db_log.medicationadministration_raw target_record SET medadm_meta_lastupdated = current_record.medadm_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medadm_meta_lastupdated) != db.to_char_immutable(current_record.medadm_meta_lastupdated);
                            UPDATE db_log.medicationadministration_raw target_record SET medadm_meta_profile = current_record.medadm_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medadm_meta_profile) != db.to_char_immutable(current_record.medadm_meta_profile);

                            -- Delete updatet datasets
                            err_section:='medicationadministration_raw-30';    err_schema:='cds2db_in';    err_table:='medicationadministration_raw';
                            DELETE FROM cds2db_in.medicationadministration_raw WHERE medicationadministration_raw_id = current_record.medicationadministration_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='medicationadministration_raw-35';    err_schema:='cds2db_in';    err_table:='medicationadministration_raw';
                            UPDATE cds2db_in.medicationadministration_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE medicationadministration_raw_id = current_record.medicationadministration_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='medicationadministration_raw-40';    err_schema:='cds2db_in';    err_table:='medicationadministration_raw';
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
                err_section:='medicationadministration_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT medicationadministration_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'medicationadministration_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.medicationadministration_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='medicationadministration_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'medicationadministration_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'medicationadministration_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'medicationadministration_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='medicationadministration_raw-50';    err_schema:='/';    err_table:='/';
        -- END medicationadministration_raw  --------   medicationadministration_raw  --------   medicationadministration_raw  --------   medicationadministration_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start medicationstatement_raw  --------   medicationstatement_raw  --------   medicationstatement_raw  --------   medicationstatement_raw
        err_section:='medicationstatement_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.medicationstatement_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='medicationstatement_raw-05';    err_schema:='cds2db_in';    err_table:='medicationstatement_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.medicationstatement_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='medicationstatement_raw-10';    err_schema:='db_log';    err_table:='medicationstatement_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.medicationstatement_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='medicationstatement_raw-15';    err_schema:='db_log';    err_table:='medicationstatement_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.medicationstatement_raw (
                                medicationstatement_raw_id,
                                medstat_id,
                                medstat_meta_versionid,
                                medstat_meta_lastupdated,
                                medstat_meta_profile,
                                medstat_identifier_use,
                                medstat_identifier_type_system,
                                medstat_identifier_type_version,
                                medstat_identifier_type_code,
                                medstat_identifier_type_display,
                                medstat_identifier_type_text,
                                medstat_identifier_system,
                                medstat_identifier_value,
                                medstat_identifier_start,
                                medstat_identifier_end,
                                medstat_encounter_ref,
                                medstat_patient_ref,
                                medstat_partof_ref,
                                medstat_basedon_ref,
                                medstat_basedon_type,
                                medstat_basedon_identifier_use,
                                medstat_basedon_identifier_type_system,
                                medstat_basedon_identifier_type_version,
                                medstat_basedon_identifier_type_code,
                                medstat_basedon_identifier_type_display,
                                medstat_basedon_identifier_type_text,
                                medstat_basedon_identifier_system,
                                medstat_basedon_identifier_value,
                                medstat_basedon_display,
                                medstat_status,
                                medstat_statusreason_system,
                                medstat_statusreason_version,
                                medstat_statusreason_code,
                                medstat_statusreason_display,
                                medstat_statusreason_text,
                                medstat_category_system,
                                medstat_category_version,
                                medstat_category_code,
                                medstat_category_display,
                                medstat_category_text,
                                medstat_medicationreference_ref,
                                medstat_medicationcodeableconcept_system,
                                medstat_medicationcodeableconcept_version,
                                medstat_medicationcodeableconcept_code,
                                medstat_medicationcodeableconcept_display,
                                medstat_medicationcodeableconcept_text,
                                medstat_effectivedatetime,
                                medstat_effectiveperiod_start,
                                medstat_effectiveperiod_end,
                                medstat_dateasserted,
                                medstat_informationsource_ref,
                                medstat_informationsource_type,
                                medstat_informationsource_identifier_use,
                                medstat_informationsource_identifier_type_system,
                                medstat_informationsource_identifier_type_version,
                                medstat_informationsource_identifier_type_code,
                                medstat_informationsource_identifier_type_display,
                                medstat_informationsource_identifier_type_text,
                                medstat_informationsource_identifier_system,
                                medstat_informationsource_identifier_value,
                                medstat_informationsource_display,
                                medstat_derivedfrom_ref,
                                medstat_derivedfrom_type,
                                medstat_derivedfrom_identifier_use,
                                medstat_derivedfrom_identifier_type_system,
                                medstat_derivedfrom_identifier_type_version,
                                medstat_derivedfrom_identifier_type_code,
                                medstat_derivedfrom_identifier_type_display,
                                medstat_derivedfrom_identifier_type_text,
                                medstat_derivedfrom_identifier_system,
                                medstat_derivedfrom_identifier_value,
                                medstat_derivedfrom_display,
                                medstat_reasoncode_system,
                                medstat_reasoncode_version,
                                medstat_reasoncode_code,
                                medstat_reasoncode_display,
                                medstat_reasoncode_text,
                                medstat_reasonreference_ref,
                                medstat_reasonreference_type,
                                medstat_reasonreference_identifier_use,
                                medstat_reasonreference_identifier_type_system,
                                medstat_reasonreference_identifier_type_version,
                                medstat_reasonreference_identifier_type_code,
                                medstat_reasonreference_identifier_type_display,
                                medstat_reasonreference_identifier_type_text,
                                medstat_reasonreference_identifier_system,
                                medstat_reasonreference_identifier_value,
                                medstat_reasonreference_display,
                                medstat_note_authorstring,
                                medstat_note_authorreference_ref,
                                medstat_note_authorreference_type,
                                medstat_note_authorreference_identifier_use,
                                medstat_note_authorreference_identifier_type_system,
                                medstat_note_authorreference_identifier_type_version,
                                medstat_note_authorreference_identifier_type_code,
                                medstat_note_authorreference_identifier_type_display,
                                medstat_note_authorreference_identifier_type_text,
                                medstat_note_authorreference_identifier_system,
                                medstat_note_authorreference_identifier_value,
                                medstat_note_authorreference_display,
                                medstat_note_time,
                                medstat_note_text,
                                medstat_dosage_sequence,
                                medstat_dosage_text,
                                medstat_dosage_additionalinstruction_system,
                                medstat_dosage_additionalinstruction_version,
                                medstat_dosage_additionalinstruction_code,
                                medstat_dosage_additionalinstruction_display,
                                medstat_dosage_additionalinstruction_text,
                                medstat_dosage_patientinstruction,
                                medstat_dosage_timing_event,
                                medstat_dosage_timing_repeat_boundsduration_value,
                                medstat_dosage_timing_repeat_boundsduration_comparator,
                                medstat_dosage_timing_repeat_boundsduration_unit,
                                medstat_dosage_timing_repeat_boundsduration_system,
                                medstat_dosage_timing_repeat_boundsduration_code,
                                medstat_dosage_timing_repeat_boundsrange_low_value,
                                medstat_dosage_timing_repeat_boundsrange_low_unit,
                                medstat_dosage_timing_repeat_boundsrange_low_system,
                                medstat_dosage_timing_repeat_boundsrange_low_code,
                                medstat_dosage_timing_repeat_boundsrange_high_value,
                                medstat_dosage_timing_repeat_boundsrange_high_unit,
                                medstat_dosage_timing_repeat_boundsrange_high_system,
                                medstat_dosage_timing_repeat_boundsrange_high_code,
                                medstat_dosage_timing_repeat_boundsperiod_start,
                                medstat_dosage_timing_repeat_boundsperiod_end,
                                medstat_dosage_timing_repeat_count,
                                medstat_dosage_timing_repeat_countmax,
                                medstat_dosage_timing_repeat_duration,
                                medstat_dosage_timing_repeat_durationmax,
                                medstat_dosage_timing_repeat_durationunit,
                                medstat_dosage_timing_repeat_frequency,
                                medstat_dosage_timing_repeat_frequencymax,
                                medstat_dosage_timing_repeat_period,
                                medstat_dosage_timing_repeat_periodmax,
                                medstat_dosage_timing_repeat_periodunit,
                                medstat_dosage_timing_repeat_dayofweek,
                                medstat_dosage_timing_repeat_timeofday,
                                medstat_dosage_timing_repeat_when,
                                medstat_dosage_timing_repeat_offset,
                                medstat_dosage_timing_code_system,
                                medstat_dosage_timing_code_version,
                                medstat_dosage_timing_code_code,
                                medstat_dosage_timing_code_display,
                                medstat_dosage_timing_code_text,
                                medstat_dosage_asneededboolean,
                                medstat_dosage_asneededcodeableconcept_system,
                                medstat_dosage_asneededcodeableconcept_version,
                                medstat_dosage_asneededcodeableconcept_code,
                                medstat_dosage_asneededcodeableconcept_display,
                                medstat_dosage_asneededcodeableconcept_text,
                                medstat_dosage_site_system,
                                medstat_dosage_site_version,
                                medstat_dosage_site_code,
                                medstat_dosage_site_display,
                                medstat_dosage_site_text,
                                medstat_dosage_route_system,
                                medstat_dosage_route_version,
                                medstat_dosage_route_code,
                                medstat_dosage_route_display,
                                medstat_dosage_route_text,
                                medstat_dosage_method_system,
                                medstat_dosage_method_version,
                                medstat_dosage_method_code,
                                medstat_dosage_method_display,
                                medstat_dosage_method_text,
                                medstat_dosage_doseandrate_type_system,
                                medstat_dosage_doseandrate_type_version,
                                medstat_dosage_doseandrate_type_code,
                                medstat_dosage_doseandrate_type_display,
                                medstat_dosage_doseandrate_type_text,
                                medstat_dosage_doseandrate_doserange_low_value,
                                medstat_dosage_doseandrate_doserange_low_unit,
                                medstat_dosage_doseandrate_doserange_low_system,
                                medstat_dosage_doseandrate_doserange_low_code,
                                medstat_dosage_doseandrate_doserange_high_value,
                                medstat_dosage_doseandrate_doserange_high_unit,
                                medstat_dosage_doseandrate_doserange_high_system,
                                medstat_dosage_doseandrate_doserange_high_code,
                                medstat_dosage_doseandrate_dosequantity_value,
                                medstat_dosage_doseandrate_dosequantity_comparator,
                                medstat_dosage_doseandrate_dosequantity_unit,
                                medstat_dosage_doseandrate_dosequantity_system,
                                medstat_dosage_doseandrate_dosequantity_code,
                                medstat_dosage_doseandrate_rateratio_numerator_value,
                                medstat_dosage_doseandrate_rateratio_numerator_comparator,
                                medstat_dosage_doseandrate_rateratio_numerator_unit,
                                medstat_dosage_doseandrate_rateratio_numerator_system,
                                medstat_dosage_doseandrate_rateratio_numerator_code,
                                medstat_dosage_doseandrate_rateratio_denominator_value,
                                medstat_dosage_doseandrate_rateratio_denominator_comparator,
                                medstat_dosage_doseandrate_rateratio_denominator_unit,
                                medstat_dosage_doseandrate_rateratio_denominator_system,
                                medstat_dosage_doseandrate_rateratio_denominator_code,
                                medstat_dosage_doseandrate_raterange_low_value,
                                medstat_dosage_doseandrate_raterange_low_unit,
                                medstat_dosage_doseandrate_raterange_low_system,
                                medstat_dosage_doseandrate_raterange_low_code,
                                medstat_dosage_doseandrate_raterange_high_value,
                                medstat_dosage_doseandrate_raterange_high_unit,
                                medstat_dosage_doseandrate_raterange_high_system,
                                medstat_dosage_doseandrate_raterange_high_code,
                                medstat_dosage_doseandrate_ratequantity_value,
                                medstat_dosage_doseandrate_ratequantity_unit,
                                medstat_dosage_doseandrate_ratequantity_system,
                                medstat_dosage_doseandrate_ratequantity_code,
                                medstat_dosage_maxdoseperperiod_numerator_value,
                                medstat_dosage_maxdoseperperiod_numerator_comparator,
                                medstat_dosage_maxdoseperperiod_numerator_unit,
                                medstat_dosage_maxdoseperperiod_numerator_system,
                                medstat_dosage_maxdoseperperiod_numerator_code,
                                medstat_dosage_maxdoseperperiod_denominator_value,
                                medstat_dosage_maxdoseperperiod_denominator_comparator,
                                medstat_dosage_maxdoseperperiod_denominator_unit,
                                medstat_dosage_maxdoseperperiod_denominator_system,
                                medstat_dosage_maxdoseperperiod_denominator_code,
                                medstat_dosage_maxdoseperadministration_value,
                                medstat_dosage_maxdoseperadministration_unit,
                                medstat_dosage_maxdoseperadministration_system,
                                medstat_dosage_maxdoseperadministration_code,
                                medstat_dosage_maxdoseperlifetime_value,
                                medstat_dosage_maxdoseperlifetime_unit,
                                medstat_dosage_maxdoseperlifetime_system,
                                medstat_dosage_maxdoseperlifetime_code,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.medicationstatement_raw_id,
                                current_record.medstat_id,
                                current_record.medstat_meta_versionid,
                                current_record.medstat_meta_lastupdated,
                                current_record.medstat_meta_profile,
                                current_record.medstat_identifier_use,
                                current_record.medstat_identifier_type_system,
                                current_record.medstat_identifier_type_version,
                                current_record.medstat_identifier_type_code,
                                current_record.medstat_identifier_type_display,
                                current_record.medstat_identifier_type_text,
                                current_record.medstat_identifier_system,
                                current_record.medstat_identifier_value,
                                current_record.medstat_identifier_start,
                                current_record.medstat_identifier_end,
                                current_record.medstat_encounter_ref,
                                current_record.medstat_patient_ref,
                                current_record.medstat_partof_ref,
                                current_record.medstat_basedon_ref,
                                current_record.medstat_basedon_type,
                                current_record.medstat_basedon_identifier_use,
                                current_record.medstat_basedon_identifier_type_system,
                                current_record.medstat_basedon_identifier_type_version,
                                current_record.medstat_basedon_identifier_type_code,
                                current_record.medstat_basedon_identifier_type_display,
                                current_record.medstat_basedon_identifier_type_text,
                                current_record.medstat_basedon_identifier_system,
                                current_record.medstat_basedon_identifier_value,
                                current_record.medstat_basedon_display,
                                current_record.medstat_status,
                                current_record.medstat_statusreason_system,
                                current_record.medstat_statusreason_version,
                                current_record.medstat_statusreason_code,
                                current_record.medstat_statusreason_display,
                                current_record.medstat_statusreason_text,
                                current_record.medstat_category_system,
                                current_record.medstat_category_version,
                                current_record.medstat_category_code,
                                current_record.medstat_category_display,
                                current_record.medstat_category_text,
                                current_record.medstat_medicationreference_ref,
                                current_record.medstat_medicationcodeableconcept_system,
                                current_record.medstat_medicationcodeableconcept_version,
                                current_record.medstat_medicationcodeableconcept_code,
                                current_record.medstat_medicationcodeableconcept_display,
                                current_record.medstat_medicationcodeableconcept_text,
                                current_record.medstat_effectivedatetime,
                                current_record.medstat_effectiveperiod_start,
                                current_record.medstat_effectiveperiod_end,
                                current_record.medstat_dateasserted,
                                current_record.medstat_informationsource_ref,
                                current_record.medstat_informationsource_type,
                                current_record.medstat_informationsource_identifier_use,
                                current_record.medstat_informationsource_identifier_type_system,
                                current_record.medstat_informationsource_identifier_type_version,
                                current_record.medstat_informationsource_identifier_type_code,
                                current_record.medstat_informationsource_identifier_type_display,
                                current_record.medstat_informationsource_identifier_type_text,
                                current_record.medstat_informationsource_identifier_system,
                                current_record.medstat_informationsource_identifier_value,
                                current_record.medstat_informationsource_display,
                                current_record.medstat_derivedfrom_ref,
                                current_record.medstat_derivedfrom_type,
                                current_record.medstat_derivedfrom_identifier_use,
                                current_record.medstat_derivedfrom_identifier_type_system,
                                current_record.medstat_derivedfrom_identifier_type_version,
                                current_record.medstat_derivedfrom_identifier_type_code,
                                current_record.medstat_derivedfrom_identifier_type_display,
                                current_record.medstat_derivedfrom_identifier_type_text,
                                current_record.medstat_derivedfrom_identifier_system,
                                current_record.medstat_derivedfrom_identifier_value,
                                current_record.medstat_derivedfrom_display,
                                current_record.medstat_reasoncode_system,
                                current_record.medstat_reasoncode_version,
                                current_record.medstat_reasoncode_code,
                                current_record.medstat_reasoncode_display,
                                current_record.medstat_reasoncode_text,
                                current_record.medstat_reasonreference_ref,
                                current_record.medstat_reasonreference_type,
                                current_record.medstat_reasonreference_identifier_use,
                                current_record.medstat_reasonreference_identifier_type_system,
                                current_record.medstat_reasonreference_identifier_type_version,
                                current_record.medstat_reasonreference_identifier_type_code,
                                current_record.medstat_reasonreference_identifier_type_display,
                                current_record.medstat_reasonreference_identifier_type_text,
                                current_record.medstat_reasonreference_identifier_system,
                                current_record.medstat_reasonreference_identifier_value,
                                current_record.medstat_reasonreference_display,
                                current_record.medstat_note_authorstring,
                                current_record.medstat_note_authorreference_ref,
                                current_record.medstat_note_authorreference_type,
                                current_record.medstat_note_authorreference_identifier_use,
                                current_record.medstat_note_authorreference_identifier_type_system,
                                current_record.medstat_note_authorreference_identifier_type_version,
                                current_record.medstat_note_authorreference_identifier_type_code,
                                current_record.medstat_note_authorreference_identifier_type_display,
                                current_record.medstat_note_authorreference_identifier_type_text,
                                current_record.medstat_note_authorreference_identifier_system,
                                current_record.medstat_note_authorreference_identifier_value,
                                current_record.medstat_note_authorreference_display,
                                current_record.medstat_note_time,
                                current_record.medstat_note_text,
                                current_record.medstat_dosage_sequence,
                                current_record.medstat_dosage_text,
                                current_record.medstat_dosage_additionalinstruction_system,
                                current_record.medstat_dosage_additionalinstruction_version,
                                current_record.medstat_dosage_additionalinstruction_code,
                                current_record.medstat_dosage_additionalinstruction_display,
                                current_record.medstat_dosage_additionalinstruction_text,
                                current_record.medstat_dosage_patientinstruction,
                                current_record.medstat_dosage_timing_event,
                                current_record.medstat_dosage_timing_repeat_boundsduration_value,
                                current_record.medstat_dosage_timing_repeat_boundsduration_comparator,
                                current_record.medstat_dosage_timing_repeat_boundsduration_unit,
                                current_record.medstat_dosage_timing_repeat_boundsduration_system,
                                current_record.medstat_dosage_timing_repeat_boundsduration_code,
                                current_record.medstat_dosage_timing_repeat_boundsrange_low_value,
                                current_record.medstat_dosage_timing_repeat_boundsrange_low_unit,
                                current_record.medstat_dosage_timing_repeat_boundsrange_low_system,
                                current_record.medstat_dosage_timing_repeat_boundsrange_low_code,
                                current_record.medstat_dosage_timing_repeat_boundsrange_high_value,
                                current_record.medstat_dosage_timing_repeat_boundsrange_high_unit,
                                current_record.medstat_dosage_timing_repeat_boundsrange_high_system,
                                current_record.medstat_dosage_timing_repeat_boundsrange_high_code,
                                current_record.medstat_dosage_timing_repeat_boundsperiod_start,
                                current_record.medstat_dosage_timing_repeat_boundsperiod_end,
                                current_record.medstat_dosage_timing_repeat_count,
                                current_record.medstat_dosage_timing_repeat_countmax,
                                current_record.medstat_dosage_timing_repeat_duration,
                                current_record.medstat_dosage_timing_repeat_durationmax,
                                current_record.medstat_dosage_timing_repeat_durationunit,
                                current_record.medstat_dosage_timing_repeat_frequency,
                                current_record.medstat_dosage_timing_repeat_frequencymax,
                                current_record.medstat_dosage_timing_repeat_period,
                                current_record.medstat_dosage_timing_repeat_periodmax,
                                current_record.medstat_dosage_timing_repeat_periodunit,
                                current_record.medstat_dosage_timing_repeat_dayofweek,
                                current_record.medstat_dosage_timing_repeat_timeofday,
                                current_record.medstat_dosage_timing_repeat_when,
                                current_record.medstat_dosage_timing_repeat_offset,
                                current_record.medstat_dosage_timing_code_system,
                                current_record.medstat_dosage_timing_code_version,
                                current_record.medstat_dosage_timing_code_code,
                                current_record.medstat_dosage_timing_code_display,
                                current_record.medstat_dosage_timing_code_text,
                                current_record.medstat_dosage_asneededboolean,
                                current_record.medstat_dosage_asneededcodeableconcept_system,
                                current_record.medstat_dosage_asneededcodeableconcept_version,
                                current_record.medstat_dosage_asneededcodeableconcept_code,
                                current_record.medstat_dosage_asneededcodeableconcept_display,
                                current_record.medstat_dosage_asneededcodeableconcept_text,
                                current_record.medstat_dosage_site_system,
                                current_record.medstat_dosage_site_version,
                                current_record.medstat_dosage_site_code,
                                current_record.medstat_dosage_site_display,
                                current_record.medstat_dosage_site_text,
                                current_record.medstat_dosage_route_system,
                                current_record.medstat_dosage_route_version,
                                current_record.medstat_dosage_route_code,
                                current_record.medstat_dosage_route_display,
                                current_record.medstat_dosage_route_text,
                                current_record.medstat_dosage_method_system,
                                current_record.medstat_dosage_method_version,
                                current_record.medstat_dosage_method_code,
                                current_record.medstat_dosage_method_display,
                                current_record.medstat_dosage_method_text,
                                current_record.medstat_dosage_doseandrate_type_system,
                                current_record.medstat_dosage_doseandrate_type_version,
                                current_record.medstat_dosage_doseandrate_type_code,
                                current_record.medstat_dosage_doseandrate_type_display,
                                current_record.medstat_dosage_doseandrate_type_text,
                                current_record.medstat_dosage_doseandrate_doserange_low_value,
                                current_record.medstat_dosage_doseandrate_doserange_low_unit,
                                current_record.medstat_dosage_doseandrate_doserange_low_system,
                                current_record.medstat_dosage_doseandrate_doserange_low_code,
                                current_record.medstat_dosage_doseandrate_doserange_high_value,
                                current_record.medstat_dosage_doseandrate_doserange_high_unit,
                                current_record.medstat_dosage_doseandrate_doserange_high_system,
                                current_record.medstat_dosage_doseandrate_doserange_high_code,
                                current_record.medstat_dosage_doseandrate_dosequantity_value,
                                current_record.medstat_dosage_doseandrate_dosequantity_comparator,
                                current_record.medstat_dosage_doseandrate_dosequantity_unit,
                                current_record.medstat_dosage_doseandrate_dosequantity_system,
                                current_record.medstat_dosage_doseandrate_dosequantity_code,
                                current_record.medstat_dosage_doseandrate_rateratio_numerator_value,
                                current_record.medstat_dosage_doseandrate_rateratio_numerator_comparator,
                                current_record.medstat_dosage_doseandrate_rateratio_numerator_unit,
                                current_record.medstat_dosage_doseandrate_rateratio_numerator_system,
                                current_record.medstat_dosage_doseandrate_rateratio_numerator_code,
                                current_record.medstat_dosage_doseandrate_rateratio_denominator_value,
                                current_record.medstat_dosage_doseandrate_rateratio_denominator_comparator,
                                current_record.medstat_dosage_doseandrate_rateratio_denominator_unit,
                                current_record.medstat_dosage_doseandrate_rateratio_denominator_system,
                                current_record.medstat_dosage_doseandrate_rateratio_denominator_code,
                                current_record.medstat_dosage_doseandrate_raterange_low_value,
                                current_record.medstat_dosage_doseandrate_raterange_low_unit,
                                current_record.medstat_dosage_doseandrate_raterange_low_system,
                                current_record.medstat_dosage_doseandrate_raterange_low_code,
                                current_record.medstat_dosage_doseandrate_raterange_high_value,
                                current_record.medstat_dosage_doseandrate_raterange_high_unit,
                                current_record.medstat_dosage_doseandrate_raterange_high_system,
                                current_record.medstat_dosage_doseandrate_raterange_high_code,
                                current_record.medstat_dosage_doseandrate_ratequantity_value,
                                current_record.medstat_dosage_doseandrate_ratequantity_unit,
                                current_record.medstat_dosage_doseandrate_ratequantity_system,
                                current_record.medstat_dosage_doseandrate_ratequantity_code,
                                current_record.medstat_dosage_maxdoseperperiod_numerator_value,
                                current_record.medstat_dosage_maxdoseperperiod_numerator_comparator,
                                current_record.medstat_dosage_maxdoseperperiod_numerator_unit,
                                current_record.medstat_dosage_maxdoseperperiod_numerator_system,
                                current_record.medstat_dosage_maxdoseperperiod_numerator_code,
                                current_record.medstat_dosage_maxdoseperperiod_denominator_value,
                                current_record.medstat_dosage_maxdoseperperiod_denominator_comparator,
                                current_record.medstat_dosage_maxdoseperperiod_denominator_unit,
                                current_record.medstat_dosage_maxdoseperperiod_denominator_system,
                                current_record.medstat_dosage_maxdoseperperiod_denominator_code,
                                current_record.medstat_dosage_maxdoseperadministration_value,
                                current_record.medstat_dosage_maxdoseperadministration_unit,
                                current_record.medstat_dosage_maxdoseperadministration_system,
                                current_record.medstat_dosage_maxdoseperadministration_code,
                                current_record.medstat_dosage_maxdoseperlifetime_value,
                                current_record.medstat_dosage_maxdoseperlifetime_unit,
                                current_record.medstat_dosage_maxdoseperlifetime_system,
                                current_record.medstat_dosage_maxdoseperlifetime_code,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='medicationstatement_raw-20';    err_schema:='cds2db_in';    err_table:='medicationstatement_raw';
                            DELETE FROM cds2db_in.medicationstatement_raw WHERE medicationstatement_raw_id = current_record.medicationstatement_raw_id;
                        ELSE
                            err_section:='medicationstatement_raw-25';    err_schema:='db_log';    err_table:='medicationstatement_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.medicationstatement_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='medicationstatement_raw-37';    err_schema:='cds2db_in';    err_table:='medicationstatement_raw';
                                                        UPDATE db_log.medicationstatement_raw target_record SET medstat_meta_versionid = current_record.medstat_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medstat_meta_versionid) != db.to_char_immutable(current_record.medstat_meta_versionid);
                            UPDATE db_log.medicationstatement_raw target_record SET medstat_meta_lastupdated = current_record.medstat_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medstat_meta_lastupdated) != db.to_char_immutable(current_record.medstat_meta_lastupdated);
                            UPDATE db_log.medicationstatement_raw target_record SET medstat_meta_profile = current_record.medstat_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(medstat_meta_profile) != db.to_char_immutable(current_record.medstat_meta_profile);

                            -- Delete updatet datasets
                            err_section:='medicationstatement_raw-30';    err_schema:='cds2db_in';    err_table:='medicationstatement_raw';
                            DELETE FROM cds2db_in.medicationstatement_raw WHERE medicationstatement_raw_id = current_record.medicationstatement_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='medicationstatement_raw-35';    err_schema:='cds2db_in';    err_table:='medicationstatement_raw';
                            UPDATE cds2db_in.medicationstatement_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE medicationstatement_raw_id = current_record.medicationstatement_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='medicationstatement_raw-40';    err_schema:='cds2db_in';    err_table:='medicationstatement_raw';
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
                err_section:='medicationstatement_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT medicationstatement_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'medicationstatement_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.medicationstatement_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='medicationstatement_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'medicationstatement_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'medicationstatement_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'medicationstatement_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='medicationstatement_raw-50';    err_schema:='/';    err_table:='/';
        -- END medicationstatement_raw  --------   medicationstatement_raw  --------   medicationstatement_raw  --------   medicationstatement_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start observation_raw  --------   observation_raw  --------   observation_raw  --------   observation_raw
        err_section:='observation_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.observation_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='observation_raw-05';    err_schema:='cds2db_in';    err_table:='observation_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.observation_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='observation_raw-10';    err_schema:='db_log';    err_table:='observation_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.observation_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='observation_raw-15';    err_schema:='db_log';    err_table:='observation_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.observation_raw (
                                observation_raw_id,
                                obs_id,
                                obs_meta_versionid,
                                obs_meta_lastupdated,
                                obs_meta_profile,
                                obs_identifier_use,
                                obs_identifier_type_system,
                                obs_identifier_type_version,
                                obs_identifier_type_code,
                                obs_identifier_type_display,
                                obs_identifier_type_text,
                                obs_identifier_system,
                                obs_identifier_value,
                                obs_identifier_start,
                                obs_identifier_end,
                                obs_encounter_ref,
                                obs_patient_ref,
                                obs_partof_ref,
                                obs_basedon_ref,
                                obs_basedon_type,
                                obs_basedon_identifier_use,
                                obs_basedon_identifier_type_system,
                                obs_basedon_identifier_type_version,
                                obs_basedon_identifier_type_code,
                                obs_basedon_identifier_type_display,
                                obs_basedon_identifier_type_text,
                                obs_basedon_identifier_system,
                                obs_basedon_identifier_value,
                                obs_basedon_display,
                                obs_status,
                                obs_category_system,
                                obs_category_version,
                                obs_category_code,
                                obs_category_display,
                                obs_category_text,
                                obs_code_system,
                                obs_code_version,
                                obs_code_code,
                                obs_code_display,
                                obs_code_text,
                                obs_effectivedatetime,
                                obs_issued,
                                obs_valuerange_low_value,
                                obs_valuerange_low_unit,
                                obs_valuerange_low_system,
                                obs_valuerange_low_code,
                                obs_valuerange_high_value,
                                obs_valuerange_high_unit,
                                obs_valuerange_high_system,
                                obs_valuerange_high_code,
                                obs_valueratio_numerator_value,
                                obs_valueratio_numerator_comparator,
                                obs_valueratio_numerator_unit,
                                obs_valueratio_numerator_system,
                                obs_valueratio_numerator_code,
                                obs_valueratio_denominator_value,
                                obs_valueratio_denominator_comparator,
                                obs_valueratio_denominator_unit,
                                obs_valueratio_denominator_system,
                                obs_valueratio_denominator_code,
                                obs_valuequantity_value,
                                obs_valuequantity_comparator,
                                obs_valuequantity_unit,
                                obs_valuequantity_system,
                                obs_valuequantity_code,
                                obs_valuecodeableconcept_system,
                                obs_valuecodeableconcept_version,
                                obs_valuecodeableconcept_code,
                                obs_valuecodeableconcept_display,
                                obs_valuecodeableconcept_text,
                                obs_dataabsentreason_system,
                                obs_dataabsentreason_version,
                                obs_dataabsentreason_code,
                                obs_dataabsentreason_display,
                                obs_dataabsentreason_text,
                                obs_note_authorstring,
                                obs_note_authorreference_ref,
                                obs_note_authorreference_type,
                                obs_note_authorreference_identifier_use,
                                obs_note_authorreference_identifier_type_system,
                                obs_note_authorreference_identifier_type_version,
                                obs_note_authorreference_identifier_type_code,
                                obs_note_authorreference_identifier_type_display,
                                obs_note_authorreference_identifier_type_text,
                                obs_note_authorreference_identifier_system,
                                obs_note_authorreference_identifier_value,
                                obs_note_authorreference_display,
                                obs_note_time,
                                obs_note_text,
                                obs_method_system,
                                obs_method_version,
                                obs_method_code,
                                obs_method_display,
                                obs_method_text,
                                obs_performer_ref,
                                obs_performer_type,
                                obs_performer_identifier_use,
                                obs_performer_identifier_type_system,
                                obs_performer_identifier_type_version,
                                obs_performer_identifier_type_code,
                                obs_performer_identifier_type_display,
                                obs_performer_identifier_type_text,
                                obs_performer_identifier_system,
                                obs_performer_identifier_value,
                                obs_performer_display,
                                obs_referencerange_low_value,
                                obs_referencerange_low_unit,
                                obs_referencerange_low_system,
                                obs_referencerange_low_code,
                                obs_referencerange_high_value,
                                obs_referencerange_high_unit,
                                obs_referencerange_high_system,
                                obs_referencerange_high_code,
                                obs_referencerange_type_system,
                                obs_referencerange_type_version,
                                obs_referencerange_type_code,
                                obs_referencerange_type_display,
                                obs_referencerange_type_text,
                                obs_referencerange_appliesto_system,
                                obs_referencerange_appliesto_version,
                                obs_referencerange_appliesto_code,
                                obs_referencerange_appliesto_display,
                                obs_referencerange_appliesto_text,
                                obs_referencerange_age_low_value,
                                obs_referencerange_age_low_unit,
                                obs_referencerange_age_low_system,
                                obs_referencerange_age_low_code,
                                obs_referencerange_age_high_value,
                                obs_referencerange_age_high_unit,
                                obs_referencerange_age_high_system,
                                obs_referencerange_age_high_code,
                                obs_referencerange_text,
                                obs_hasmember_ref,
                                obs_hasmember_type,
                                obs_hasmember_identifier_use,
                                obs_hasmember_identifier_type_system,
                                obs_hasmember_identifier_type_version,
                                obs_hasmember_identifier_type_code,
                                obs_hasmember_identifier_type_display,
                                obs_hasmember_identifier_type_text,
                                obs_hasmember_identifier_system,
                                obs_hasmember_identifier_value,
                                obs_hasmember_display,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.observation_raw_id,
                                current_record.obs_id,
                                current_record.obs_meta_versionid,
                                current_record.obs_meta_lastupdated,
                                current_record.obs_meta_profile,
                                current_record.obs_identifier_use,
                                current_record.obs_identifier_type_system,
                                current_record.obs_identifier_type_version,
                                current_record.obs_identifier_type_code,
                                current_record.obs_identifier_type_display,
                                current_record.obs_identifier_type_text,
                                current_record.obs_identifier_system,
                                current_record.obs_identifier_value,
                                current_record.obs_identifier_start,
                                current_record.obs_identifier_end,
                                current_record.obs_encounter_ref,
                                current_record.obs_patient_ref,
                                current_record.obs_partof_ref,
                                current_record.obs_basedon_ref,
                                current_record.obs_basedon_type,
                                current_record.obs_basedon_identifier_use,
                                current_record.obs_basedon_identifier_type_system,
                                current_record.obs_basedon_identifier_type_version,
                                current_record.obs_basedon_identifier_type_code,
                                current_record.obs_basedon_identifier_type_display,
                                current_record.obs_basedon_identifier_type_text,
                                current_record.obs_basedon_identifier_system,
                                current_record.obs_basedon_identifier_value,
                                current_record.obs_basedon_display,
                                current_record.obs_status,
                                current_record.obs_category_system,
                                current_record.obs_category_version,
                                current_record.obs_category_code,
                                current_record.obs_category_display,
                                current_record.obs_category_text,
                                current_record.obs_code_system,
                                current_record.obs_code_version,
                                current_record.obs_code_code,
                                current_record.obs_code_display,
                                current_record.obs_code_text,
                                current_record.obs_effectivedatetime,
                                current_record.obs_issued,
                                current_record.obs_valuerange_low_value,
                                current_record.obs_valuerange_low_unit,
                                current_record.obs_valuerange_low_system,
                                current_record.obs_valuerange_low_code,
                                current_record.obs_valuerange_high_value,
                                current_record.obs_valuerange_high_unit,
                                current_record.obs_valuerange_high_system,
                                current_record.obs_valuerange_high_code,
                                current_record.obs_valueratio_numerator_value,
                                current_record.obs_valueratio_numerator_comparator,
                                current_record.obs_valueratio_numerator_unit,
                                current_record.obs_valueratio_numerator_system,
                                current_record.obs_valueratio_numerator_code,
                                current_record.obs_valueratio_denominator_value,
                                current_record.obs_valueratio_denominator_comparator,
                                current_record.obs_valueratio_denominator_unit,
                                current_record.obs_valueratio_denominator_system,
                                current_record.obs_valueratio_denominator_code,
                                current_record.obs_valuequantity_value,
                                current_record.obs_valuequantity_comparator,
                                current_record.obs_valuequantity_unit,
                                current_record.obs_valuequantity_system,
                                current_record.obs_valuequantity_code,
                                current_record.obs_valuecodeableconcept_system,
                                current_record.obs_valuecodeableconcept_version,
                                current_record.obs_valuecodeableconcept_code,
                                current_record.obs_valuecodeableconcept_display,
                                current_record.obs_valuecodeableconcept_text,
                                current_record.obs_dataabsentreason_system,
                                current_record.obs_dataabsentreason_version,
                                current_record.obs_dataabsentreason_code,
                                current_record.obs_dataabsentreason_display,
                                current_record.obs_dataabsentreason_text,
                                current_record.obs_note_authorstring,
                                current_record.obs_note_authorreference_ref,
                                current_record.obs_note_authorreference_type,
                                current_record.obs_note_authorreference_identifier_use,
                                current_record.obs_note_authorreference_identifier_type_system,
                                current_record.obs_note_authorreference_identifier_type_version,
                                current_record.obs_note_authorreference_identifier_type_code,
                                current_record.obs_note_authorreference_identifier_type_display,
                                current_record.obs_note_authorreference_identifier_type_text,
                                current_record.obs_note_authorreference_identifier_system,
                                current_record.obs_note_authorreference_identifier_value,
                                current_record.obs_note_authorreference_display,
                                current_record.obs_note_time,
                                current_record.obs_note_text,
                                current_record.obs_method_system,
                                current_record.obs_method_version,
                                current_record.obs_method_code,
                                current_record.obs_method_display,
                                current_record.obs_method_text,
                                current_record.obs_performer_ref,
                                current_record.obs_performer_type,
                                current_record.obs_performer_identifier_use,
                                current_record.obs_performer_identifier_type_system,
                                current_record.obs_performer_identifier_type_version,
                                current_record.obs_performer_identifier_type_code,
                                current_record.obs_performer_identifier_type_display,
                                current_record.obs_performer_identifier_type_text,
                                current_record.obs_performer_identifier_system,
                                current_record.obs_performer_identifier_value,
                                current_record.obs_performer_display,
                                current_record.obs_referencerange_low_value,
                                current_record.obs_referencerange_low_unit,
                                current_record.obs_referencerange_low_system,
                                current_record.obs_referencerange_low_code,
                                current_record.obs_referencerange_high_value,
                                current_record.obs_referencerange_high_unit,
                                current_record.obs_referencerange_high_system,
                                current_record.obs_referencerange_high_code,
                                current_record.obs_referencerange_type_system,
                                current_record.obs_referencerange_type_version,
                                current_record.obs_referencerange_type_code,
                                current_record.obs_referencerange_type_display,
                                current_record.obs_referencerange_type_text,
                                current_record.obs_referencerange_appliesto_system,
                                current_record.obs_referencerange_appliesto_version,
                                current_record.obs_referencerange_appliesto_code,
                                current_record.obs_referencerange_appliesto_display,
                                current_record.obs_referencerange_appliesto_text,
                                current_record.obs_referencerange_age_low_value,
                                current_record.obs_referencerange_age_low_unit,
                                current_record.obs_referencerange_age_low_system,
                                current_record.obs_referencerange_age_low_code,
                                current_record.obs_referencerange_age_high_value,
                                current_record.obs_referencerange_age_high_unit,
                                current_record.obs_referencerange_age_high_system,
                                current_record.obs_referencerange_age_high_code,
                                current_record.obs_referencerange_text,
                                current_record.obs_hasmember_ref,
                                current_record.obs_hasmember_type,
                                current_record.obs_hasmember_identifier_use,
                                current_record.obs_hasmember_identifier_type_system,
                                current_record.obs_hasmember_identifier_type_version,
                                current_record.obs_hasmember_identifier_type_code,
                                current_record.obs_hasmember_identifier_type_display,
                                current_record.obs_hasmember_identifier_type_text,
                                current_record.obs_hasmember_identifier_system,
                                current_record.obs_hasmember_identifier_value,
                                current_record.obs_hasmember_display,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='observation_raw-20';    err_schema:='cds2db_in';    err_table:='observation_raw';
                            DELETE FROM cds2db_in.observation_raw WHERE observation_raw_id = current_record.observation_raw_id;
                        ELSE
                            err_section:='observation_raw-25';    err_schema:='db_log';    err_table:='observation_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.observation_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='observation_raw-37';    err_schema:='cds2db_in';    err_table:='observation_raw';
                                                        UPDATE db_log.observation_raw target_record SET obs_meta_versionid = current_record.obs_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(obs_meta_versionid) != db.to_char_immutable(current_record.obs_meta_versionid);
                            UPDATE db_log.observation_raw target_record SET obs_meta_lastupdated = current_record.obs_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(obs_meta_lastupdated) != db.to_char_immutable(current_record.obs_meta_lastupdated);
                            UPDATE db_log.observation_raw target_record SET obs_meta_profile = current_record.obs_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(obs_meta_profile) != db.to_char_immutable(current_record.obs_meta_profile);

                            -- Delete updatet datasets
                            err_section:='observation_raw-30';    err_schema:='cds2db_in';    err_table:='observation_raw';
                            DELETE FROM cds2db_in.observation_raw WHERE observation_raw_id = current_record.observation_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='observation_raw-35';    err_schema:='cds2db_in';    err_table:='observation_raw';
                            UPDATE cds2db_in.observation_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE observation_raw_id = current_record.observation_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='observation_raw-40';    err_schema:='cds2db_in';    err_table:='observation_raw';
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
                err_section:='observation_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT observation_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'observation_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.observation_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='observation_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'observation_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'observation_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'observation_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='observation_raw-50';    err_schema:='/';    err_table:='/';
        -- END observation_raw  --------   observation_raw  --------   observation_raw  --------   observation_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start diagnosticreport_raw  --------   diagnosticreport_raw  --------   diagnosticreport_raw  --------   diagnosticreport_raw
        err_section:='diagnosticreport_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.diagnosticreport_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='diagnosticreport_raw-05';    err_schema:='cds2db_in';    err_table:='diagnosticreport_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.diagnosticreport_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='diagnosticreport_raw-10';    err_schema:='db_log';    err_table:='diagnosticreport_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.diagnosticreport_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='diagnosticreport_raw-15';    err_schema:='db_log';    err_table:='diagnosticreport_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.diagnosticreport_raw (
                                diagnosticreport_raw_id,
                                diagrep_id,
                                diagrep_meta_versionid,
                                diagrep_meta_lastupdated,
                                diagrep_meta_profile,
                                diagrep_identifier_use,
                                diagrep_identifier_type_system,
                                diagrep_identifier_type_version,
                                diagrep_identifier_type_code,
                                diagrep_identifier_type_display,
                                diagrep_identifier_type_text,
                                diagrep_identifier_system,
                                diagrep_identifier_value,
                                diagrep_identifier_start,
                                diagrep_identifier_end,
                                diagrep_encounter_ref,
                                diagrep_patient_ref,
                                diagrep_partof_ref,
                                diagrep_result_ref,
                                diagrep_basedon_ref,
                                diagrep_status,
                                diagrep_category_system,
                                diagrep_category_version,
                                diagrep_category_code,
                                diagrep_category_display,
                                diagrep_category_text,
                                diagrep_code_system,
                                diagrep_code_version,
                                diagrep_code_code,
                                diagrep_code_display,
                                diagrep_code_text,
                                diagrep_effectivedatetime,
                                diagrep_issued,
                                diagrep_performer_ref,
                                diagrep_performer_type,
                                diagrep_performer_identifier_use,
                                diagrep_performer_identifier_type_system,
                                diagrep_performer_identifier_type_version,
                                diagrep_performer_identifier_type_code,
                                diagrep_performer_identifier_type_display,
                                diagrep_performer_identifier_type_text,
                                diagrep_performer_identifier_system,
                                diagrep_performer_identifier_value,
                                diagrep_performer_display,
                                diagrep_conclusion,
                                diagrep_conclusioncode_system,
                                diagrep_conclusioncode_version,
                                diagrep_conclusioncode_code,
                                diagrep_conclusioncode_display,
                                diagrep_conclusioncode_text,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.diagnosticreport_raw_id,
                                current_record.diagrep_id,
                                current_record.diagrep_meta_versionid,
                                current_record.diagrep_meta_lastupdated,
                                current_record.diagrep_meta_profile,
                                current_record.diagrep_identifier_use,
                                current_record.diagrep_identifier_type_system,
                                current_record.diagrep_identifier_type_version,
                                current_record.diagrep_identifier_type_code,
                                current_record.diagrep_identifier_type_display,
                                current_record.diagrep_identifier_type_text,
                                current_record.diagrep_identifier_system,
                                current_record.diagrep_identifier_value,
                                current_record.diagrep_identifier_start,
                                current_record.diagrep_identifier_end,
                                current_record.diagrep_encounter_ref,
                                current_record.diagrep_patient_ref,
                                current_record.diagrep_partof_ref,
                                current_record.diagrep_result_ref,
                                current_record.diagrep_basedon_ref,
                                current_record.diagrep_status,
                                current_record.diagrep_category_system,
                                current_record.diagrep_category_version,
                                current_record.diagrep_category_code,
                                current_record.diagrep_category_display,
                                current_record.diagrep_category_text,
                                current_record.diagrep_code_system,
                                current_record.diagrep_code_version,
                                current_record.diagrep_code_code,
                                current_record.diagrep_code_display,
                                current_record.diagrep_code_text,
                                current_record.diagrep_effectivedatetime,
                                current_record.diagrep_issued,
                                current_record.diagrep_performer_ref,
                                current_record.diagrep_performer_type,
                                current_record.diagrep_performer_identifier_use,
                                current_record.diagrep_performer_identifier_type_system,
                                current_record.diagrep_performer_identifier_type_version,
                                current_record.diagrep_performer_identifier_type_code,
                                current_record.diagrep_performer_identifier_type_display,
                                current_record.diagrep_performer_identifier_type_text,
                                current_record.diagrep_performer_identifier_system,
                                current_record.diagrep_performer_identifier_value,
                                current_record.diagrep_performer_display,
                                current_record.diagrep_conclusion,
                                current_record.diagrep_conclusioncode_system,
                                current_record.diagrep_conclusioncode_version,
                                current_record.diagrep_conclusioncode_code,
                                current_record.diagrep_conclusioncode_display,
                                current_record.diagrep_conclusioncode_text,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='diagnosticreport_raw-20';    err_schema:='cds2db_in';    err_table:='diagnosticreport_raw';
                            DELETE FROM cds2db_in.diagnosticreport_raw WHERE diagnosticreport_raw_id = current_record.diagnosticreport_raw_id;
                        ELSE
                            err_section:='diagnosticreport_raw-25';    err_schema:='db_log';    err_table:='diagnosticreport_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.diagnosticreport_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='diagnosticreport_raw-37';    err_schema:='cds2db_in';    err_table:='diagnosticreport_raw';
                                                        UPDATE db_log.diagnosticreport_raw target_record SET diagrep_meta_versionid = current_record.diagrep_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(diagrep_meta_versionid) != db.to_char_immutable(current_record.diagrep_meta_versionid);
                            UPDATE db_log.diagnosticreport_raw target_record SET diagrep_meta_lastupdated = current_record.diagrep_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(diagrep_meta_lastupdated) != db.to_char_immutable(current_record.diagrep_meta_lastupdated);
                            UPDATE db_log.diagnosticreport_raw target_record SET diagrep_meta_profile = current_record.diagrep_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(diagrep_meta_profile) != db.to_char_immutable(current_record.diagrep_meta_profile);

                            -- Delete updatet datasets
                            err_section:='diagnosticreport_raw-30';    err_schema:='cds2db_in';    err_table:='diagnosticreport_raw';
                            DELETE FROM cds2db_in.diagnosticreport_raw WHERE diagnosticreport_raw_id = current_record.diagnosticreport_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='diagnosticreport_raw-35';    err_schema:='cds2db_in';    err_table:='diagnosticreport_raw';
                            UPDATE cds2db_in.diagnosticreport_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE diagnosticreport_raw_id = current_record.diagnosticreport_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='diagnosticreport_raw-40';    err_schema:='cds2db_in';    err_table:='diagnosticreport_raw';
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
                err_section:='diagnosticreport_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT diagnosticreport_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'diagnosticreport_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.diagnosticreport_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='diagnosticreport_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'diagnosticreport_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'diagnosticreport_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'diagnosticreport_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='diagnosticreport_raw-50';    err_schema:='/';    err_table:='/';
        -- END diagnosticreport_raw  --------   diagnosticreport_raw  --------   diagnosticreport_raw  --------   diagnosticreport_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start servicerequest_raw  --------   servicerequest_raw  --------   servicerequest_raw  --------   servicerequest_raw
        err_section:='servicerequest_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.servicerequest_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='servicerequest_raw-05';    err_schema:='cds2db_in';    err_table:='servicerequest_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.servicerequest_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='servicerequest_raw-10';    err_schema:='db_log';    err_table:='servicerequest_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.servicerequest_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='servicerequest_raw-15';    err_schema:='db_log';    err_table:='servicerequest_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.servicerequest_raw (
                                servicerequest_raw_id,
                                servreq_id,
                                servreq_meta_versionid,
                                servreq_meta_lastupdated,
                                servreq_meta_profile,
                                servreq_identifier_use,
                                servreq_identifier_type_system,
                                servreq_identifier_type_version,
                                servreq_identifier_type_code,
                                servreq_identifier_type_display,
                                servreq_identifier_type_text,
                                servreq_identifier_system,
                                servreq_identifier_value,
                                servreq_identifier_start,
                                servreq_identifier_end,
                                servreq_encounter_ref,
                                servreq_patient_ref,
                                servreq_basedon_ref,
                                servreq_basedon_type,
                                servreq_basedon_identifier_use,
                                servreq_basedon_identifier_type_system,
                                servreq_basedon_identifier_type_version,
                                servreq_basedon_identifier_type_code,
                                servreq_basedon_identifier_type_display,
                                servreq_basedon_identifier_type_text,
                                servreq_basedon_identifier_system,
                                servreq_basedon_identifier_value,
                                servreq_basedon_display,
                                servreq_status,
                                servreq_intent,
                                servreq_category_system,
                                servreq_category_version,
                                servreq_category_code,
                                servreq_category_display,
                                servreq_category_text,
                                servreq_code_system,
                                servreq_code_version,
                                servreq_code_code,
                                servreq_code_display,
                                servreq_code_text,
                                servreq_authoredon,
                                servreq_requester_ref,
                                servreq_requester_type,
                                servreq_requester_identifier_use,
                                servreq_requester_identifier_type_system,
                                servreq_requester_identifier_type_version,
                                servreq_requester_identifier_type_code,
                                servreq_requester_identifier_type_display,
                                servreq_requester_identifier_type_text,
                                servreq_requester_identifier_system,
                                servreq_requester_identifier_value,
                                servreq_requester_display,
                                servreq_performer_ref,
                                servreq_performer_type,
                                servreq_performer_identifier_use,
                                servreq_performer_identifier_type_system,
                                servreq_performer_identifier_type_version,
                                servreq_performer_identifier_type_code,
                                servreq_performer_identifier_type_display,
                                servreq_performer_identifier_type_text,
                                servreq_performer_identifier_system,
                                servreq_performer_identifier_value,
                                servreq_performer_display,
                                servreq_locationcode_system,
                                servreq_locationcode_version,
                                servreq_locationcode_code,
                                servreq_locationcode_display,
                                servreq_locationcode_text,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.servicerequest_raw_id,
                                current_record.servreq_id,
                                current_record.servreq_meta_versionid,
                                current_record.servreq_meta_lastupdated,
                                current_record.servreq_meta_profile,
                                current_record.servreq_identifier_use,
                                current_record.servreq_identifier_type_system,
                                current_record.servreq_identifier_type_version,
                                current_record.servreq_identifier_type_code,
                                current_record.servreq_identifier_type_display,
                                current_record.servreq_identifier_type_text,
                                current_record.servreq_identifier_system,
                                current_record.servreq_identifier_value,
                                current_record.servreq_identifier_start,
                                current_record.servreq_identifier_end,
                                current_record.servreq_encounter_ref,
                                current_record.servreq_patient_ref,
                                current_record.servreq_basedon_ref,
                                current_record.servreq_basedon_type,
                                current_record.servreq_basedon_identifier_use,
                                current_record.servreq_basedon_identifier_type_system,
                                current_record.servreq_basedon_identifier_type_version,
                                current_record.servreq_basedon_identifier_type_code,
                                current_record.servreq_basedon_identifier_type_display,
                                current_record.servreq_basedon_identifier_type_text,
                                current_record.servreq_basedon_identifier_system,
                                current_record.servreq_basedon_identifier_value,
                                current_record.servreq_basedon_display,
                                current_record.servreq_status,
                                current_record.servreq_intent,
                                current_record.servreq_category_system,
                                current_record.servreq_category_version,
                                current_record.servreq_category_code,
                                current_record.servreq_category_display,
                                current_record.servreq_category_text,
                                current_record.servreq_code_system,
                                current_record.servreq_code_version,
                                current_record.servreq_code_code,
                                current_record.servreq_code_display,
                                current_record.servreq_code_text,
                                current_record.servreq_authoredon,
                                current_record.servreq_requester_ref,
                                current_record.servreq_requester_type,
                                current_record.servreq_requester_identifier_use,
                                current_record.servreq_requester_identifier_type_system,
                                current_record.servreq_requester_identifier_type_version,
                                current_record.servreq_requester_identifier_type_code,
                                current_record.servreq_requester_identifier_type_display,
                                current_record.servreq_requester_identifier_type_text,
                                current_record.servreq_requester_identifier_system,
                                current_record.servreq_requester_identifier_value,
                                current_record.servreq_requester_display,
                                current_record.servreq_performer_ref,
                                current_record.servreq_performer_type,
                                current_record.servreq_performer_identifier_use,
                                current_record.servreq_performer_identifier_type_system,
                                current_record.servreq_performer_identifier_type_version,
                                current_record.servreq_performer_identifier_type_code,
                                current_record.servreq_performer_identifier_type_display,
                                current_record.servreq_performer_identifier_type_text,
                                current_record.servreq_performer_identifier_system,
                                current_record.servreq_performer_identifier_value,
                                current_record.servreq_performer_display,
                                current_record.servreq_locationcode_system,
                                current_record.servreq_locationcode_version,
                                current_record.servreq_locationcode_code,
                                current_record.servreq_locationcode_display,
                                current_record.servreq_locationcode_text,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='servicerequest_raw-20';    err_schema:='cds2db_in';    err_table:='servicerequest_raw';
                            DELETE FROM cds2db_in.servicerequest_raw WHERE servicerequest_raw_id = current_record.servicerequest_raw_id;
                        ELSE
                            err_section:='servicerequest_raw-25';    err_schema:='db_log';    err_table:='servicerequest_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.servicerequest_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='servicerequest_raw-37';    err_schema:='cds2db_in';    err_table:='servicerequest_raw';
                                                        UPDATE db_log.servicerequest_raw target_record SET servreq_meta_versionid = current_record.servreq_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(servreq_meta_versionid) != db.to_char_immutable(current_record.servreq_meta_versionid);
                            UPDATE db_log.servicerequest_raw target_record SET servreq_meta_lastupdated = current_record.servreq_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(servreq_meta_lastupdated) != db.to_char_immutable(current_record.servreq_meta_lastupdated);
                            UPDATE db_log.servicerequest_raw target_record SET servreq_meta_profile = current_record.servreq_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(servreq_meta_profile) != db.to_char_immutable(current_record.servreq_meta_profile);

                            -- Delete updatet datasets
                            err_section:='servicerequest_raw-30';    err_schema:='cds2db_in';    err_table:='servicerequest_raw';
                            DELETE FROM cds2db_in.servicerequest_raw WHERE servicerequest_raw_id = current_record.servicerequest_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='servicerequest_raw-35';    err_schema:='cds2db_in';    err_table:='servicerequest_raw';
                            UPDATE cds2db_in.servicerequest_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE servicerequest_raw_id = current_record.servicerequest_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='servicerequest_raw-40';    err_schema:='cds2db_in';    err_table:='servicerequest_raw';
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
                err_section:='servicerequest_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT servicerequest_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'servicerequest_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.servicerequest_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='servicerequest_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'servicerequest_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'servicerequest_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'servicerequest_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='servicerequest_raw-50';    err_schema:='/';    err_table:='/';
        -- END servicerequest_raw  --------   servicerequest_raw  --------   servicerequest_raw  --------   servicerequest_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start procedure_raw  --------   procedure_raw  --------   procedure_raw  --------   procedure_raw
        err_section:='procedure_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.procedure_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='procedure_raw-05';    err_schema:='cds2db_in';    err_table:='procedure_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.procedure_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='procedure_raw-10';    err_schema:='db_log';    err_table:='procedure_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.procedure_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='procedure_raw-15';    err_schema:='db_log';    err_table:='procedure_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.procedure_raw (
                                procedure_raw_id,
                                proc_id,
                                proc_meta_versionid,
                                proc_meta_lastupdated,
                                proc_meta_profile,
                                proc_identifier_use,
                                proc_identifier_type_system,
                                proc_identifier_type_version,
                                proc_identifier_type_code,
                                proc_identifier_type_display,
                                proc_identifier_type_text,
                                proc_identifier_system,
                                proc_identifier_value,
                                proc_identifier_start,
                                proc_identifier_end,
                                proc_encounter_ref,
                                proc_patient_ref,
                                proc_partof_ref,
                                proc_basedon_ref,
                                proc_basedon_type,
                                proc_basedon_identifier_use,
                                proc_basedon_identifier_type_system,
                                proc_basedon_identifier_type_version,
                                proc_basedon_identifier_type_code,
                                proc_basedon_identifier_type_display,
                                proc_basedon_identifier_type_text,
                                proc_basedon_identifier_system,
                                proc_basedon_identifier_value,
                                proc_basedon_display,
                                proc_status,
                                proc_statusreason_system,
                                proc_statusreason_version,
                                proc_statusreason_code,
                                proc_statusreason_display,
                                proc_statusreason_text,
                                proc_category_system,
                                proc_category_version,
                                proc_category_code,
                                proc_category_display,
                                proc_category_text,
                                proc_code_system,
                                proc_code_version,
                                proc_code_code,
                                proc_code_display,
                                proc_code_text,
                                proc_performeddatetime,
                                proc_performedperiod_start,
                                proc_performedperiod_end,
                                proc_reasoncode_system,
                                proc_reasoncode_version,
                                proc_reasoncode_code,
                                proc_reasoncode_display,
                                proc_reasoncode_text,
                                proc_reasonreference_ref,
                                proc_reasonreference_type,
                                proc_reasonreference_identifier_use,
                                proc_reasonreference_identifier_type_system,
                                proc_reasonreference_identifier_type_version,
                                proc_reasonreference_identifier_type_code,
                                proc_reasonreference_identifier_type_display,
                                proc_reasonreference_identifier_type_text,
                                proc_reasonreference_identifier_system,
                                proc_reasonreference_identifier_value,
                                proc_reasonreference_display,
                                proc_note_authorstring,
                                proc_note_authorreference_ref,
                                proc_note_authorreference_type,
                                proc_note_authorreference_identifier_use,
                                proc_note_authorreference_identifier_type_system,
                                proc_note_authorreference_identifier_type_version,
                                proc_note_authorreference_identifier_type_code,
                                proc_note_authorreference_identifier_type_display,
                                proc_note_authorreference_identifier_type_text,
                                proc_note_authorreference_identifier_system,
                                proc_note_authorreference_identifier_value,
                                proc_note_authorreference_display,
                                proc_note_time,
                                proc_note_text,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.procedure_raw_id,
                                current_record.proc_id,
                                current_record.proc_meta_versionid,
                                current_record.proc_meta_lastupdated,
                                current_record.proc_meta_profile,
                                current_record.proc_identifier_use,
                                current_record.proc_identifier_type_system,
                                current_record.proc_identifier_type_version,
                                current_record.proc_identifier_type_code,
                                current_record.proc_identifier_type_display,
                                current_record.proc_identifier_type_text,
                                current_record.proc_identifier_system,
                                current_record.proc_identifier_value,
                                current_record.proc_identifier_start,
                                current_record.proc_identifier_end,
                                current_record.proc_encounter_ref,
                                current_record.proc_patient_ref,
                                current_record.proc_partof_ref,
                                current_record.proc_basedon_ref,
                                current_record.proc_basedon_type,
                                current_record.proc_basedon_identifier_use,
                                current_record.proc_basedon_identifier_type_system,
                                current_record.proc_basedon_identifier_type_version,
                                current_record.proc_basedon_identifier_type_code,
                                current_record.proc_basedon_identifier_type_display,
                                current_record.proc_basedon_identifier_type_text,
                                current_record.proc_basedon_identifier_system,
                                current_record.proc_basedon_identifier_value,
                                current_record.proc_basedon_display,
                                current_record.proc_status,
                                current_record.proc_statusreason_system,
                                current_record.proc_statusreason_version,
                                current_record.proc_statusreason_code,
                                current_record.proc_statusreason_display,
                                current_record.proc_statusreason_text,
                                current_record.proc_category_system,
                                current_record.proc_category_version,
                                current_record.proc_category_code,
                                current_record.proc_category_display,
                                current_record.proc_category_text,
                                current_record.proc_code_system,
                                current_record.proc_code_version,
                                current_record.proc_code_code,
                                current_record.proc_code_display,
                                current_record.proc_code_text,
                                current_record.proc_performeddatetime,
                                current_record.proc_performedperiod_start,
                                current_record.proc_performedperiod_end,
                                current_record.proc_reasoncode_system,
                                current_record.proc_reasoncode_version,
                                current_record.proc_reasoncode_code,
                                current_record.proc_reasoncode_display,
                                current_record.proc_reasoncode_text,
                                current_record.proc_reasonreference_ref,
                                current_record.proc_reasonreference_type,
                                current_record.proc_reasonreference_identifier_use,
                                current_record.proc_reasonreference_identifier_type_system,
                                current_record.proc_reasonreference_identifier_type_version,
                                current_record.proc_reasonreference_identifier_type_code,
                                current_record.proc_reasonreference_identifier_type_display,
                                current_record.proc_reasonreference_identifier_type_text,
                                current_record.proc_reasonreference_identifier_system,
                                current_record.proc_reasonreference_identifier_value,
                                current_record.proc_reasonreference_display,
                                current_record.proc_note_authorstring,
                                current_record.proc_note_authorreference_ref,
                                current_record.proc_note_authorreference_type,
                                current_record.proc_note_authorreference_identifier_use,
                                current_record.proc_note_authorreference_identifier_type_system,
                                current_record.proc_note_authorreference_identifier_type_version,
                                current_record.proc_note_authorreference_identifier_type_code,
                                current_record.proc_note_authorreference_identifier_type_display,
                                current_record.proc_note_authorreference_identifier_type_text,
                                current_record.proc_note_authorreference_identifier_system,
                                current_record.proc_note_authorreference_identifier_value,
                                current_record.proc_note_authorreference_display,
                                current_record.proc_note_time,
                                current_record.proc_note_text,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='procedure_raw-20';    err_schema:='cds2db_in';    err_table:='procedure_raw';
                            DELETE FROM cds2db_in.procedure_raw WHERE procedure_raw_id = current_record.procedure_raw_id;
                        ELSE
                            err_section:='procedure_raw-25';    err_schema:='db_log';    err_table:='procedure_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.procedure_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='procedure_raw-37';    err_schema:='cds2db_in';    err_table:='procedure_raw';
                                                        UPDATE db_log.procedure_raw target_record SET proc_meta_versionid = current_record.proc_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(proc_meta_versionid) != db.to_char_immutable(current_record.proc_meta_versionid);
                            UPDATE db_log.procedure_raw target_record SET proc_meta_lastupdated = current_record.proc_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(proc_meta_lastupdated) != db.to_char_immutable(current_record.proc_meta_lastupdated);
                            UPDATE db_log.procedure_raw target_record SET proc_meta_profile = current_record.proc_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(proc_meta_profile) != db.to_char_immutable(current_record.proc_meta_profile);

                            -- Delete updatet datasets
                            err_section:='procedure_raw-30';    err_schema:='cds2db_in';    err_table:='procedure_raw';
                            DELETE FROM cds2db_in.procedure_raw WHERE procedure_raw_id = current_record.procedure_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='procedure_raw-35';    err_schema:='cds2db_in';    err_table:='procedure_raw';
                            UPDATE cds2db_in.procedure_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE procedure_raw_id = current_record.procedure_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='procedure_raw-40';    err_schema:='cds2db_in';    err_table:='procedure_raw';
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
                err_section:='procedure_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT procedure_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'procedure_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.procedure_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='procedure_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'procedure_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'procedure_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'procedure_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='procedure_raw-50';    err_schema:='/';    err_table:='/';
        -- END procedure_raw  --------   procedure_raw  --------   procedure_raw  --------   procedure_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start consent_raw  --------   consent_raw  --------   consent_raw  --------   consent_raw
        err_section:='consent_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.consent_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='consent_raw-05';    err_schema:='cds2db_in';    err_table:='consent_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.consent_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='consent_raw-10';    err_schema:='db_log';    err_table:='consent_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.consent_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='consent_raw-15';    err_schema:='db_log';    err_table:='consent_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.consent_raw (
                                consent_raw_id,
                                cons_id,
                                cons_meta_versionid,
                                cons_meta_lastupdated,
                                cons_meta_profile,
                                cons_identifier_use,
                                cons_identifier_type_system,
                                cons_identifier_type_version,
                                cons_identifier_type_code,
                                cons_identifier_type_display,
                                cons_identifier_type_text,
                                cons_identifier_system,
                                cons_identifier_value,
                                cons_identifier_start,
                                cons_identifier_end,
                                cons_patient_ref,
                                cons_status,
                                cons_scope_system,
                                cons_scope_version,
                                cons_scope_code,
                                cons_scope_display,
                                cons_scope_text,
                                cons_datetime,
                                cons_provision_type,
                                cons_provision_period_start,
                                cons_provision_period_end,
                                cons_provision_actor_role_system,
                                cons_provision_actor_role_version,
                                cons_provision_actor_role_code,
                                cons_provision_actor_role_display,
                                cons_provision_actor_role_text,
                                cons_provision_actor_ref,
                                cons_provision_actor_type,
                                cons_provision_actor_identifier_use,
                                cons_provision_actor_identifier_type_system,
                                cons_provision_actor_identifier_type_version,
                                cons_provision_actor_identifier_type_code,
                                cons_provision_actor_identifier_type_display,
                                cons_provision_actor_identifier_type_text,
                                cons_provision_actor_identifier_system,
                                cons_provision_actor_identifier_value,
                                cons_provision_actor_display,
                                cons_provision_code_system,
                                cons_provision_code_version,
                                cons_provision_code_code,
                                cons_provision_code_display,
                                cons_provision_code_text,
                                cons_provision_dataperiod_start,
                                cons_provision_dataperiod_end,
                                cons_provision_provision_type,
                                cons_provision_provision_period_start,
                                cons_provision_provision_period_end,
                                cons_provision_provision_actor_role_system,
                                cons_provision_provision_actor_role_version,
                                cons_provision_provision_actor_role_code,
                                cons_provision_provision_actor_role_display,
                                cons_provision_provision_actor_role_text,
                                cons_provision_provision_actor_ref,
                                cons_provision_provision_actor_type,
                                cons_provision_provision_actor_identifier_use,
                                cons_provision_provision_actor_identifier_type_system,
                                cons_provision_provision_actor_identifier_type_version,
                                cons_provision_provision_actor_identifier_type_code,
                                cons_provision_provision_actor_identifier_type_display,
                                cons_provision_provision_actor_identifier_type_text,
                                cons_provision_provision_actor_identifier_system,
                                cons_provision_provision_actor_identifier_value,
                                cons_provision_provision_actor_display,
                                cons_provision_provision_code_system,
                                cons_provision_provision_code_version,
                                cons_provision_provision_code_code,
                                cons_provision_provision_code_display,
                                cons_provision_provision_code_text,
                                cons_provision_provision_dataperiod_start,
                                cons_provision_provision_dataperiod_end,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.consent_raw_id,
                                current_record.cons_id,
                                current_record.cons_meta_versionid,
                                current_record.cons_meta_lastupdated,
                                current_record.cons_meta_profile,
                                current_record.cons_identifier_use,
                                current_record.cons_identifier_type_system,
                                current_record.cons_identifier_type_version,
                                current_record.cons_identifier_type_code,
                                current_record.cons_identifier_type_display,
                                current_record.cons_identifier_type_text,
                                current_record.cons_identifier_system,
                                current_record.cons_identifier_value,
                                current_record.cons_identifier_start,
                                current_record.cons_identifier_end,
                                current_record.cons_patient_ref,
                                current_record.cons_status,
                                current_record.cons_scope_system,
                                current_record.cons_scope_version,
                                current_record.cons_scope_code,
                                current_record.cons_scope_display,
                                current_record.cons_scope_text,
                                current_record.cons_datetime,
                                current_record.cons_provision_type,
                                current_record.cons_provision_period_start,
                                current_record.cons_provision_period_end,
                                current_record.cons_provision_actor_role_system,
                                current_record.cons_provision_actor_role_version,
                                current_record.cons_provision_actor_role_code,
                                current_record.cons_provision_actor_role_display,
                                current_record.cons_provision_actor_role_text,
                                current_record.cons_provision_actor_ref,
                                current_record.cons_provision_actor_type,
                                current_record.cons_provision_actor_identifier_use,
                                current_record.cons_provision_actor_identifier_type_system,
                                current_record.cons_provision_actor_identifier_type_version,
                                current_record.cons_provision_actor_identifier_type_code,
                                current_record.cons_provision_actor_identifier_type_display,
                                current_record.cons_provision_actor_identifier_type_text,
                                current_record.cons_provision_actor_identifier_system,
                                current_record.cons_provision_actor_identifier_value,
                                current_record.cons_provision_actor_display,
                                current_record.cons_provision_code_system,
                                current_record.cons_provision_code_version,
                                current_record.cons_provision_code_code,
                                current_record.cons_provision_code_display,
                                current_record.cons_provision_code_text,
                                current_record.cons_provision_dataperiod_start,
                                current_record.cons_provision_dataperiod_end,
                                current_record.cons_provision_provision_type,
                                current_record.cons_provision_provision_period_start,
                                current_record.cons_provision_provision_period_end,
                                current_record.cons_provision_provision_actor_role_system,
                                current_record.cons_provision_provision_actor_role_version,
                                current_record.cons_provision_provision_actor_role_code,
                                current_record.cons_provision_provision_actor_role_display,
                                current_record.cons_provision_provision_actor_role_text,
                                current_record.cons_provision_provision_actor_ref,
                                current_record.cons_provision_provision_actor_type,
                                current_record.cons_provision_provision_actor_identifier_use,
                                current_record.cons_provision_provision_actor_identifier_type_system,
                                current_record.cons_provision_provision_actor_identifier_type_version,
                                current_record.cons_provision_provision_actor_identifier_type_code,
                                current_record.cons_provision_provision_actor_identifier_type_display,
                                current_record.cons_provision_provision_actor_identifier_type_text,
                                current_record.cons_provision_provision_actor_identifier_system,
                                current_record.cons_provision_provision_actor_identifier_value,
                                current_record.cons_provision_provision_actor_display,
                                current_record.cons_provision_provision_code_system,
                                current_record.cons_provision_provision_code_version,
                                current_record.cons_provision_provision_code_code,
                                current_record.cons_provision_provision_code_display,
                                current_record.cons_provision_provision_code_text,
                                current_record.cons_provision_provision_dataperiod_start,
                                current_record.cons_provision_provision_dataperiod_end,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='consent_raw-20';    err_schema:='cds2db_in';    err_table:='consent_raw';
                            DELETE FROM cds2db_in.consent_raw WHERE consent_raw_id = current_record.consent_raw_id;
                        ELSE
                            err_section:='consent_raw-25';    err_schema:='db_log';    err_table:='consent_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.consent_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='consent_raw-37';    err_schema:='cds2db_in';    err_table:='consent_raw';
                                                        UPDATE db_log.consent_raw target_record SET cons_meta_versionid = current_record.cons_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(cons_meta_versionid) != db.to_char_immutable(current_record.cons_meta_versionid);
                            UPDATE db_log.consent_raw target_record SET cons_meta_lastupdated = current_record.cons_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(cons_meta_lastupdated) != db.to_char_immutable(current_record.cons_meta_lastupdated);
                            UPDATE db_log.consent_raw target_record SET cons_meta_profile = current_record.cons_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(cons_meta_profile) != db.to_char_immutable(current_record.cons_meta_profile);

                            -- Delete updatet datasets
                            err_section:='consent_raw-30';    err_schema:='cds2db_in';    err_table:='consent_raw';
                            DELETE FROM cds2db_in.consent_raw WHERE consent_raw_id = current_record.consent_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='consent_raw-35';    err_schema:='cds2db_in';    err_table:='consent_raw';
                            UPDATE cds2db_in.consent_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE consent_raw_id = current_record.consent_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='consent_raw-40';    err_schema:='cds2db_in';    err_table:='consent_raw';
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
                err_section:='consent_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT consent_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'consent_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.consent_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='consent_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'consent_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'consent_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'consent_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='consent_raw-50';    err_schema:='/';    err_table:='/';
        -- END consent_raw  --------   consent_raw  --------   consent_raw  --------   consent_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start location_raw  --------   location_raw  --------   location_raw  --------   location_raw
        err_section:='location_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.location_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='location_raw-05';    err_schema:='cds2db_in';    err_table:='location_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.location_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='location_raw-10';    err_schema:='db_log';    err_table:='location_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.location_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='location_raw-15';    err_schema:='db_log';    err_table:='location_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.location_raw (
                                location_raw_id,
                                loc_id,
                                loc_meta_versionid,
                                loc_meta_lastupdated,
                                loc_meta_profile,
                                loc_identifier_use,
                                loc_identifier_type_system,
                                loc_identifier_type_version,
                                loc_identifier_type_code,
                                loc_identifier_type_display,
                                loc_identifier_type_text,
                                loc_identifier_system,
                                loc_identifier_value,
                                loc_identifier_start,
                                loc_identifier_end,
                                loc_status,
                                loc_name,
                                loc_description,
                                loc_alias,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.location_raw_id,
                                current_record.loc_id,
                                current_record.loc_meta_versionid,
                                current_record.loc_meta_lastupdated,
                                current_record.loc_meta_profile,
                                current_record.loc_identifier_use,
                                current_record.loc_identifier_type_system,
                                current_record.loc_identifier_type_version,
                                current_record.loc_identifier_type_code,
                                current_record.loc_identifier_type_display,
                                current_record.loc_identifier_type_text,
                                current_record.loc_identifier_system,
                                current_record.loc_identifier_value,
                                current_record.loc_identifier_start,
                                current_record.loc_identifier_end,
                                current_record.loc_status,
                                current_record.loc_name,
                                current_record.loc_description,
                                current_record.loc_alias,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='location_raw-20';    err_schema:='cds2db_in';    err_table:='location_raw';
                            DELETE FROM cds2db_in.location_raw WHERE location_raw_id = current_record.location_raw_id;
                        ELSE
                            err_section:='location_raw-25';    err_schema:='db_log';    err_table:='location_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.location_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='location_raw-37';    err_schema:='cds2db_in';    err_table:='location_raw';
                                                        UPDATE db_log.location_raw target_record SET loc_meta_versionid = current_record.loc_meta_versionid WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(loc_meta_versionid) != db.to_char_immutable(current_record.loc_meta_versionid);
                            UPDATE db_log.location_raw target_record SET loc_meta_lastupdated = current_record.loc_meta_lastupdated WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(loc_meta_lastupdated) != db.to_char_immutable(current_record.loc_meta_lastupdated);
                            UPDATE db_log.location_raw target_record SET loc_meta_profile = current_record.loc_meta_profile WHERE target_record.hash_index_col = current_record.hash_index_col AND db.to_char_immutable(loc_meta_profile) != db.to_char_immutable(current_record.loc_meta_profile);

                            -- Delete updatet datasets
                            err_section:='location_raw-30';    err_schema:='cds2db_in';    err_table:='location_raw';
                            DELETE FROM cds2db_in.location_raw WHERE location_raw_id = current_record.location_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='location_raw-35';    err_schema:='cds2db_in';    err_table:='location_raw';
                            UPDATE cds2db_in.location_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE location_raw_id = current_record.location_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='location_raw-40';    err_schema:='cds2db_in';    err_table:='location_raw';
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
                err_section:='location_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT location_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'location_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.location_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='location_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'location_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'location_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'location_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='location_raw-50';    err_schema:='/';    err_table:='/';
        -- END location_raw  --------   location_raw  --------   location_raw  --------   location_raw
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start pids_per_ward_raw  --------   pids_per_ward_raw  --------   pids_per_ward_raw  --------   pids_per_ward_raw
        err_section:='pids_per_ward_raw-01';
        SELECT COUNT(1) INTO data_count_all FROM cds2db_in.pids_per_ward_raw; -- Counting new records in the source

        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_raw_cds_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;

            data_count:=0; data_count_update:=0; data_count_new:=0;

            err_section:='pids_per_ward_raw-05';    err_schema:='cds2db_in';    err_table:='pids_per_ward_raw';

            FOR current_record IN (SELECT * FROM cds2db_in.pids_per_ward_raw)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found

                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all

                        err_section:='pids_per_ward_raw-10';    err_schema:='db_log';    err_table:='pids_per_ward_raw';
                        SELECT count(1) INTO data_count
                        FROM db_log.pids_per_ward_raw target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;

                        err_section:='pids_per_ward_raw-15';    err_schema:='db_log';    err_table:='pids_per_ward_raw';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.pids_per_ward_raw (
                                pids_per_ward_raw_id,
                                ward_name,
                                patient_id,
                                encounter_id,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.pids_per_ward_raw_id,
                                current_record.ward_name,
                                current_record.patient_id,
                                current_record.encounter_id,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );

                            -- Delete importet datasets
                            err_section:='pids_per_ward_raw-20';    err_schema:='cds2db_in';    err_table:='pids_per_ward_raw';
                            DELETE FROM cds2db_in.pids_per_ward_raw WHERE pids_per_ward_raw_id = current_record.pids_per_ward_raw_id;
                        ELSE
                            err_section:='pids_per_ward_raw-25';    err_schema:='db_log';    err_table:='pids_per_ward_raw';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.pids_per_ward_raw target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;

                            err_section:='pids_per_ward_raw-37';    err_schema:='cds2db_in';    err_table:='pids_per_ward_raw';
                            

                            -- Delete updatet datasets
                            err_section:='pids_per_ward_raw-30';    err_schema:='cds2db_in';    err_table:='pids_per_ward_raw';
                            DELETE FROM cds2db_in.pids_per_ward_raw WHERE pids_per_ward_raw_id = current_record.pids_per_ward_raw_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='pids_per_ward_raw-35';    err_schema:='cds2db_in';    err_table:='pids_per_ward_raw';
                            UPDATE cds2db_in.pids_per_ward_raw
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_raw_cds_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE pids_per_ward_raw_id = current_record.pids_per_ward_raw_id;


                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='pids_per_ward_raw-40';    err_schema:='cds2db_in';    err_table:='pids_per_ward_raw';
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
                err_section:='pids_per_ward_raw-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT pids_per_ward_raw_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'pids_per_ward_raw' AS table_name, last_pro_datetime, current_dataset_status, 'copy_raw_cds_in_to_db_log' AS function_name FROM db_log.pids_per_ward_raw d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;

            -- Collect and save counts for the entity
            err_section:='pids_per_ward_raw-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;

            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'pids_per_ward_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_new, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'pids_per_ward_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_update, tmp_sec, temp);

            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'pids_per_ward_raw', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary

        err_section:='pids_per_ward_raw-50';    err_schema:='/';    err_table:='/';
        -- END pids_per_ward_raw  --------   pids_per_ward_raw  --------   pids_per_ward_raw  --------   pids_per_ward_raw
        -----------------------------------------------------------------------------------------------------------------------


        err_section:='BOTTON-01';  err_schema:='db_log';    err_table:='data_import_hist';

        -- Collect and save counts for the function
        SELECT res FROM pg_background_result(pg_background_launch(
        'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US''
        )'))  AS t(res TEXT) INTO timestamp_end;

        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;

        err_section:='BOTTON-05';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_all', 'db_log', 'copy_raw_cds_in_to_db_log', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );

        err_section:='BOTTON-10';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_new', 'db_log', 'copy_raw_cds_in_to_db_log', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_pro_new, tmp_sec, 'Count all new Datasetzs '||temp);

        err_section:='BOTTON-15';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_upd', 'db_log', 'copy_raw_cds_in_to_db_log', last_pro_datetime, 'copy_raw_cds_in_to_db_log', data_count_pro_upd, tmp_sec, 'Count all updatetd Datasetzs '||temp);

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

    RETURN 'Done db.copy_raw_cds_in_to_db_log - last_pro_nr:'||last_pro_nr;

EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.copy_raw_cds_in_to_db_log()' AS VARCHAR),     -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' e:'||erg AS VARCHAR),       -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler db.copy_raw_cds_in_to_db_log - '||SQLSTATE||' - last_pro_nr:'||last_pro_nr;
END;
$$ LANGUAGE plpgsql;

-----------------------------

