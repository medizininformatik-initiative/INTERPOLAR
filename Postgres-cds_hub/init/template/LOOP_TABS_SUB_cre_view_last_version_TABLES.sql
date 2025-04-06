-------- VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> ------------ <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "raw"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "typed"%>
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
  SELECT * 
  FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> q
  , (SELECT MAX(COALESCE(i.<%COLUMN_PREFIX%>_meta_lastupdated, <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" " TO_CHAR(i.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')"%> <%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" " i.last_check_datetime"%>)) AS LAST_VERSION_DATE, i.<%COLUMN_PREFIX%>_id AS ID
      FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> i GROUP BY i.<%COLUMN_PREFIX%>_id) w
  WHERE COALESCE(q.<%COLUMN_PREFIX%>_meta_lastupdated, <%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "TO_CHAR(q.last_check_datetime,'YYYY-MM-DD HH24:MI:SS')"%><%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "q.last_check_datetime"%>) = w.LAST_VERSION_DATE AND q.<%COLUMN_PREFIX%>_id = w.ID
);

