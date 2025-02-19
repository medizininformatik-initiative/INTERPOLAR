-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-01-13 09:38:21
-- Rights definition file size        : 15240 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2025-02-12 20:33:35
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  43_cre_table_frontend_log.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db_log_user
-- OWNER_SCHEMA:  db_log
-- TAGS:  INT_ID
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _fe
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  db_log_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  62_fe_in_to_db_log.sql
-- COPY_FUNC_TEMPLATE:  template_copy_function.sql
-- COPY_FUNC_NAME:  copy_fe_fe_in_to_db_log
-- SCHEMA_2:  db2frontend_in
-- TABLE_POSTFIX_2:  _fe
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

------------------------------
CREATE OR REPLACE FUNCTION db.copy_fe_fe_in_to_db_log()
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
    -- Copy datasets - Functionname: copy_fe_fe_in_to_db_log - From: db2frontend_in -> To: db_log
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
    -- set start time
	SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
    ))  AS t(res TEXT) INTO timestamp_start;
 
    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' copy_fe_fe_in_to_db_log'', last_change_timestamp=CURRENT_TIMESTAMP
    WHERE pc_name=''timepoint_1_cron_job_data_transfer'''
    ) ) AS t(res TEXT) INTO erg;

    -- Counting datasets
    err_section:='HEAD-10';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT SUM(anz) INTO data_count_pro_all
    FROM ( SELECT 0::INT AS anz
        UNION SELECT COUNT(1) AS anz FROM db2frontend_in.patient_fe
    UNION SELECT COUNT(1) AS anz FROM db2frontend_in.fall_fe
    UNION SELECT COUNT(1) AS anz FROM db2frontend_in.medikationsanalyse_fe
    UNION SELECT COUNT(1) AS anz FROM db2frontend_in.mrpdokumentation_validierung_fe
    UNION SELECT COUNT(1) AS anz FROM db2frontend_in.risikofaktor_fe
    UNION SELECT COUNT(1) AS anz FROM db2frontend_in.trigger_fe
    );

    -- Counting 
    IF data_count_pro_all>0 THEN
         -- Copy Functionname: copy_fe_fe_in_to_db_log - From: db2frontend_in -> To: db_log
        err_section:='HEAD-05';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes'; -- Get value for documentation of each individual data record

    	-- Number of data records then status have to be set
    	SELECT COALESCE(parameter_value::INT,10) INTO data_count_last_status_max FROM db_config.db_parameter WHERE parameter_name='number_of_data_records_after_which_the_status_is_updated';

        err_section:='HEAD-20';    err_schema:='db_config';    err_table:='db_process_control';
        -- Set current executed function and total number of records
        SELECT res FROM pg_background_result(pg_background_launch(
        'UPDATE db_config.db_process_control set pc_value=''db.copy_fe_fe_in_to_db_log()'', last_change_timestamp=CURRENT_TIMESTAMP
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
        -- Start patient_fe  --------   patient_fe  --------   patient_fe  --------   patient_fe
        err_section:='patient_fe-01';
        SELECT COUNT(1) INTO data_count_all FROM db2frontend_in.patient_fe; -- Counting new records in the source
    
        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;
            
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_fe_fe_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;
        
            data_count:=0; data_count_update:=0; data_count_new:=0;
        
            err_section:='patient_fe-05';    err_schema:='db2frontend_in';    err_table:='patient_fe';
        
            FOR current_record IN (SELECT * FROM db2frontend_in.patient_fe)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found
                        
                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all
        
                        err_section:='patient_fe-10';    err_schema:='db_log';    err_table:='patient_fe';
                        SELECT count(1) INTO data_count
                        FROM db_log.patient_fe target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;
        
                        err_section:='patient_fe-15';    err_schema:='db_log';    err_table:='patient_fe';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.patient_fe (
                                patient_fe_id,
                                record_id,
                                redcap_repeat_instrument,
                                redcap_repeat_instance,
                                pat_header,
                                pat_id,
                                pat_femb_1,
                                pat_cis_pid,
                                pat_name,
                                pat_vorname,
                                pat_gebdat,
                                pat_aktuell_alter,
                                pat_geschlecht,
                                patient_complete,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.patient_fe_id,
                                current_record.record_id,
                                current_record.redcap_repeat_instrument,
                                current_record.redcap_repeat_instance,
                                current_record.pat_header,
                                current_record.pat_id,
                                current_record.pat_femb_1,
                                current_record.pat_cis_pid,
                                current_record.pat_name,
                                current_record.pat_vorname,
                                current_record.pat_gebdat,
                                current_record.pat_aktuell_alter,
                                current_record.pat_geschlecht,
                                current_record.patient_complete,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );
        
                            -- Delete importet datasets
                            err_section:='patient_fe-20';    err_schema:='db2frontend_in';    err_table:='patient_fe';
                            DELETE FROM db2frontend_in.patient_fe WHERE patient_fe_id = current_record.patient_fe_id;
                        ELSE
                            err_section:='patient_fe-25';    err_schema:='db_log';    err_table:='patient_fe';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.patient_fe target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;
        
                            -- Delete updatet datasets
                            err_section:='patient_fe-30';    err_schema:='db2frontend_in';    err_table:='patient_fe';
                            DELETE FROM db2frontend_in.patient_fe WHERE patient_fe_id = current_record.patient_fe_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='patient_fe-35';    err_schema:='db2frontend_in';    err_table:='patient_fe';
                            UPDATE db2frontend_in.patient_fe
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE patient_fe_id = current_record.patient_fe_id;
      
        
                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_fe_fe_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='patient_fe-40';    err_schema:='db2frontend_in';    err_table:='patient_fe';
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
                err_section:='patient_fe-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT patient_fe_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'patient_fe' AS table_name, last_pro_datetime, current_dataset_status, 'copy_fe_fe_in_to_db_log' AS function_name FROM db_log.patient_fe d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;
    
            -- Collect and save counts for the entity
            err_section:='patient_fe-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;    
            
            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'patient_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_new, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'patient_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_update, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'patient_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
    
        err_section:='patient_fe-50';    err_schema:='/';    err_table:='/';
        -- END patient_fe  --------   patient_fe  --------   patient_fe  --------   patient_fe
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start fall_fe  --------   fall_fe  --------   fall_fe  --------   fall_fe
        err_section:='fall_fe-01';
        SELECT COUNT(1) INTO data_count_all FROM db2frontend_in.fall_fe; -- Counting new records in the source
    
        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;
            
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_fe_fe_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;
        
            data_count:=0; data_count_update:=0; data_count_new:=0;
        
            err_section:='fall_fe-05';    err_schema:='db2frontend_in';    err_table:='fall_fe';
        
            FOR current_record IN (SELECT * FROM db2frontend_in.fall_fe)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found
                        
                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all
        
                        err_section:='fall_fe-10';    err_schema:='db_log';    err_table:='fall_fe';
                        SELECT count(1) INTO data_count
                        FROM db_log.fall_fe target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;
        
                        err_section:='fall_fe-15';    err_schema:='db_log';    err_table:='fall_fe';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.fall_fe (
                                fall_fe_id,
                                record_id,
                                fall_header,
                                fall_id,
                                fall_pat_id,
                                patient_id_fk,
                                fall_femb_1,
                                redcap_repeat_instrument,
                                redcap_repeat_instance,
                                fall_studienphase,
                                fall_station,
                                fall_zimmernr,
                                fall_aufn_dat,
                                fall_aufn_diag,
                                fall_gewicht_aktuell,
                                fall_gewicht_aktl_einheit,
                                fall_groesse,
                                fall_groesse_einheit,
                                fall_bmi,
                                fall_femb_2,
                                fall_femb_3,
                                fall_femb_4,
                                fall_femb_5,
                                fall_femb_6,
                                fall_nieren_insuf_chron,
                                fall_nieren_insuf_ausmass_lbl,
                                fall_nieren_insuf_ausmass,
                                fall_nieren_insuf_dialysev_lbl,
                                fall_nieren_insuf_dialysev,
                                fall_leber_insuf,
                                fall_leber_insuf_ausmass_lbl,
                                fall_leber_insuf_ausmass,
                                fall_schwanger_mo,
                                fall_schwanger_mo_lbl,
                                fall_status,
                                fall_ent_dat,
                                fall_complete,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.fall_fe_id,
                                current_record.record_id,
                                current_record.fall_header,
                                current_record.fall_id,
                                current_record.fall_pat_id,
                                current_record.patient_id_fk,
                                current_record.fall_femb_1,
                                current_record.redcap_repeat_instrument,
                                current_record.redcap_repeat_instance,
                                current_record.fall_studienphase,
                                current_record.fall_station,
                                current_record.fall_zimmernr,
                                current_record.fall_aufn_dat,
                                current_record.fall_aufn_diag,
                                current_record.fall_gewicht_aktuell,
                                current_record.fall_gewicht_aktl_einheit,
                                current_record.fall_groesse,
                                current_record.fall_groesse_einheit,
                                current_record.fall_bmi,
                                current_record.fall_femb_2,
                                current_record.fall_femb_3,
                                current_record.fall_femb_4,
                                current_record.fall_femb_5,
                                current_record.fall_femb_6,
                                current_record.fall_nieren_insuf_chron,
                                current_record.fall_nieren_insuf_ausmass_lbl,
                                current_record.fall_nieren_insuf_ausmass,
                                current_record.fall_nieren_insuf_dialysev_lbl,
                                current_record.fall_nieren_insuf_dialysev,
                                current_record.fall_leber_insuf,
                                current_record.fall_leber_insuf_ausmass_lbl,
                                current_record.fall_leber_insuf_ausmass,
                                current_record.fall_schwanger_mo,
                                current_record.fall_schwanger_mo_lbl,
                                current_record.fall_status,
                                current_record.fall_ent_dat,
                                current_record.fall_complete,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );
        
                            -- Delete importet datasets
                            err_section:='fall_fe-20';    err_schema:='db2frontend_in';    err_table:='fall_fe';
                            DELETE FROM db2frontend_in.fall_fe WHERE fall_fe_id = current_record.fall_fe_id;
                        ELSE
                            err_section:='fall_fe-25';    err_schema:='db_log';    err_table:='fall_fe';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.fall_fe target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;
        
                            -- Delete updatet datasets
                            err_section:='fall_fe-30';    err_schema:='db2frontend_in';    err_table:='fall_fe';
                            DELETE FROM db2frontend_in.fall_fe WHERE fall_fe_id = current_record.fall_fe_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='fall_fe-35';    err_schema:='db2frontend_in';    err_table:='fall_fe';
                            UPDATE db2frontend_in.fall_fe
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE fall_fe_id = current_record.fall_fe_id;
      
        
                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_fe_fe_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='fall_fe-40';    err_schema:='db2frontend_in';    err_table:='fall_fe';
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
                err_section:='fall_fe-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT fall_fe_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'fall_fe' AS table_name, last_pro_datetime, current_dataset_status, 'copy_fe_fe_in_to_db_log' AS function_name FROM db_log.fall_fe d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;
    
            -- Collect and save counts for the entity
            err_section:='fall_fe-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;    
            
            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'fall_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_new, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'fall_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_update, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'fall_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
    
        err_section:='fall_fe-50';    err_schema:='/';    err_table:='/';
        -- END fall_fe  --------   fall_fe  --------   fall_fe  --------   fall_fe
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start medikationsanalyse_fe  --------   medikationsanalyse_fe  --------   medikationsanalyse_fe  --------   medikationsanalyse_fe
        err_section:='medikationsanalyse_fe-01';
        SELECT COUNT(1) INTO data_count_all FROM db2frontend_in.medikationsanalyse_fe; -- Counting new records in the source
    
        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;
            
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_fe_fe_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;
        
            data_count:=0; data_count_update:=0; data_count_new:=0;
        
            err_section:='medikationsanalyse_fe-05';    err_schema:='db2frontend_in';    err_table:='medikationsanalyse_fe';
        
            FOR current_record IN (SELECT * FROM db2frontend_in.medikationsanalyse_fe)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found
                        
                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all
        
                        err_section:='medikationsanalyse_fe-10';    err_schema:='db_log';    err_table:='medikationsanalyse_fe';
                        SELECT count(1) INTO data_count
                        FROM db_log.medikationsanalyse_fe target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;
        
                        err_section:='medikationsanalyse_fe-15';    err_schema:='db_log';    err_table:='medikationsanalyse_fe';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.medikationsanalyse_fe (
                                medikationsanalyse_fe_id,
                                record_id,
                                meda_header,
                                meda_femb_1,
                                meda_femb_2,
                                meda_femb_3,
                                fall_fe_id,
                                redcap_repeat_instrument,
                                redcap_repeat_instance,
                                meda_dat,
                                meda_typ,
                                meda_ma_thueberw,
                                meda_mrp_detekt,
                                meda_aufwand_zeit,
                                meda_aufwand_zeit_and_lbl,
                                meda_aufwand_zeit_and,
                                meda_notiz,
                                medikationsanalyse_complete,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.medikationsanalyse_fe_id,
                                current_record.record_id,
                                current_record.meda_header,
                                current_record.meda_femb_1,
                                current_record.meda_femb_2,
                                current_record.meda_femb_3,
                                current_record.fall_fe_id,
                                current_record.redcap_repeat_instrument,
                                current_record.redcap_repeat_instance,
                                current_record.meda_dat,
                                current_record.meda_typ,
                                current_record.meda_ma_thueberw,
                                current_record.meda_mrp_detekt,
                                current_record.meda_aufwand_zeit,
                                current_record.meda_aufwand_zeit_and_lbl,
                                current_record.meda_aufwand_zeit_and,
                                current_record.meda_notiz,
                                current_record.medikationsanalyse_complete,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );
        
                            -- Delete importet datasets
                            err_section:='medikationsanalyse_fe-20';    err_schema:='db2frontend_in';    err_table:='medikationsanalyse_fe';
                            DELETE FROM db2frontend_in.medikationsanalyse_fe WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
                        ELSE
                            err_section:='medikationsanalyse_fe-25';    err_schema:='db_log';    err_table:='medikationsanalyse_fe';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.medikationsanalyse_fe target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;
        
                            -- Delete updatet datasets
                            err_section:='medikationsanalyse_fe-30';    err_schema:='db2frontend_in';    err_table:='medikationsanalyse_fe';
                            DELETE FROM db2frontend_in.medikationsanalyse_fe WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='medikationsanalyse_fe-35';    err_schema:='db2frontend_in';    err_table:='medikationsanalyse_fe';
                            UPDATE db2frontend_in.medikationsanalyse_fe
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
      
        
                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_fe_fe_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='medikationsanalyse_fe-40';    err_schema:='db2frontend_in';    err_table:='medikationsanalyse_fe';
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
                err_section:='medikationsanalyse_fe-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT medikationsanalyse_fe_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'medikationsanalyse_fe' AS table_name, last_pro_datetime, current_dataset_status, 'copy_fe_fe_in_to_db_log' AS function_name FROM db_log.medikationsanalyse_fe d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;
    
            -- Collect and save counts for the entity
            err_section:='medikationsanalyse_fe-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;    
            
            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'medikationsanalyse_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_new, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'medikationsanalyse_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_update, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'medikationsanalyse_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
    
        err_section:='medikationsanalyse_fe-50';    err_schema:='/';    err_table:='/';
        -- END medikationsanalyse_fe  --------   medikationsanalyse_fe  --------   medikationsanalyse_fe  --------   medikationsanalyse_fe
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start mrpdokumentation_validierung_fe  --------   mrpdokumentation_validierung_fe  --------   mrpdokumentation_validierung_fe  --------   mrpdokumentation_validierung_fe
        err_section:='mrpdokumentation_validierung_fe-01';
        SELECT COUNT(1) INTO data_count_all FROM db2frontend_in.mrpdokumentation_validierung_fe; -- Counting new records in the source
    
        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;
            
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_fe_fe_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;
        
            data_count:=0; data_count_update:=0; data_count_new:=0;
        
            err_section:='mrpdokumentation_validierung_fe-05';    err_schema:='db2frontend_in';    err_table:='mrpdokumentation_validierung_fe';
        
            FOR current_record IN (SELECT * FROM db2frontend_in.mrpdokumentation_validierung_fe)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found
                        
                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all
        
                        err_section:='mrpdokumentation_validierung_fe-10';    err_schema:='db_log';    err_table:='mrpdokumentation_validierung_fe';
                        SELECT count(1) INTO data_count
                        FROM db_log.mrpdokumentation_validierung_fe target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;
        
                        err_section:='mrpdokumentation_validierung_fe-15';    err_schema:='db_log';    err_table:='mrpdokumentation_validierung_fe';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.mrpdokumentation_validierung_fe (
                                mrpdokumentation_validierung_fe_id,
                                record_id,
                                meda_fe_id,
                                redcap_repeat_instrument,
                                redcap_repeat_instance,
                                mrp_header,
                                mrp_femb_1,
                                mrp_femb_2,
                                mrp_femb_3,
                                mrp_pi_info,
                                mrp_pi_info___1,
                                mrp_mf_info,
                                mrp_mf_info___1,
                                mrp_pi_info_txt,
                                mrp_mf_info_txt,
                                mrp_femb_4,
                                mrp_femb_5,
                                mrp_femb_6,
                                mrp_entd_dat,
                                mrp_kurzbeschr,
                                mrp_entd_algorithmisch,
                                mrp_hinweisgeber_lbl,
                                mrp_hinweisgeber,
                                mrp_gewissheit_lbl,
                                mrp_gewissheit,
                                mrp_femb_22,
                                mrp_gewissheit_oth,
                                mrp_femb_23,
                                mrp_hinweisgeber_oth,
                                mrp_gewiss_grund_abl_lbl,
                                mrp_gewiss_grund_abl,
                                mrp_gewiss_grund_abl_sonst_lbl,
                                mrp_gewiss_grund_abl_sonst,
                                mrp_femb_7,
                                mrp_femb_8,
                                mrp_femb_9,
                                mrp_femb_10,
                                mrp_femb_11,
                                mrp_femb_12,
                                mrp_wirkstoff,
                                mrp_atc1_lbl,
                                mrp_atc1,
                                mrp_atc2_lbl,
                                mrp_atc2,
                                mrp_atc3_lbl,
                                mrp_atc3,
                                mrp_atc4_lbl,
                                mrp_atc4,
                                mrp_atc5_lbl,
                                mrp_atc5,
                                mrp_femb_13,
                                mrp_med_prod,
                                mrp_med_prod_sonst_lbl,
                                mrp_med_prod_sonst,
                                mrp_dokup_fehler,
                                mrp_dokup_intervention,
                                mrp_femb_14,
                                mrp_pigrund,
                                mrp_pigrund___1,
                                mrp_pigrund___2,
                                mrp_pigrund___3,
                                mrp_pigrund___4,
                                mrp_pigrund___5,
                                mrp_pigrund___6,
                                mrp_pigrund___7,
                                mrp_pigrund___8,
                                mrp_pigrund___9,
                                mrp_pigrund___10,
                                mrp_pigrund___11,
                                mrp_pigrund___12,
                                mrp_pigrund___13,
                                mrp_pigrund___14,
                                mrp_pigrund___15,
                                mrp_pigrund___16,
                                mrp_pigrund___17,
                                mrp_pigrund___18,
                                mrp_pigrund___19,
                                mrp_pigrund___20,
                                mrp_pigrund___21,
                                mrp_pigrund___22,
                                mrp_pigrund___23,
                                mrp_pigrund___24,
                                mrp_pigrund___25,
                                mrp_pigrund___26,
                                mrp_pigrund___27,
                                mrp_femb_15,
                                mrp_ip_klasse,
                                mrp_ip_klasse___1,
                                mrp_ip_klasse___2,
                                mrp_ip_klasse___3,
                                mrp_ip_klasse___4,
                                mrp_ip_klasse___5,
                                mrp_femb_16,
                                mrp_femb_17,
                                mrp_ip_klasse_disease,
                                mrp_ip_klasse_labor,
                                mrp_femb_18,
                                mrp_massn_am,
                                mrp_massn_am___1,
                                mrp_massn_am___2,
                                mrp_massn_am___3,
                                mrp_massn_am___4,
                                mrp_massn_am___5,
                                mrp_massn_am___6,
                                mrp_massn_am___7,
                                mrp_massn_am___8,
                                mrp_massn_am___9,
                                mrp_massn_am___10,
                                mrp_femb_19,
                                mrp_massn_orga,
                                mrp_massn_orga___1,
                                mrp_massn_orga___2,
                                mrp_massn_orga___3,
                                mrp_massn_orga___4,
                                mrp_massn_orga___5,
                                mrp_massn_orga___6,
                                mrp_massn_orga___7,
                                mrp_massn_orga___8,
                                mrp_femb_20,
                                mrp_notiz,
                                mrp_femb_21,
                                mrp_dokup_hand_emp_akz,
                                mrp_merp,
                                mrp_merp_info,
                                mrp_merp_info___1,
                                mrp_merp_txt,
                                mrpdokumentation_validierung_complete,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.mrpdokumentation_validierung_fe_id,
                                current_record.record_id,
                                current_record.meda_fe_id,
                                current_record.redcap_repeat_instrument,
                                current_record.redcap_repeat_instance,
                                current_record.mrp_header,
                                current_record.mrp_femb_1,
                                current_record.mrp_femb_2,
                                current_record.mrp_femb_3,
                                current_record.mrp_pi_info,
                                current_record.mrp_pi_info___1,
                                current_record.mrp_mf_info,
                                current_record.mrp_mf_info___1,
                                current_record.mrp_pi_info_txt,
                                current_record.mrp_mf_info_txt,
                                current_record.mrp_femb_4,
                                current_record.mrp_femb_5,
                                current_record.mrp_femb_6,
                                current_record.mrp_entd_dat,
                                current_record.mrp_kurzbeschr,
                                current_record.mrp_entd_algorithmisch,
                                current_record.mrp_hinweisgeber_lbl,
                                current_record.mrp_hinweisgeber,
                                current_record.mrp_gewissheit_lbl,
                                current_record.mrp_gewissheit,
                                current_record.mrp_femb_22,
                                current_record.mrp_gewissheit_oth,
                                current_record.mrp_femb_23,
                                current_record.mrp_hinweisgeber_oth,
                                current_record.mrp_gewiss_grund_abl_lbl,
                                current_record.mrp_gewiss_grund_abl,
                                current_record.mrp_gewiss_grund_abl_sonst_lbl,
                                current_record.mrp_gewiss_grund_abl_sonst,
                                current_record.mrp_femb_7,
                                current_record.mrp_femb_8,
                                current_record.mrp_femb_9,
                                current_record.mrp_femb_10,
                                current_record.mrp_femb_11,
                                current_record.mrp_femb_12,
                                current_record.mrp_wirkstoff,
                                current_record.mrp_atc1_lbl,
                                current_record.mrp_atc1,
                                current_record.mrp_atc2_lbl,
                                current_record.mrp_atc2,
                                current_record.mrp_atc3_lbl,
                                current_record.mrp_atc3,
                                current_record.mrp_atc4_lbl,
                                current_record.mrp_atc4,
                                current_record.mrp_atc5_lbl,
                                current_record.mrp_atc5,
                                current_record.mrp_femb_13,
                                current_record.mrp_med_prod,
                                current_record.mrp_med_prod_sonst_lbl,
                                current_record.mrp_med_prod_sonst,
                                current_record.mrp_dokup_fehler,
                                current_record.mrp_dokup_intervention,
                                current_record.mrp_femb_14,
                                current_record.mrp_pigrund,
                                current_record.mrp_pigrund___1,
                                current_record.mrp_pigrund___2,
                                current_record.mrp_pigrund___3,
                                current_record.mrp_pigrund___4,
                                current_record.mrp_pigrund___5,
                                current_record.mrp_pigrund___6,
                                current_record.mrp_pigrund___7,
                                current_record.mrp_pigrund___8,
                                current_record.mrp_pigrund___9,
                                current_record.mrp_pigrund___10,
                                current_record.mrp_pigrund___11,
                                current_record.mrp_pigrund___12,
                                current_record.mrp_pigrund___13,
                                current_record.mrp_pigrund___14,
                                current_record.mrp_pigrund___15,
                                current_record.mrp_pigrund___16,
                                current_record.mrp_pigrund___17,
                                current_record.mrp_pigrund___18,
                                current_record.mrp_pigrund___19,
                                current_record.mrp_pigrund___20,
                                current_record.mrp_pigrund___21,
                                current_record.mrp_pigrund___22,
                                current_record.mrp_pigrund___23,
                                current_record.mrp_pigrund___24,
                                current_record.mrp_pigrund___25,
                                current_record.mrp_pigrund___26,
                                current_record.mrp_pigrund___27,
                                current_record.mrp_femb_15,
                                current_record.mrp_ip_klasse,
                                current_record.mrp_ip_klasse___1,
                                current_record.mrp_ip_klasse___2,
                                current_record.mrp_ip_klasse___3,
                                current_record.mrp_ip_klasse___4,
                                current_record.mrp_ip_klasse___5,
                                current_record.mrp_femb_16,
                                current_record.mrp_femb_17,
                                current_record.mrp_ip_klasse_disease,
                                current_record.mrp_ip_klasse_labor,
                                current_record.mrp_femb_18,
                                current_record.mrp_massn_am,
                                current_record.mrp_massn_am___1,
                                current_record.mrp_massn_am___2,
                                current_record.mrp_massn_am___3,
                                current_record.mrp_massn_am___4,
                                current_record.mrp_massn_am___5,
                                current_record.mrp_massn_am___6,
                                current_record.mrp_massn_am___7,
                                current_record.mrp_massn_am___8,
                                current_record.mrp_massn_am___9,
                                current_record.mrp_massn_am___10,
                                current_record.mrp_femb_19,
                                current_record.mrp_massn_orga,
                                current_record.mrp_massn_orga___1,
                                current_record.mrp_massn_orga___2,
                                current_record.mrp_massn_orga___3,
                                current_record.mrp_massn_orga___4,
                                current_record.mrp_massn_orga___5,
                                current_record.mrp_massn_orga___6,
                                current_record.mrp_massn_orga___7,
                                current_record.mrp_massn_orga___8,
                                current_record.mrp_femb_20,
                                current_record.mrp_notiz,
                                current_record.mrp_femb_21,
                                current_record.mrp_dokup_hand_emp_akz,
                                current_record.mrp_merp,
                                current_record.mrp_merp_info,
                                current_record.mrp_merp_info___1,
                                current_record.mrp_merp_txt,
                                current_record.mrpdokumentation_validierung_complete,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );
        
                            -- Delete importet datasets
                            err_section:='mrpdokumentation_validierung_fe-20';    err_schema:='db2frontend_in';    err_table:='mrpdokumentation_validierung_fe';
                            DELETE FROM db2frontend_in.mrpdokumentation_validierung_fe WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
                        ELSE
                            err_section:='mrpdokumentation_validierung_fe-25';    err_schema:='db_log';    err_table:='mrpdokumentation_validierung_fe';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.mrpdokumentation_validierung_fe target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;
        
                            -- Delete updatet datasets
                            err_section:='mrpdokumentation_validierung_fe-30';    err_schema:='db2frontend_in';    err_table:='mrpdokumentation_validierung_fe';
                            DELETE FROM db2frontend_in.mrpdokumentation_validierung_fe WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='mrpdokumentation_validierung_fe-35';    err_schema:='db2frontend_in';    err_table:='mrpdokumentation_validierung_fe';
                            UPDATE db2frontend_in.mrpdokumentation_validierung_fe
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
      
        
                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_fe_fe_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='mrpdokumentation_validierung_fe-40';    err_schema:='db2frontend_in';    err_table:='mrpdokumentation_validierung_fe';
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
                err_section:='mrpdokumentation_validierung_fe-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT mrpdokumentation_validierung_fe_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'mrpdokumentation_validierung_fe' AS table_name, last_pro_datetime, current_dataset_status, 'copy_fe_fe_in_to_db_log' AS function_name FROM db_log.mrpdokumentation_validierung_fe d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;
    
            -- Collect and save counts for the entity
            err_section:='mrpdokumentation_validierung_fe-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;    
            
            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'mrpdokumentation_validierung_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_new, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'mrpdokumentation_validierung_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_update, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'mrpdokumentation_validierung_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
    
        err_section:='mrpdokumentation_validierung_fe-50';    err_schema:='/';    err_table:='/';
        -- END mrpdokumentation_validierung_fe  --------   mrpdokumentation_validierung_fe  --------   mrpdokumentation_validierung_fe  --------   mrpdokumentation_validierung_fe
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start risikofaktor_fe  --------   risikofaktor_fe  --------   risikofaktor_fe  --------   risikofaktor_fe
        err_section:='risikofaktor_fe-01';
        SELECT COUNT(1) INTO data_count_all FROM db2frontend_in.risikofaktor_fe; -- Counting new records in the source
    
        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;
            
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_fe_fe_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;
        
            data_count:=0; data_count_update:=0; data_count_new:=0;
        
            err_section:='risikofaktor_fe-05';    err_schema:='db2frontend_in';    err_table:='risikofaktor_fe';
        
            FOR current_record IN (SELECT * FROM db2frontend_in.risikofaktor_fe)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found
                        
                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all
        
                        err_section:='risikofaktor_fe-10';    err_schema:='db_log';    err_table:='risikofaktor_fe';
                        SELECT count(1) INTO data_count
                        FROM db_log.risikofaktor_fe target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;
        
                        err_section:='risikofaktor_fe-15';    err_schema:='db_log';    err_table:='risikofaktor_fe';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.risikofaktor_fe (
                                risikofaktor_fe_id,
                                record_id,
                                patient_id_fk,
                                rskfk_gerhemmer,
                                rskfk_tah,
                                rskfk_immunsupp,
                                rskfk_tumorth,
                                rskfk_opiat,
                                rskfk_atcn,
                                rskfk_ait,
                                rskfk_anzam,
                                rskfk_priscus,
                                rskfk_qtc,
                                rskfk_meld,
                                rskfk_dialyse,
                                rskfk_entern,
                                rskfkt_anz_rskamklassen,
                                risikofaktor_complete,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.risikofaktor_fe_id,
                                current_record.record_id,
                                current_record.patient_id_fk,
                                current_record.rskfk_gerhemmer,
                                current_record.rskfk_tah,
                                current_record.rskfk_immunsupp,
                                current_record.rskfk_tumorth,
                                current_record.rskfk_opiat,
                                current_record.rskfk_atcn,
                                current_record.rskfk_ait,
                                current_record.rskfk_anzam,
                                current_record.rskfk_priscus,
                                current_record.rskfk_qtc,
                                current_record.rskfk_meld,
                                current_record.rskfk_dialyse,
                                current_record.rskfk_entern,
                                current_record.rskfkt_anz_rskamklassen,
                                current_record.risikofaktor_complete,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );
        
                            -- Delete importet datasets
                            err_section:='risikofaktor_fe-20';    err_schema:='db2frontend_in';    err_table:='risikofaktor_fe';
                            DELETE FROM db2frontend_in.risikofaktor_fe WHERE risikofaktor_fe_id = current_record.risikofaktor_fe_id;
                        ELSE
                            err_section:='risikofaktor_fe-25';    err_schema:='db_log';    err_table:='risikofaktor_fe';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.risikofaktor_fe target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;
        
                            -- Delete updatet datasets
                            err_section:='risikofaktor_fe-30';    err_schema:='db2frontend_in';    err_table:='risikofaktor_fe';
                            DELETE FROM db2frontend_in.risikofaktor_fe WHERE risikofaktor_fe_id = current_record.risikofaktor_fe_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='risikofaktor_fe-35';    err_schema:='db2frontend_in';    err_table:='risikofaktor_fe';
                            UPDATE db2frontend_in.risikofaktor_fe
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE risikofaktor_fe_id = current_record.risikofaktor_fe_id;
      
        
                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_fe_fe_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='risikofaktor_fe-40';    err_schema:='db2frontend_in';    err_table:='risikofaktor_fe';
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
                err_section:='risikofaktor_fe-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT risikofaktor_fe_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'risikofaktor_fe' AS table_name, last_pro_datetime, current_dataset_status, 'copy_fe_fe_in_to_db_log' AS function_name FROM db_log.risikofaktor_fe d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;
    
            -- Collect and save counts for the entity
            err_section:='risikofaktor_fe-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;    
            
            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'risikofaktor_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_new, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'risikofaktor_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_update, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'risikofaktor_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
    
        err_section:='risikofaktor_fe-50';    err_schema:='/';    err_table:='/';
        -- END risikofaktor_fe  --------   risikofaktor_fe  --------   risikofaktor_fe  --------   risikofaktor_fe
        -----------------------------------------------------------------------------------------------------------------------


        -----------------------------------------------------------------------------------------------------------------------
        -- Start trigger_fe  --------   trigger_fe  --------   trigger_fe  --------   trigger_fe
        err_section:='trigger_fe-01';
        SELECT COUNT(1) INTO data_count_all FROM db2frontend_in.trigger_fe; -- Counting new records in the source
    
        IF data_count_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_start;
            
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'', last_change_timestamp=CURRENT_TIMESTAMP
            copy_fe_fe_in_to_db_log'' WHERE pc_name=''timepoint_2_cron_job_data_transfer'''
            ) ) AS t(res TEXT) INTO erg;
        
            data_count:=0; data_count_update:=0; data_count_new:=0;
        
            err_section:='trigger_fe-05';    err_schema:='db2frontend_in';    err_table:='trigger_fe';
        
            FOR current_record IN (SELECT * FROM db2frontend_in.trigger_fe)
                LOOP
                    BEGIN
                        IF last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO last_pro_nr; END IF; -- Get the processing number for this process only if records found
                        
                        data_count_pro_processed:=data_count_pro_processed+1; -- count processes ds since last info
                        data_count_last_status_set:=data_count_last_status_set+1; -- counting processing ds over all
        
                        err_section:='trigger_fe-10';    err_schema:='db_log';    err_table:='trigger_fe';
                        SELECT count(1) INTO data_count
                        FROM db_log.trigger_fe target_record
                        WHERE target_record.hash_index_col = current_record.hash_index_col
                        ;
        
                        err_section:='trigger_fe-15';    err_schema:='db_log';    err_table:='trigger_fe';
                        IF data_count = 0
                        THEN
                            data_count_new:=data_count_new+1;
                            INSERT INTO db_log.trigger_fe (
                                trigger_fe_id,
                                patient_id_fk,
                                record_id,
                                trg_ast,
                                trg_alt,
                                trg_crp,
                                trg_leuk_penie,
                                trg_leuk_ose,
                                trg_thrmb_penie,
                                trg_aptt,
                                trg_hyp_haem,
                                trg_hypo_glyk,
                                trg_hyper_glyk,
                                trg_hyper_bilirbnm,
                                trg_ck,
                                trg_hypo_serablmn,
                                trg_hypo_nat,
                                trg_hyper_nat,
                                trg_hyper_kal,
                                trg_hypo_kal,
                                trg_inr_ern,
                                trg_inr_erh,
                                trg_inr_erh_antikoa,
                                trg_krea,
                                trg_egfr,
                                trigger_complete,
                                input_datetime,
                                last_check_datetime,
                                input_processing_nr,
                                last_processing_nr
                            )
                            VALUES (
                                current_record.trigger_fe_id,
                                current_record.patient_id_fk,
                                current_record.record_id,
                                current_record.trg_ast,
                                current_record.trg_alt,
                                current_record.trg_crp,
                                current_record.trg_leuk_penie,
                                current_record.trg_leuk_ose,
                                current_record.trg_thrmb_penie,
                                current_record.trg_aptt,
                                current_record.trg_hyp_haem,
                                current_record.trg_hypo_glyk,
                                current_record.trg_hyper_glyk,
                                current_record.trg_hyper_bilirbnm,
                                current_record.trg_ck,
                                current_record.trg_hypo_serablmn,
                                current_record.trg_hypo_nat,
                                current_record.trg_hyper_nat,
                                current_record.trg_hyper_kal,
                                current_record.trg_hypo_kal,
                                current_record.trg_inr_ern,
                                current_record.trg_inr_erh,
                                current_record.trg_inr_erh_antikoa,
                                current_record.trg_krea,
                                current_record.trg_egfr,
                                current_record.trigger_complete,
                                current_record.input_datetime,
                                last_pro_datetime,
                                last_pro_nr,
                                last_pro_nr
                            );
        
                            -- Delete importet datasets
                            err_section:='trigger_fe-20';    err_schema:='db2frontend_in';    err_table:='trigger_fe';
                            DELETE FROM db2frontend_in.trigger_fe WHERE trigger_fe_id = current_record.trigger_fe_id;
                        ELSE
                            err_section:='trigger_fe-25';    err_schema:='db_log';    err_table:='trigger_fe';
                            data_count_update:=data_count_update+1;
                            UPDATE db_log.trigger_fe target_record
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                            , last_processing_nr = last_pro_nr
                            WHERE target_record.hash_index_col = current_record.hash_index_col
                            ;
        
                            -- Delete updatet datasets
                            err_section:='trigger_fe-30';    err_schema:='db2frontend_in';    err_table:='trigger_fe';
                            DELETE FROM db2frontend_in.trigger_fe WHERE trigger_fe_id = current_record.trigger_fe_id;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_section:='trigger_fe-35';    err_schema:='db2frontend_in';    err_table:='trigger_fe';
                            UPDATE db2frontend_in.trigger_fe
                            SET last_check_datetime = last_pro_datetime
                            , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                            , last_processing_nr = last_pro_nr
                            WHERE trigger_fe_id = current_record.trigger_fe_id;
      
        
                            SELECT db.error_log(
                                err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
                                err_objekt => CAST('db.copy_fe_fe_in_to_db_log()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
                                err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
                                err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
                                err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
                                err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
                                last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
                            ) INTO temp;
                    END;

                    err_section:='trigger_fe-40';    err_schema:='db2frontend_in';    err_table:='trigger_fe';
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
                err_section:='trigger_fe-40';    err_schema:='db_log';    err_table:='data_import_hist';
                INSERT INTO db.data_import_hist (table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
                ( SELECT trigger_fe_id AS table_primary_key, last_processing_nr,'data_import_hist_every_dataset' as variable_name , 'db_log' AS schema_name, 'trigger_fe' AS table_name, last_pro_datetime, current_dataset_status, 'copy_fe_fe_in_to_db_log' AS function_name FROM db_log.trigger_fe d WHERE d.last_processing_nr=last_pro_nr
                EXCEPT SELECT table_primary_key, last_processing_nr, variable_name, schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db.data_import_hist h WHERE h.last_processing_nr=last_pro_nr
                );
            END IF;
    
            -- Collect and save counts for the entity
            err_section:='trigger_fe-45';    err_schema:='db_log';    err_table:='data_import_hist';
            data_count_pro_new:=data_count_pro_new+data_count_new;
            -- calculation of the time period
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'
            ))  AS t(res TEXT) INTO timestamp_ent_end;    
            
            SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_ent_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_ent_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_ent_start||' o '||timestamp_ent_end INTO tmp_sec, temp;
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_new', 'db_log', 'trigger_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_new, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_update', 'db_log', 'trigger_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_update, tmp_sec, temp);
        
            INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
            VALUES ( last_pro_nr,'data_count_all', 'db_log', 'trigger_fe', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_all, tmp_sec, temp);
        END IF; -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
    
        err_section:='trigger_fe-50';    err_schema:='/';    err_table:='/';
        -- END trigger_fe  --------   trigger_fe  --------   trigger_fe  --------   trigger_fe
        -----------------------------------------------------------------------------------------------------------------------


        err_section:='BOTTON-01';  err_schema:='db_log';    err_table:='data_import_hist';

        -- Collect and save counts for the function
        SELECT res FROM pg_background_result(pg_background_launch(
        'SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US''
        )'))  AS t(res TEXT) INTO timestamp_end;

        SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;
    
        err_section:='BOTTON-05';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_all', 'db_log', 'copy_fe_fe_in_to_db_log', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_pro_all, tmp_sec, 'Count all Datasetzs '||temp );

        err_section:='BOTTON-10';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_new', 'db_log', 'copy_fe_fe_in_to_db_log', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_pro_new, tmp_sec, 'Count all new Datasetzs '||temp);
    
        err_section:='BOTTON-15';  err_schema:='db_log';    err_table:='data_import_hist';
        INSERT INTO db.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
        VALUES ( last_pro_nr,'data_count_pro_upd', 'db_log', 'copy_fe_fe_in_to_db_log', last_pro_datetime, 'copy_fe_fe_in_to_db_log', data_count_pro_upd, tmp_sec, 'Count all updatetd Datasetzs '||temp);

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

    RETURN 'Done db.copy_fe_fe_in_to_db_log - last_pro_nr:'||last_pro_nr;

EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.copy_fe_fe_in_to_db_log()' AS VARCHAR),     -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' e:'||erg AS VARCHAR),       -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(last_pro_nr AS int)                -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler db.copy_fe_fe_in_to_db_log - '||SQLSTATE||' - last_pro_nr:'||last_pro_nr;
END;
$$ LANGUAGE plpgsql;

-----------------------------

