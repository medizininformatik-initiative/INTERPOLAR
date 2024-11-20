CREATE OR REPLACE FUNCTION db.cron_job_data_transfer()
RETURNS VOID AS $$
DECLARE
    temp varchar;
    status varchar;
    num int;
BEGIN
    -- Doppelt angelegte Cron-Jobs deaktivieren
    UPDATE cron.job m SET active = FALSE WHERE m.command in
    (select i.command as t from (select command, count(1) anz from cron.job group by command) i where anz>1)
    and m.jobid not in (select min(f.jobid) from cron.job f where f.command in (select i.command as t from (select command, count(1) anz from cron.job group by       command) i where anz>1));

    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','pause','semaphore to control the cron_job_data_transfer job, contains the current processing status - ongoing / pause / ready / interrupted'); -- Normal Status are: ready --> ongoing --> pause --> ready
        status='pause';
    END IF;

-- Erinnerung ToDo bei obgoing evt Parameter einbauen für Maximaldauer einer Blockade

    IF status='ready' THEN
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 1/5 db.copy_raw_cds_in_to_db_log()'; PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');

        -- FHIR Data
        SELECT db.copy_raw_cds_in_to_db_log() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;
    
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 2/5 db.copy_type_cds_in_to_db_log()'; PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');

        SELECT db.copy_type_cds_in_to_db_log() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;

        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 3/5 db.take_over_last_check_date()'; PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
    
        SELECT db.take_over_last_check_date() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;
    
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 4/5 db.copy_fe_dp_in_to_db_log()'; PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');

        -- Study data
        SELECT db.copy_fe_dp_in_to_db_log() INTO temp;
    
        SELECT pg_sleep(1) INTO temp;
    
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        status='ongoing - 5/5 db.copy_fe_fe_in_to_db_log()'; PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');

        SELECT db.copy_fe_fe_in_to_db_log() INTO temp;

        -- Pause durchführen
        SELECT count(1) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num=0 THEN -- falls Parameter fehlt - initial setzen
            insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
            values ('pause_after_process_execution','20','Pause after copy process execution in second');
        END IF;

        SELECT CAST(parameter_value AS NUMERIC) INTO num FROM db_config.db_parameter WHERE parameter_name='pause_after_process_execution';
        If num<10 then num:=10; END IF; -- Wenn kleiner als 10 sec - Mindestwartedauer um chance für externe intervention zu geben
        If num>60 then num:=45; END IF; -- Wenn größer als JobInterval - kleiner setzen um wieder in Takt zu kommen

        -- Semaphore setzen das Pause gemacht werden kann - ohne Rückgabe der SubProzessID
        PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''pause'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');

        SELECT pg_sleep(num) INTO temp;
    
        -- Semaphore wieder frei geben - ohne Rückgabe der SubProzessID
        PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''ready'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_value not like ''ongoing%'' and pc_name=''semaphor_cron_job_data_transfer''');
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Datatransfer Job anlegen
SELECT cron.schedule('*/1 * * * *', 'SELECT db.cron_job_data_transfer();');

-- Funktion zum steuern des cron-jobs für Externe - Anhalten
CREATE OR REPLACE FUNCTION db.data_transfer_stop(msg varchar DEFAULT 'InterpolarModul_Bitte_Angeben')
RETURNS BOOLEAN AS $$
DECLARE
    num int;
    status varchar;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','pause','semaphore to control the cron_job_data_transfer job, contains the current processing status - ongoing / pause / ready / interrupted'); -- Normal Status are: ready --> ongoing --> pause --> ready
        status='pause';
    END IF;

    IF status in ('pause') THEN -- Prozess ruht - also kann er blokiert werden
        -- Semaphore setzen - ohne Rückgabe der SubProzessID - optinal mit übergeben Text
        status='ongoing - '||msg;
        PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value='''||status||''', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
    	RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;


GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_stop(varchar) TO db_user;

-- Funktion zum steuern des cron-jobs für Externe - Starten
CREATE OR REPLACE FUNCTION db.data_transfer_start(msg varchar DEFAULT 'InterpolarModul_Bitte_Angeben')
RETURNS BOOLEAN AS $$
DECLARE
    num int;
    status varchar;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden - ansonsten value setzen
    SELECT count(1) INTO num FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    IF num=1 THEN
        SELECT pc_value INTO status FROM db_config.db_process_control WHERE pc_name='semaphor_cron_job_data_transfer';
    ELSE
        INSERT INTO db_config.db_process_control (pc_name, pc_value, pc_description)
        VALUES ('semaphor_cron_job_data_transfer','pause','semaphore to control the cron_job_data_transfer job, contains the current processing status - ongoing / pause / ready / interrupted'); -- Normal Status are: ready --> ongoing --> pause --> ready
        status='pause';
    END IF;

    IF status like 'ongoing%'||msg THEN -- Prozess ruht von diesem Aufruf(Schlüssel) - also kann er blokiert werden
        -- Semaphore setzen - ohne Rückgabe der SubProzessID
        PERFORM pg_background_launch('UPDATE db_config.db_process_control SET pc_value=''ready'', last_change_timestamp=CURRENT_TIMESTAMP WHERE pc_name=''semaphor_cron_job_data_transfer''');
	RETURN TRUE;
    ELSE
	RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar) TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar) TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar) TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_start(varchar) TO db_user;

-- Funktion um aktuellen Status zu erfahren
CREATE OR REPLACE FUNCTION db.data_transfer_status()
RETURNS TEXT AS $$
DECLARE
    status TEXT;
BEGIN
    -- Aktuellen Verarbeitungsstatus holen - wenn vorhanden
    SELECT pc_value || ' since ' || to_char(last_change_timestamp, 'YYYY-MM-DD HH24:MI:SS')
    INTO status
    FROM db_config.db_process_control
    WHERE pc_name = 'semaphor_cron_job_data_transfer';

    RETURN status;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO cds2db_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2dataprocessor_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db2frontend_user;
GRANT EXECUTE ON FUNCTION db.data_transfer_status() TO db_user;

