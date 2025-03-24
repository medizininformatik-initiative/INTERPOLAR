-------- VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> ------------ typed -
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
  SELECT * 
  FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> q
  , (SELECT MAX(COALESCE(i.<%COLUMN_PREFIX%>_meta_lastupdated, i.last_check_datetime)) AS LAST_VERSION_DATE, i.<%COLUMN_PREFIX%>_id AS ID
      FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> i GROUP BY i.<%COLUMN_PREFIX%>_id) w
  WHERE COALESCE(q.<%COLUMN_PREFIX%>_meta_lastupdated, q.last_check_datetime) = w.LAST_VERSION_DATE AND q.<%COLUMN_PREFIX%>_id = w.ID
);

