<%IF TAGS "\bRAW\b" "comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%COLUMN_NAME%> is '<%COLUMN_DESCRIPTION%> (varchar)';"%>
<%IF NOT TAGS "\bRAW\b" "comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%COLUMN_NAME%> is '<%COLUMN_DESCRIPTION%> (<%COLUMN_TYPE%>)';"%>
