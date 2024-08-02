<%IF TAGS "\bRAW\b" "comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%COLUMN_NAME%> is '<%COLUMN_DESCRIPTION%> (varchar)';"%>
<%IF TAGS "^(?!.*\bRAW\b).*$" "comment on column <%OWNER_SCHEMA%>.<%TABLE_NAME%>.<%COLUMN_NAME%> is '<%COLUMN_DESCRIPTION%> (<%COLUMN_TYPE%>)';"%>
