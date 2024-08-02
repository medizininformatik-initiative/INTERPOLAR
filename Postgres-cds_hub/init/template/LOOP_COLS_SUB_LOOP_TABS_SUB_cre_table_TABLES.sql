<%IF TAGS "\bRAW\b" "<%COLUMN_NAME%> varchar,   -- <%COLUMN_DESCRIPTION%> (varchar)"%>
<%IF TAGS "^(?!.*\bRAW\b).*$" "<%COLUMN_NAME%> <%COLUMN_TYPE%>,   -- <%COLUMN_DESCRIPTION%> (<%COLUMN_TYPE%>)"%>
