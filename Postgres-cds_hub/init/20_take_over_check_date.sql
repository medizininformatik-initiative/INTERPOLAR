-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-12-04 14:36:29
-- Rights definition file size        : 15121 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2024-12-04 16:23:23
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
    new_last_pro_nr INT; -- New processing number for these sync
    last_raw_pro_nr INT; -- Last processing number in raw data - last new dataimport (offset)
    max_last_pro_nr INT; -- Last processing number over all entities
    last_pro_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP; -- Last time function is startet
    data_import_hist_every_dataset INT:=0; -- Value for documentation of each individual data record switch off
    temp varchar; -- Temporary variable for interim results
    timestamp_start varchar;
    timestamp_end varchar;
    tmp_sec double precision:=0; -- Temporary variable to store execution time
    err_section varchar;
    err_schema varchar;
    err_table varchar;
    err_pid varchar;
BEGIN
    -- Take over last check datetime Functionname: take_over_last_check_date the last_pro_nr - From: db_log (raw) -> To: db_log
   
    -- set start time
    err_section:='HEAD-01';    err_schema:='db_config';    err_table:='db_process_control';
	SELECT res FROM public.pg_background_result(public.pg_background_launch('SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'))  AS t(res TEXT) INTO timestamp_start;
    err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')||'' take_over_last_check_date'' WHERE pc_name=''timepoint_1_cron_job_data_transfer''');

    -- Last import Nr in raw-data
    err_section:='HEAD-05';    err_schema:='db_log';    err_table:='data_import_hist';
    SELECT MAX(last_processing_nr) INTO last_raw_pro_nr FROM db_log.data_import_hist WHERE table_name like '%_raw' AND schema_name='db_log';

    err_section:='HEAD-10';    err_schema:='db_config';    err_table:='db_parameter';
    SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes'; -- Get value for documentation of each individual data record

    -- Get the last processing number across all data to mark current data across the board
    err_section:='HEAD-15';    err_schema:='db_log';    err_table:='- all_entitys -';
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr
    FROM ( SELECT 0 AS last_processing_nr
        UNION SELECT DISTINCT last_processing_nr
    FROM db_log.encounter_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.encounter_raw WHERE encounter_raw_id IN 
            (SELECT encounter_raw_id FROM db_log.encounter WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.encounter)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.encounter)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.patient_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.patient_raw WHERE patient_raw_id IN 
            (SELECT patient_raw_id FROM db_log.patient WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.patient)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.patient)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.condition_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.condition_raw WHERE condition_raw_id IN 
            (SELECT condition_raw_id FROM db_log.condition WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.condition)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.condition)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.medication_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medication_raw WHERE medication_raw_id IN 
            (SELECT medication_raw_id FROM db_log.medication WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medication)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medication)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.medicationrequest_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationrequest_raw WHERE medicationrequest_raw_id IN 
            (SELECT medicationrequest_raw_id FROM db_log.medicationrequest WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medicationrequest)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medicationrequest)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.medicationadministration_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationadministration_raw WHERE medicationadministration_raw_id IN 
            (SELECT medicationadministration_raw_id FROM db_log.medicationadministration WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medicationadministration)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medicationadministration)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.medicationstatement_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationstatement_raw WHERE medicationstatement_raw_id IN 
            (SELECT medicationstatement_raw_id FROM db_log.medicationstatement WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medicationstatement)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medicationstatement)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.observation_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.observation_raw WHERE observation_raw_id IN 
            (SELECT observation_raw_id FROM db_log.observation WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.observation)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.observation)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.diagnosticreport_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.diagnosticreport_raw WHERE diagnosticreport_raw_id IN 
            (SELECT diagnosticreport_raw_id FROM db_log.diagnosticreport WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.diagnosticreport)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.diagnosticreport)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.servicerequest_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.servicerequest_raw WHERE servicerequest_raw_id IN 
            (SELECT servicerequest_raw_id FROM db_log.servicerequest WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.servicerequest)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.servicerequest)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.procedure_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.procedure_raw WHERE procedure_raw_id IN 
            (SELECT procedure_raw_id FROM db_log.procedure WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.procedure)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.procedure)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.consent_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.consent_raw WHERE consent_raw_id IN 
            (SELECT consent_raw_id FROM db_log.consent WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.consent)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.consent)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.location_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.location_raw WHERE location_raw_id IN 
            (SELECT location_raw_id FROM db_log.location WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.location)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.location)
    UNION SELECT DISTINCT last_processing_nr
    FROM db_log.pids_per_ward_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.pids_per_ward_raw WHERE pids_per_ward_raw_id IN 
            (SELECT pids_per_ward_raw_id FROM db_log.pids_per_ward WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.pids_per_ward)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.pids_per_ward)

    );

    err_section:='HEAD-20';    err_schema:='db_log';    err_table:='/';

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.encounter_raw to db_log.encounter

    -- Start encounter
    err_section:='encounter-01';    err_schema:='db_log';    err_table:='encounter';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT encounter_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.encounter_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.encounter_raw WHERE encounter_raw_id IN 
            (SELECT encounter_raw_id FROM db_log.encounter WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.encounter)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.encounter) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT encounter_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'encounter_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.encounter_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT encounter_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'encounter' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.encounter
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End encounter
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.patient_raw to db_log.patient

    -- Start patient
    err_section:='patient-01';    err_schema:='db_log';    err_table:='patient';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT patient_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.patient_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.patient_raw WHERE patient_raw_id IN 
            (SELECT patient_raw_id FROM db_log.patient WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.patient)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.patient) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT patient_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.patient_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT patient_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.patient
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End patient
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.condition_raw to db_log.condition

    -- Start condition
    err_section:='condition-01';    err_schema:='db_log';    err_table:='condition';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT condition_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.condition_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.condition_raw WHERE condition_raw_id IN 
            (SELECT condition_raw_id FROM db_log.condition WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.condition)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.condition) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT condition_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'condition_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.condition_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT condition_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'condition' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.condition
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End condition
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medication_raw to db_log.medication

    -- Start medication
    err_section:='medication-01';    err_schema:='db_log';    err_table:='medication';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medication_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medication_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medication_raw WHERE medication_raw_id IN 
            (SELECT medication_raw_id FROM db_log.medication WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medication)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medication) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medication_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medication_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medication_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medication_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medication' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medication
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End medication
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationrequest_raw to db_log.medicationrequest

    -- Start medicationrequest
    err_section:='medicationrequest-01';    err_schema:='db_log';    err_table:='medicationrequest';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medicationrequest_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medicationrequest_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationrequest_raw WHERE medicationrequest_raw_id IN 
            (SELECT medicationrequest_raw_id FROM db_log.medicationrequest WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medicationrequest)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medicationrequest) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationrequest_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationrequest_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationrequest_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationrequest_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationrequest' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationrequest
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End medicationrequest
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationadministration_raw to db_log.medicationadministration

    -- Start medicationadministration
    err_section:='medicationadministration-01';    err_schema:='db_log';    err_table:='medicationadministration';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medicationadministration_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medicationadministration_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationadministration_raw WHERE medicationadministration_raw_id IN 
            (SELECT medicationadministration_raw_id FROM db_log.medicationadministration WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medicationadministration)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medicationadministration) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationadministration_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationadministration_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationadministration_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationadministration_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationadministration' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationadministration
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End medicationadministration
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationstatement_raw to db_log.medicationstatement

    -- Start medicationstatement
    err_section:='medicationstatement-01';    err_schema:='db_log';    err_table:='medicationstatement';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medicationstatement_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medicationstatement_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationstatement_raw WHERE medicationstatement_raw_id IN 
            (SELECT medicationstatement_raw_id FROM db_log.medicationstatement WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.medicationstatement)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.medicationstatement) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationstatement_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationstatement_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationstatement_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT medicationstatement_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationstatement' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationstatement
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End medicationstatement
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.observation_raw to db_log.observation

    -- Start observation
    err_section:='observation-01';    err_schema:='db_log';    err_table:='observation';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT observation_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.observation_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.observation_raw WHERE observation_raw_id IN 
            (SELECT observation_raw_id FROM db_log.observation WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.observation)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.observation) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT observation_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'observation_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.observation_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT observation_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'observation' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.observation
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End observation
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.diagnosticreport_raw to db_log.diagnosticreport

    -- Start diagnosticreport
    err_section:='diagnosticreport-01';    err_schema:='db_log';    err_table:='diagnosticreport';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT diagnosticreport_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.diagnosticreport_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.diagnosticreport_raw WHERE diagnosticreport_raw_id IN 
            (SELECT diagnosticreport_raw_id FROM db_log.diagnosticreport WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.diagnosticreport)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.diagnosticreport) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT diagnosticreport_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'diagnosticreport_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.diagnosticreport_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT diagnosticreport_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'diagnosticreport' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.diagnosticreport
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End diagnosticreport
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.servicerequest_raw to db_log.servicerequest

    -- Start servicerequest
    err_section:='servicerequest-01';    err_schema:='db_log';    err_table:='servicerequest';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT servicerequest_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.servicerequest_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.servicerequest_raw WHERE servicerequest_raw_id IN 
            (SELECT servicerequest_raw_id FROM db_log.servicerequest WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.servicerequest)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.servicerequest) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT servicerequest_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'servicerequest_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.servicerequest_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT servicerequest_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'servicerequest' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.servicerequest
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End servicerequest
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.procedure_raw to db_log.procedure

    -- Start procedure
    err_section:='procedure-01';    err_schema:='db_log';    err_table:='procedure';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT procedure_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.procedure_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.procedure_raw WHERE procedure_raw_id IN 
            (SELECT procedure_raw_id FROM db_log.procedure WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.procedure)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.procedure) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT procedure_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'procedure_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.procedure_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT procedure_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'procedure' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.procedure
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End procedure
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.consent_raw to db_log.consent

    -- Start consent
    err_section:='consent-01';    err_schema:='db_log';    err_table:='consent';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT consent_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.consent_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.consent_raw WHERE consent_raw_id IN 
            (SELECT consent_raw_id FROM db_log.consent WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.consent)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.consent) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT consent_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'consent_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.consent_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT consent_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'consent' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.consent
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End consent
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.location_raw to db_log.location

    -- Start location
    err_section:='location-01';    err_schema:='db_log';    err_table:='location';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT location_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.location_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.location_raw WHERE location_raw_id IN 
            (SELECT location_raw_id FROM db_log.location WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.location)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.location) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT location_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'location_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.location_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT location_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'location' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.location
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End location
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.pids_per_ward_raw to db_log.pids_per_ward

    -- Start pids_per_ward
    err_section:='pids_per_ward-01';    err_schema:='db_log';    err_table:='pids_per_ward';

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT pids_per_ward_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.pids_per_ward_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.pids_per_ward_raw WHERE pids_per_ward_raw_id IN 
            (SELECT pids_per_ward_raw_id FROM db_log.pids_per_ward WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM db_log.pids_per_ward)
            )
         )
    AND (last_processing_nr!=(SELECT MAX(last_processing_nr) FROM db_log.pids_per_ward) -- if not yet compared and brought to the same level
	 OR last_processing_nr=max_last_pro_nr -- Same processing number as in another entity that was imported (again) at the same time
        )
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
    END LOOP;

    IF data_import_hist_every_dataset=1 THEN -- documentenion is switcht on
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT pids_per_ward_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'pids_per_ward_raw' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.pids_per_ward_raw
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    
        INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
        ( SELECT pids_per_ward_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'pids_per_ward' AS table_name, last_pro_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.pids_per_ward
        EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_pro_datetime, current_dataset_status, function_name FROM db_log.data_import_hist);
    END IF;
    -- End pids_per_ward
    -----------------------------------------------------------------------------------------------------------------

    -- calculation of the time period
    err_section:='BOTTOM-01';    err_schema:='/';    err_table:='/';
    SELECT res FROM pg_background_result(pg_background_launch('SELECT to_char(CURRENT_TIMESTAMP,''YYYY-MM-DD HH24:MI:SS.US'')'))  AS t(res TEXT) INTO timestamp_end;

    err_section:='BOTTOM-05';    err_schema:='/';    err_table:='/';
    SELECT EXTRACT(EPOCH FROM (to_timestamp(timestamp_end,'YYYY-MM-DD HH24:MI:SS.US') - to_timestamp(timestamp_start,'YYYY-MM-DD HH24:MI:SS.US'))), ' '||timestamp_start||' o '||timestamp_end INTO tmp_sec, temp;

    err_section:='BOTTOM-10';    err_schema:='db_log';    err_table:='data_import_hist';
    INSERT INTO db_log.data_import_hist (last_processing_nr, variable_name, schema_name, table_name, last_check_datetime, function_name, dataset_count, copy_time_in_sec, current_dataset_status)
    VALUES ( last_raw_pro_nr,'data_count_pro_all', 'db_log', 'take_over_last_check_date', last_pro_datetime, 'take_over_last_check_date', 0, tmp_sec, 'Count all Datasetzs '||temp );

    err_section:='BOTTOM-20';    err_schema:='/';    err_table:='/';
    RETURN 'Done db.take_over_last_check_date - last_raw_pro_nr:'||last_raw_pro_nr;

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

    RETURN 'Fehler db.take_over_last_check_date - '||SQLSTATE||' - last_raw_pro_nr:'||last_raw_pro_nr;
END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
-- Move to copy function - SELECT cron.schedule('*/1 * * * *', 'SELECT db.take_over_last_check_date();');
-----------------------------

