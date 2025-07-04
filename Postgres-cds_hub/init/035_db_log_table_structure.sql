-- Table "log_table_structure" in schema "db_config" - Dokumentation der umgesetzen Änderung der Datenbankstrucktur
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.log_table_structure (
  id SERIAL PRIMARY KEY,
  object_type VARCHAR, -- TABLE, VIEW, FUNCTION, TRIGGER
  schema_name VARCHAR, -- Schemaname
  table_name VARCHAR, -- Tabellen- / View- / Funktions- oder Triggername
  column_name VARCHAR, -- Spaltenbezeichnung (Tabelle) bzw. Triggereigenschaften
  data_type VARCHAR,
  is_nullable VARCHAR,
  column_default VARCHAR,
  definition VARCHAR, -- SQL Definition von View, Funktionen bzw. Trigger
  status VARCHAR, -- A -Aktuell  / H - Historie für Wiederkehrende Änderungen im zeitlichen Verlauf 
  version_info VARCHAR, -- Dokumentation der Release-Version und des Datums
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

----------------------------------------------------
-- Index

DO
$$
BEGIN
------------------------------------------------------------------------------------------------
    IF EXISTS ( -- Zielspalte existiert
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'db_config' AND table_name = 'log_table_structure' AND column_name = 'status'
    ) THEN
        IF EXISTS ( -- INDEX vorhanden
            SELECT 1 FROM pg_indexes where indexname='idx_db_log_table_structure_status'
        ) THEN -- aktuellen Stand überprüfen
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes
                WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_config' AND tablename = 'log_table_structure' AND indexname='idx_db_log_table_structure_status'
		AND indexdef != 'CREATE INDEX idx_db_log_table_structure_status ON db_config.log_table_structure USING btree (status)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
                ALTER INDEX db_config.idx_db_log_table_structure_status RENAME TO del_db_log_table_structure_status;
		DROP INDEX IF EXISTS db_config.del_db_log_table_structure_status;
		CREATE INDEX idx_db_log_table_structure_status ON db_config.log_table_structure USING btree (status);
            END IF; -- aktueller Stand
	ELSE -- (einfach) Neu Anlegen
	    CREATE INDEX idx_db_log_table_structure_status ON db_config.log_table_structure USING btree (status);
        END IF; -- Index vorhanden
    END IF; -- Zielspalte

------------------------------------------------------------------------------------------------
    IF EXISTS ( -- Zielspalte existiert
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'db_config' AND table_name = 'log_table_structure' AND column_name = 'object_type'
    ) THEN
        IF EXISTS ( -- INDEX vorhanden
            SELECT 1 FROM pg_indexes where indexname='idx_db_log_table_structure_object_type'
        ) THEN -- aktuellen Stand überprüfen
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes
                WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_config' AND tablename = 'log_table_structure' AND indexname='idx_db_log_table_structure_object_type'
		AND indexdef != 'CREATE INDEX idx_db_log_table_structure_object_type ON db_config.log_table_structure USING btree (object_type)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
                ALTER INDEX db_config.idx_db_log_table_structure_object_type RENAME TO del_db_log_table_structure_object_type;
		DROP INDEX IF EXISTS db_config.del_db_log_table_structure_object_typ;
		CREATE INDEX idx_db_log_table_structure_object_type ON db_config.log_table_structure USING btree (object_type);
            END IF; -- aktueller Stand
	ELSE -- (einfach) Neu Anlegen
	    CREATE INDEX idx_db_log_table_structure_object_type ON db_config.log_table_structure USING btree (object_type);
        END IF; -- Index vorhanden
    END IF; -- Zielspalte

------------------------------------------------------------------------------------------------
    IF EXISTS ( -- Zielspalte existiert
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'db_config' AND table_name = 'log_table_structure' AND column_name = 'schema_name'
    ) THEN
        IF EXISTS ( -- INDEX vorhanden
            SELECT 1 FROM pg_indexes where indexname='idx_db_log_table_structure_data'
        ) THEN -- aktuellen Stand überprüfen
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes
                WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_config' AND tablename = 'log_table_structure' AND indexname='idx_db_log_table_structure_data'
		AND indexdef != 'CREATE INDEX idx_db_log_table_structure_data ON db_config.log_table_structure USING btree (schema_name, table_name, column_name)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
                ALTER INDEX db_config.idx_db_log_table_structure_data RENAME TO del_db_log_table_structure_data;
		DROP INDEX IF EXISTS db_config.del_db_log_table_structure_data;
		CREATE INDEX idx_db_log_table_structure_data ON db_config.log_table_structure USING btree (schema_name, table_name, column_name);
            END IF; -- aktueller Stand
	ELSE -- (einfach) Neu Anlegen
	    CREATE INDEX idx_db_log_table_structure_data ON db_config.log_table_structure USING btree (schema_name, table_name, column_name);
        END IF; -- Index vorhanden
    END IF; -- Zielspalte

------------------------------------------------------------------------------------------------
    IF EXISTS ( -- Zielspalte existiert
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'db_config' AND table_name = 'log_table_structure' AND column_name = 'definition'
    ) THEN
        IF EXISTS ( -- INDEX vorhanden
            SELECT 1 FROM pg_indexes where indexname='idx_db_log_table_structure_definition'
        ) THEN -- aktuellen Stand überprüfen
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes
                WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_config' AND tablename = 'log_table_structure' AND indexname='idx_db_log_table_structure_definition'
		AND indexdef != 'CREATE INDEX idx_db_log_table_structure_definition ON db_config.log_table_structure USING btree (md5((definition)::text))'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
                ALTER INDEX db_config.idx_db_log_table_structure_definition RENAME TO del_db_log_table_structure_definition;
		DROP INDEX IF EXISTS db_config.del_db_log_table_structure_definition;
		CREATE INDEX idx_db_log_table_structure_definition ON db_config.log_table_structure USING btree (md5((definition)::text));
            END IF; -- aktueller Stand
	ELSE -- (einfach) Neu Anlegen
	    CREATE INDEX idx_db_log_table_structure_definition ON db_config.log_table_structure USING btree (md5((definition)::text));
        END IF; -- Index vorhanden
    END IF; -- Zielspalte
------------------------------------------------------------------------------------------------
END
$$;

----------------------------------------------------
-- Berechtigungen
GRANT INSERT ON db_config.log_table_structure TO db_user;
GRANT SELECT ON db_config.log_table_structure TO db_user;
GRANT UPDATE ON db_config.log_table_structure TO db_user;

-- Erstelle die Funktion zur Extraktion der Struktur
----------------------------------------------------
CREATE OR REPLACE FUNCTION db.log_table_view_structure()
RETURNS VOID 
SECURITY DEFINER
AS $$
DECLARE
    temp VARCHAR;
    err_section VARCHAR;
    err_schema VARCHAR;
    err_table VARCHAR;
    num INT;
BEGIN
    ----------------------------------------------------------------------------------------------------------------------------
    -- TABLE Nicht vorhandene Einträge hinzfügen
    err_section:='log_table_view_structure-01';    err_schema:='db_config';    err_table:='TABLE';
    INSERT INTO db_config.log_table_structure (object_type, schema_name, table_name, column_name, data_type, is_nullable, column_default, status, version_info, input_datetime, last_change_timestamp)
    (SELECT 
        'TABLE' AS object_type,
        c.table_schema AS schema_name,
        c.table_name AS table_name,
        c.column_name AS column_name,
        c.data_type AS data_type,
        c.is_nullable AS is_nullable,
        c.column_default||c.generation_expression AS column_default,
        'A' AS status,
        (SELECT 'release_version: '||parameter_value||' / ' FROM db_config.db_parameter WHERE parameter_name='release_version')
        ||(SELECT 'release_version_date: '||parameter_value FROM db_config.db_parameter WHERE parameter_name='release_version_date') AS version_info,
        CURRENT_TIMESTAMP AS input_datetime,
        CURRENT_TIMESTAMP AS last_change_timestamp
    FROM information_schema.columns c
    WHERE c.table_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in')
    AND c.is_updatable = 'YES' -- Views ausschließen welche in TABLE enthalten sind
    AND COALESCE(c.table_schema,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(c.column_name,'#')||'#'||COALESCE(c.data_type,'#')||'#'||COALESCE(c.is_nullable,'#')||'#'||COALESCE(c.column_default||c.generation_expression,'#')
    NOT IN (SELECT COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(l.data_type,'#')||'#'||COALESCE(l.is_nullable,'#')||'#'||COALESCE(l.column_default,'#')
            FROM db_config.log_table_structure l
            WHERE l.status='A' AND l.object_type='TABLE'
            )
    ORDER BY table_schema, table_name, column_name
    );

    -- TABLE Alle nicht aktuellen Einträge auf Historie setzen
    err_section:='log_table_view_structure-02';    err_schema:='db_config';    err_table:='TABLE';
    UPDATE db_config.log_table_structure l SET status='H'
    WHERE COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(l.data_type,'#')||'#'||COALESCE(l.is_nullable,'#')||'#'||COALESCE(l.column_default,'#')
    NOT IN (SELECT COALESCE(c.table_schema,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(c.column_name,'#')||'#'||COALESCE(c.data_type,'#')||'#'||COALESCE(c.is_nullable,'#')||'#'||COALESCE(c.column_default||c.generation_expression,'#')
            FROM information_schema.columns c
            WHERE c.table_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in')
            AND c.is_updatable = 'YES' -- Views ausschließen welche in TABLE enthalten sind
            )
    AND l.object_type='TABLE' AND status='A'
    ;
    
    -- TABLE Alle aktuellen Einträge das last_change_timestamp neu setzen
    err_section:='log_table_view_structure-03';    err_schema:='db_config';    err_table:='TABLE';
    UPDATE db_config.log_table_structure SET last_change_timestamp=CURRENT_TIMESTAMP WHERE status='A' AND object_type='TABLE';

    ----------------------------------------------------------------------------------------------------------------------------
    -- VIEW Nicht vorhandene Einträge hinzfügen
    err_section:='log_table_view_structure-05';    err_schema:='db_config';    err_table:='VIEW';
    INSERT INTO db_config.log_table_structure (object_type, schema_name, table_name, definition, status, version_info, input_datetime, last_change_timestamp)
    (SELECT * FROM
        (SELECT
            'VIEW' AS object_type,
            v.table_schema AS schema_name,
            v.table_name AS table_name,
            view_definition AS definition,
            'A' AS status,
            (SELECT 'release_version: '||parameter_value||' / ' FROM db_config.db_parameter WHERE parameter_name='release_version')
            ||(SELECT 'release_version_date: '||parameter_value FROM db_config.db_parameter WHERE parameter_name='release_version_date') AS version_info,
            CURRENT_TIMESTAMP AS input_datetime,
            CURRENT_TIMESTAMP AS last_change_timestamp
        FROM (SELECT * FROM information_schema.views WHERE table_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in') ) v
        JOIN pg_views ON v.table_schema = pg_views.schemaname AND v.table_name = pg_views.viewname
        ) c
    WHERE COALESCE(c.schema_name,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(md5(c.definition),'#')
    NOT IN (SELECT COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(md5(l.definition),'#')
            FROM db_config.log_table_structure l
            WHERE l.status='A' AND l.object_type='VIEW'
            )
    ORDER BY schema_name, table_name
    );

    -- VIEW Alle nicht aktuellen Einträge auf Historie setzen
    err_section:='log_table_view_structure-06';    err_schema:='db_config';    err_table:='VIEW';
    UPDATE db_config.log_table_structure SET status='H'
    WHERE  COALESCE(schema_name,'#')||'#'||COALESCE(table_name,'#')||'#'||COALESCE(md5(definition),'#')
    NOT IN (SELECT
            COALESCE(v.table_schema,'#')||'#'||COALESCE(v.table_name,'#')||'#'||COALESCE(md5(view_definition),'#')
        FROM (SELECT * FROM information_schema.views WHERE table_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in') ) v
        JOIN pg_views ON v.table_schema = pg_views.schemaname AND v.table_name = pg_views.viewname
    )
    AND status='A' AND object_type='VIEW'
    ;
    
    -- VIEW Alle aktuellen Einträge das last_change_timestamp neu setzen
    err_section:='log_table_view_structure-07';    err_schema:='db_config';    err_table:='VIEW';
    UPDATE db_config.log_table_structure SET last_change_timestamp=CURRENT_TIMESTAMP WHERE status='A' AND object_type='VIEW';

    ----------------------------------------------------------------------------------------------------------------------------
    -- FUNCTION Nicht vorhandene Einträge hinzfügen
    err_section:='log_table_view_structure-10';    err_schema:='db_config';    err_table:='FUNCTION';
    INSERT INTO db_config.log_table_structure (object_type, schema_name, table_name, definition, status, version_info, input_datetime, last_change_timestamp)
    (SELECT * FROM
        (SELECT 
           'FUNCTION' AS object_type,
           n.nspname AS schema_name,
           p.proname AS table_name,
           p.prosrc AS definition,
           'A' AS status,
           (SELECT 'release_version: '||parameter_value||' / ' FROM db_config.db_parameter WHERE parameter_name='release_version')
           ||(SELECT 'release_version_date: '||parameter_value FROM db_config.db_parameter WHERE parameter_name='release_version_date') AS version_info,
           CURRENT_TIMESTAMP AS input_datetime,
           CURRENT_TIMESTAMP AS last_change_timestamp
        FROM pg_proc p
        JOIN (SELECT * FROM pg_namespace WHERE nspname IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in') ) n ON p.pronamespace = n.oid
        ) c
    WHERE COALESCE(c.schema_name,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(md5(c.definition),'#')
    NOT IN (SELECT COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(md5(l.definition),'#')
            FROM db_config.log_table_structure l
            WHERE l.status='A' AND l.object_type='FUNCTION'
            )
    ORDER BY schema_name, table_name
    );

    -- FUNCTION Alle nicht aktuellen Einträge auf Historie setzen
    err_section:='log_table_view_structure-11';    err_schema:='db_config';    err_table:='FUNCTION';
    UPDATE db_config.log_table_structure SET status='H'
    WHERE  COALESCE(schema_name,'#')||'#'||COALESCE(table_name,'#')||'#'||COALESCE(md5(definition),'#')
    NOT IN (SELECT
              COALESCE(n.nspname,'#')||'#'||COALESCE(p.proname,'#')||'#'||COALESCE(md5(p.prosrc),'#')
            FROM pg_proc p
            JOIN (SELECT * FROM pg_namespace WHERE nspname IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in') ) n ON p.pronamespace = n.oid
           )
    AND status='A' AND object_type='FUNCTION'
    ;
    
    -- FUNCTION Alle aktuellen Einträge das last_change_timestamp neu setzen
    err_section:='log_table_view_structure-12';    err_schema:='db_config';    err_table:='FUNCTION';
    UPDATE db_config.log_table_structure SET last_change_timestamp=CURRENT_TIMESTAMP WHERE status='A' AND object_type='FUNCTION';

    ----------------------------------------------------------------------------------------------------------------------------
    -- TRIGGER Nicht vorhandene Einträge hinzfügen
    err_section:='log_table_view_structure-15';    err_schema:='db_config';    err_table:='TRIGGER';
    INSERT INTO db_config.log_table_structure (object_type, schema_name, table_name, column_name, definition, status, version_info, input_datetime, last_change_timestamp)
    (SELECT 
        'TRIGGER' AS object_type,
        c.trigger_schema AS schema_name,
        c.trigger_name AS table_name,
        c.action_timing||' '||event_manipulation||' - ('||action_orientation||') ON '||event_object_schema||'.'||event_object_table AS column_name,
        c.action_statement AS definition,
        'A' AS status,
        (SELECT 'release_version: '||parameter_value||' / ' FROM db_config.db_parameter WHERE parameter_name='release_version')
        ||(SELECT 'release_version_date: '||parameter_value FROM db_config.db_parameter WHERE parameter_name='release_version_date') AS version_info,
        CURRENT_TIMESTAMP AS input_datetime,
        CURRENT_TIMESTAMP AS last_change_timestamp
    FROM information_schema.triggers c
    WHERE c.trigger_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in')
    AND COALESCE(c.trigger_schema,'#')||'#'||COALESCE(c.trigger_name,'#')||'#'||COALESCE(c.action_timing||' '||event_manipulation||' - ('||action_orientation||') ON '||event_object_schema||'.'||event_object_table,'#')||'#'||md5(c.action_statement)
    NOT IN (SELECT COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(md5(l.definition),'#')
            FROM db_config.log_table_structure l
            WHERE l.status='A' AND l.object_type='TRIGGER'
            )
    ORDER BY schema_name, table_name
    );

    -- TRIGGER Alle nicht aktuellen Einträge auf Historie setzen
    err_section:='log_table_view_structure-16';    err_schema:='db_config';    err_table:='TRIGGER';
    UPDATE db_config.log_table_structure l SET status='H'
    WHERE COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(md5(l.definition),'#')
    NOT IN (SELECT COALESCE(c.trigger_schema,'#')||'#'||COALESCE(c.trigger_name,'#')||'#'||COALESCE(c.action_timing||' '||event_manipulation||' - ('||action_orientation||') ON '||event_object_schema||'.'||event_object_table,'#')||'#'||md5(c.action_statement)
            FROM information_schema.triggers c
            WHERE c.trigger_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in')
            )
    AND l.object_type='TRIGGER' AND status='A'
    ;
    
    -- TABLE Alle aktuellen Einträge das last_change_timestamp neu setzen
    err_section:='log_table_view_structure-17';    err_schema:='db_config';    err_table:='TRIGGER';
    UPDATE db_config.log_table_structure SET last_change_timestamp=CURRENT_TIMESTAMP WHERE status='A' AND object_type='TRIGGER';

    ----------------------------------------------------------------------------------------------------------------------------
    -- INDEX Nicht vorhandene Einträge hinzfügen
    err_section:='log_table_view_structure-20';    err_schema:='db_config';    err_table:='INDEX';
    INSERT INTO db_config.log_table_structure (object_type, schema_name, table_name, column_name, definition, data_type, status, version_info, input_datetime, last_change_timestamp)
    (SELECT * FROM (
        SELECT 
            'INDEX' AS object_type, n.nspname AS schema_name, t.relname AS table_name, c.relname AS column_name,
            pg_get_indexdef(i.indexrelid) AS definition, 'unique:'||i.indisunique||' primary:'||i.indisprimary||' index_type:'||a.amname AS data_type,
            'A' AS status,
            (SELECT 'release_version: '||parameter_value||' / ' FROM db_config.db_parameter WHERE parameter_name='release_version')
            ||(SELECT 'release_version_date: '||parameter_value FROM db_config.db_parameter WHERE parameter_name='release_version_date') AS version_info,
            CURRENT_TIMESTAMP AS input_datetime,
            CURRENT_TIMESTAMP AS last_change_timestamp
        FROM pg_index i
        JOIN pg_class c ON c.oid = i.indexrelid
        JOIN pg_class t ON t.oid = i.indrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_am a ON c.relam = a.oid
        WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schema_name, table_name, column_name
    ) c
    WHERE c.schema_name IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in')
    AND COALESCE(c.schema_name,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(c.column_name,'#')||'#'||COALESCE(md5(c.definition))||'#'||COALESCE(c.data_type,'#')
    NOT IN (SELECT COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(md5(l.definition))||'#'||COALESCE(l.data_type,'#')
            FROM db_config.log_table_structure l
            WHERE l.status='A' AND l.object_type='INDEX'
            )
    ORDER BY schema_name, table_name
    );

    -- INDEX Alle nicht aktuellen Einträge auf Historie setzen
    err_section:='log_table_view_structure-21';    err_schema:='db_config';    err_table:='INDEX';
    UPDATE db_config.log_table_structure l SET status='H'
    WHERE COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(md5(l.definition))||'#'||COALESCE(l.data_type,'#')
    NOT IN (SELECT COALESCE(c.schema_name,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(c.column_name,'#')||'#'||COALESCE(md5(c.definition))||'#'||COALESCE(c.data_type,'#')
            FROM (
                SELECT 
                    'INDEX' AS object_type, n.nspname AS schema_name, t.relname AS table_name, c.relname AS column_name,
                    pg_get_indexdef(i.indexrelid) AS definition, 'unique:'||i.indisunique||' primary:'||i.indisprimary||' index_type:'||a.amname AS data_type,
                    'A' AS status,
                    (SELECT 'release_version: '||parameter_value||' / ' FROM db_config.db_parameter WHERE parameter_name='release_version')
                    ||(SELECT 'release_version_date: '||parameter_value FROM db_config.db_parameter WHERE parameter_name='release_version_date') AS version_info,
                    CURRENT_TIMESTAMP AS input_datetime,
                    CURRENT_TIMESTAMP AS last_change_timestamp
                FROM pg_index i
                JOIN pg_class c ON c.oid = i.indexrelid
                JOIN pg_class t ON t.oid = i.indrelid
                JOIN pg_namespace n ON n.oid = c.relnamespace
                JOIN pg_am a ON c.relam = a.oid
                WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
            ) c
            WHERE c.schema_name IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in')
            )
    AND l.object_type='INDEX' AND status='A'
    ;
    
    -- INDEX Alle aktuellen Einträge das last_change_timestamp neu setzen
    err_section:='log_table_view_structure-22';    err_schema:='db_config';    err_table:='INDEX';
    UPDATE db_config.log_table_structure SET last_change_timestamp=CURRENT_TIMESTAMP WHERE status='A' AND object_type='INDEX';

    err_section:='log_table_view_structure-99';    err_schema:='db_config';    err_table:='-';
    ----------------------------------------------------------------------------------------------------------------------------
EXCEPTION
    WHEN OTHERS THEN
    SELECT MAX(last_processing_nr) INTO num FROM db.data_import_hist; -- aktuelle proz.number zum Zeitpunkt des Fehlers mit dokumentieren

    SELECT db.error_log(
        err_schema => CAST(err_schema AS VARCHAR),                    -- err_schema (VARCHAR) Schema, in dem der Fehler auftrat
        err_objekt => CAST('db.log_table_view_structure()' AS VARCHAR), -- err_objekt (VARCHAR) Objekt (Tabelle, Funktion, etc.)
        err_user => CAST(current_user AS VARCHAR),                    -- err_user (VARCHAR) Benutzer (kann durch current_user ersetzt werden)
        err_msg => CAST(SQLSTATE || ' - ' || SQLERRM AS VARCHAR),     -- err_msg (VARCHAR) Fehlernachricht
        err_line => CAST(err_section AS VARCHAR),                     -- err_line (VARCHAR) Zeilennummer oder Abschnitt
        err_variables => CAST('Tab: ' ||err_table||' lastErg:'||erg AS VARCHAR), -- err_variables (VARCHAR) Debug-Informationen zu Variablen
        last_processing_nr => CAST(num AS INT)                          -- last_processing_nr (INT) Letzte Verarbeitungsnummer - wenn vorhanden
    ) INTO temp;
END;
$$ LANGUAGE plpgsql; -- db.log_table_view_structure

----------------------------------------------------
SELECT db.log_table_view_structure(); -- initiales Ausführen