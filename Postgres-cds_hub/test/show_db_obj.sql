-- Tabellen Eigenschaften Speicher -------------------------
SELECT 
    schemaname,
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS data_size,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS index_size
    , t.*
FROM pg_catalog.pg_statio_user_tables t
WHERE schemaname in ('cds2db_in','cds2db_out','cron','db','db2dataprocessor_in','db2dataprocessor_out','db2frontend_in','db2frontend_out','db_config','db_log','information_schema','pg_catalog','pg_toast')
--ORDER BY schemaname, table_name
ORDER BY pg_total_relation_size(relid) DESC;

-- INDEX -----------------------------------
SELECT * FROM
(SELECT 
    schemaname,
    relname AS db_object,
    indexrelname AS index_name,
    pg_size_pretty(pg_relation_size(relid)) AS index_size_pretty
    pg_relation_size(relid) AS index_size
    ,last_idx_scan
    , idx_tup_read
    , idx_tup_fetch
FROM pg_catalog.pg_stat_user_indexes
JOIN pg_index ON pg_stat_user_indexes.indexrelid = pg_index.indexrelid
ORDER BY pg_relation_size(relid) DESC
) WHERE schemaname in ('cds2db_in','cds2db_out','cron','db','db2dataprocessor_in','db2dataprocessor_out','db2frontend_in','db2frontend_out','db_config','db_log','information_schema','pg_catalog','pg_toast')
ORDER BY schemaname, db_object, index_name
;

-- Indextyp und Auslagerungsdatein -------------------
SELECT 
    n.nspname AS schema_name,
    c.relname AS relation_name,
    u.rolname AS owner_name,
    pg_size_pretty(pg_total_relation_size(c.oid)) size,
    am.amname AS access_method,    -- Access Method Name (nur sinnvoll bei Indexen)
    c.relfilenode AS DateiID,                  -- DateiID  
    t.relname AS toast_table_name,     -- Name der zugehörigen TOAST-Tabelle (wenn vorhanden)
  
    -- Relkind als lesbarer Text
    CASE c.relkind
        WHEN 'r' THEN 'table'
        WHEN 'i' THEN 'index'
        WHEN 'S' THEN 'sequence'
        WHEN 'v' THEN 'view'
        WHEN 'm' THEN 'materialized view'
        WHEN 'c' THEN 'composite type'
        WHEN 't' THEN 'TOAST table'
        WHEN 'f' THEN 'foreign table'
        WHEN 'p' THEN 'partitioned table'
        ELSE 'other'
    END AS relation_type
FROM pg_class c
LEFT JOIN pg_namespace n ON c.relnamespace = n.oid -- Schema-Name auflösen
LEFT JOIN pg_roles u ON c.relowner = u.oid -- Owner-Name auflösen
LEFT JOIN pg_am am ON c.relam = am.oid -- Access Method (z.B. btree, hash) – nur bei Indizes relevant
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid -- TOAST-Tabelle auflösen
WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname != 'information_schema' -- Optional: Nur echte Objekte anzeigen (keine Systemobjekte)
AND n.nspname IN ('cds2db_in','cds2db_out','cron','db','db2dataprocessor_in','db2dataprocessor_out','db2frontend_in','db2frontend_out','db_config','db_log','information_schema','pg_catalog','pg_toast')
ORDER BY n.nspname,c.relname;



-- Doppelte Indexe oder Überlappende indexe ----
        SELECT 
            i1.indexrelid::regclass AS index1,
            i2.indexrelid::regclass AS index2,
            t.relname AS table_name,
            n.nspname AS schema_name
        FROM pg_index i1
        JOIN pg_index i2 ON 
            i1.indrelid = i2.indrelid AND
            i1.indexrelid <> i2.indexrelid AND
            i1.indkey = i2.indkey
        JOIN pg_class t ON t.oid = i1.indrelid
        JOIN pg_class c1 ON c1.oid = i1.indexrelid
        JOIN pg_class c2 ON c2.oid = i2.indexrelid
        JOIN pg_namespace n ON n.oid = c1.relnamespace
        WHERE c1.relam = (SELECT oid FROM pg_am WHERE amname = 'btree')
          AND c2.relam = c1.relam
        ORDER BY n.nspname, t.relname;

-- rows per page ----------------------
SELECT relname,
       reltuples::bigint AS rows_estimate,
       relpages::bigint AS pages
       ,case when relpages>0 then (reltuples / relpages)::numeric(10,2) end AS rows_per_page 
FROM pg_class
where relname in (select table_name FROM information_schema.columns where table_schema IN ('db','db_config','db_log','cds2db_in','cds2db_out','db2dataprocessor_out','db2dataprocessor_in','db2frontend_out','db2frontend_in'))
order by 1;

-- cach ansehen -----------------
SELECT 
    c.relkind,
    c.relname,
    count(*) AS buffers,
    count(*) * 8192 AS bytes
FROM 
    pg_buffercache b
JOIN 
    pg_class c ON b.relfilenode = pg_relation_filenode(c.oid)
JOIN 
    pg_database d ON b.reldatabase = d.oid
WHERE 
    d.datname = current_database()
GROUP BY 
    c.relkind, c.relname
ORDER BY 
    buffers DESC;
