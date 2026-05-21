
-------- VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> ------------ <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "raw"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "typed"%>
DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
        ) THEN
            DROP VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%>; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
            SELECT q.*,
                   COALESCE(q.<%COLUMN_PREFIX%>_meta_lastupdated, <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" " q.last_check_datetime"%>) AS LAST_VERSION_DATE,
                   q.<%COLUMN_PREFIX%>_id AS ID
            FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> q
            JOIN (
                SELECT v.<%COLUMN_PREFIX%>_id AS ID,
                       v.LAST_VERSION_DATE,
                       MAX(v.last_processing_nr) AS LAST_PROCESSING_NR
                FROM (
                    SELECT i.<%COLUMN_PREFIX%>_id,
                           COALESCE(i.<%COLUMN_PREFIX%>_meta_lastupdated, <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" " i.last_check_datetime"%>) AS LAST_VERSION_DATE,
                           i.last_processing_nr
                    FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> i
                    JOIN (
                        SELECT j.<%COLUMN_PREFIX%>_id AS ID,
                               COALESCE(MAX(j.<%COLUMN_PREFIX%>_meta_lastupdated), MAX(<%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "TO_CHAR(j.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "j.last_check_datetime"%>)) AS LAST_VERSION_DATE
                        FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> j
                        GROUP BY j.<%COLUMN_PREFIX%>_id
                    ) m
                    ON i.<%COLUMN_PREFIX%>_id = m.ID
                       AND COALESCE(i.<%COLUMN_PREFIX%>_meta_lastupdated, <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "TO_CHAR(i.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" " i.last_check_datetime"%>) = m.LAST_VERSION_DATE
                ) v
                GROUP BY v.<%COLUMN_PREFIX%>_id, v.LAST_VERSION_DATE
            ) w
            ON q.<%COLUMN_PREFIX%>_id = w.ID
               AND COALESCE(q.<%COLUMN_PREFIX%>_meta_lastupdated, <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "TO_CHAR(q.last_check_datetime, 'YYYY-MM-DD HH24:MI:SS')"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" " q.last_check_datetime"%>) = w.LAST_VERSION_DATE
               AND q.last_processing_nr IS NOT DISTINCT FROM w.LAST_PROCESSING_NR
        );
----------------------------
    END IF; -- do migration
END
$innerview$;
