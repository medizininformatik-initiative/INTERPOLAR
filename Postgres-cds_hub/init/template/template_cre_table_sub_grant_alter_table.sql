ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ALTER COLUMN <%TABLE_NAME%>_id SET DEFAULT (nextval('<%OWNER_SCHEMA%>.<%SEQ_NAME%>));