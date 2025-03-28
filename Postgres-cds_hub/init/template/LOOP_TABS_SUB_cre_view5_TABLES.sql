-------- VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> ------------ raw -
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
  SELECT * 
  FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> q
  , (SELECT MAX(COALESCE(i.<%COLUMN_PREFIX%>_meta_lastupdated, TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS'))) AS LAST_VERSION_DATE, i.<%COLUMN_PREFIX%>_id AS ID
      FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> i GROUP BY i.<%COLUMN_PREFIX%>_id) w
  WHERE COALESCE(q.<%COLUMN_PREFIX%>_meta_lastupdated, TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')) = w.LAST_VERSION_DATE AND q.<%COLUMN_PREFIX%>_id = w.ID
);

