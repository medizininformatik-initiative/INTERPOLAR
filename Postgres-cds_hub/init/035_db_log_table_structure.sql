-- Table "log_table_structure" in schema "db_config" - Dokumentation der umgesetzen Änderung der Datenbankstrucktur
----------------------------------------------------
CREATE TABLE IF NOT EXISTS db_config.log_table_structure (
  id SERIAL PRIMARY KEY,
  schema_name VARCHAR,
  table_name VARCHAR,
  column_name VARCHAR,
  data_type VARCHAR,
  is_nullable VARCHAR,
  column_default VARCHAR,
  status VARCHAR, -- A -Aktuell  / H - Historie für Wiederkehrende Änderungen im zeitlichen Verlauf 
  version_info VARCHAR, -- Dokumentation der Release-Version und des Datums
  input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Time at which the data record is inserted
  last_change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of last change
);

GRANT INSERT ON db_config.log_table_structure TO db_user;
GRANT SELECT ON db_config.log_table_structure TO db_user;
GRANT UPDATE ON db_config.log_table_structure TO db_user;


-- Erstelle die Funktion zur Extraktion der Struktur
----------------------------------------------------
CREATE OR REPLACE FUNCTION db.log_table_view_structure()
RETURNS VOID 
SECURITY DEFINER
AS $$
BEGIN
    -- Nicht vorhandene Einträge hinzfügen
    INSERT INTO db_config.log_table_structure (schema_name, table_name, column_name, data_type, is_nullable, column_default, status, version_info, input_datetime, last_change_timestamp)
    (SELECT 
        c.table_schema AS schema_name,
        c.table_name AS table_name,
        c.column_name AS column_name,
        c.data_type AS data_type,
        c.is_nullable AS is_nullable,
        c.column_default AS column_default,
        'A' AS status,
        (SELECT 'release_version: '||parameter_value||' / ' FROM db_config.db_parameter WHERE parameter_name='release_version')
        ||(SELECT 'release_version_date: '||parameter_value FROM db_config.db_parameter WHERE parameter_name='release_version_date') AS version_info,
        CURRENT_TIMESTAMP AS input_datetime,
        CURRENT_TIMESTAMP AS last_change_timestamp
    FROM information_schema.columns c
    WHERE c.table_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in')
    AND COALESCE(c.table_schema,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(c.column_name,'#')||'#'||COALESCE(c.data_type,'#')||'#'||COALESCE(c.is_nullable,'#')||'#'||COALESCE(c.column_default,'#')
    NOT IN (SELECT COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(l.data_type,'#')||'#'||COALESCE(l.is_nullable,'#')||'#'||COALESCE(l.column_default,'#') FROM db_config.log_table_structure l WHERE status='A')
    ORDER BY table_schema, table_name, column_name
    );

    -- Alle nicht aktuellen Einträge auf Historie setzen
    UPDATE db_config.log_table_structure l SET status='H'
    WHERE COALESCE(l.schema_name,'#')||'#'||COALESCE(l.table_name,'#')||'#'||COALESCE(l.column_name,'#')||'#'||COALESCE(l.data_type,'#')||'#'||COALESCE(l.is_nullable,'#')||'#'||COALESCE(l.column_default,'#')
    NOT IN (SELECT COALESCE(c.table_schema,'#')||'#'||COALESCE(c.table_name,'#')||'#'||COALESCE(c.column_name,'#')||'#'||COALESCE(c.data_type,'#')||'#'||COALESCE(c.is_nullable,'#')||'#'||COALESCE(c.column_default,'#') FROM information_schema.columns c)
    ;
    
    -- Alle aktuellen Einträge das last_change_timestamp neu setzen
    UPDATE db_config.log_table_structure SET last_change_timestamp=CURRENT_TIMESTAMP WHERE status='A';
END;
$$ LANGUAGE plpgsql; -- db.log_table_view_structure


----------------------------------------------------
SELECT db.log_table_view_structure(); -- initiales Ausführen