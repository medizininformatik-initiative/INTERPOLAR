
-- Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
GRANT TRIGGER ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> TO <%OWNER_USER%>;
GRANT USAGE ON SCHEMA <%OWNER_SCHEMA%> TO <%OWNER_USER%>;
GRANT USAGE ON db.db_seq TO <%OWNER_USER%>;

<%LOOP_DEF_SUB_LOOP_TABS_SUB_cre_table_GRANTS_AND_FUNCS%>
