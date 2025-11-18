-------------- Tabelle für die einmalige berechnung der Referenzen für "Altdaten" --------------------- 
DO
$$
BEGIN
    IF NOT EXISTS ( -- Table exists
        SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'cds2db_in' AND table_name = 'temp_calculated_items'
    ) THEN

        CREATE TABLE IF NOT EXISTS cds2db_in.temp_calculated_items (
          cal_schema VARCHAR         -- Ziel für die Berechnung
          , cal_resource VARCHAR     -- Resourcce für welche etwas berechnet werden soll
          , cal_fhir_column VARCHAR  -- Spaltenname der FHIR ID
          , cal_fhir_id VARCHAR      -- FHIR ID auf die geändert werden soll
          , cal_calculated_column_name VARCHAR  -- Name der berechneten Spalte
          , cal_calculated_value VARCHAR        -- Wert der berechneten Spalte
          , cal_theme VARCHAR        -- Zur Info was berechnet wurde z.b. "calculated refs"
          , input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP -- Time at which data record was created
         );       

         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_schema IS 'Ziel für die Berechnung';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_resource IS 'Resourcce für welche etwas berechnet werden soll';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_fhir_column IS 'Spaltenname der FHIR ID';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_fhir_id IS 'FHIR ID auf die geändert werden soll';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_calculated_column_name IS 'Name der berechneten Spalte';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_calculated_value IS 'Wert der berechneten Spalte';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_theme IS 'Info was berechnet wurde';

         CREATE INDEX idx_temp_calculated_items_cal_fhir_id ON cds2db_in.temp_calculated_items USING btree (cal_fhir_id);

         GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.temp_calculated_items TO cds2db_user; -- Additional authorizations for testing
    END IF; -- Table exists

EXECUTE $f$
------------------------
-- Funktion um für Altdaten die berechneten Items in die Resourcen aus Hilfstabelle cds2db_in.temp_calculated_items zu übernehmen.
------------------------
CREATE OR REPLACE FUNCTION db.temp_700_calculated_olddata_items()
RETURNS VOID
SECURITY DEFINER
AS $inner$
DECLARE
    current_record record;
    temp VARCHAR;
    erg TEXT;
    status VARCHAR;
    num INT;
    num2 INT;
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
    err_pid VARCHAR;
    set_sem_erg BOOLEAN;
BEGIN
    err_section:='temp_700_calculated_olddata_items_break-01';    err_schema:='db';    err_table:='pg_sleep';
    SELECT pg_sleep(2) INTO temp; -- Time to inelize dynamic shared memory 

    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='temp_700_calculated_olddata_items_break-05';    err_schema:='db';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','ReadyToConnect','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / INTerrupted'); -- Normal Status are: WaitForCronJob--> Ongoing --> ReadyToConnect --> WaitForCronJob
        status='ReadyToConnect';
    END IF;

    SELECT pg_sleep(1) INTO temp; -- Time to inelize dynamic shared memory 

    err_section:='temp_700_calculated_olddata_items_break-10';    err_schema:='db_config';    err_table:='/';
    IF status like 'Ongoing%' THEN -- Notaus überprüfen
        err_section:='temp_700_calculated_olddata_items_break-15';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT count(1) INTO num FROM db_config.db_parameter WHERE parameter_name='max_process_time_set_ready';
        If num=1 THEN
            SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='max_process_time_set_ready';
        END IF;

        If num=0 THEN -- falls Parameter fehlt - initial setzen
            num:=5;
        END IF;

        -- Bisher Zeitspanne seit letztem start von ongoing - in Parametern angegebene Minuten überschritten
        err_section:='temp_700_calculated_olddata_items_break-20';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT round(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP-last_change_timestamp))) INTO num2
        FROM db_config.db_process_control WHERE pc_name = 'semaphor_cron_job_data_transfer';

        err_section:='temp_700_calculated_olddata_items_break-20';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing since '||num2||' sec - '||(num*60)||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''timepoINT_3_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        If num2>=(num*60) THEN
            status:='WaitForCronJob';
            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'' and pc_value!='''||status||''''
            ) ) AS t(res TEXT) INTO erg;
        END IF;
    END IF;
    err_section:='temp_700_calculated_olddata_items_break-22';    err_schema:='/';    err_table:='/';

    IF status in ('WaitForCronJob') THEN
        -- Langzeit Ongoin Info wieder zurück setzen

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Normal Ongoing'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='temp_700_calculated_olddata_items_break-START-24';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='temp_700_calculated_olddata_items_break-25';    err_schema:='db';    err_table:='temp_700_calculated_olddata_items_break()';

        -- Updates in die Resourcen übernehmen
        FOR current_record IN (SELECT DISTINCT cal_schema, cal_resource, cal_fhir_column, cal_fhir_id, cal_calculated_column_name, cal_calculated_value FROM cds2db_in.temp_calculated_items) LOOP

            err_section:='temp_700_calculated_olddata_items_break-30';    err_schema:='(DynSQL) '||current_record.cal_schema;    err_table:='(Dyn) '||current_record.cal_resource;

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE '||current_record.cal_schema||'.'||current_record.cal_resource||' SET '||current_record.cal_calculated_column_name||'='''||current_record.cal_calculated_value||''' WHERE '||current_record.cal_fhir_column||'='''||current_record.cal_fhir_id||''''
            ) ) AS t(res TEXT) INTO erg;

            err_section:='temp_700_calculated_olddata_items_break-35';    err_schema:='cds2db_in';    err_table:='temp_calculated_items';

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'DELETE FROM cds2db_in.temp_calculated_items WHERE cal_schema='''||current_record.cal_schema||''' AND cal_resource='''||current_record.cal_resource||''' AND cal_fhir_column='''||current_record.cal_fhir_column||''' AND cal_fhir_id='''||current_record.cal_fhir_id||''' AND cal_calculated_column_name='''||current_record.cal_calculated_column_name||''' AND cal_calculated_value='''||current_record.cal_calculated_value||''''
            ) ) AS t(res TEXT) INTO erg;
        END LOOP;

        -- ReadyToConnect (Pause) durchführen -----------------------
        err_section:='temp_700_calculated_olddata_items_break-50';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT count(1) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num=0 THEN -- falls Parameter fehlt - initial setzen
            insert INTo db_config.db_parameter (parameter_name, parameter_value, parameter_description)
            values ('pause_after_process_execution','5','Pause after copy process execution in second');
        END IF;

        err_section:='temp_700_calculated_olddata_items_break-52';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<5 then num:=5; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe INTervention zu geben
        If num>45 then num:=40; END IF; -- Wenn größer als JobINTerval - kleiner setzen um wieder in Takt zu kommen

        err_section:='temp_700_calculated_olddata_items_break-53';    err_schema:='system';    err_table:='Aufraeumen';

        -- Semaphore setzen das ReadyToConnect (Pause) gemacht werden kann weil alle Verarbeitungsschritte abgearbeitet sind
--        set_sem_erg:= db.data_transfer_start('db.cron_job_data_transfer'::VARCHAR, status::VARCHAR, TRUE);
        status:='ReadyToConnect';
        -- Semaphore setzen -----------------------------------------
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        SELECT pg_sleep(num) INTO temp;

        -- Semaphore wieder frei geben
        err_section:='temp_700_calculated_olddata_items_break-55';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Ongoing%'' and pc_value=''ReadyToConnect'' and pc_name=''semaphor_cron_job_data_transfer'''
        )) AS t(res TEXT) INTO erg;

        status:='WaitForCronJob';

        err_section:='temp_700_calculated_olddata_items_break-60';    err_schema:='/';    err_table:='/';
    END IF;
    err_section:='temp_700_calculated_olddata_items_break-60';    err_schema:='/';    err_table:='/';

    IF status in ('ReadyToConnect') THEN
        -- ReadyToConnect (Pause) durchführen
        err_section:='temp_700_calculated_olddata_items_break-65';    err_schema:='db_config';    err_table:='db_parameter';

        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<5 then num:=5; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe INTervention zu geben
        If num>45 then num:=40; END IF; -- Wenn größer als JobINTerval - kleiner setzen um wieder in Takt zu kommen

        SELECT pg_sleep(num) INTO temp;

        -- Semaphore wieder frei geben - ohne Rückgabe der SubProzessID
        err_section:='temp_700_calculated_olddata_items_break-70';    err_schema:='db_config';    err_table:='db_process_control';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Ongoing%'' and pc_value=''ReadyToConnect'' and pc_name=''semaphor_cron_job_data_transfer'''
        )) AS t(res TEXT) INTO erg;
    END IF;
    err_section:='temp_700_calculated_olddata_items_break-80';    err_schema:='/';    err_table:='/';
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.temp_700_calculated_olddata_items_break()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' ||err_table||' lastErg:'||erg AS VARCHAR), -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    -- Semapohore wegen Fehler anhalten
    SELECT res FROM public.pg_background_result(public.pg_background_launch(
    'UPDATE db_config.db_process_control SET pc_value=''INTerrupted wegen Fehler in '||err_section||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Ongoing%'' and pc_value=''ReadyToConnect'' and pc_name=''semaphor_cron_job_data_transfer'''
    )) AS t(res TEXT) INTO erg;
END;
$inner$ LANGUAGE plpgsql; -- db.temp_700_calculated_olddata_items

$f$;
------------------------
GRANT EXECUTE ON FUNCTION db.temp_700_calculated_olddata_items() TO cds2db_user;

END
$$;
