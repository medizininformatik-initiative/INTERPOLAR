DROP VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%>; -- first drop the view

CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI:SS') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI:SS') FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
);
