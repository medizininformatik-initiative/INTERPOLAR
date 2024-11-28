CREATE OR REPLACE FUNCTION db.cron_job_data_transfer()
RETURNS VOID
SECURITY DEFINER
AS $$
DECLARE
    temp varchar;
    status varchar;
    num int;
    err_section varchar;
    err_schema varchar;
    err_table varchar;
    err_pid varchar;
BEGIN
    -- Doppelt angelegte Cron-Jobs deaktivieren
    err_section:='cron_job_data_transfer-01';    err_schema:='cron';    err_table:='job';
    UPDATE cron.job m SET active = FALSE WHERE m.command in
    (select i.command as t from (select command, count(1) anz from cron.job group by command) i where anz>1)
    and m.jobid not in (select min(f.jobid) from cron.job f where f.command in (select i.command as t from (select command, count(1) anz from cron.job group by       command) i where anz>1));

    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='cron_job_data_transfer-05';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','pause','semaphore to control the cron_job_data_transfer job, contains the current processing status - ongoing / pause / ready / interrupted'); -- Normal Status are: ready --> ongoing --> pause --> ready
        status='pause';
    END IF;

    err_section:='cron_job_data_transfer-10';    err_schema:='db_config';    err_table:='/';
    IF status like 'ongoing%' THEN -- Notaus überprüfen
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
        SELECT CASE WHEN round(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP-last_change_timestamp))) > (60*num) THEN 0 ELSE 1 END INTO num
        FROM db_config.db_process_control WHERE pc_name = 'semaphor_cron_job_data_transfer';
        
        If num=1 THEN
            status:='ready';
        END IF;
    END IF;

    IF status in ('ready') THEN
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 1/5 db.copy_raw_cds_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-25';    err_schema:='db';    err_table:='copy_raw_cds_in_to_db_log()';

        -- FHIR Data
        SELECT db.copy_raw_cds_in_to_db_log() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;
    
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 2/5 db.copy_type_cds_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-30';    err_schema:='db';    err_table:='copy_type_cds_in_to_db_log()';

        SELECT db.copy_type_cds_in_to_db_log() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;

        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 3/5 db.take_over_last_check_date()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-35';    err_schema:='db';    err_table:='take_over_last_check_date()';
    
        SELECT db.take_over_last_check_date() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;
    
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 4/5 db.copy_fe_dp_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-40';    err_schema:='db';    err_table:='copy_fe_dp_in_to_db_log()';

        -- Study data
        SELECT db.copy_fe_dp_in_to_db_log() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;
    
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 5/5 db.copy_fe_fe_in_to_db_log()'; err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-45';    err_schema:='db';    err_table:='copy_fe_fe_in_to_db_log()';

        SELECT db.copy_fe_fe_in_to_db_log() INTO temp;

        -- Pause durchführen
        err_section:='cron_job_data_transfer-50';    err_schema:='db_config';    err_table:='db_parameter';
        SELECT count(1) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num=0 THEN -- falls Parameter fehlt - initial setzen
            insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
            values ('pause_after_process_execution','5','Pause after copy process execution in second');
        END IF;

        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<5 then num:=5; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe intervention zu geben
        If num>45 then num:=40; END IF; -- Wenn größer als JobInterval - kleiner setzen um wieder in Takt zu kommen

        -- Semaphore setzen das Pause gemacht werden kann - ohne Rückgabe der SubProzessID
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''pause'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-55';    err_schema:='db_config';    err_table:='db_parameter';

        SELECT pg_sleep(num) INTO temp;
    
        -- Semaphore wieder frei geben - ohne Rückgabe der SubProzessID
        err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''ready'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''ongoing%'' and pc_value=''pause'' and pc_name=''semaphor_cron_job_data_transfer''');
        err_section:='cron_job_data_transfer-60';    err_schema:='/';    err_table:='/';
    END IF;
    err_section:='cron_job_data_transfer-60';    err_schema:='/';    err_table:='/';

/*
EXCEPTION
    WHEN OTHERS THEN
        SELECT db.error_log(
            err_schema,                     -- Schema, in dem der Fehler auftrat
            'db.cron_job_data_transfer() - '||err_table, -- Objekt (Tabelle, Funktion, etc.)
            current_user,                   -- Benutzer (kann durch current_user ersetzt werden)
            SQLSTATE||' - '||SQLERRM,       -- Fehlernachricht
            err_section,                    -- Zeilennummer oder Abschnitt
            PG_EXCEPTION_CONTEXT,           -- Debug-Informationen zu Variablen
            0                               -- Letzte Verarbeitungsnummer
        );
*/
END;
$$ LANGUAGE plpgsql;

-- Datatransfer Job anlegen
SELECT cron.schedule('*/1 * * * *', 'SELECT db.cron_job_data_transfer();');

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
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='db.data_transfer_stop-01';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','pause','semaphore to control the cron_job_data_transfer job, contains the current processing status - ongoing / pause / ready / interrupted'); -- Normal Status are: ready --> ongoing --> pause --> ready
        status='pause';
    END IF;

    err_section:='db.data_transfer_stop-10';    err_schema:='db_config';    err_table:='db_process_control';
    IF status in ('pause','ready') THEN -- Prozess ruht bzw. wartend - also kann er blokiert werden
        -- Semaphore setzen - ohne Rückgabe der SubProzessID - optinal mit übergeben Text
        err_section:='db.data_transfer_stop-15';    err_schema:='db_config';    err_table:='db_process_control';
        status='ongoing - '||msg;
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
/*
        SELECT db.error_log(
            err_schema,                     -- Schema, in dem der Fehler auftrat
            'db.data_transfer_stop() - '||err_table, -- Objekt (Tabelle, Funktion, etc.)
            current_user,                   -- Benutzer (kann durch current_user ersetzt werden)
            SQLSTATE||' - '||SQLERRM,       -- Fehlernachricht
            err_section,                    -- Zeilennummer oder Abschnitt
            PG_EXCEPTION_CONTEXT,           -- Debug-Informationen zu Variablen
            0                               -- Letzte Verarbeitungsnummer
        );
*/
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db_user;

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
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    err_section:='db.data_transfer_start-01';    err_schema:='db_config';    err_table:='db_process_control';
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','pause','semaphore to control the cron_job_data_transfer job, contains the current processing status - ongoing / pause / ready / interrupted'); -- Normal Status are: ready --> ongoing --> pause --> ready
        status='pause';
    END IF;

    err_section:='db.data_transfer_start-10';    err_schema:='db_config';    err_table:='db_process_control';
    IF status='ongoing - '||msg THEN -- Prozess ruht von diesem Aufruf(Schlüssel) - also kann er blokiert werden
        -- Semaphore setzen
        IF read_only THEN -- Zugriff war nur lesend, also keine Datenänderung - Datenstand gleich wieder verfügbar
            err_section:='db.data_transfer_start-15';    err_schema:='db_config';    err_table:='db_process_control';
            err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''pause'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
        ELSE
            err_section:='db.data_transfer_start-17';    err_schema:='db_config';    err_table:='db_process_control';
            err_pid:=public.pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''ready'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
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
/*
        SELECT db.error_log(
            err_schema,                     -- Schema, in dem der Fehler auftrat
            'db.data_transfer_start() - '||err_table, -- Objekt (Tabelle, Funktion, etc.)
            current_user,                   -- Benutzer (kann durch current_user ersetzt werden)
            SQLSTATE||' - '||SQLERRM,       -- Fehlernachricht
            err_section,                    -- Zeilennummer oder Abschnitt
            PG_EXCEPTION_CONTEXT,           -- Debug-Informationen zu Variablen
            0                               -- Letzte Verarbeitungsnummer
        );
*/
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar,Boolean) TO db_user;

-- Funktion um aktuellen Status zu erfahren
CREATE OR REPLACE FUNCTION db.data_transfer_status()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    status TEXT;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden
    SELECT pc_value || ' since ' || to_char(last_change_timestamp, 'YYYY-MM-DD HH24:MI:SS')
    INTO status
    FROM db_config.db_process_control
    WHERE pc_name = 'semaphor_cron_job_data_transfer';

    RETURN status;
EXCEPTION
    WHEN OTHERS THEN
/*
        SELECT db.error_log(
            'db_config',                    -- Schema, in dem der Fehler auftrat
            'db.data_transfer_status() - db_process_control', -- Objekt (Tabelle, Funktion, etc.)
            current_user,                   -- Benutzer (kann durch current_user ersetzt werden)
            SQLSTATE||' - '||SQLERRM,       -- Fehlernachricht
            '/',                            -- Zeilennummer oder Abschnitt
            PG_EXCEPTION_CONTEXT,           -- Debug-Informationen zu Variablen
            0                               -- Letzte Verarbeitungsnummer
        );
*/
    RETURN 'Fehler ist Aufgetreten';
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db_user;
