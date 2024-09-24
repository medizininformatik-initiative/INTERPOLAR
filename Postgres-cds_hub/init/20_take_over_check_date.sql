-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2024-08-21 09:59:34
-- Rights definition file size        : 15036 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2024-08-28 11:51:18
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
RETURNS VOID AS $$
DECLARE
    current_record record;
    new_last_pro_nr INT; -- New processing number for these sync
    max_last_pro_nr INT; -- Last processing number in core data
    last_raw_pro_nr INT; -- Last processing number in raw data - last new dataimport (offset)
BEGIN
    -- Take over last check datetime Functionname: take_over_last_check_date the last_pro_nr - From: db_log (raw) -> To: db_log
    
    -- Last import Nr in raw-data
    SELECT MAX(last_processing_nr) INTO last_raw_pro_nr FROM db_log.data_import_hist WHERE table_name like '%_raw' AND schema_name='db_log';

    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.encounter_raw to db_log.encounter

    -- Start encounter
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.encounter;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT encounter_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.encounter_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.encounter_raw WHERE encounter_raw_id IN 
            (SELECT encounter_raw_id FROM db_log.encounter WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.encounter
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE encounter_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.encounter_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE encounter_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT encounter_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'encounter_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.encounter_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT encounter_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'encounter' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.encounter
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End encounter
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.patient_raw to db_log.patient

    -- Start patient
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.patient;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT patient_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.patient_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.patient_raw WHERE patient_raw_id IN 
            (SELECT patient_raw_id FROM db_log.patient WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.patient
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE patient_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.patient_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE patient_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT patient_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.patient_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT patient_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'patient' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.patient
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End patient
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.condition_raw to db_log.condition

    -- Start condition
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.condition;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT condition_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.condition_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.condition_raw WHERE condition_raw_id IN 
            (SELECT condition_raw_id FROM db_log.condition WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.condition
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE condition_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.condition_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE condition_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT condition_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'condition_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.condition_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT condition_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'condition' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.condition
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End condition
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medication_raw to db_log.medication

    -- Start medication
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.medication;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medication_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medication_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medication_raw WHERE medication_raw_id IN 
            (SELECT medication_raw_id FROM db_log.medication WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.medication
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medication_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.medication_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medication_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medication_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medication_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medication_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medication_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medication' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medication
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End medication
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationrequest_raw to db_log.medicationrequest

    -- Start medicationrequest
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.medicationrequest;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medicationrequest_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medicationrequest_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationrequest_raw WHERE medicationrequest_raw_id IN 
            (SELECT medicationrequest_raw_id FROM db_log.medicationrequest WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.medicationrequest
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medicationrequest_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.medicationrequest_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medicationrequest_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medicationrequest_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationrequest_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationrequest_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medicationrequest_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationrequest' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationrequest
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End medicationrequest
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationadministration_raw to db_log.medicationadministration

    -- Start medicationadministration
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.medicationadministration;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medicationadministration_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medicationadministration_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationadministration_raw WHERE medicationadministration_raw_id IN 
            (SELECT medicationadministration_raw_id FROM db_log.medicationadministration WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.medicationadministration
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medicationadministration_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.medicationadministration_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medicationadministration_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medicationadministration_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationadministration_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationadministration_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medicationadministration_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationadministration' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationadministration
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End medicationadministration
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.medicationstatement_raw to db_log.medicationstatement

    -- Start medicationstatement
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.medicationstatement;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT medicationstatement_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.medicationstatement_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.medicationstatement_raw WHERE medicationstatement_raw_id IN 
            (SELECT medicationstatement_raw_id FROM db_log.medicationstatement WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.medicationstatement
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE medicationstatement_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.medicationstatement_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE medicationstatement_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medicationstatement_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationstatement_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationstatement_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT medicationstatement_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'medicationstatement' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.medicationstatement
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End medicationstatement
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.observation_raw to db_log.observation

    -- Start observation
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.observation;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT observation_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.observation_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.observation_raw WHERE observation_raw_id IN 
            (SELECT observation_raw_id FROM db_log.observation WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.observation
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE observation_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.observation_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE observation_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT observation_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'observation_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.observation_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT observation_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'observation' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.observation
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End observation
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.diagnosticreport_raw to db_log.diagnosticreport

    -- Start diagnosticreport
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.diagnosticreport;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT diagnosticreport_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.diagnosticreport_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.diagnosticreport_raw WHERE diagnosticreport_raw_id IN 
            (SELECT diagnosticreport_raw_id FROM db_log.diagnosticreport WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.diagnosticreport
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE diagnosticreport_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.diagnosticreport_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE diagnosticreport_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT diagnosticreport_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'diagnosticreport_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.diagnosticreport_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT diagnosticreport_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'diagnosticreport' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.diagnosticreport
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End diagnosticreport
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.servicerequest_raw to db_log.servicerequest

    -- Start servicerequest
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.servicerequest;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT servicerequest_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.servicerequest_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.servicerequest_raw WHERE servicerequest_raw_id IN 
            (SELECT servicerequest_raw_id FROM db_log.servicerequest WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.servicerequest
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE servicerequest_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.servicerequest_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE servicerequest_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT servicerequest_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'servicerequest_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.servicerequest_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT servicerequest_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'servicerequest' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.servicerequest
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End servicerequest
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.procedure_raw to db_log.procedure

    -- Start procedure
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.procedure;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT procedure_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.procedure_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.procedure_raw WHERE procedure_raw_id IN 
            (SELECT procedure_raw_id FROM db_log.procedure WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.procedure
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE procedure_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.procedure_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE procedure_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT procedure_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'procedure_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.procedure_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT procedure_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'procedure' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.procedure
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End procedure
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.consent_raw to db_log.consent

    -- Start consent
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.consent;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT consent_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.consent_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.consent_raw WHERE consent_raw_id IN 
            (SELECT consent_raw_id FROM db_log.consent WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.consent
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE consent_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.consent_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE consent_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT consent_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'consent_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.consent_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT consent_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'consent' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.consent
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End consent
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.location_raw to db_log.location

    -- Start location
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.location;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT location_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.location_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.location_raw WHERE location_raw_id IN 
            (SELECT location_raw_id FROM db_log.location WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.location
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE location_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.location_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE location_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT location_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'location_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.location_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT location_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'location' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.location
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End location
    -----------------------------------------------------------------------------------------------------------------
    -- Transfer last check date, last_processing_nr (new) from raw to data - if no data changes have occurred
    -- from  db_log.pids_per_ward_raw to db_log.pids_per_ward

    -- Start pids_per_ward
    SELECT MAX(last_processing_nr) INTO max_last_pro_nr FROM db_log.pids_per_ward;

    -- If new dataimports in raw then set process nr of checking
    FOR current_record IN (
    SELECT pids_per_ward_raw_id AS id, last_check_datetime AS lcd, current_dataset_status AS cds
    FROM db_log.pids_per_ward_raw WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM db_log.pids_per_ward_raw WHERE pids_per_ward_raw_id IN 
            (SELECT pids_per_ward_raw_id FROM db_log.pids_per_ward WHERE last_processing_nr=max_last_pro_nr
            )
         )
    AND last_processing_nr!=max_last_pro_nr -- if not yet compared and brought to the same level
    )
        LOOP
            BEGIN
                -- Obtain a new processing number if necessary
                IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

                UPDATE db_log.pids_per_ward
                SET last_check_datetime = current_record.lcd
                , current_dataset_status = current_record.cds
                , last_processing_nr = new_last_pro_nr
                WHERE pids_per_ward_raw_id = current_record.id;

                -- sync done
                UPDATE db_log.pids_per_ward_raw
                SET last_processing_nr = new_last_pro_nr
                WHERE pids_per_ward_raw_id = current_record.id;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
    END LOOP;

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT pids_per_ward_raw_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'pids_per_ward_raw' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.pids_per_ward_raw
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );

    INSERT INTO db_log.data_import_hist (table_primary_key, last_processing_nr, schema_name, table_name, last_check_datetime, current_dataset_status, function_name)
    ( SELECT pids_per_ward_id AS table_primary_key, last_processing_nr, 'db_log' AS schema_name, 'pids_per_ward' AS table_name, last_check_datetime, current_dataset_status, 'take_over_last_check_date' FROM db_log.pids_per_ward
    EXCEPT SELECT table_primary_key, last_processing_nr,schema_name, table_name, last_check_datetime, current_dataset_status, function_name FROM db_log.data_import_hist
    );
    -- End pids_per_ward
    -----------------------------------------------------------------------------------------------------------------

END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
-- Move to copy function - SELECT cron.schedule('*/1 * * * *', 'SELECT db.take_over_last_check_date();');
-----------------------------



