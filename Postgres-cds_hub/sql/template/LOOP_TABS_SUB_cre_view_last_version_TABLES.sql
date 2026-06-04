
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
            SELECT m.* FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> m, (
                SELECT MAX(q.last_processing_nr) AS LPN, q.<%COLUMN_PREFIX%>_meta_lastupdated, q.<%COLUMN_PREFIX%>_id FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> q
                , (SELECT MAX(i.<%COLUMN_PREFIX%>_meta_lastupdated) AS LAST_VERSION_DATE, i.<%COLUMN_PREFIX%>_id AS ID FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> i GROUP BY i.<%COLUMN_PREFIX%>_id) w
	        WHERE q.<%COLUMN_PREFIX%>_meta_lastupdated = w.LAST_VERSION_DATE AND q.<%COLUMN_PREFIX%>_id = w.ID
                GROUP BY q.<%COLUMN_PREFIX%>_meta_lastupdated, q.<%COLUMN_PREFIX%>_id) f
            WHERE m.last_processing_nr = f.lpn and m.<%COLUMN_PREFIX%>_meta_lastupdated = f.<%COLUMN_PREFIX%>_meta_lastupdated and m.<%COLUMN_PREFIX%>_id = f.<%COLUMN_PREFIX%>_id                
        );
----------------------------
    END IF; -- do migration
END
$innerview$;