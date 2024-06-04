CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS ( SELECT DISTINCT m.* FROM (SELECT * FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> UNION SELECT * FROM <%SCHEMA_3%>.<%TABLE_NAME_2%>) m WHERE m.<%SIMPLE_TABLENAME%>_id NOT IN (SELECT <%TABLE_NAME_2%>_id FROM <%SCHEMA_2%>.<%SIMPLE_TABLENAME%> UNION SELECT <%TABLE_NAME_2%>_id FROM <%SCHEMA_3%>.<%SIMPLE_TABLENAME%>));
