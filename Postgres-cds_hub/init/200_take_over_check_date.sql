-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-04-29 15:00:37
-- Rights definition file size        : 15631 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2025-04-29 15:06:21
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  200_take_over_check_date.sql
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
    max_last_pro_nr INT:=0; -- Last processing number over all entities
    max_ent_pro_nr INT:=0;  -- Max processing number from a entiti
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
    copy_fhir_metadata_from_raw_to_typed VARCHAR;
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

    ---- Start check db_log.encounter_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.encounter_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.encounter;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.encounter_raw r, db_log.encounter_raw r2, db_log.encounter t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.encounter_raw_id=t.encounter_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''encounter_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.encounter ----

    ---- Start check db_log.patient_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.patient_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.patient;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.patient_raw r, db_log.patient_raw r2, db_log.patient t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.patient_raw_id=t.patient_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''patient_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.patient ----

    ---- Start check db_log.condition_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.condition_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.condition;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.condition_raw r, db_log.condition_raw r2, db_log.condition t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.condition_raw_id=t.condition_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''condition_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.condition ----

    ---- Start check db_log.medication_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.medication_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.medication;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.medication_raw r, db_log.medication_raw r2, db_log.medication t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.medication_raw_id=t.medication_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medication_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medication ----

    ---- Start check db_log.medicationrequest_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.medicationrequest_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.medicationrequest;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.medicationrequest_raw r, db_log.medicationrequest_raw r2, db_log.medicationrequest t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.medicationrequest_raw_id=t.medicationrequest_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medicationrequest_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medicationrequest ----

    ---- Start check db_log.medicationadministration_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.medicationadministration_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.medicationadministration;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.medicationadministration_raw r, db_log.medicationadministration_raw r2, db_log.medicationadministration t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.medicationadministration_raw_id=t.medicationadministration_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medicationadministration_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medicationadministration ----

    ---- Start check db_log.medicationstatement_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.medicationstatement_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.medicationstatement;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.medicationstatement_raw r, db_log.medicationstatement_raw r2, db_log.medicationstatement t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.medicationstatement_raw_id=t.medicationstatement_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''medicationstatement_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.medicationstatement ----

    ---- Start check db_log.observation_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.observation_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.observation;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.observation_raw r, db_log.observation_raw r2, db_log.observation t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.observation_raw_id=t.observation_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''observation_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.observation ----

    ---- Start check db_log.diagnosticreport_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.diagnosticreport_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.diagnosticreport;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.diagnosticreport_raw r, db_log.diagnosticreport_raw r2, db_log.diagnosticreport t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.diagnosticreport_raw_id=t.diagnosticreport_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''diagnosticreport_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.diagnosticreport ----

    ---- Start check db_log.servicerequest_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.servicerequest_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.servicerequest;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.servicerequest_raw r, db_log.servicerequest_raw r2, db_log.servicerequest t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.servicerequest_raw_id=t.servicerequest_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''servicerequest_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.servicerequest ----

    ---- Start check db_log.procedure_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.procedure_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.procedure;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.procedure_raw r, db_log.procedure_raw r2, db_log.procedure t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.procedure_raw_id=t.procedure_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''procedure_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.procedure ----

    ---- Start check db_log.consent_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.consent_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.consent;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.consent_raw r, db_log.consent_raw r2, db_log.consent t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.consent_raw_id=t.consent_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''consent_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.consent ----

    ---- Start check db_log.location_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.location_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.location;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.location_raw r, db_log.location_raw r2, db_log.location t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.location_raw_id=t.location_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''location_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.location ----

    ---- Start check db_log.pids_per_ward_raw ----
    err_section:='CHECK-15';    err_schema:='db_log';    err_table:='db_log.pids_per_ward_raw';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM db_log.pids_per_ward;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;

    IF data_count_pro_all=0 AND COALESCE(max_ent_pro_nr,0)!=0 THEN -- Nur wenn bisher keine Datensätze gefunden wurden diese Entität überprüfen - sobald eine E. gefunden wurde über alle berechnen
        SELECT COUNT(1) INTO data_count_pro_all
    	FROM db_log.pids_per_ward_raw r, db_log.pids_per_ward_raw r2, db_log.pids_per_ward t
    	WHERE r.last_processing_nr=r2.last_processing_nr AND r2.pids_per_ward_raw_id=t.pids_per_ward_raw_id
        AND t.last_processing_nr=max_ent_pro_nr  AND r.last_processing_nr!=max_ent_pro_nr;

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', ''pids_per_ward_raw'', ''db_log'', ''max_ent_pro_nr / data_count_pro_all :'||max_ent_pro_nr||' / '||data_count_pro_all||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;
    END IF;
    ---- End check db_log.pids_per_ward ----


--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''data_count_pro_all / max_last_pro_nr:'||data_count_pro_all||' / '||max_last_pro_nr||''' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

    IF data_count_pro_all>0 THEN -- Complete execution is only necessary if new data records are available - otherwise no database access is necessary
        -- Copy FHIR metadata from raw to typed
        err_section:='MAIN-12';    err_schema:='db_log';    err_table:='copy_fhir_metadata_from_raw_to_typed';
        SELECT parameter_value INTO copy_fhir_metadata_from_raw_to_typed FROM db_config.db_parameter WHERE parameter_name='copy_fhir_metadata_from_raw_to_typed';
        IF copy_fhir_metadata_from_raw_to_typed like 'Y%' THEN
                        ---- Start check db_log.encounter ---- Update FHIR Metadata
            UPDATE db_log.encounter z SET
                                z.enc_meta_versionid = q.enc_meta_versionid,
                z.enc_meta_lastupdated = q.enc_meta_lastupdated,
                z.enc_meta_profile = q.enc_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.encounter_raw q
            WHERE z.encounter_raw_id = q.encounter_raw_id AND (
                                z.enc_meta_versionid != q.enc_meta_versionid OR
                z.enc_meta_lastupdated != q.enc_meta_lastupdated OR
                z.enc_meta_profile != q.enc_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.encounter ---- Update FHIR Metadata

            ---- Start check db_log.patient ---- Update FHIR Metadata
            UPDATE db_log.patient z SET
                                z.pat_meta_versionid = q.pat_meta_versionid,
                z.pat_meta_lastupdated = q.pat_meta_lastupdated,
                z.pat_meta_profile = q.pat_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.patient_raw q
            WHERE z.patient_raw_id = q.patient_raw_id AND (
                                z.pat_meta_versionid != q.pat_meta_versionid OR
                z.pat_meta_lastupdated != q.pat_meta_lastupdated OR
                z.pat_meta_profile != q.pat_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.patient ---- Update FHIR Metadata

            ---- Start check db_log.condition ---- Update FHIR Metadata
            UPDATE db_log.condition z SET
                                z.con_meta_versionid = q.con_meta_versionid,
                z.con_meta_lastupdated = q.con_meta_lastupdated,
                z.con_meta_profile = q.con_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.condition_raw q
            WHERE z.condition_raw_id = q.condition_raw_id AND (
                                z.con_meta_versionid != q.con_meta_versionid OR
                z.con_meta_lastupdated != q.con_meta_lastupdated OR
                z.con_meta_profile != q.con_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.condition ---- Update FHIR Metadata

            ---- Start check db_log.medication ---- Update FHIR Metadata
            UPDATE db_log.medication z SET
                                z.med_meta_versionid = q.med_meta_versionid,
                z.med_meta_lastupdated = q.med_meta_lastupdated,
                z.med_meta_profile = q.med_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.medication_raw q
            WHERE z.medication_raw_id = q.medication_raw_id AND (
                                z.med_meta_versionid != q.med_meta_versionid OR
                z.med_meta_lastupdated != q.med_meta_lastupdated OR
                z.med_meta_profile != q.med_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.medication ---- Update FHIR Metadata

            ---- Start check db_log.medicationrequest ---- Update FHIR Metadata
            UPDATE db_log.medicationrequest z SET
                                z.medreq_meta_versionid = q.medreq_meta_versionid,
                z.medreq_meta_lastupdated = q.medreq_meta_lastupdated,
                z.medreq_meta_profile = q.medreq_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.medicationrequest_raw q
            WHERE z.medicationrequest_raw_id = q.medicationrequest_raw_id AND (
                                z.medreq_meta_versionid != q.medreq_meta_versionid OR
                z.medreq_meta_lastupdated != q.medreq_meta_lastupdated OR
                z.medreq_meta_profile != q.medreq_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.medicationrequest ---- Update FHIR Metadata

            ---- Start check db_log.medicationadministration ---- Update FHIR Metadata
            UPDATE db_log.medicationadministration z SET
                                z.medadm_meta_versionid = q.medadm_meta_versionid,
                z.medadm_meta_lastupdated = q.medadm_meta_lastupdated,
                z.medadm_meta_profile = q.medadm_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.medicationadministration_raw q
            WHERE z.medicationadministration_raw_id = q.medicationadministration_raw_id AND (
                                z.medadm_meta_versionid != q.medadm_meta_versionid OR
                z.medadm_meta_lastupdated != q.medadm_meta_lastupdated OR
                z.medadm_meta_profile != q.medadm_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.medicationadministration ---- Update FHIR Metadata

            ---- Start check db_log.medicationstatement ---- Update FHIR Metadata
            UPDATE db_log.medicationstatement z SET
                                z.medstat_meta_versionid = q.medstat_meta_versionid,
                z.medstat_meta_lastupdated = q.medstat_meta_lastupdated,
                z.medstat_meta_profile = q.medstat_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.medicationstatement_raw q
            WHERE z.medicationstatement_raw_id = q.medicationstatement_raw_id AND (
                                z.medstat_meta_versionid != q.medstat_meta_versionid OR
                z.medstat_meta_lastupdated != q.medstat_meta_lastupdated OR
                z.medstat_meta_profile != q.medstat_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.medicationstatement ---- Update FHIR Metadata

            ---- Start check db_log.observation ---- Update FHIR Metadata
            UPDATE db_log.observation z SET
                                z.obs_meta_versionid = q.obs_meta_versionid,
                z.obs_meta_lastupdated = q.obs_meta_lastupdated,
                z.obs_meta_profile = q.obs_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.observation_raw q
            WHERE z.observation_raw_id = q.observation_raw_id AND (
                                z.obs_meta_versionid != q.obs_meta_versionid OR
                z.obs_meta_lastupdated != q.obs_meta_lastupdated OR
                z.obs_meta_profile != q.obs_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.observation ---- Update FHIR Metadata

            ---- Start check db_log.diagnosticreport ---- Update FHIR Metadata
            UPDATE db_log.diagnosticreport z SET
                                z.diagrep_meta_versionid = q.diagrep_meta_versionid,
                z.diagrep_meta_lastupdated = q.diagrep_meta_lastupdated,
                z.diagrep_meta_profile = q.diagrep_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.diagnosticreport_raw q
            WHERE z.diagnosticreport_raw_id = q.diagnosticreport_raw_id AND (
                                z.diagrep_meta_versionid != q.diagrep_meta_versionid OR
                z.diagrep_meta_lastupdated != q.diagrep_meta_lastupdated OR
                z.diagrep_meta_profile != q.diagrep_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.diagnosticreport ---- Update FHIR Metadata

            ---- Start check db_log.servicerequest ---- Update FHIR Metadata
            UPDATE db_log.servicerequest z SET
                                z.servreq_meta_versionid = q.servreq_meta_versionid,
                z.servreq_meta_lastupdated = q.servreq_meta_lastupdated,
                z.servreq_meta_profile = q.servreq_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.servicerequest_raw q
            WHERE z.servicerequest_raw_id = q.servicerequest_raw_id AND (
                                z.servreq_meta_versionid != q.servreq_meta_versionid OR
                z.servreq_meta_lastupdated != q.servreq_meta_lastupdated OR
                z.servreq_meta_profile != q.servreq_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.servicerequest ---- Update FHIR Metadata

            ---- Start check db_log.procedure ---- Update FHIR Metadata
            UPDATE db_log.procedure z SET
                                z.proc_meta_versionid = q.proc_meta_versionid,
                z.proc_meta_lastupdated = q.proc_meta_lastupdated,
                z.proc_meta_profile = q.proc_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.procedure_raw q
            WHERE z.procedure_raw_id = q.procedure_raw_id AND (
                                z.proc_meta_versionid != q.proc_meta_versionid OR
                z.proc_meta_lastupdated != q.proc_meta_lastupdated OR
                z.proc_meta_profile != q.proc_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.procedure ---- Update FHIR Metadata

            ---- Start check db_log.consent ---- Update FHIR Metadata
            UPDATE db_log.consent z SET
                                z.cons_meta_versionid = q.cons_meta_versionid,
                z.cons_meta_lastupdated = q.cons_meta_lastupdated,
                z.cons_meta_profile = q.cons_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.consent_raw q
            WHERE z.consent_raw_id = q.consent_raw_id AND (
                                z.cons_meta_versionid != q.cons_meta_versionid OR
                z.cons_meta_lastupdated != q.cons_meta_lastupdated OR
                z.cons_meta_profile != q.cons_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.consent ---- Update FHIR Metadata

            ---- Start check db_log.location ---- Update FHIR Metadata
            UPDATE db_log.location z SET
                                z.loc_meta_versionid = q.loc_meta_versionid,
                z.loc_meta_lastupdated = q.loc_meta_lastupdated,
                z.loc_meta_profile = q.loc_meta_profile,
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.location_raw q
            WHERE z.location_raw_id = q.location_raw_id AND (
                                z.loc_meta_versionid != q.loc_meta_versionid OR
                z.loc_meta_lastupdated != q.loc_meta_lastupdated OR
                z.loc_meta_profile != q.loc_meta_profile OR
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.location ---- Update FHIR Metadata

            ---- Start check db_log.pids_per_ward ---- Update FHIR Metadata
            UPDATE db_log.pids_per_ward z SET
                
                z.last_check_datetime = q.last_check_datetime
            FROM db_log.pids_per_ward_raw q
            WHERE z.pids_per_ward_raw_id = q.pids_per_ward_raw_id AND (
                
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check db_log.pids_per_ward ---- Update FHIR Metadata

        END IF;

        -- Main takeover
        err_section:='MAIN-15';    err_schema:='db_config';    err_table:='db_parameter';
	-- Get value for documentation of each individual data record
        SELECT COUNT(1) INTO data_import_hist_every_dataset FROM db_config.db_parameter WHERE parameter_name='data_import_hist_every_dataset' and parameter_value='yes';

    	-- Number of data records then status have to be set
    	SELECT COALESCE(parameter_value::INT,10) INTO data_count_last_status_max FROM db_config.db_parameter WHERE parameter_name='number_of_data_records_after_which_the_status_is_updated';

        err_section:='MAIN-20';    err_schema:='db_config';    err_table:='db_process_control';
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

        IF new_last_pro_nr IS NULL THEN SELECT nextval('db.db_seq') INTO new_last_pro_nr; END IF;

        err_section:='MAIN-30';    err_schema:='db_log';    err_table:='lpn_collection';

--/*Test*/SELECT res FROM pg_background_result(pg_background_launch(
--/*Test*/ 'INSERT INTO db.data_import_hist (function_name, table_name, schema_name, variable_name ) VALUES ( ''take_over_check_data'', '''||err_section||' - '||err_table||''', '''||err_schema||''', ''Vor Einzelnen Tabellen'' );'
--/*Test*/))  AS t(res TEXT) INTO erg;

        ---------------------------------------------------------------------------------------------
        CREATE TEMP TABLE lpn_collection
        ON COMMIT DROP
        AS (
            SELECT DISTINCT LPN FROM (
                SELECT -1 AS LPN
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.encounter_raw r, (SELECT encounter_raw_id FROM db_log.encounter WHERE last_processing_nr=max_last_pro_nr) t WHERE r.encounter_raw_id=t.encounter_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.patient_raw r, (SELECT patient_raw_id FROM db_log.patient WHERE last_processing_nr=max_last_pro_nr) t WHERE r.patient_raw_id=t.patient_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.condition_raw r, (SELECT condition_raw_id FROM db_log.condition WHERE last_processing_nr=max_last_pro_nr) t WHERE r.condition_raw_id=t.condition_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.medication_raw r, (SELECT medication_raw_id FROM db_log.medication WHERE last_processing_nr=max_last_pro_nr) t WHERE r.medication_raw_id=t.medication_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.medicationrequest_raw r, (SELECT medicationrequest_raw_id FROM db_log.medicationrequest WHERE last_processing_nr=max_last_pro_nr) t WHERE r.medicationrequest_raw_id=t.medicationrequest_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.medicationadministration_raw r, (SELECT medicationadministration_raw_id FROM db_log.medicationadministration WHERE last_processing_nr=max_last_pro_nr) t WHERE r.medicationadministration_raw_id=t.medicationadministration_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.medicationstatement_raw r, (SELECT medicationstatement_raw_id FROM db_log.medicationstatement WHERE last_processing_nr=max_last_pro_nr) t WHERE r.medicationstatement_raw_id=t.medicationstatement_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.observation_raw r, (SELECT observation_raw_id FROM db_log.observation WHERE last_processing_nr=max_last_pro_nr) t WHERE r.observation_raw_id=t.observation_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.diagnosticreport_raw r, (SELECT diagnosticreport_raw_id FROM db_log.diagnosticreport WHERE last_processing_nr=max_last_pro_nr) t WHERE r.diagnosticreport_raw_id=t.diagnosticreport_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.servicerequest_raw r, (SELECT servicerequest_raw_id FROM db_log.servicerequest WHERE last_processing_nr=max_last_pro_nr) t WHERE r.servicerequest_raw_id=t.servicerequest_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.procedure_raw r, (SELECT procedure_raw_id FROM db_log.procedure WHERE last_processing_nr=max_last_pro_nr) t WHERE r.procedure_raw_id=t.procedure_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.consent_raw r, (SELECT consent_raw_id FROM db_log.consent WHERE last_processing_nr=max_last_pro_nr) t WHERE r.consent_raw_id=t.consent_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.location_raw r, (SELECT location_raw_id FROM db_log.location WHERE last_processing_nr=max_last_pro_nr) t WHERE r.location_raw_id=t.location_raw_id
                UNION ALL SELECT last_processing_nr AS lpn FROM db_log.pids_per_ward_raw r, (SELECT pids_per_ward_raw_id FROM db_log.pids_per_ward WHERE last_processing_nr=max_last_pro_nr) t WHERE r.pids_per_ward_raw_id=t.pids_per_ward_raw_id
            )
        );

            ----------------- Update for encounter_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='encounter';
	    UPDATE db_log.encounter SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE encounter_raw_id IN (SELECT encounter_raw_ID FROM db_log.encounter_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='encounter_raw';
            UPDATE db_log.encounter_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE encounter_raw_id IN (SELECT encounter_raw_ID FROM db_log.encounter_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for patient_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='patient';
	    UPDATE db_log.patient SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE patient_raw_id IN (SELECT patient_raw_ID FROM db_log.patient_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='patient_raw';
            UPDATE db_log.patient_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE patient_raw_id IN (SELECT patient_raw_ID FROM db_log.patient_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for condition_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='condition';
	    UPDATE db_log.condition SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE condition_raw_id IN (SELECT condition_raw_ID FROM db_log.condition_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='condition_raw';
            UPDATE db_log.condition_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE condition_raw_id IN (SELECT condition_raw_ID FROM db_log.condition_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for medication_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='medication';
	    UPDATE db_log.medication SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medication_raw_id IN (SELECT medication_raw_ID FROM db_log.medication_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='medication_raw';
            UPDATE db_log.medication_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medication_raw_id IN (SELECT medication_raw_ID FROM db_log.medication_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for medicationrequest_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='medicationrequest';
	    UPDATE db_log.medicationrequest SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medicationrequest_raw_id IN (SELECT medicationrequest_raw_ID FROM db_log.medicationrequest_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='medicationrequest_raw';
            UPDATE db_log.medicationrequest_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medicationrequest_raw_id IN (SELECT medicationrequest_raw_ID FROM db_log.medicationrequest_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for medicationadministration_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='medicationadministration';
	    UPDATE db_log.medicationadministration SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medicationadministration_raw_id IN (SELECT medicationadministration_raw_ID FROM db_log.medicationadministration_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='medicationadministration_raw';
            UPDATE db_log.medicationadministration_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medicationadministration_raw_id IN (SELECT medicationadministration_raw_ID FROM db_log.medicationadministration_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for medicationstatement_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='medicationstatement';
	    UPDATE db_log.medicationstatement SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medicationstatement_raw_id IN (SELECT medicationstatement_raw_ID FROM db_log.medicationstatement_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='medicationstatement_raw';
            UPDATE db_log.medicationstatement_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE medicationstatement_raw_id IN (SELECT medicationstatement_raw_ID FROM db_log.medicationstatement_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for observation_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='observation';
	    UPDATE db_log.observation SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE observation_raw_id IN (SELECT observation_raw_ID FROM db_log.observation_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='observation_raw';
            UPDATE db_log.observation_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE observation_raw_id IN (SELECT observation_raw_ID FROM db_log.observation_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for diagnosticreport_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='diagnosticreport';
	    UPDATE db_log.diagnosticreport SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE diagnosticreport_raw_id IN (SELECT diagnosticreport_raw_ID FROM db_log.diagnosticreport_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='diagnosticreport_raw';
            UPDATE db_log.diagnosticreport_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE diagnosticreport_raw_id IN (SELECT diagnosticreport_raw_ID FROM db_log.diagnosticreport_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for servicerequest_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='servicerequest';
	    UPDATE db_log.servicerequest SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE servicerequest_raw_id IN (SELECT servicerequest_raw_ID FROM db_log.servicerequest_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='servicerequest_raw';
            UPDATE db_log.servicerequest_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE servicerequest_raw_id IN (SELECT servicerequest_raw_ID FROM db_log.servicerequest_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for procedure_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='procedure';
	    UPDATE db_log.procedure SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE procedure_raw_id IN (SELECT procedure_raw_ID FROM db_log.procedure_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='procedure_raw';
            UPDATE db_log.procedure_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE procedure_raw_id IN (SELECT procedure_raw_ID FROM db_log.procedure_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for consent_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='consent';
	    UPDATE db_log.consent SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE consent_raw_id IN (SELECT consent_raw_ID FROM db_log.consent_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='consent_raw';
            UPDATE db_log.consent_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE consent_raw_id IN (SELECT consent_raw_ID FROM db_log.consent_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for location_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='location';
	    UPDATE db_log.location SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE location_raw_id IN (SELECT location_raw_ID FROM db_log.location_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='location_raw';
            UPDATE db_log.location_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE location_raw_id IN (SELECT location_raw_ID FROM db_log.location_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
            ----------------- Update for pids_per_ward_raw ----------------------------------
            --err_section:='UPDATE-35';    err_schema:='db_log';    err_table:='pids_per_ward';
	    UPDATE db_log.pids_per_ward SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE pids_per_ward_raw_id IN (SELECT pids_per_ward_raw_ID FROM db_log.pids_per_ward_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='db_log';    err_table:='pids_per_ward_raw';
            UPDATE db_log.pids_per_ward_raw SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE pids_per_ward_raw_id IN (SELECT pids_per_ward_raw_ID FROM db_log.pids_per_ward_raw t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

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

