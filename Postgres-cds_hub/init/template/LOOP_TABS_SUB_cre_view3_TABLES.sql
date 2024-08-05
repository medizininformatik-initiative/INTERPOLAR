
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> as (SELECT * from <%SCHEMA_2%>.<%TABLE_NAME_2%>
WHERE TO_CHAR(COALESCE(last_check_datetime,input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime,input_datetime)),'YYYY-MM-DD HH24:MI') FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
);
