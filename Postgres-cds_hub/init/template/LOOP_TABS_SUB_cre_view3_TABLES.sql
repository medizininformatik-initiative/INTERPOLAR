
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>
<%IF TAGS "\bTYPED\b" "WHERE COALESCE(last_check_datetime, input_datetime) IN (SELECT MAX(COALESCE(last_check_datetime, input_datetime))"%>
<%IF TAGS "\bRAW\b" "WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI')"%>
FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
);
