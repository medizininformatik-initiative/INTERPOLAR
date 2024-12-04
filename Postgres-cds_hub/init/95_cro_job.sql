----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db.cron_job_data_transfer()
RETURNS VOID
SECURITY DEFINER
AS $$
DECLARE
    temp varchar;
    erg TEXT;
    status varchar;
    num int;
    num2 int;
    err_section varchar;
    err_schema varchar;
    err_table varchar;
    err_pid varchar;
BEGIN
    -- Doppelt angelegte Cron-Jobs deaktivieren
    err_section:='cron_job_data_transfer_break-01';    err_schema:='cron';    err_table:='job';
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
        VALUES ('semaphor_cron_job_data_transfer','ReadyToConnect','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / Interrupted'); -- Normal Status are: WaitForCronJo--> Ongoing --> ReadyToConnect --> WaitForCronJob 
        status='ReadyToConnect';
    END IF;

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
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''Ongoing since '||num2||' sec - '||(num*60)||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''timepoint_3_cron_job_data_transfer''');
        If num2>=(num*60) THEN
            status:='WaitForCronJob';
            err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        END IF;
    END IF;
    err_section:='cron_job_data_transfer-22';    err_schema:='/';    err_table:='/';

    IF status in ('WaitForCronJob') THEN
        -- Langzeit Ongoin Info wieder zurück setzen
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''Normal Ongoing'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''timepoint_3_cron_job_data_transfer''');

        -- Semaphore setzen -----------------------------------------
        status='Ongoing - 1/5 db.copy_raw_cds_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-25';    err_schema:='db';    err_table:='copy_raw_cds_in_to_db_log()';

        -- FHIR Data cds2db_in -> db_log
        SELECT res FROM public.pg_background_result(public.pg_background_launch('SELECT db.copy_raw_cds_in_to_db_log()')) AS t(res TEXT) INTO erg;
    
        -- Semaphore setzen -----------------------------------------
        status='Ongoing - 2/5 db.copy_type_cds_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-30';    err_schema:='db';    err_table:='copy_type_cds_in_to_db_log()';

        SELECT res FROM public.pg_background_result(public.pg_background_launch('SELECT db.copy_type_cds_in_to_db_log()')) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status='Ongoing - 3/5 db.take_over_last_check_date()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-35';    err_schema:='db';    err_table:='take_over_last_check_date()';
    
        SELECT res FROM public.pg_background_result(public.pg_background_launch('SELECT db.take_over_last_check_date()')) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status='Ongoing - 4/5 db.copy_fe_dp_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-40';    err_schema:='db';    err_table:='copy_fe_dp_in_to_db_log()';

        -- Study data
        SELECT res FROM public.pg_background_result(public.pg_background_launch('SELECT db.copy_fe_dp_in_to_db_log()')) AS t(res TEXT) INTO erg;

        -- Semaphore setzen -----------------------------------------
        status='Ongoing - 5/5 db.copy_fe_fe_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-45';    err_schema:='db';    err_table:='copy_fe_fe_in_to_db_log()';

        SELECT res FROM public.pg_background_result(public.pg_background_launch('SELECT db.copy_fe_fe_in_to_db_log()')) AS t(res TEXT) INTO erg;

        -- ReadyToConnect (Pause) durchführen -----------------------
        err_section:='cron_job_data_transfer-50';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT count(1) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num=0 THEN -- falls Parameter fehlt - initial setzen
            insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
            values ('pause_after_process_execution','5','Pause after copy process execution in second');
        END IF;

        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<5 then num:=5; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe intervention zu geben
        If num>45 then num:=40; END IF; -- Wenn größer als JobInterval - kleiner setzen um wieder in Takt zu kommen

        -- Semaphore setzen das ReadyToConnect (Pause) gemacht werden kann - ohne Rückgabe der SubProzessID
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''ReadyToConnect'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-55';    err_schema:='db_config';    err_table:='db_parameter';

        SELECT pg_sleep(num) INTO temp;
    
        -- Semaphore wieder frei geben - ohne Rückgabe der SubProzessID
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Ongoing%'' and pc_value=''ReadyToConnect'' and pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-60';    err_schema:='/';    err_table:='/';
    END IF;
    err_section:='cron_job_data_transfer-60';    err_schema:='/';    err_table:='/';

    IF status in ('ReadyToConnect') THEN
        -- ReadyToConnect (Pause) durchführen
        err_section:='cron_job_data_transfer-65';    err_schema:='db_config';    err_table:='db_parameter';

        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<5 then num:=5; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe intervention zu geben
        If num>45 then num:=40; END IF; -- Wenn größer als JobInterval - kleiner setzen um wieder in Takt zu kommen

        SELECT pg_sleep(num) INTO temp;
    
        -- Semaphore wieder frei geben - ohne Rückgabe der SubProzessID
        err_section:='cron_job_data_transfer-70';    err_schema:='db_config';    err_table:='db_process_control';
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Ongoing%'' and pc_value=''ReadyToConnect'' and pc_name=''semaphor_cron_job_data_transfer''');
    END IF;
    err_section:='cron_job_data_transfer-80';    err_schema:='/';    err_table:='/';
EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.cron_job_data_transfer()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table AS varchar),       -- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(0 AS int)                          -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    -- Semapohore wegen Fehler anhalten
    err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''Interrupted wegen Fehler in '||err_section||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''Interrupted%'' and pc_name=''semaphor_cron_job_data_transfer''');
END;
$$ LANGUAGE plpgsql;

-- Datatransfer Job anlegen
SELECT cron.schedule('*/1 * * * *', 'SELECT db.cron_job_data_transfer();');

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion zum steuern des cron-jobs für Externe - Anhalten
CREATE OR REPLACE FUNCTION db.data_transfer_stop(msg varchar DEFAULT 'InterpolarModul_Bitte_Angeben')
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
DECLARE
    num int;
    status varchar;
    err_section varchar;
    err_schema varchar;
    err_table varchar;
    err_pid varchar;
    temp varchar;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='db.data_transfer_stop-01';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','ReadyToConnect','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / Interrupted'); -- Normal Status are: WaitForCronJo--> Ongoing --> ReadyToConnect --> WaitForCronJob
        status='ReadyToConnect';
    END IF;

    err_section:='db.data_transfer_stop-10';    err_schema:='db_config';    err_table:='db_process_control';
    IF status in ('ReadyToConnect','WaitForCronJob') THEN -- Prozess ruht bzw. wartend - also kann er blokiert werden
        -- Semaphore setzen - ohne Rückgabe der SubProzessID - optinal mit übergeben Text
        err_section:='db.data_transfer_stop-15';    err_schema:='db_config';    err_table:='db_process_control';
        status='Ongoing - '||msg;
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
    	RETURN TRUE;
    ELSE
        err_section:='db.data_transfer_stop-20';    err_schema:='db_config';    err_table:='db_process_control';
        RETURN FALSE;
    END IF;

    err_section:='db.data_transfer_stop-25';    err_schema:='/';    err_table:='/';
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_stop()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' Key:'||msg AS varchar),-- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(0 AS int)                          -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db_user;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion zum steuern des cron-jobs für Externe - Starten
CREATE OR REPLACE FUNCTION db.data_transfer_start(msg varchar DEFAULT 'InterpolarModul_Bitte_Angeben', read_only Boolean DEFAULT FALSE)
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
DECLARE
    num int;
    status varchar;
    err_section varchar;
    err_schema varchar;
    err_table varchar;
    err_pid varchar;
    temp varchar;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='db.data_transfer_start-01';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','ReadyToConnect','semaphore to control the cron_job_data_transfer job, contains the current processing status - Ongoing / ReadyToConnect / WaitForCronJob / Interrupted'); -- Normal Status are: WaitForCronJo--> Ongoing --> ReadyToConnect --> WaitForCronJob 
        status='ReadyToConnect';
    END IF;

    err_section:='db.data_transfer_start-10';    err_schema:='db_config';    err_table:='db_process_control';
    IF status='Ongoing - '||msg THEN -- Prozess ruht von diesem Aufruf(Schlüssel) - also kann er blokiert werden
        -- Semaphore setzen
        IF read_only THEN -- Zugriff war nur lesend, also keine Datenänderung - Datenstand gleich wieder verfügbar
            err_section:='db.data_transfer_start-15';    err_schema:='db_config';    err_table:='db_process_control';
            err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''ReadyToConnect'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        ELSE
            err_section:='db.data_transfer_start-17';    err_schema:='db_config';    err_table:='db_process_control';
            err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''WaitForCronJob'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        END IF;
	    RETURN TRUE;
    ELSE
        err_section:='db.data_transfer_start-20';    err_schema:='db_config';    err_table:='db_process_control';
	    RETURN FALSE;
    END IF;

    err_section:='db.data_transfer_start-25';    err_schema:='/';    err_table:='/';
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST(err_schema AS varchar),                    -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_start()' AS varchar), -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST(err_section AS varchar),                     -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' || err_table||' Key:'||msg AS varchar),-- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(0 AS int)                          -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO db_user;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funktion um aktuellen Status zu erfahren
CREATE OR REPLACE FUNCTION db.data_transfer_status()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    status TEXT;
    temp varchar;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden
    SELECT pc_value || ' since ' || to_char(last_change_timestamp, 'YYYY-MM-DD HH24:MI:SS')||' Reporttime: '||to_char(CURRENT_TIMESTAMP,'HH24:MI:SS')
    INTO status
    FROM db_config.db_process_control
    WHERE pc_name = 'semaphor_cron_job_data_transfer';

    RETURN status;
EXCEPTION
    WHEN OTHERS THEN
    SELECT db.error_log(
        err_schema => CAST('db_config' AS varchar),                   -- err_schema (varchar) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.data_transfer_stop()' AS varchar),     -- err_objekt (varchar) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS varchar),                    -- err_user (varchar) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS varchar),     -- err_msg (varchar) Fehlernachricht
        err_line => CAST('db.data_transfer_status-01' AS varchar),    -- err_line (varchar) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: db_process_control' AS varchar),  -- err_variables (varchar) Debug-Informationen zu Variablen
        last_processing_nr => CAST(0 AS int)                          -- last_processing_nr (int) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;
    
    RETURN 'Fehler bei Abfrage ist Aufgetreten -'||SQLSTATE;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db_user;
