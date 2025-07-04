----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.cron_job_data_transfer()
RETURNS VOID
SECURITY DEFINER
AS $$
DECLARE
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
    err_section:='cron_job_data_transfer_break-01';    err_schema:='';    err_table:='pg_sleep';
    SELECT pg_sleep(2) INTO temp; -- Time to inelize dynamic shared memory 

    -- Document changes to the database
    err_section:='cron_job_data_transfer_break-02';    err_schema:='db_config';    err_table:='db.log_table_view_structure';
    SELECT db.log_table_view_structure() INTO erg;

    -- Doppelt angelegte Cron-Jobs deaktivieren
    err_section:='cron_job_data_transfer_break-03';    err_schema:='cron';    err_table:='job';
    UPDATE cron.job m SET active = FALSE WHERE m.command in
    (select i.command as t from (select command, count(1) anz from cron.job group by command) i where anz>1)
    and m.jobid not in (select min(f.jobid) from cron.job f where f.command in (select i.command as t from (select command, count(1) anz from cron.job group by       command) i where anz>1));

    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='cron_job_data_transfer_break-05';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','ReadyToConnect','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / INTerrupted'); -- Normal Status are: WaitForCronJob--> Ongoing --> ReadyToConnect --> WaitForCronJob
        status='ReadyToConnect';
    END IF;

    -- db.cron_job_data_transfer nur ausführen wenn auch durch postgre cron aktuell direkt gestartet und nicht im nachhinein nachgeholt (cron job startet immer zur vollen Minute)
    num:=to_char(CURRENT_TIMESTAMP,'SS')::INT;
    IF num>5 THEN
        status:='cron_job_data_transfer nicht ausführen';
    END IF;

    SELECT pg_sleep(1) INTO temp; -- Time to inelize dynamic shared memory 

    err_section:='cron_job_data_transfer-10';    err_schema:='db_config';    err_table:='/';
    IF status like 'Ongoing%' THEN -- Notaus überprüfen
        err_section:='cron_job_data_transfer-15';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT count(1) INTO num FROM db_config.db_parameter WHERE parameter_name='max_process_time_set_ready';
        If num=1 THEN
            SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='max_process_time_set_ready';
        END IF;

        If num=0 THEN -- falls Parameter fehlt - initial setzen
            num:=5;
        END IF;

        -- Bisher Zeitspanne seit letztem start von ongoing - in Parametern angegebene Minuten überschritten
        err_section:='cron_job_data_transfer-20';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT round(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP-last_change_timestamp))) INTO num2
        FROM db_config.db_process_control WHERE pc_name = 'semaphor_cron_job_data_transfer';

        err_section:='cron_job_data_transfer-20';    err_schema:='db_config';    err_table:='db_process_control';
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
    err_section:='cron_job_data_transfer-22';    err_schema:='/';    err_table:='/';

    IF status in ('WaitForCronJob') THEN
        -- Langzeit Ongoin Info wieder zurück setzen

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Normal Ongoing'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='1/8 db.add_hist_raw_records()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-23';    err_schema:='db';    err_table:='add_hist_raw_records()';

        -- FHIR Data db_log(Hist) -> cds2db_in
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.add_hist_raw_records()'
        )) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='2/8 db.copy_raw_cds_in_to_db_log()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-25';    err_schema:='db';    err_table:='copy_raw_cds_in_to_db_log()';

        -- FHIR Data cds2db_in -> db_log
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.copy_raw_cds_in_to_db_log()'
        )) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='3/8 db.copy_type_cds_in_to_db_log()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-30';    err_schema:='db';    err_table:='copy_type_cds_in_to_db_log()';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.copy_type_cds_in_to_db_log()'
        )) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='4/8 db.take_over_last_check_date()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-35';    err_schema:='db';    err_table:='take_over_last_check_date()';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.take_over_last_check_date()'
        )) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='5/8 db.copy_fe_dp_in_to_db_log()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-40';    err_schema:='db';    err_table:='copy_fe_dp_in_to_db_log()';

        -- Study data
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.copy_fe_dp_in_to_db_log()'
        )) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='6/8 db.copy_fe_fe_in_to_db_log()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-42';    err_schema:='db';    err_table:='copy_fe_fe_in_to_db_log()';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.copy_fe_fe_in_to_db_log()'
        )) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='7/8 db.copy_submodules_dp_in_to_db_log()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-44';    err_schema:='db';    err_table:='copy_submodules_dp_in_to_db_log()';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.copy_submodules_dp_in_to_db_log()'
        )) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status:='8/8 db.copy_core_dp_in_to_db_log()';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''Ongoing - '||status||' (#db.cron_job_data_transfer#)'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        err_section:='cron_job_data_transfer-44';    err_schema:='db';    err_table:='copy_core_dp_in_to_db_log()';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'SELECT db.copy_core_dp_in_to_db_log()'
        )) AS t(res TEXT) INTO erg;

        -- ReadyToConnect (Pause) durchführen -----------------------
        err_section:='cron_job_data_transfer-50';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT count(1) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num=0 THEN -- falls Parameter fehlt - initial setzen
            insert INTo db_config.db_parameter (parameter_name, parameter_value, parameter_description)
            values ('pause_after_process_execution','5','Pause after copy process execution in second');
        END IF;

        err_section:='cron_job_data_transfer-52';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<5 then num:=5; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe INTervention zu geben
        If num>45 then num:=40; END IF; -- Wenn größer als JobINTerval - kleiner setzen um wieder in Takt zu kommen

        err_section:='cron_job_data_transfer-53';    err_schema:='system';    err_table:='Aufraeumen';
--	VACUUM ANALYZE;

        err_section:='cron_job_data_transfer-54';    err_schema:='db_config';    err_table:='db_process_control';

        -- Semaphore setzen das ReadyToConnect (Pause) gemacht werden kann weil alle Verarbeitungsschritte abgearbeitet sind
--        set_sem_erg:= db.data_transfer_start('db.cron_job_data_transfer'::VARCHAR, status::VARCHAR, TRUE);
        status:='ReadyToConnect';
        -- Semaphore setzen -----------------------------------------
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        ) ) AS t(res TEXT) INTO erg;

        SELECT pg_sleep(num) INTO temp;

        -- Semaphore wieder frei geben
        err_section:='cron_job_data_transfer-55';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Ongoing%'' and pc_value=''ReadyToConnect'' and pc_name=''semaphor_cron_job_data_transfer'''
        )) AS t(res TEXT) INTO erg;

        status:='WaitForCronJob';

        err_section:='cron_job_data_transfer-60';    err_schema:='/';    err_table:='/';
    END IF;
    err_section:='cron_job_data_transfer-60';    err_schema:='/';    err_table:='/';

    IF status in ('ReadyToConnect') THEN
        -- ReadyToConnect (Pause) durchführen
        err_section:='cron_job_data_transfer-65';    err_schema:='db_config';    err_table:='db_parameter';

        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<5 then num:=5; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe INTervention zu geben
        If num>45 then num:=40; END IF; -- Wenn größer als JobINTerval - kleiner setzen um wieder in Takt zu kommen

        SELECT pg_sleep(num) INTO temp;

        -- Semaphore wieder frei geben - ohne Rückgabe der SubProzessID
        err_section:='cron_job_data_transfer-70';    err_schema:='db_config';    err_table:='db_process_control';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Ongoing%'' and pc_value=''ReadyToConnect'' and pc_name=''semaphor_cron_job_data_transfer'''
        )) AS t(res TEXT) INTO erg;
    END IF;
    err_section:='cron_job_data_transfer-80';    err_schema:='/';    err_table:='/';
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.cron_job_data_transfer()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
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
$$ LANGUAGE plpgsql; -- db.cron_job_data_transfer

DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM cron.job j WHERE j.active IS TRUE AND command='SELECT db.cron_job_data_transfer();'
    ) THEN
        -- Datatransfer Job anlegen
        PERFORM cron.schedule('*/1 * * * *', 'SELECT db.cron_job_data_transfer();');
    END IF;
END
$$;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion zum steuern des cron-jobs für Externe - Anhalten
CREATE OR REPLACE FUNCTION db.data_transfer_stop(module VARCHAR DEFAULT 'Interpolar_Module_bitte_angeben', msg VARCHAR DEFAULT 'Interpolar_Aufrufposition_bitte_angeben')
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
DECLARE
    num INT;
    status VARCHAR;
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
    err_pid VARCHAR;
    temp VARCHAR;
    i INT:=10;
BEGIN
    -- Übergebene Variablen auf vollständigkeit prüfen
    err_section:='db.data_transfer_stop-01';    err_schema:='/';    err_table:='/';
    IF module='Interpolar_Module_bitte_angeben' OR msg='Interpolar_Aufrufposition_bitte_angeben' OR module='' OR msg='' THEN
        RETURN FALSE;
    END IF;

    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='db.data_transfer_stop-05';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','ReadyToConnect','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / INTerrupted'); -- Normal Status are: WaitForCronJo--> Ongoing --> ReadyToConnect --> WaitForCronJob
        status='ReadyToConnect';
    END IF;

    err_section:='db.data_transfer_stop-10';    err_schema:='db_config';    err_table:='db_process_control';
    IF status in ('ReadyToConnect','WaitForCronJob') THEN -- Prozess ruht bzw. wartend - also kann er blokiert werden
        -- Semaphore setzen - ohne Rückgabe der SubProzessID - optinal mit übergeben Text
        err_section:='db.data_transfer_stop-15';    err_schema:='db_config';    err_table:='db_process_control';

        status='Ongoing - '||msg||' (#'||module||'#)';
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'''
        )) AS t(res TEXT) INTO temp;

        -- set modul as last locked modul
        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value='''||module||'-'||msg||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_last_block_modul'''
        )) AS t(res TEXT) INTO temp;

        err_section:='db.data_transfer_stop-16';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen
        IF num=0 THEN   
            LOOP 
                SELECT pg_sleep(1) INTO temp; -- Time to write data

                err_section:='db.data_transfer_stop-17';    err_schema:='db_config';    err_table:='db_process_control';
                SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen
    
                -- Überprüfen, ob der Wert geschrieben wurde
                IF num > 0 THEN EXIT; -- Schleife beenden
                END IF;
    
                -- Inkrementieren der Schleifenvariable
                i := i - 1;
    
                -- Schleife abbrechen, wenn anzahl des initialen Wertes durchlaufen
                IF i <= 0 THEN
                    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.data_transfer_stop()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST('Semapohore wurde auch nach mehreren Sekunden nicht geschrieben!' AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
                        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table||' Status:'||status AS VARCHAR),-- err_variables (VARCHAR) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
                    EXIT;
                END IF;

                err_section:='db.data_transfer_stop-18';    err_schema:='db_config';    err_table:='db_process_control';
                SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen

                IF num=0 THEN RETURN FALSE; END IF;
            END LOOP;
        END IF;
	
    	RETURN TRUE; -- semaphore set successfully
    ELSE
        err_section:='db.data_transfer_stop-20';    err_schema:='db_config';    err_table:='db_process_control';
        RETURN FALSE;
    END IF;

    err_section:='db.data_transfer_stop-25';    err_schema:='/';    err_table:='/';
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_stop()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' Key:'||msg AS VARCHAR),-- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql; -- db.data_transfer_stop

GRANT EXECUTE ON FUNCTION db.data_transfer_stop(VARCHAR, VARCHAR) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(VARCHAR, VARCHAR) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(VARCHAR, VARCHAR) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(VARCHAR, VARCHAR) TO db_user;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion zum steuern des cron-jobs für Externe - Starten
CREATE OR REPLACE FUNCTION db.data_transfer_start(module VARCHAR DEFAULT 'Interpolar_Module_bitte_angeben', msg VARCHAR DEFAULT 'Interpolar_Aufrufposition_bitte_angeben', read_only BOOLEAN DEFAULT FALSE)
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
DECLARE
    num INT;
    status VARCHAR;
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
    err_pid VARCHAR;
    temp VARCHAR;
    i INT:=10;
BEGIN
    -- Übergebene Variablen auf vollständigkeit prüfen
    err_section:='db.data_transfer_start-01';    err_schema:='/';    err_table:='/';
    IF module='Interpolar_Module_bitte_angeben' OR msg='Interpolar_Aufrufposition_bitte_angeben' OR module='' OR msg='' THEN
        RETURN FALSE;
    END IF;

    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='db.data_transfer_start-05';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','ReadyToConnect','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / INTerrupted'); -- Normal Status are: WaitForCronJo--> Ongoing --> ReadyToConnect --> WaitForCronJob
        status='ReadyToConnect';
    END IF;

    err_section:='db.data_transfer_start-10';    err_schema:='db_config';    err_table:='db_process_control';
    IF status like 'Ongoing%'||msg||'%#'||module||'#%' THEN -- Prozess ruht von diesem Aufruf(Schlüssel) - also kann er blokiert werden
        -- Semaphore setzen
        IF read_only THEN -- Zugriff war nur lesend, also keine Datenänderung - Datenstand gleich wieder verfügbar
            err_section:='db.data_transfer_start-15';    err_schema:='db_config';    err_table:='db_process_control';

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=''ReadyToConnect'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'' and pc_value!=''ReadyToConnect'''
            )) AS t(res TEXT) INTO temp;
            status:='ReadyToConnect';
        ELSE
            err_section:='db.data_transfer_start-17';    err_schema:='db_config';    err_table:='db_process_control';

            SELECT res FROM public.pg_background_result(public.pg_background_launch(
            'UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'' and pc_value!=''WaitForCronJob'''
            )) AS t(res TEXT) INTO temp;
            status:='WaitForCronJob';
        END IF;

        err_section:='db.data_transfer_start-18';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen
        IF num=0 THEN   
            LOOP 
                SELECT pg_sleep(1) INTO temp; -- Time to write data

                err_section:='db.data_transfer_start-19';    err_schema:='db_config';    err_table:='db_process_control';
                SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen
    
                -- Überprüfen, ob der Wert geschrieben wurde
                IF num > 0 THEN EXIT; -- Schleife beenden
                END IF;
    
                -- Inkrementieren der Schleifenvariable
                i := i - 1;
    
                -- Schleife abbrechen, wenn anzahl des initialen Wertes durchlaufen
                IF i <= 0 THEN
                    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.data_transfer_start()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST('Semapohore wurde auch nach mehreren Sekunden nicht geschrieben!' AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
                        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table||' Status:'||status AS VARCHAR),-- err_variables (VARCHAR) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
                    EXIT;
                END IF;

                err_section:='db.data_transfer_start-20';    err_schema:='db_config';    err_table:='db_process_control';
                SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen

                IF num=0 THEN RETURN FALSE; END IF;
            END LOOP;
        END IF;

        RETURN TRUE; -- semaphore set successfully
    ELSE
        err_section:='db.data_transfer_start-20';    err_schema:='db_config';    err_table:='db_process_control';
	    RETURN FALSE;
    END IF;

    err_section:='db.data_transfer_start-25';    err_schema:='/';    err_table:='/';
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_start()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' Key:'||msg AS VARCHAR),-- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql; -- db.data_transfer_start

GRANT EXECUTE ON FUNCTION db.data_transfer_start(VARCHAR,VARCHAR,BOOLEAN) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(VARCHAR,VARCHAR,BOOLEAN) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(VARCHAR,VARCHAR,BOOLEAN) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(VARCHAR,VARCHAR,BOOLEAN) TO db_user;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion um das Modul auszugeben welches die letzte Semaphore gespeert hat
CREATE OR REPLACE FUNCTION db.data_transfer_get_lock_module()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    status TEXT;
    temp VARCHAR;
    num INT;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden
    SELECT  split_part(pc_value,'#',2) INTO status
    FROM db_config.db_process_control
    WHERE pc_name = 'semaphor_cron_job_data_transfer';

    RETURN status; -- get_lock_module successfully
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST('db_config' AS VARCHAR),                   -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_get_lock_module()' AS VARCHAR),     -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST('db.data_transfer_get_lock_module-01' AS VARCHAR),    -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: db_process_control' AS VARCHAR),  -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN 'Fehler bei Abfrage ist Aufgetreten -'||SQLSTATE;
END;
$$ LANGUAGE plpgsql; -- db.data_transfer_get_lock_module

GRANT EXECUTE ON FUNCTION db.data_transfer_get_lock_module() TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_get_lock_module() TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_get_lock_module() TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_get_lock_module() TO db_user;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion zum steuern des cron-jobs für Externe - Starten im Fehlerfall - schreiben eines Errorlog EINTrages
CREATE OR REPLACE FUNCTION db.data_transfer_reset_lock(module VARCHAR DEFAULT 'Interpolar_Module_bitte_angeben')
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
DECLARE
    num INT;
    status VARCHAR;
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
    err_pid VARCHAR;
    temp VARCHAR;
    i INT:=10;
BEGIN
    -- Übergebene Variablen auf vollständigkeit prüfen
    err_section:='db.data_transfer_reset_lock-01';    err_schema:='/';    err_table:='/';
    IF module='Interpolar_Module_bitte_angeben' OR module='' THEN
        RETURN FALSE;
    END IF;

    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='db.data_transfer_reset_lock-05';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    END IF;

    err_section:='db.data_transfer_reset_lock-07';    err_schema:='db_log';    err_table:='data_import_hist';
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist;
    
    err_section:='db.data_transfer_reset_lock-10';    err_schema:='db';    err_table:='error_log';
    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('EXTERN --> db.data_transfer_reset_lock()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST('Semaphore wurde durch Modul #'||module||'# in db.data_transfer_reset_lock zurück gesetzt.' AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST('Aktuelle Semaphore:'||status||' Modul:'||module AS VARCHAR), -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' Modul:'||module AS VARCHAR),-- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    err_section:='db.data_transfer_reset_lock-15';    err_schema:='db_config';    err_table:='db_process_control';
    IF status like 'Ongoing%#'||module||'#%' THEN -- Prozess ruht von diesem Aufruf(Schlüssel) - also kann er blokiert werden
        -- Semaphore setzen
        err_section:='db.data_transfer_reset_lock-17';    err_schema:='db_config';    err_table:='db_process_control';

        SELECT res FROM public.pg_background_result(public.pg_background_launch(
        'UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer'' and pc_value!=''WaitForCronJob'''
        )) AS t(res TEXT) INTO temp;
        status:='WaitForCronJob';

        err_section:='db.data_transfer_reset_lock-18';    err_schema:='db_config';    err_table:='db_process_control';
        SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen
        IF num=0 THEN   
            LOOP 
                SELECT pg_sleep(1) INTO temp; -- Time to write data

                err_section:='db.data_transfer_reset_lock-19';    err_schema:='db_config';    err_table:='db_process_control';
                SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen
    
                -- Überprüfen, ob der Wert geschrieben wurde
                IF num > 0 THEN EXIT; -- Schleife beenden
                END IF;
    
                -- Inkrementieren der Schleifenvariable
                i := i - 1;
    
                -- Schleife abbrechen, wenn anzahl des initialen Wertes durchlaufen
                IF i <= 0 THEN
                    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

                    SELECT db.error_log(
                        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
                        err_objekt => CAST('db.data_transfer_reset_lock()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
                        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
                        err_msg => CAST('Semapohore wurde auch nach mehreren Sekunden nicht geschrieben!' AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
                        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
                        err_variables => CAST('Tab: ' || err_table||' Status:'||status AS VARCHAR),-- err_variables (VARCHAR) Debug-Informationen zu Variablen
                        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
                    ) INTO temp;
                    EXIT;
                END IF;

                err_section:='db.data_transfer_reset_lock-20';    err_schema:='db_config';    err_table:='db_process_control';
                SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer' AND pc_value=status; -- Eintrag manuell Überprüfen

                IF num=0 THEN RETURN FALSE; END IF;
            END LOOP;
        END IF;
	
        RETURN TRUE; -- semaphore set successfully
    ELSE
        err_section:='db.data_transfer_reset_lock-21';    err_schema:='db_config';    err_table:='db_process_control';
	    RETURN FALSE;
    END IF;

    err_section:='db.data_transfer_reset_lock-25';    err_schema:='/';    err_table:='/';
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_reset_lock()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' Modul:'||module AS VARCHAR),-- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql; -- db.data_transfer_reset_lock

GRANT EXECUTE ON FUNCTION db.data_transfer_reset_lock(VARCHAR) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_reset_lock(VARCHAR) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_reset_lock(VARCHAR) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_reset_lock(VARCHAR) TO db_user;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion um aktuellen Status zu erfahren
CREATE OR REPLACE FUNCTION db.data_transfer_status()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    status TEXT;
    temp VARCHAR;
    num INT;
    last_bl_modul VARCHAR;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden
    SELECT pc_value || ' since ' || to_char(last_change_timestamp, 'YYYY-MM-DD HH24:MI:SS')
    ||' ReportTime: '||to_char(CURRENT_TIMESTAMP,'HH24:MI:SS')
    INTO status
    FROM db_config.db_process_control
    WHERE pc_name = 'semaphor_cron_job_data_transfer';

    -- get last modul locked semaphor
    SELECT  ' | last_bl_modul:'||pc_value||' (set on :'||to_char(last_change_timestamp, 'YYYY-MM-DD HH24:MI:SS')||')' INTO last_bl_modul
    FROM db_config.db_process_control
    WHERE pc_name = 'semaphor_last_block_modul';

    IF status LIKE 'Ongo%' THEN
        SELECT CASE WHEN LENGTH(pc_value)<1 THEN 'n.a.' ELSE pc_value END INTO temp FROM db_config.db_process_control WHERE pc_name='current_total_number_of_records_in_the_function';

        IF temp!='n.a.' THEN
            SELECT status||' ( '||(SELECT CASE WHEN LENGTH(pc_value)<1 THEN 'n.a.' ELSE pc_value END FROM db_config.db_process_control WHERE pc_name='currently_processed_number_of_data_records_in_the_function')||' / '||temp||' datasets )' INTO status;
        END IF;
    END IF;

    RETURN status||last_bl_modul;
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST('db_config' AS VARCHAR),                   -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_stop()' AS VARCHAR),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST('db.data_transfer_status-01' AS VARCHAR),    -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: db_process_control' AS VARCHAR),  -- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;
    
    RETURN 'Fehler bei Abfrage ist Aufgetreten -'||SQLSTATE;
END;
$$ LANGUAGE plpgsql; --db.data_transfer_status

GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db_user;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion um aktuellen Status zu erfahren
-- CREATE OR REPLACE FUNCTION db.get_last_processing_nr_typed()

-- Vergabe der Berechtigungen zur generierten Funktion
GRANT EXECUTE ON FUNCTION db.get_last_processing_nr_typed() TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.get_last_processing_nr_typed() TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.get_last_processing_nr_typed() TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.get_last_processing_nr_typed() TO db_user;
