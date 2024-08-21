
-- sources are the plain typed data tables with a table name without any pre oder postfix -> SIMPLE_TABLE_NAME
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (SELECT * from <%SCHEMA_2%>.<%SIMPLE_TABLE_NAME%>);
GRANT SELECT ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> TO <%OWNER_USER%>;
GRANT USAGE ON SCHEMA <%OWNER_SCHEMA%> TO <%OWNER_USER%>;
