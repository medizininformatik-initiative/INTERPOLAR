------------------------------
CREATE OR REPLACE FUNCTION db.<%COPY_FUNC_NAME%>()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    current_record record;
    new_last_pro_nr INT; -- New processing number for these sync
    max_last_pro_nr INT; -- Last processing number in core data
    last_raw_pro_nr INT; -- Last processing number in raw data - last new dataimport (offset)
    last_pro_datetime timestamp not null DEFAULT CURRENT_TIMESTAMP; -- Last time function is startet
BEGIN
    -- Take over last check datetime Functionname: <%COPY_FUNC_NAME%> the last_pro_nr - From: <%SCHEMA_2%> (raw) -> To: <%OWNER_SCHEMA%>
    
    -- Last import Nr in raw-data
    SELECT MAX(last_processing_nr) INTO last_raw_pro_nr FROM db_log.data_import_hist WHERE table_name like '%_raw' AND schema_name='db_log';

<%LOOP_TABS_SUB_take_over_check_date_function%>

    RETURN 'Done db.<%COPY_FUNC_NAME%>';

/*
EXCEPTION
    WHEN OTHERS THEN
        SELECT db.error_log(
            err_schema,                     -- Schema, in dem der Fehler auftrat
            'db.<%COPY_FUNC_NAME%> - '||err_table, -- Objekt (Tabelle, Funktion, etc.)
            current_user,                   -- Benutzer (kann durch current_user ersetzt werden)
            SQLSTATE||' - '||SQLERRM,       -- Fehlernachricht
            err_section,                    -- Zeilennummer oder Abschnitt
            PG_EXCEPTION_CONTEXT,           -- Debug-Informationen zu Variablen
            last_pro_nr                     -- Letzte Verarbeitungsnummer
        );
*/
    RETURN 'Fehler db.<%COPY_FUNC_NAME%> - '||SQLSTATE;
END;
$$ LANGUAGE plpgsql;

-- CopyJob CDS in 2 DB_log
-- Move to copy function - SELECT cron.schedule('*/1 * * * *', 'SELECT db.<%COPY_FUNC_NAME%>();');
-----------------------------


